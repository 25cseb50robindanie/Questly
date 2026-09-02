import '../services/speech_recognition_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../services/dendy_nlp_service.dart';
import '../services/localization_service.dart';
import '../services/sound_service.dart';
import 'dendy_mascot.dart';
import 'dendy_speak_button.dart';

class DendyChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  DendyChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class DendyChatPanel extends StatefulWidget {
  final VoidCallback onClose;

  const DendyChatPanel({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  /// Global launcher to open the exact same right-side sliding chat panel from anywhere in the app
  static void open(BuildContext context) {
    SoundService.playClick();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Ask Dendy',
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: DendyChatPanel(
              onClose: () => Navigator.of(ctx).pop(),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  @override
  _DendyChatPanelState createState() => _DendyChatPanelState();
}

class _DendyChatPanelState extends State<DendyChatPanel> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  static final List<DendyChatMessage> _persistentMessages = [];
  List<DendyChatMessage> get _messages => _persistentMessages;
  bool _isListening = false;
  dynamic _speechRecognition;

  final List<String> _quickPrompts = [
    'what_is_density',
    'why_wood_float',
    'how_steel_ships_float',
    'why_ice_float',
    'what_is_titration',
  ];

  @override
  void initState() {
    super.initState();
    // Initial welcome message from Dendy if empty
    if (_persistentMessages.isEmpty) {
      _persistentMessages.add(
        DendyChatMessage(
          text: l('ask_me_anything'),
          isUser: false,
        ),
      );
    }
    _scrollToBottom();
  }

  @override
  void dispose() {
    _stopListening();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _isGenerating = false;

  void _sendMessage([String? customText]) async {
    final text = (customText ?? _textController.text).trim();
    if (text.isEmpty || _isGenerating) return;

    SoundService.playClick();

    setState(() {
      _messages.add(DendyChatMessage(text: text, isUser: true));
      if (customText == null) {
        _textController.clear();
      }
      _isGenerating = true;
      // Add empty Dendy message placeholder to stream into
      _messages.add(DendyChatMessage(text: '', isUser: false));
    });

    _scrollToBottom();

    final dendyMsgIndex = _messages.length - 1;
    final tokenBuffer = StringBuffer();

    try {
      await for (final token in Locator.aiTutorService.askDendyStream(question: text, moduleId: 'mod_density')) {
        if (!mounted) break;
        tokenBuffer.write(token);
        setState(() {
          _messages[dendyMsgIndex] = DendyChatMessage(
            text: tokenBuffer.toString(),
            isUser: false,
          );
        });
        _scrollToBottom();
      }
      SoundService.playStarPop();
    } catch (e) {
      if (mounted) {
        final fallbackAnswer = LocalizationService.translate(DendyNlpService.answer(text));
        setState(() {
          _messages[dendyMsgIndex] = DendyChatMessage(
            text: fallbackAnswer,
            isUser: false,
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _toggleSpeechRecognition() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    if (!SpeechRecognitionHelper.isSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition is not supported on this platform.')),
      );
      return;
    }

    try {
      final lang = LocalizationService.currentLanguage;
      final langCode = lang == 'ta'
          ? 'ta-IN'
          : (lang == 'hi' ? 'hi-IN' : (lang == 'or' ? 'or-IN' : 'en-US'));

      final recognition = SpeechRecognitionHelper.create();
      if (recognition != null) {
        recognition.start(
          langCode: langCode,
          continuous: false,
          interimResults: true,
          onStart: () {
            if (mounted) setState(() => _isListening = true);
          },
          onResult: (transcript) {
            if (mounted && transcript.trim().isNotEmpty) {
              setState(() {
                _textController.text = transcript.trim();
              });
            }
          },
          onError: () {
            if (mounted) setState(() => _isListening = false);
          },
          onEnd: () {
            if (mounted) setState(() => _isListening = false);
          },
        );

        _speechRecognition = recognition;
        SoundService.playClick();
      }
    } catch (e) {
      debugPrint('[SpeechRecognition Error] $e');
      if (mounted) setState(() => _isListening = false);
    }
  }

  void _stopListening() {
    try {
      if (_speechRecognition != null) {
        _speechRecognition.stop();
      }
    } catch (_) {}
    if (mounted) setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isShort = size.height < 450;

    return Container(
      width: isShort ? 340 : 380,
      height: double.infinity,
      decoration: BoxDecoration(
        color: ColorSystem.cream,
        border: const Border(
          left: BorderSide(color: ColorSystem.plum, width: 2.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(-4, 0),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: ColorSystem.plum.withOpacity(0.15), width: 1.5),
              ),
            ),
            child: Row(
              children: [
                DendyMascot(
                  size: 38,
                  mood: _isGenerating
                      ? DendyMood.thinking
                      : (_isListening ? DendyMood.thinking : DendyMood.happy),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l('ask_dendy'),
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: ColorSystem.purple,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: ColorSystem.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l('dendy_companion'),
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 9.5,
                              color: ColorSystem.plum.withOpacity(0.65),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: ColorSystem.plum, size: 20),
                  onPressed: () {
                    SoundService.playClick();
                    Locator.readAloudService.stop();
                    widget.onClose();
                  },
                ),
              ],
            ),
          ),

          // Quick Prompt Chips
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: ColorSystem.lavender.withOpacity(0.3),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final promptKey = _quickPrompts[index];
                return GestureDetector(
                  onTap: () => _sendMessage(l(promptKey)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ColorSystem.plum.withOpacity(0.18)),
                    ),
                    child: Center(
                      child: Text(
                        l(promptKey),
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: ColorSystem.purple,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Thread List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Input Bar with Mic & Send Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: ColorSystem.plum.withOpacity(0.15), width: 1.5),
              ),
            ),
            child: Row(
              children: [
                // Speech-to-Text Microphone Button
                GestureDetector(
                  onTap: _toggleSpeechRecognition,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _isListening ? ColorSystem.coral : ColorSystem.lavender.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isListening ? Colors.red : ColorSystem.plum.withOpacity(0.2),
                        width: _isListening ? 2 : 1,
                      ),
                      boxShadow: [
                        if (_isListening)
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: _isListening ? Colors.white : ColorSystem.purple,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Text Input
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: ColorSystem.cream.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ColorSystem.plum.withOpacity(0.2)),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 12,
                        color: ColorSystem.plum,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: _isListening ? l('listening') : l('type_question'),
                        hintStyle: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 11,
                          color: _isListening ? ColorSystem.coral : ColorSystem.plum.withOpacity(0.45),
                          fontWeight: FontWeight.w600,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Send Button
                GestureDetector(
                  onTap: () => _sendMessage(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: ColorSystem.purple,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(DendyChatMessage message) {
    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 32),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ColorSystem.purple,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(2),
              ),
              boxShadow: [
                BoxShadow(
                  color: ColorSystem.purple.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DendyMascot(size: 26, mood: DendyMood.explaining),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border.all(color: ColorSystem.plum.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: ColorSystem.plum.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: ColorSystem.plum,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dendy AI',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.purple.withOpacity(0.6),
                          ),
                        ),
                        DendySpeakButton(
                          textToSpeak: message.text,
                          size: 22,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
