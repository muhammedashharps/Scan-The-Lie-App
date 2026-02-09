import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'widgets/confetti_widget.dart';
import 'screens/splash/splash_screen.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'data/models/product.dart';
import 'data/models/chat_message.dart';
import 'data/repositories/scan_history_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'services/gemini_service.dart';

import 'screens/home/home_screen.dart';
import 'screens/scan/scan_screen.dart';
import 'screens/results/results_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/questionnaire_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'data/models/user_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late ScanHistoryRepository _scanHistoryRepo;
  late SettingsRepository _settingsRepo;
  late GeminiService _geminiService;
  late Widget _initialScreen;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Splash delay
    final minDelay = Future.delayed(const Duration(milliseconds: 2500));

    await Hive.initFlutter();

    _registerAdapters();

    _scanHistoryRepo = ScanHistoryRepository();
    _settingsRepo = SettingsRepository();

    await _scanHistoryRepo.init();
    await _settingsRepo.init();

    _geminiService = GeminiService();
    final apiKey = _settingsRepo.getApiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      _geminiService.initialize(apiKey);
    }

    final prefs = _settingsRepo.getUserPreferences();
    if (prefs.username == null || prefs.username!.isEmpty) {
      _initialScreen = WelcomeScreen(
        repository: _settingsRepo,
        scanHistoryRepo: _scanHistoryRepo,
        geminiService: _geminiService,
      );
    } else if (!prefs.completedQuestionnaire) {
      _initialScreen = QuestionnaireScreen(
        repository: _settingsRepo,
        scanHistoryRepo: _scanHistoryRepo,
        geminiService: _geminiService,
        isOnboarding: true,
      );
    } else {
      _initialScreen = MainScreen(
        scanHistoryRepo: _scanHistoryRepo,
        settingsRepo: _settingsRepo,
        geminiService: _geminiService,
      );
    }

    await minDelay;
    if (mounted) setState(() => _isReady = true);
  }

  void _registerAdapters() {
    // Check to avoid errors on hot restart if logic runs again
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ProductAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(IngredientAdapter());
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ClaimVerificationAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(NutritionFactsAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ChatMessageAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(PersonalAnalysisAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(HealthConsiderationAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(UserPreferencesAdapter());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      );
    }

    return ScanTheLieApp(
      scanHistoryRepo: _scanHistoryRepo,
      settingsRepo: _settingsRepo,
      geminiService: _geminiService,
      initialScreen: _initialScreen,
    );
  }
}

class ScanTheLieApp extends StatelessWidget {
  final ScanHistoryRepository scanHistoryRepo;
  final SettingsRepository settingsRepo;
  final GeminiService geminiService;
  final Widget initialScreen;

  const ScanTheLieApp({
    super.key,
    required this.scanHistoryRepo,
    required this.settingsRepo,
    required this.geminiService,
    required this.initialScreen,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scan The Lie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: initialScreen,
    );
  }
}

class MainScreen extends StatefulWidget {
  final ScanHistoryRepository scanHistoryRepo;
  final SettingsRepository settingsRepo;
  final GeminiService geminiService;
  final bool showCelebration;

  const MainScreen({
    super.key,
    required this.scanHistoryRepo,
    required this.settingsRepo,
    required this.geminiService,
    this.showCelebration = false,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    if (widget.showCelebration) {
      _showCelebration = true;
      // Hide confetti right after animation completes (animation is 2 seconds)
      Future.delayed(const Duration(milliseconds: 2200), () {
        if (mounted) {
          setState(() {
            _showCelebration = false;
          });
        }
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onScanPressed() {
    setState(() => _selectedIndex = 1);
  }

  void _onProductScanned(Product product) async {
    final existingProduct = widget.scanHistoryRepo.findDuplicate(
      product.name,
      product.brand,
    );
    final productToDisplay = existingProduct ?? product;

    if (existingProduct == null) {
      await widget.scanHistoryRepo.saveProduct(product);
    }
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            product: productToDisplay,
            settingsRepo: widget.settingsRepo,
            onChatPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    geminiService: widget.geminiService,
                    product: productToDisplay,
                  ),
                ),
              );
            },
            onBackPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
  }

  void _onProductSelected(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          product: product,
          settingsRepo: widget.settingsRepo,
          onChatPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  geminiService: widget.geminiService,
                  product: product,
                ),
              ),
            );
          },
          onBackPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onScanPressed: _onScanPressed,
        onHistoryPressed: () => _onItemTapped(2),
        onSettingsPressed: () => _onItemTapped(3),
        scanHistoryRepo: widget.scanHistoryRepo,
        settingsRepo: widget.settingsRepo,
      ),
      ScanScreen(
        geminiService: widget.geminiService,
        settingsRepo: widget.settingsRepo,
        onProductScanned: _onProductScanned,
      ),
      HistoryScreen(
        repository: widget.scanHistoryRepo,
        onProductSelected: _onProductSelected,
      ),
      SettingsScreen(
        repository: widget.settingsRepo,
        geminiService: widget.geminiService,
      ),
    ];

    final scaffold = Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.lightGray, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
            _buildNavItem(
              1,
              Icons.document_scanner_outlined,
              Icons.document_scanner,
              'Scan',
            ),
            _buildNavItem(2, Icons.history_outlined, Icons.history, 'History'),
            _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
          ],
        ),
      ),
    );

    return ConfettiWidget(isPlaying: _showCelebration, child: scaffold);
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _selectedIndex == index;

    if (isSelected) {
      return GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(activeIcon, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.lightGray.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.gray, size: 20),
      ),
    );
  }
}
