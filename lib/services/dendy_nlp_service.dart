import 'localization_service.dart';

class DendyNlpService {
  static final DendyNlpService _instance = DendyNlpService._internal();
  factory DendyNlpService() => _instance;
  DendyNlpService._internal();

  /// Static helper for quick answering
  static String answer(String userQuery) => _instance.getResponse(userQuery);

  /// Evaluates student query using real offline rule-based knowledge matching
  String getResponse(String userQuery) {
    final query = userQuery.toLowerCase().trim();

    if (query.isEmpty) {
      return l('dendy_resp_empty');
    }

    // 1. Greetings & Identity
    if (query.contains('hello') ||
        query == 'hi' ||
        query.startsWith('hi ') ||
        query.contains(' hi ') ||
        query.contains('hey') ||
        query.contains('who are you') ||
        query.contains('who is dendy') ||
        query.contains('வணக்கம்') ||
        query.contains('नमस्ते') ||
        query.contains('ନମସ୍କାର')) {
      return l('dendy_resp_hello');
    }

    // 2. Density Definition & Formula
    if (query.contains('what is density') ||
        query.contains('density formula') ||
        query.contains('define density') ||
        query == 'density' ||
        query.contains('அடர்த்தி') ||
        query.contains('घनत्व') ||
        query.contains('ଘନତ୍ୱ')) {
      return l('dendy_resp_density');
    }

    // 3. Why does wood float?
    if (query.contains('why does wood float') ||
        query.contains('wood float') ||
        query.contains('does wood float') ||
        query.contains('மரம்') ||
        query.contains('लकड़ी') ||
        query.contains('କାଠ')) {
      return l('dendy_resp_wood');
    }

    // 4. Buoyancy
    if (query.contains('buoyancy') ||
        query.contains('buoyant force') ||
        query.contains('explain buoyancy') ||
        query.contains('மிதப்பு') ||
        query.contains('उत्प्लावकता') ||
        query.contains('ପ୍ଳବନତା')) {
      return l('dendy_resp_buoyancy');
    }

    // 5. How do steel ships float?
    if (query.contains('ship') ||
        query.contains('boat') ||
        query.contains('steel float') ||
        query.contains('heavy ship') ||
        query.contains('கப்பல்') ||
        query.contains('जहाज') ||
        query.contains('ଜାହାଜ')) {
      return l('dendy_resp_ship');
    }

    // 6. Mass vs Volume
    if (query.contains('mass') ||
        query.contains('volume') ||
        query.contains('difference between mass and volume') ||
        query.contains('நிறை') ||
        query.contains('பருமன்') ||
        query.contains('द्रव्यमान') ||
        query.contains('आयतन') ||
        query.contains('ବସ୍ତୁତ୍ୱ') ||
        query.contains('ଆୟତନ')) {
      return l('dendy_resp_mass_vol');
    }

    // 7. Icebergs & Ice Floating
    if (query.contains('ice') ||
        query.contains('iceberg') ||
        query.contains('பனிக்கட்டி') ||
        query.contains('बर्फ') ||
        query.contains('ବରଫ')) {
      return l('dendy_resp_ice');
    }

    // 8. Titration & Chemistry Lab
    if (query.contains('titration') ||
        query.contains('acid') ||
        query.contains('base') ||
        query.contains('ph') ||
        query.contains('indicator') ||
        query.contains('டைட்ரேஷன்') ||
        query.contains('அமிலம்') ||
        query.contains('अनुमापन') ||
        query.contains('अम्ल') ||
        query.contains('ଅନୁମାପନ') ||
        query.contains('ଅମ୍ଳ')) {
      return l('dendy_resp_titration');
    }

    // 9. Fractions
    if (query.contains('fraction') ||
        query.contains('numerator') ||
        query.contains('denominator') ||
        query.contains('பின்னம்') ||
        query.contains('தொகுதி') ||
        query.contains('பகுதி') ||
        query.contains('भिन्न') ||
        query.contains('अंश') ||
        query.contains('हर') ||
        query.contains('ଭଗ୍ନାଂଶ')) {
      return l('dendy_resp_fraction');
    }

    // 10. Density Column & Liquids
    if (query.contains('liquid') ||
        query.contains('oil') ||
        query.contains('honey') ||
        query.contains('layers') ||
        query.contains('column') ||
        query.contains('திரவம்') ||
        query.contains('எண்ணெய்') ||
        query.contains('தேன்') ||
        query.contains('तरल') ||
        query.contains('तेल') ||
        query.contains('शहद') ||
        query.contains('ତରଳ') ||
        query.contains('ତେଲ') ||
        query.contains('ମହୁ')) {
      return l('dendy_resp_liquid');
    }

    // 11. Help / Tips
    if (query.contains('help') ||
        query.contains('tip') ||
        query.contains('guide') ||
        query.contains('உதவி') ||
        query.contains('मदद') ||
        query.contains('ସାହାଯ୍ୟ')) {
      return l('dendy_resp_help');
    }

    // 12. Fallback for unrecognized queries
    return l('dendy_resp_help');
  }
}
