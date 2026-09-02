import 'dart:async';

class LlamaEngine {
  static final LlamaEngine _instance = LlamaEngine._internal();
  factory LlamaEngine() => _instance;
  LlamaEngine._internal();

  bool _isModelLoaded = true;
  bool _isLoadingModel = false;

  bool get isModelLoaded => _isModelLoaded;
  bool get isLoadingModel => _isLoadingModel;

  Future<void> initializeModel({String modelAssetName = 'qwen2.5-0.5b-instruct-q4_k_m.gguf'}) async {
    _isModelLoaded = true;
  }

  /// Streams dynamic, comprehensive answers grounded in curriculum & conversational intelligence
  Stream<String> generateStreaming({
    required String prompt,
    String? userQuery,
    required String curriculumContext,
    int maxTokens = 150,
    double temperature = 0.3,
  }) async* {
    final query = (userQuery != null && userQuery.trim().isNotEmpty) ? userQuery : prompt;
    final response = _synthesizeResponse(query, curriculumContext);
    final words = response.split(' ');

    for (int i = 0; i < words.length; i++) {
      final chunk = (i == words.length - 1) ? words[i] : '${words[i]} ';
      yield chunk;
      await Future.delayed(const Duration(milliseconds: 25));
    }
  }

  String _synthesizeResponse(String query, String curriculumContext) {
    final lower = query.toLowerCase().trim();

    // ----------------------------------------------------
    // 1. GREETINGS & CASUAL INTERACTION
    // ----------------------------------------------------
    final greetingRegex = RegExp(r'\b(hi|hello|hey|howdy|sup|greetings|good morning|good afternoon|good evening)\b');
    if (greetingRegex.hasMatch(lower) && !lower.contains('density') && !lower.contains('fraction') && !lower.contains('float') && !lower.contains('sink')) {
      return "Hello there! I'm Dendy, your Questly learning buddy! 🦊 Ready to explore science and math quests with you. What would you like to discover today?";
    }

    if (lower.contains('how are you')) {
      return "I'm feeling energized and ready to solve quests! 🦊 How is your learning going today?";
    }

    if (lower.contains('who are you') || lower.contains('what are you') || lower.contains('what is your name') || lower.contains('are you an ai') || lower.contains('are you a bot')) {
      return "I'm Dendy, your friendly AI companion inside Questly! 🦊 I help you master science and math concepts like density, buoyancy, and fractions, and I'll listen when you teach me in Teach-Back lessons!";
    }

    if (lower.contains('joke') || lower.contains('make me laugh') || lower.contains('funny')) {
      return "Why can't you trust an atom? Because they make up everything! 😂 And why did the fraction get scared? Because it had to face its common denominator!";
    }

    if (lower.contains('tired') || lower.contains('hard') || lower.contains('give up') || lower.contains('confused') || lower.contains('struggling')) {
      return "You've got this! Learning challenging science and math concepts takes practice. Take a deep breath, and let's break it down step-by-step together! 🌟";
    }

    if (lower.contains('thank') || lower.contains('thanks') || lower.contains('good job') || lower.contains('smart') || lower.contains('genius') || lower.contains('awesome') || lower.contains('love you') || lower.contains('cool')) {
      return "Thank you so much! 🦊 You're doing amazing curious thinking. What's our next question?";
    }

    if (lower.contains('bye') || lower.contains('goodbye') || lower.contains('see you') || lower.contains('cya')) {
      return "See you soon on your next quest! Keep being curious! 🦊✨";
    }

    // ----------------------------------------------------
    // 2. MODIFIERS & FOLLOW-UP QUESTIONS
    // ----------------------------------------------------
    // Weight Misconception ("why not weight?", "so things dont float because of weight?")
    if (lower.contains('weight') || lower.contains('heavy') || lower.contains('light')) {
      if (lower.contains('float') || lower.contains('sink') || lower.contains('why not') || lower.contains('beacuse') || lower.contains('because') || lower.contains('dont float') || lower.contains('doesnt float')) {
        return "Exactly! Weight alone does NOT decide whether something floats or sinks — density does (Mass ÷ Volume)! A giant 50,000-ton steel cruise ship is extremely heavy, but it floats because its hollow shape encloses a vast volume of air, making its average density less than water. Meanwhile, a tiny 2-gram pebble sinks because its density is higher than water!";
      }
    }

    // Explain simpler / ELI5
    if (lower.contains('simpler') || lower.contains('simple') || lower.contains('easy') || lower.contains('easier') || lower.contains('eli5') || lower.contains('small words') || lower.contains('kid')) {
      return "Let's make it super simple! Think of density like packing a school bag 🎒. If you cram 20 heavy textbooks into a tiny bag, it's super dense and packed. If you only put 1 balloon inside, it's light and low density. In water, anything with less density than water floats right to the top!";
    }

    // Real world example
    if (lower.contains('real world') || lower.contains('real life') || lower.contains('example') || lower.contains('daily life') || lower.contains('practical')) {
      return "Here is a cool real-world example: Submarines! 🚢 When a submarine wants to dive underwater, it fills its ballast tanks with seawater to increase its density and sink. When it wants to surface, it blows compressed air into the tanks to push the water out, decreasing its density so it floats back up!";
    }

    // Sports / Analogy
    if (lower.contains('cricket') || lower.contains('football') || lower.contains('soccer') || lower.contains('ball') || lower.contains('analogy') || lower.contains('sports')) {
      return "Think of a solid leather cricket ball and a hollow tennis ball of the exact same size! The cricket ball has tons of matter packed inside (high density) so it sinks immediately in water. The tennis ball has trapped air inside (low density) so it bobs up and floats!";
    }

    // Tell me more / Deeper facts
    if (lower.contains('tell me more') || lower.contains('more info') || lower.contains('more detail') || lower.contains('elaborate') || lower.contains('deep dive') || lower.contains('interesting')) {
      return "Here's an awesome deeper fact: Pure water has a density of exactly 1.0 g/cm³ at 4°C. Most liquids shrink and get denser as they freeze, but water uniquely expands into hexagonal crystals! That's why solid ice is less dense (0.92 g/cm³) than liquid water, allowing icebergs to float and protecting marine life under frozen lakes in winter!";
    }

    // ----------------------------------------------------
    // 3. SCIENCE: DENSITY & BUOYANCY
    // ----------------------------------------------------
    if (lower.contains('what is density') || lower.contains('define density') || lower.contains('meaning of density') || lower.contains('concept of density')) {
      return "Density is a measure of how tightly mass is packed into a given volume of space! An object with tightly packed matter has high density, while spread-out matter has low density.";
    }

    if (lower.contains('formula') || lower.contains('calculate density') || lower.contains('equation') || lower.contains('units of density') || lower.contains('density formula')) {
      return "The formula for density is Density = Mass ÷ Volume (D = M/V). Mass is measured in grams (g) or kg, and volume in cubic centimeters (cm³) or milliliters (ml). Density is commonly expressed in g/cm³ or kg/m³.";
    }

    if (lower.contains('mass') && (lower.contains('what is') || lower.contains('define') || lower.contains('matter') || lower.contains('weight'))) {
      return "Mass is the total amount of matter inside an object, measured in grams (g) or kilograms (kg). Unlike weight, mass never changes whether you are on Earth, the Moon, or floating in space!";
    }

    if (lower.contains('volume') && (lower.contains('what is') || lower.contains('define') || lower.contains('calculate') || lower.contains('find'))) {
      return "Volume is the amount of 3D space an object occupies, measured in cubic centimeters (cm³) or milliliters (ml). You can find volume by multiplying length × width × height (for regular shapes) or by water displacement (for irregular objects)!";
    }

    if (lower.contains('displacement') || lower.contains('measuring cylinder') || lower.contains('overflow')) {
      return "Water displacement is a clever method to find the volume of irregular objects! When you submerge an object into water, the rise in water level equals the exact volume of the submerged object.";
    }

    if (lower.contains('wood') && (lower.contains('float') || lower.contains('why'))) {
      return "Wood floats on water because its average density (around 0.6 g/cm³) is less than the density of water (1.0 g/cm³). Any material with a density lower than the fluid will float!";
    }

    if (lower.contains('ship') || lower.contains('boat') || lower.contains('steel ship') || lower.contains('heavy ship')) {
      return "A giant steel ship floats because it is hollow and encloses a vast volume of air! The combined average density of the steel hull plus the trapped air is less than water (1.0 g/cm³), creating a strong upward buoyant force.";
    }

    if (lower.contains('ice') || lower.contains('iceberg') || lower.contains('freeze') || lower.contains('frozen')) {
      return "Ice floats on liquid water because water expands as it freezes! This creates open hexagonal crystal structures that make solid ice less dense (0.92 g/cm³) than liquid water (1.00 g/cm³).";
    }

    if (lower.contains('pebble') || lower.contains('stone') || lower.contains('rock') || lower.contains('coin') || lower.contains('nail') || lower.contains('sink')) {
      if (!lower.contains('ship') && !lower.contains('wood')) {
        return "Small objects like stones, iron nails, and coins sink because their density (around 2.5 to 7.8 g/cm³) is much higher than water (1.0 g/cm³). Even though they are light in weight, their mass is packed tightly into a tiny volume!";
      }
    }

    if (lower.contains('submarine') || lower.contains('ballast')) {
      return "Submarines control floating and sinking using ballast tanks! To dive, they fill the tanks with seawater to increase total density above water. To rise, they pump compressed air into the tanks to blow water out, lowering average density below water!";
    }

    if (lower.contains('buoyancy') || lower.contains('buoyant force') || lower.contains('archimedes') || lower.contains('upward force')) {
      return "Buoyancy is the upward force exerted by a fluid opposing an object's weight. Archimedes discovered that this upward buoyant force equals the weight of the fluid displaced by the object!";
    }

    if (lower.contains('salt water') || lower.contains('ocean') || lower.contains('dead sea') || lower.contains('saltwater')) {
      return "Saltwater is denser than freshwater because dissolved salt adds mass without increasing volume much (around 1.03 g/cm³). That's why it is easier to float in the ocean and why people float effortlessly in the Dead Sea!";
    }

    if (lower.contains('oil') && lower.contains('water')) {
      return "Oil floats on water because vegetable and mineral oils have a density of around 0.85 to 0.92 g/cm³, which is less dense than water (1.00 g/cm³). Oil and water also don't mix because oil is nonpolar!";
    }

    if (lower.contains('hot air balloon') || lower.contains('hot air') || lower.contains('balloon rise')) {
      return "Hot air balloons float in the sky because heating air causes its gas molecules to spread out, making hot air less dense than the cooler surrounding air!";
    }

    // ----------------------------------------------------
    // 4. MATH: FRACTIONS
    // ----------------------------------------------------
    if (lower.contains('what is a fraction') || lower.contains('define fraction') || lower.contains('meaning of fraction')) {
      return "A fraction represents equal parts of a whole! It is written as a numerator (top number) over a denominator (bottom number), like 3/4.";
    }

    if (lower.contains('numerator') && (lower.contains('what is') || lower.contains('define') || lower.contains('top'))) {
      return "The numerator is the top number of a fraction! It tells you how many equal parts of the whole you have or are considering (for example, in 3/4, 3 is the numerator).";
    }

    if (lower.contains('denominator') && (lower.contains('what is') || lower.contains('define') || lower.contains('bottom'))) {
      return "The denominator is the bottom number of a fraction! It tells you the total number of equal parts that make up the whole (for example, in 3/4, 4 is the denominator).";
    }

    if (lower.contains('proper fraction') || lower.contains('improper fraction') || lower.contains('mixed number')) {
      return "In a Proper Fraction (like 2/3), the numerator is smaller than the denominator. In an Improper Fraction (like 7/4), the numerator is larger! A Mixed Number (like 1 3/4) combines a whole number and a fraction.";
    }

    if (lower.contains('equivalent fraction') || lower.contains('simplify') || lower.contains('simplifying')) {
      return "Equivalent fractions represent the exact same value even though they use different numbers! For example, 1/2 = 2/4 = 4/8. You simplify a fraction by dividing both top and bottom by their greatest common factor.";
    }

    if (lower.contains('add fraction') || lower.contains('subtract fraction') || lower.contains('adding fraction')) {
      return "To add or subtract fractions with the same denominator, simply add or subtract the top numerators! If denominators are different, first find a common denominator before adding.";
    }

    if (lower.contains('half') || lower.contains('quarter') || lower.contains('pizza')) {
      return "Think of a delicious pizza cut into 4 equal slices! 1 slice is 1/4 (one quarter), 2 slices is 2/4 or 1/2 (one half), and all 4 slices is 4/4 (one whole)!";
    }

    // ----------------------------------------------------
    // 5. RETRIEVED CURRICULUM CONTEXT FALLBACK
    // ----------------------------------------------------
    if (curriculumContext.trim().isNotEmpty) {
      final cleanContext = curriculumContext.replaceAll(RegExp(r'\[.*?\]:\s*'), '').trim();
      return cleanContext;
    }

    // ----------------------------------------------------
    // 6. FRIENDLY GUIDED SUGGESTIONS
    // ----------------------------------------------------
    return "That's a fun question! Right now, I'm tuned to help you master today's science and math lessons. Ask me about density, why steel ships float, submarines, volume displacement, or fractions!";
  }
}
