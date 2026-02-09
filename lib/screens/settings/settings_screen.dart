import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_preferences.dart';
import '../../data/repositories/settings_repository.dart';
import '../../services/gemini_service.dart';
import 'questionnaire_screen.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsRepository repository;
  final GeminiService geminiService;

  const SettingsScreen({
    super.key,
    required this.repository,
    required this.geminiService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;
  bool _hasApiKey = false;
  String _selectedModel = GeminiService.defaultModel;

  @override
  void initState() {
    super.initState();
    final apiKey = widget.repository.getApiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      _apiKeyController.text = apiKey;
      _hasApiKey = true;
    }
    // Load current model from service
    _selectedModel = widget.geminiService.currentModel;
  }

  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) return;
    await widget.repository.saveApiKey(apiKey);
    widget.geminiService.initialize(apiKey, _selectedModel);
    setState(() => _hasApiKey = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'API Key saved successfully!',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _updateModel(String? newModel) {
    if (newModel != null && newModel != _selectedModel) {
      setState(() => _selectedModel = newModel);
      widget.geminiService.setModel(newModel);
      if (_hasApiKey && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Model changed to $newModel'),
            backgroundColor: AppColors.cyan,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: widget.repository.getListenable()!,
        builder: (context, box, _) {
          final prefs = widget.repository.getUserPreferences();
          final username = prefs.username ?? 'User';

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.cyan.withAlpha(25), AppColors.offWhite],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SETTINGS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Hi, $username 👋',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildApiKeyCard(),
                    const SizedBox(height: 16),
                    _buildHealthProfileCard(prefs),
                    const SizedBox(height: 16),
                    _buildAboutCard(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ... (ApiKeyCard and AboutCard remain same, but need to be careful if I replaced them in this block. I didn't include them in replacement content if I target start/end line carefully.
  // Wait, I am replacing the BUILD method. I need to make sure I don't delete helper methods.
  // The ReplacementContent above includes the build method.
  // I also need to update _buildHealthProfileCard signature.

  Widget _buildHealthProfileCard(UserPreferences prefs) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Health Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.gray),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          QuestionnaireScreen(repository: widget.repository),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Manage your preferences. These settings directly influence the AI analysis.',
            style: TextStyle(fontSize: 13, color: AppColors.gray),
          ),
          const SizedBox(height: 20),
          _buildProfileSection('Diet', prefs.dietaryPreferences),
          const SizedBox(height: 12),
          _buildProfileSection('Allergies', prefs.allergies),
          const SizedBox(height: 12),
          _buildProfileSection('Concerns', prefs.healthConcerns),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .take(
                5,
              ) // Limit to 5 to prevent overload w/ generic text for more
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.lightGray),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildApiKeyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cyan, width: 2),
                ),
                child: const Icon(Icons.key, color: AppColors.cyan, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Gemini API Key',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Required for product scanning and AI analysis',
            style: TextStyle(fontSize: 13, color: AppColors.gray),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureApiKey,
            decoration: InputDecoration(
              hintText: 'Enter your API key',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureApiKey ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _obscureApiKey = !_obscureApiKey),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveApiKey,
              child: Text(_hasApiKey ? 'UPDATE API KEY' : 'SAVE API KEY'),
            ),
          ),
          if (_hasApiKey) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.green.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.green),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'API Key configured',
                    style: TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cyan.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cyan.withAlpha(77)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to get your API key:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  '1. Go to aistudio.google.com\n2. Sign in with Google\n3. Click "Get API Key"\n4. Create and copy the key',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // AI Model Selection
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.purple.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.purple, width: 2),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: AppColors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Model',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Choose the Gemini model for scanning',
            style: TextStyle(fontSize: 13, color: AppColors.gray),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightGray, width: 2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedModel,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.black),
                style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                items: GeminiService.availableModels.map((model) {
                  return DropdownMenuItem<String>(
                    value: model,
                    child: Text(model),
                  );
                }).toList(),
                onChanged: _updateModel,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.purple.withAlpha(13),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.purple.withAlpha(77)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.purple, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pro models are slower but more accurate. Flash models are faster.',
                    style: TextStyle(fontSize: 11, color: AppColors.gray),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.purple.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.purple, width: 2),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: AppColors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'About',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('App', 'Scan The Lie'),
          _buildInfoRow('Version', '1.0.0'),
          _buildInfoRow('Powered by', 'Google Gemini AI'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.gray, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
