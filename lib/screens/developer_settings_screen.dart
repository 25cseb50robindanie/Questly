import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../widgets/custom_button.dart';
import '../widgets/questly_background.dart';
import '../services/ollama_ai_provider.dart';

class DeveloperSettingsScreen extends StatefulWidget {
  const DeveloperSettingsScreen({Key? key}) : super(key: key);

  @override
  _DeveloperSettingsScreenState createState() => _DeveloperSettingsScreenState();
}

class _DeveloperSettingsScreenState extends State<DeveloperSettingsScreen> {
  final _urlController = TextEditingController();
  final _modelController = TextEditingController();
  String _statusMessage = 'Not tested';
  Color _statusColor = ColorSystem.plum;
  List<String> _availableModels = [];

  @override
  void initState() {
    super.initState();
    _urlController.text = Locator.storageService.getString('ollama_url') ?? "http://localhost:11434";
    _modelController.text = Locator.storageService.getString('ollama_model') ?? "gemma:2b";
  }

  @override
  void dispose() {
    _urlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  // Verification process over direct IP endpoint
  Future<void> _testConnection() async {
    setState(() {
      _statusMessage = 'Testing connection...';
      _statusColor = ColorSystem.plum.withOpacity(0.65);
      _availableModels = [];
    });

    final url = _urlController.text.trim();
    final modelName = _modelController.text.trim();
    final tester = OllamaAIProvider();

    final isReachable = await tester.isAvailable(url);
    if (!isReachable) {
      setState(() {
        _statusMessage = '✗ Unable to connect to Ollama. Check IP / Port.';
        _statusColor = ColorSystem.pink;
      });
      return;
    }

    final models = await tester.getAvailableModels(url);
    final hasModel = models.contains(modelName);

    setState(() {
      _availableModels = models;
      if (hasModel) {
        _statusMessage = '✓ Connected. Model "$modelName" is available!';
        _statusColor = ColorSystem.green;
      } else {
        _statusMessage = models.isEmpty
            ? '✓ Connected to Ollama, but no models were found on the server.'
            : '✓ Connected to Ollama, but "$modelName" was not found on the server. Available: ${models.join(", ")}';
        _statusColor = ColorSystem.gold;
      }
    });
  }

  Future<void> _saveConfig() async {
    final url = _urlController.text.trim();
    final model = _modelController.text.trim();

    await Locator.storageService.setString('ollama_url', url);
    await Locator.storageService.setString('ollama_model', model);
    await Locator.storageService.setBool('ollama_configured', true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Developer AI settings saved successfully.',
          style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold),
        ),
        backgroundColor: ColorSystem.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: QuestlyBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header Row
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'DEVELOPER AI CONFIGURATION',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.plum,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Settings main panel card
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorSystem.plum, width: 2),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PROTOTYPE LOCAL INFERENCE SETTINGS',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: ColorSystem.purple,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Base URL Config input
                          const Text(
                            'Ollama Base URL (Host & Port)',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ColorSystem.plum,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _urlController,
                            decoration: InputDecoration(
                              hintText: 'e.g. http://192.168.1.100:11434',
                              hintStyle: TextStyle(color: ColorSystem.plum.withOpacity(0.4)),
                              filled: true,
                              fillColor: ColorSystem.cream.withOpacity(0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: ColorSystem.plum, width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Model Name Config input
                          const Text(
                            'Target LLM Model Name',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ColorSystem.plum,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _modelController,
                            decoration: InputDecoration(
                              hintText: 'e.g. gemma:2b',
                              hintStyle: TextStyle(color: ColorSystem.plum.withOpacity(0.4)),
                              filled: true,
                              fillColor: ColorSystem.cream.withOpacity(0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: ColorSystem.plum, width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Status text display panel
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _statusColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _statusColor.withOpacity(0.35), width: 1.2),
                            ),
                            child: Text(
                              _statusMessage,
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _statusColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Actions Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomButton(
                                text: 'TEST CONNECTION',
                                backgroundColor: ColorSystem.cream,
                                textColor: ColorSystem.plum,
                                width: 160,
                                height: 38,
                                onPressed: _testConnection,
                              ),
                              CustomButton(
                                text: 'SAVE CONFIG',
                                backgroundColor: ColorSystem.purple,
                                textColor: Colors.white,
                                width: 160,
                                height: 38,
                                onPressed: _saveConfig,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
