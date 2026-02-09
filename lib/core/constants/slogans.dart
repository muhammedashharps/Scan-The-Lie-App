import 'dart:math';

/// Anti-corporate slogans and messages for Scan The Lie app
class AppSlogans {
  static final Random _random = Random();

  /// Main taglines for the app
  static const List<String> mainSlogans = [
    "Expose The Lies! 🔍",
    "Don't Trust The Label, Trust The Truth! 💪",
    "Big Food Can't Hide From Us! 🚫",
    "Know What You Eat! 🍎",
    "Fight The Food Fraud! ⚔️",
    "Unmask The Ingredients! 🎭",
    "Your Right To Know! ✊",
    "Scan It, Expose It! 📱",
    "Truth Over Marketing! 📢",
    "No More Hidden Junk! 🗑️",
  ];

  /// Slogans specifically against corporations
  static const List<String> antiCorpSlogans = [
    "Corporations Lie, We Verify! 🏭",
    "Marketing ≠ Truth 📺",
    "Don't Let Big Food Fool You! 🤡",
    "They Profit, You Suffer! 💰",
    "Read Between The Labels! 📖",
    "Fake 'Natural' = Real Chemicals! ⚗️",
    "'Healthy' Is Just Marketing! 🎪",
    "Question Everything! ❓",
    "Wake Up & Scan! ☕",
    "Your Body Deserves Truth! 💚",
  ];

  /// Loading messages with attitude
  static const List<String> loadingMessages = [
    "Hunting for lies... 🔎",
    "Exposing corporate tricks... 🕵️",
    "Decoding chemical names... 🧪",
    "Unmasking the truth... 🎭",
    "Analyzing suspicious claims... 🤨",
    "Reading between the lines... 📝",
    "Checking for hidden nasties... 👀",
    "AI is on the case! 🤖",
    "Separating fact from fiction... ⚖️",
    "Almost got 'em... 💪",
  ];

  /// Scan success messages
  static const List<String> scanSuccessMessages = [
    "Gotcha! Here's the truth! 🎯",
    "Exposed! Check this out! 💥",
    "The lies have been scanned! ✅",
    "Truth unlocked! 🔓",
    "No more secrets! 🔦",
  ];

  /// Wojak-style reactions based on health score
  static const Map<String, List<String>> wojackReactions = {
    'good': [
      "Based food choice! 😎",
      "Your body thanks you! 🏆",
      "Clean eating FTW! 💪",
      "Rare W from food industry! 🌟",
    ],
    'average': [
      "Could be worse... 😐",
      "Mid tier fuel 🤷",
      "It's... acceptable 🙄",
      "Room for improvement! 📈",
    ],
    'bad': [
      "Bruh... 💀",
      "Your body is NOT a dumpster! 🗑️",
      "Chemical soup detected! ☠️",
      "Big Food moment... 😤",
      "This ain't it chief 🚫",
    ],
  };

  /// Ingredient risk warnings
  static const Map<String, String> riskWarnings = {
    'low': "Looking clean! 🌿",
    'moderate': "Hmm, watch out... 👀",
    'high': "RED FLAG! 🚩",
  };

  /// Claim verification reactions
  static const Map<String, List<String>> claimReactions = {
    'true': [
      "Rare honest label! ✅",
      "They actually told the truth! 😲",
      "Verified! 🎖️",
    ],
    'misleading': [
      "Classic marketing trick! 🎪",
      "Half-truth detected! ⚠️",
      "Technically true, actually sus... 🤔",
    ],
    'false': [
      "LIES DETECTED! 🚨",
      "Straight up cap! 🧢",
      "Report this! ❌",
    ],
  };

  /// Get random main slogan
  static String getRandomSlogan() {
    return mainSlogans[_random.nextInt(mainSlogans.length)];
  }

  /// Get random anti-corp slogan
  static String getRandomAntiCorpSlogan() {
    return antiCorpSlogans[_random.nextInt(antiCorpSlogans.length)];
  }

  /// Get random loading message
  static String getRandomLoadingMessage() {
    return loadingMessages[_random.nextInt(loadingMessages.length)];
  }

  /// Get wojak reaction based on health score
  static String getWojakReaction(int score) {
    if (score >= 70) {
      return wojackReactions['good']![
          _random.nextInt(wojackReactions['good']!.length)];
    } else if (score >= 40) {
      return wojackReactions['average']![
          _random.nextInt(wojackReactions['average']!.length)];
    } else {
      return wojackReactions['bad']![
          _random.nextInt(wojackReactions['bad']!.length)];
    }
  }

  /// Get claim reaction
  static String getClaimReaction(String verdict) {
    final reactions = claimReactions[verdict.toLowerCase()];
    if (reactions != null) {
      return reactions[_random.nextInt(reactions.length)];
    }
    return "Hmm... 🤔";
  }
}

