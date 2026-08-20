class DendyNlpService {
  static final DendyNlpService _instance = DendyNlpService._internal();
  factory DendyNlpService() => _instance;
  DendyNlpService._internal();

  /// Evaluates student query using real offline rule-based knowledge matching
  String getResponse(String userQuery) {
    final query = userQuery.toLowerCase().trim();

    if (query.isEmpty) {
      return "I didn't hear a question! Ask me anything about density, buoyancy, fractions, or experiments.";
    }

    // 1. Greetings & Identity
    if (query.contains('hello') || query.contains('hi') || query.contains('hey') || query.contains('who are you') || query.contains('who is dendy')) {
      return "Hi there, Explorer! I'm Dendy, your science quest companion. Ask me anything about density, buoyancy, fractions, or your interactive labs!";
    }

    // 2. Density Definition & Formula
    if (query.contains('what is density') || query.contains('density formula') || query.contains('define density') || query == 'density') {
      return "Density is the amount of mass packed into a given volume! The formula is Density = Mass ÷ Volume (d = m/v). Tightly packed atoms make materials dense, while spread-out atoms make them light.";
    }

    // 3. Why does wood float?
    if (query.contains('why does wood float') || query.contains('wood float') || query.contains('does wood float')) {
      return "Wood floats because its density (around 0.6 g/cm³) is less than the density of water (1.0 g/cm³). Anything with a lower density than water will float!";
    }

    // 4. Buoyancy
    if (query.contains('buoyancy') || query.contains('buoyant force') || query.contains('explain buoyancy')) {
      return "Buoyancy is the upward force that fluids (like water) apply to an object. Archimedes discovered that this upward force equals the weight of the water displaced by the object!";
    }

    // 5. How do steel ships float?
    if (query.contains('ship') || query.contains('boat') || query.contains('steel float') || query.contains('heavy ship')) {
      return "Even though steel is very dense, a ship is built with large hollow air chambers inside. The combined density of steel plus all that trapped air is much lower than water, allowing giant ships to float!";
    }

    // 6. Mass vs Volume
    if (query.contains('mass') || query.contains('volume') || query.contains('difference between mass and volume')) {
      return "Mass is how much matter is inside an object (measured in grams or kg). Volume is how much 3D space it occupies (measured in cm³ or Litres). Density combines both: Mass ÷ Volume!";
    }

    // 7. Icebergs & Ice Floating
    if (query.contains('ice') || query.contains('iceberg')) {
      return "Water expands when it freezes into ice, making ice less dense than liquid water (0.92 g/cm³ vs 1.0 g/cm³). That's why ice cubes and icebergs float with about 90% underwater!";
    }

    // 8. Titration & Chemistry Lab
    if (query.contains('titration') || query.contains('acid') || query.contains('base') || query.contains('ph') || query.contains('indicator')) {
      return "Titration is a chemistry lab method to determine the unknown concentration of an acid or base by carefully neutralizing it drop-by-drop with an indicator like phenolphthalein!";
    }

    // 9. Fractions
    if (query.contains('fraction') || query.contains('numerator') || query.contains('denominator')) {
      return "A fraction represents equal parts of a whole! The top number (numerator) tells how many parts you have, and the bottom number (denominator) tells the total number of equal parts.";
    }

    // 10. Density Column & Liquids
    if (query.contains('liquid') || query.contains('oil') || query.contains('honey') || query.contains('layers') || query.contains('column')) {
      return "In a density column, liquids naturally stack by density! Honey sinks to the bottom (1.42 g/cm³), water sits in the middle (1.0 g/cm³), and oil floats on top (0.92 g/cm³).";
    }

    // 11. Help / Tips
    if (query.contains('help') || query.contains('tip') || query.contains('guide')) {
      return "You can ask me questions like: 'What is density?', 'Why does wood float?', 'Explain buoyancy', 'How do steel ships float?', or 'What is titration?'.";
    }

    // 12. Honest fallback for unrecognized queries
    return "I'm still learning! My offline AI will answer this in a future version. Try asking me about density, floating, buoyancy, titration, or fractions!";
  }
}
