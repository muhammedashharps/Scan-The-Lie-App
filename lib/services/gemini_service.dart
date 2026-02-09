import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../data/models/product.dart';
import '../data/models/user_preferences.dart';
import 'package:uuid/uuid.dart';

/// Service for Gemini AI integration - product scanning and chatbot
class GeminiService {
  GenerativeModel? _visionModel;
  GenerativeModel? _chatModel;
  String _currentModel = defaultModel;
  String? _currentApiKey;

  static const String defaultModel = 'gemini-3-flash-preview';
  static const String _chatbotModel =
      'gemini-flash-latest'; // Fixed model for chatbot

  /// Available Gemini models for selection
  static const List<String> availableModels = [
    'gemini-3-pro-preview',
    'gemini-3-flash-preview',
    'gemini-flash-latest',
    'gemini-flash-lite-latest',
  ];

  /// Get current model name
  String get currentModel => _currentModel;

  /// Initialize Gemini with API key and optional model
  void initialize(String apiKey, [String? modelName]) {
    _currentApiKey = apiKey;
    _currentModel = modelName ?? _currentModel;

    // Vision model uses user-selected model
    _visionModel = GenerativeModel(
      model: 'models/$_currentModel',
      apiKey: apiKey,
    );
    // Chatbot always uses gemini-flash-latest for consistency
    _chatModel = GenerativeModel(
      model: 'models/$_chatbotModel',
      apiKey: apiKey,
    );
  }

  /// Change the AI model (requires re-initialization)
  void setModel(String modelName) {
    if (!availableModels.contains(modelName)) return;
    if (_currentApiKey != null) {
      initialize(_currentApiKey!, modelName);
    }
    _currentModel = modelName;
  }

  /// Classify errors into user-friendly messages
  Exception _classifyError(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    // Rate limit errors
    if (errorStr.contains('429') ||
        errorStr.contains('rate limit') ||
        errorStr.contains('quota') ||
        errorStr.contains('too many requests')) {
      return Exception(
        'API rate limit reached. Please wait a moment and try again.',
      );
    }

    // Model overload errors
    if (errorStr.contains('503') ||
        errorStr.contains('overload') ||
        errorStr.contains('unavailable') ||
        errorStr.contains('capacity')) {
      return Exception(
        'AI model is currently busy. Please try again in a few seconds.',
      );
    }

    // Connectivity errors
    if (errorStr.contains('socketexception') ||
        errorStr.contains('network') ||
        errorStr.contains('connection') ||
        errorStr.contains('timeout') ||
        errorStr.contains('unreachable')) {
      return Exception(
        'No internet connection. Please check your network and try again.',
      );
    }

    // API key errors
    if (errorStr.contains('401') ||
        errorStr.contains('invalid') && errorStr.contains('key') ||
        errorStr.contains('unauthorized')) {
      return Exception('Invalid API key. Please check your key in Settings.');
    }

    // Safety/content filter errors
    if (errorStr.contains('safety') ||
        errorStr.contains('blocked') ||
        errorStr.contains('harmful')) {
      return Exception(
        'Content was blocked by safety filters. Try scanning a different product.',
      );
    }

    // Generic error with original message
    if (error is Exception) {
      final msg = error.toString().replaceFirst('Exception: ', '');
      return Exception(msg);
    }

    return Exception('Something went wrong. Please try again.');
  }

  /// Check if service is initialized
  bool get isInitialized => _visionModel != null;

  /// Analyze a product using Front and Back images and optional User Preferences
  Future<Product> analyzeProduct(
    File frontImage,
    File backImage, [
    UserPreferences? userPrefs,
  ]) async {
    if (_visionModel == null) {
      throw Exception(
        'Gemini service not initialized. Please add your API key in Settings.',
      );
    }

    final frontBytes = await frontImage.readAsBytes();
    final backBytes = await backImage.readAsBytes();

    final frontPart = DataPart('image/jpeg', frontBytes);
    final backPart = DataPart('image/jpeg', backBytes);

    String prefsContext = '';
    if (userPrefs != null) {
      prefsContext =
          '''
USER HEALTH PROFILE (Customize "personalAnalysis" based on this):
- Health Concerns: ${userPrefs.healthConcerns.join(', ')}
- Allergies: ${userPrefs.allergies.join(', ')}
- Diet: ${userPrefs.dietaryPreferences.join(', ')}
CRITICAL: If the product contains any ingredient related to the user's Allergies, set "compatibility" to "Low" and add a CRITICAL Health Consideration.
''';
    }

    final prompt = TextPart('''
Analyze these two images.
CRITICAL CHECK: Do these images depict a packaged FOOD, BEVERAGE, or SUPPLEMENT product with a label?
If NO (e.g., it's a person, animal, electronic, furniture, random object, or unclear):
Return ONLY this JSON: {"error": "not_food_product"}

If YES, proceed to analyze the product.
Image 1 is the FRONT (Marketing Claims).
Image 2 is the BACK (Ingredients & Nutrition).

$prefsContext

Extract the following information in JSON format:

{
  "name": "Product name from front",
  "brand": "Brand name",
  "claims": ["list of marketing claims on the package like 'Natural', 'Organic', 'No Added Sugar', etc."],
  "healthScore": 0-100 (General health score based on ingredients/nutrition ONLY. Do NOT skew this based on user preferences.),
  "ingredients": [
    {
      "name": "Ingredient name",
      "purpose": "What this ingredient does",
      "origin": "Natural/Synthetic/Processed",
      "controversy": "Any health concerns or controversies",
      "riskLevel": "low/moderate/high",
      "bannedCountries": ["list of countries where banned, or empty array"],
      "safeLimit": "Safe consumption limits if applicable"
    }
  ],
  "claimVerifications": [
    {
      "claim": "The marketing claim",
      "verdict": "true/misleading/false",
      "explanation": "OBJECTIVE Verification: Verify purely based on ingredients and nutrition. DO NOT consider user preferences here. (e.g., If label says 'High Protein' and it has 20g, verdict is True, even if user wants low protein)."
    }
  ],
  "nutritionFacts": {
    "fat": number or null,
    "calories": number or null,
    "carbs": number or null,
    "protein": number or null,
    "sugar": number or null,
    "sodium": number or null,
    "fiber": number or null,
    "servingSize": "size string or null"
  },
  "personalAnalysis": {
    "compatibility": "High/Medium/Low (Subjective assessment based STRICTLY on User Profile and Goals)",
    "healthConsiderations": [
      {
        "title": "Short title (e.g., 'Contains Peanuts', 'High Sugar')",
        "description": "Brief explanation flagging conflicts with USER allergies/goals",
        "severity": "info/warning/critical"
      }
    ],
    "recommendations": ["List of 2-3 actionable recommendations considering user goals"]
  }
}

Be critical of marketing claims. Look for:
- "Natural" claims with synthetic ingredients
- "Healthy" claims with high sugar/sodium
- Misleading portion sizes
- Hidden additives with E-numbers
- Controversial preservatives or colorings

Return ONLY valid JSON, no markdown formatting.
''');

    GenerateContentResponse response;
    try {
      response = await _visionModel!.generateContent([
        Content.multi([prompt, frontPart, backPart]),
      ]);
    } catch (e) {
      throw _classifyError(e);
    }

    final responseText = response.text ?? '';

    // Parse the JSON response
    try {
      // Clean up the response - remove markdown code blocks if present
      String cleanJson = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final data = json.decode(cleanJson) as Map<String, dynamic>;

      if (data.containsKey('error') && data['error'] == 'not_food_product') {
        throw Exception(
          'This does not look like a food product. Please scan a valid label.',
        );
      }

      return _parseProductFromJson(data, frontImage.path);
    } catch (e) {
      throw Exception(
        'Failed to parse product data. Please try scanning again.',
      );
    }
  }

  /// Parse JSON data into Product model
  Product _parseProductFromJson(Map<String, dynamic> data, String imagePath) {
    final ingredients =
        (data['ingredients'] as List<dynamic>?)
            ?.map(
              (i) => Ingredient(
                name: i['name'] ?? 'Unknown',
                purpose: i['purpose'] ?? '',
                origin: i['origin'] ?? 'Unknown',
                controversy: i['controversy'] ?? 'None known',
                riskLevel: i['riskLevel'] ?? 'low',
                bannedCountries: List<String>.from(i['bannedCountries'] ?? []),
                safeLimit: i['safeLimit'] ?? 'No specific limit',
              ),
            )
            .toList() ??
        [];

    final claimVerifications =
        (data['claimVerifications'] as List<dynamic>?)
            ?.map(
              (c) => ClaimVerification(
                claim: c['claim'] ?? '',
                verdict: c['verdict'] ?? 'misleading',
                explanation: c['explanation'] ?? '',
              ),
            )
            .toList() ??
        [];

    final nutritionData = data['nutritionFacts'] as Map<String, dynamic>?;
    final nutritionFacts = nutritionData != null
        ? NutritionFacts(
            fat: (nutritionData['fat'] as num?)?.toDouble(),
            calories: (nutritionData['calories'] as num?)?.toDouble(),
            carbs: (nutritionData['carbs'] as num?)?.toDouble(),
            protein: (nutritionData['protein'] as num?)?.toDouble(),
            sugar: (nutritionData['sugar'] as num?)?.toDouble(),
            sodium: (nutritionData['sodium'] as num?)?.toDouble(),
            fiber: (nutritionData['fiber'] as num?)?.toDouble(),
            servingSize: nutritionData['servingSize'] as String?,
          )
        : null;

    final personalData = data['personalAnalysis'] as Map<String, dynamic>?;
    final personalAnalysis = personalData != null
        ? PersonalAnalysis(
            compatibility: personalData['compatibility'] ?? 'Medium',
            healthConsiderations:
                (personalData['healthConsiderations'] as List<dynamic>?)
                    ?.map(
                      (h) => HealthConsideration(
                        title: h['title'] ?? '',
                        description: h['description'] ?? '',
                        severity: h['severity'] ?? 'info',
                      ),
                    )
                    .toList() ??
                [],
            recommendations: List<String>.from(
              personalData['recommendations'] ?? [],
            ),
          )
        : null;

    return Product(
      id: const Uuid().v4(),
      name: data['name'] ?? 'Unknown Product',
      brand: data['brand'] ?? 'Unknown Brand',
      claims: List<String>.from(data['claims'] ?? []),
      healthScore: data['healthScore'] ?? 50,
      scanDate: DateTime.now(),
      imageUrl: imagePath,
      imagePath: imagePath,
      ingredients: ingredients,
      claimVerifications: claimVerifications,
      nutritionFacts: nutritionFacts,
      personalAnalysis: personalAnalysis,
    );
  }

  /// Chat with AI about a product
  Future<String> chat(String message, Product? product) async {
    if (_chatModel == null) {
      throw Exception(
        'Gemini service not initialized. Please add your API key in Settings.',
      );
    }

    String context = '';
    if (product != null) {
      context =
          '''
You are analyzing the product: ${product.name} by ${product.brand}.
Health Score: ${product.healthScore}/100
Ingredients: ${product.ingredients.map((i) => i.name).join(', ')}
Claims: ${product.claims.join(', ')}

Be helpful but also critical of big food corporations. Use a friendly, slightly rebellious tone.
If the user asks about health implications, be honest about any concerns.

IMPORTANT: 
- Keep your response SHORT and CONCISE.
- DO NOT use markdown symbols like * or #. Use plain text only.
- Write like you are chatting, not writing an essay.
''';
    } else {
      context = '''
You are a food health assistant for the "Scan The Lie" app. 
You help users understand food labels and expose misleading marketing practices.
Be friendly, informative, and slightly rebellious against big food corporations.

IMPORTANT: 
- Keep your response SHORT and CONCISE.
- DO NOT use markdown symbols like * or #. Use plain text only.
- Write like you are chatting, not writing an essay.
''';
    }

    final prompt = '$context\n\nUser question: $message';

    GenerateContentResponse response;
    try {
      response = await _chatModel!.generateContent([Content.text(prompt)]);
    } catch (e) {
      return _classifyError(e).toString().replaceFirst('Exception: ', '');
    }

    return response.text ?? 'Sorry, I could not generate a response.';
  }
}
