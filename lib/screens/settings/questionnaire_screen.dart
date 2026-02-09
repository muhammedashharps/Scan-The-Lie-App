import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_preferences.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/scan_history_repository.dart';
import '../../services/gemini_service.dart';
import '../../main.dart';

class QuestionnaireScreen extends StatefulWidget {
  final SettingsRepository repository;
  final ScanHistoryRepository? scanHistoryRepo;
  final GeminiService? geminiService;
  final bool isOnboarding;

  const QuestionnaireScreen({
    super.key,
    required this.repository,
    this.scanHistoryRepo,
    this.geminiService,
    this.isOnboarding = false,
  });

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  late UserPreferences _prefs;
  int _currentStep = 0; // For Wizard

  // Storage for answers (Synced with Prefs)
  final Set<String> _healthConcerns = {};
  final Set<String> _allergies = {};
  final Set<String> _dietaryPreferences = {};

  @override
  void initState() {
    super.initState();
    _prefs = widget.repository.getUserPreferences();
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    _healthConcerns.clear();
    _allergies.clear();
    _dietaryPreferences.clear();
    _healthConcerns.addAll(_prefs.healthConcerns);
    _allergies.addAll(_prefs.allergies);
    _dietaryPreferences.addAll(_prefs.dietaryPreferences);

    // Sanitize data: remove exclusive options if other options exist
    _sanitizeSet(_healthConcerns, 'healthConcerns');
    _sanitizeSet(_allergies, 'allergies');
    _sanitizeSet(_dietaryPreferences, 'dietaryPreferences');
  }

  void _sanitizeSet(Set<String> targetSet, String category) {
    final exclusiveOptions = [
      'None of the above',
      'None',
      'No diagnosed conditions',
      'No food allergies',
      'No specific dietary restrictions',
      'Not monitoring specific nutrients',
      'No digestive conditions',
      'No known sensitivities',
      'No specific goal',
    ];

    final questions = QUESTIONNAIRE_QUESTIONS.where(
      (q) => q.category == category,
    );

    for (var q in questions) {
      final textExclusive = q.options.where(
        (o) => exclusiveOptions.contains(o),
      );

      for (var exc in textExclusive) {
        if (targetSet.contains(exc)) {
          // Check if there are other options selected for this same question
          bool hasOthers = q.options.any(
            (o) => targetSet.contains(o) && o != exc,
          );
          if (hasOthers) {
            targetSet.remove(exc);
          }
        }
      }
    }
  }

  Future<void> _saveAll() async {
    _prefs.healthConcerns = _healthConcerns.toList();
    _prefs.allergies = _allergies.toList();
    _prefs.dietaryPreferences = _dietaryPreferences.toList();
    _prefs.completedQuestionnaire = true;

    await widget.repository.saveUserPreferences(_prefs);
  }

  Future<void> _finishWizard() async {
    await _saveAll();
    if (mounted) {
      if (widget.isOnboarding &&
          widget.scanHistoryRepo != null &&
          widget.geminiService != null) {
        // Navigate to Home with Celebration
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => MainScreen(
              scanHistoryRepo: widget.scanHistoryRepo!,
              settingsRepo: widget.repository,
              geminiService: widget.geminiService!,
              showCelebration: true,
            ),
          ),
          (route) => false, // Remove all previous routes (Welcome, etc)
        );
      } else {
        // Edit mode or fallback
        Navigator.pop(context);
      }
    }
  }

  void _toggleOption(
    String category,
    String option,
    bool allowMultiple,
    List<String> currentQuestionOptions,
  ) {
    setState(() {
      _performToggleLogic(
        category,
        option,
        allowMultiple,
        currentQuestionOptions,
      );
    });
  }

  // Logic without setState wrapper for use in modal's StatefulBuilder
  void _performToggleLogic(
    String category,
    String option,
    bool allowMultiple,
    List<String> currentQuestionOptions,
  ) {
    Set<String> targetSet;
    switch (category) {
      case 'healthConcerns':
        targetSet = _healthConcerns;
        break;
      case 'allergies':
        targetSet = _allergies;
        break;
      case 'dietaryPreferences':
        targetSet = _dietaryPreferences;
        break;
      default:
        return;
    }

    if (allowMultiple) {
      if (targetSet.contains(option)) {
        targetSet.remove(option);
      } else {
        // Define exclusive options that cannot be combined with others
        final exclusiveOptions = [
          'None of the above',
          'None',
          'No diagnosed conditions',
          'No food allergies',
          'No specific dietary restrictions',
          'Not monitoring specific nutrients',
          'No digestive conditions',
          'No known sensitivities',
          'No specific goal',
        ];

        if (exclusiveOptions.contains(option)) {
          // If user selects an exclusive option, clear OTHER options from SAME question only
          targetSet.removeWhere(
            (e) => currentQuestionOptions.contains(e) && e != option,
          );
          targetSet.add(option);
        } else {
          // If user selects a normal option, remove exclusive options from SAME question only
          targetSet.removeWhere(
            (e) =>
                exclusiveOptions.contains(e) &&
                currentQuestionOptions.contains(e),
          );
          targetSet.add(option);
        }
      }
    } else {
      // Single selection mode always clears previous
      targetSet.clear();
      targetSet.add(option);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If onboarding, show Wizard. If Edit, show Dashboard.
    if (widget.isOnboarding) {
      return _buildWizard();
    } else {
      return _buildDashboard();
    }
  }

  // --- WIZARD MODE ---
  Widget _buildWizard() {
    final question = QUESTIONNAIRE_QUESTIONS[_currentStep];
    final isLast = _currentStep == QUESTIONNAIRE_QUESTIONS.length - 1;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Step ${_currentStep + 1}/${QUESTIONNAIRE_QUESTIONS.length}',
          style: const TextStyle(color: AppColors.gray, fontSize: 14),
        ),
        centerTitle: true,
        leading: _currentStep > 0
            ? BackButton(
                color: AppColors.black,
                onPressed: () => setState(() => _currentStep--),
              )
            : null,
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            height: 4,
            width: double.infinity,
            color: AppColors.lightGray.withOpacity(0.3),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: (_currentStep + 1) / QUESTIONNAIRE_QUESTIONS.length,
              child: Container(color: AppColors.primary),
            ),
          ),

          Expanded(child: _buildQuestionContent(question)),

          // Bottom Bar
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: () {
                if (isLast) {
                  _finishWizard();
                } else {
                  setState(() => _currentStep++);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                isLast ? 'COMPLETE PROFILE' : 'NEXT',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(QuestionnaireQuestion question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.categoryDisplay.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: question.options.map((option) {
              bool isSelected = _isSelected(question.category, option);
              return GestureDetector(
                onTap: () => _toggleOption(
                  question.category,
                  option,
                  question.allowMultiple,
                  question.options,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.black : AppColors.white,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.black
                          : AppColors.gray.withOpacity(0.5),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        option,
                        style: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check,
                          color: AppColors.white,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool _isSelected(String category, String option) {
    if (category == 'healthConcerns') return _healthConcerns.contains(option);
    if (category == 'allergies') return _allergies.contains(option);
    if (category == 'dietaryPreferences') {
      return _dietaryPreferences.contains(option);
    }
    return false;
  }

  // --- DASHBOARD MODE (Real-time Stream) ---
  Widget _buildDashboard() {
    return StreamBuilder<UserPreferences>(
      stream: widget.repository.watchUserPreferences(),
      initialData: widget.repository.getUserPreferences(),
      builder: (context, snapshot) {
        final prefs = snapshot.data ?? UserPreferences();

        return Scaffold(
          backgroundColor: AppColors.offWhite,
          appBar: AppBar(
            title: const Text(
              'Health Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.white,
            elevation: 0,
            foregroundColor: AppColors.black,
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: QUESTIONNAIRE_QUESTIONS.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final question = QUESTIONNAIRE_QUESTIONS[index];
              return _buildQuestionCard(question, prefs);
            },
          ),
        );
      },
    );
  }

  Widget _buildQuestionCard(
    QuestionnaireQuestion question,
    UserPreferences prefs,
  ) {
    final selection = _getSelectedOptionsForQuestion(question, prefs);
    final icon = _getIconForCategory(question.category);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: div(icon, AppColors.black),
            title: Text(
              question.categoryDisplay,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () => _openQuestionEditor(question, prefs),
            ),
          ),
          Divider(height: 1, color: AppColors.lightGray.withOpacity(0.3)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: selection.isEmpty
                  ? const Text(
                      'None selected',
                      style: TextStyle(
                        color: AppColors.gray,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selection
                          .map(
                            (s) => Chip(
                              label: Text(
                                s,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: AppColors.lightGray.withOpacity(
                                0.2,
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getSelectedOptionsForQuestion(
    QuestionnaireQuestion q,
    UserPreferences prefs,
  ) {
    List<String> sourceList;
    switch (q.category) {
      case 'healthConcerns':
        sourceList = prefs.healthConcerns;
        break;
      case 'allergies':
        sourceList = prefs.allergies;
        break;
      case 'dietaryPreferences':
        sourceList = prefs.dietaryPreferences;
        break;
      default:
        return [];
    }
    return sourceList.where((opt) => q.options.contains(opt)).toList();
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'healthConcerns':
        return Icons.health_and_safety;
      case 'allergies':
        return Icons.warning_amber_rounded;
      case 'dietaryPreferences':
        return Icons.restaurant_menu;
      default:
        return Icons.help_outline;
    }
  }

  Widget div(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  void _openQuestionEditor(
    QuestionnaireQuestion q,
    UserPreferences currentPrefs,
  ) {
    // Isolated local state for editing
    final Set<String> localSelection = {};
    switch (q.category) {
      case 'healthConcerns':
        localSelection.addAll(currentPrefs.healthConcerns);
        break;
      case 'allergies':
        localSelection.addAll(currentPrefs.allergies);
        break;
      case 'dietaryPreferences':
        localSelection.addAll(currentPrefs.dietaryPreferences);
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.70,
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Edit ${q.categoryDisplay}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.question,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: q.options.map((option) {
                            bool isSelected = localSelection.contains(option);
                            return GestureDetector(
                              onTap: () {
                                // Use isolated logic on localSelection
                                _performIsolatedToggle(
                                  q.category,
                                  option,
                                  q.allowMultiple,
                                  localSelection,
                                  q.options,
                                );
                                setModalState(() {}); // Rebuild modal
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.black
                                      : AppColors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.black
                                        : AppColors.gray.withAlpha(128),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.black.withAlpha(
                                              77,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      option,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.white
                                            : AppColors.black,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.check,
                                        color: AppColors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Save changes to repo
                          switch (q.category) {
                            case 'healthConcerns':
                              currentPrefs.healthConcerns = localSelection
                                  .toList();
                              break;
                            case 'allergies':
                              currentPrefs.allergies = localSelection.toList();
                              break;
                            case 'dietaryPreferences':
                              currentPrefs.dietaryPreferences = localSelection
                                  .toList();
                              break;
                          }
                          await widget.repository.saveUserPreferences(
                            currentPrefs,
                          );
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: const Text(
                          'SAVE CHANGES',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _performIsolatedToggle(
    String category,
    String option,
    bool allowMultiple,
    Set<String> targetSet,
    List<String> currentQuestionOptions,
  ) {
    if (allowMultiple) {
      if (targetSet.contains(option)) {
        targetSet.remove(option);
      } else {
        final exclusiveOptions = [
          'None of the above',
          'None',
          'No diagnosed conditions',
          'No food allergies',
          'No specific dietary restrictions',
          'Not monitoring specific nutrients',
          'No digestive conditions',
          'No known sensitivities',
          'No specific goal',
        ];

        if (exclusiveOptions.contains(option)) {
          targetSet.removeWhere(
            (e) => currentQuestionOptions.contains(e) && e != option,
          );
          targetSet.add(option);
        } else {
          targetSet.removeWhere(
            (e) =>
                exclusiveOptions.contains(e) &&
                currentQuestionOptions.contains(e),
          );
          targetSet.add(option);
        }
      }
    } else {
      targetSet.clear();
      targetSet.add(option);
    }
  }
}

class QuestionnaireQuestion {
  final String id;
  final String category;
  final String categoryDisplay;
  final String question;
  final List<String> options;
  final bool allowMultiple;

  const QuestionnaireQuestion({
    required this.id,
    required this.category,
    required this.categoryDisplay,
    required this.question,
    required this.options,
    required this.allowMultiple,
  });
}

const List<QuestionnaireQuestion> QUESTIONNAIRE_QUESTIONS = [
  QuestionnaireQuestion(
    id: 'health-1',
    category: 'healthConcerns',
    categoryDisplay: 'Health Conditions',
    question: 'Do you have any of the following health conditions?',
    options: [
      'Diabetes',
      'Cardiovascular Disease',
      'Hypertension',
      'High Cholesterol',
      'No diagnosed conditions',
    ],
    allowMultiple: true,
  ),
  QuestionnaireQuestion(
    id: 'allergies-1',
    category: 'allergies',
    categoryDisplay: 'Allergies',
    question: 'Do you have any of these common food allergies?',
    options: [
      'Milk/Dairy',
      'Eggs',
      'Fish',
      'Shellfish',
      'Tree Nuts',
      'Peanuts',
      'Wheat',
      'Soy',
      'No food allergies',
    ],
    allowMultiple: true,
  ),
  QuestionnaireQuestion(
    id: 'diet-1',
    category: 'dietaryPreferences',
    categoryDisplay: 'Dietary Preferences',
    question: 'What are your dietary practices?',
    options: [
      'Vegetarian',
      'Vegan',
      'Gluten-Free',
      'Kosher',
      'Halal',
      'No specific dietary restrictions',
    ],
    allowMultiple: false,
  ),
  QuestionnaireQuestion(
    id: 'health-2',
    category: 'healthConcerns',
    categoryDisplay: 'Nutrient Monitoring',
    question: 'Are you monitoring your intake of any of these nutrients?',
    options: [
      'Sodium (Salt)',
      'Added Sugars',
      'Saturated Fats',
      'Protein',
      'Fiber',
      'Not monitoring specific nutrients',
    ],
    allowMultiple: true,
  ),
  QuestionnaireQuestion(
    id: 'health-3',
    category: 'healthConcerns',
    categoryDisplay: 'Digestive Health',
    question: 'Do you have any digestive health conditions?',
    options: [
      'Celiac Disease',
      'Inflammatory Bowel Disease (IBD)',
      'Irritable Bowel Syndrome (IBS)',
      'Acid Reflux (GERD)',
      'Lactose Intolerance',
      'No digestive conditions',
    ],
    allowMultiple: true,
  ),
  QuestionnaireQuestion(
    id: 'allergies-2',
    category: 'allergies',
    categoryDisplay: 'Sensitivities',
    question: 'Do you have any sensitivities to these food additives?',
    options: [
      'Artificial Sweeteners',
      'MSG (Monosodium Glutamate)',
      'Sulfites',
      'Food Colorings',
      'Preservatives',
      'No known sensitivities',
    ],
    allowMultiple: true,
  ),
  QuestionnaireQuestion(
    id: 'diet-2',
    category: 'dietaryPreferences',
    categoryDisplay: 'Goals',
    question: 'What is your primary goal for food choices?',
    options: [
      'Weight Management',
      'Athletic Performance',
      'Heart Health',
      'Blood Sugar Control',
      'General Wellness',
      'No specific goal',
    ],
    allowMultiple: false,
  ),
];
