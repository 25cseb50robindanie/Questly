import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/student.dart';
import '../services/dendy_nlp_service.dart';
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

  @override
  _DendyChatPanelState createState() => _DendyChatPanelState();
}

class _DendyChatPanelState extends State<DendyChatPanel> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<DendyChatMessage> _messages = [];
  bool _isListening = false;
  dynamic _speechRecognition;

  final List<String> _quickPrompts = [
    'What is density?',
    'Why does wood float?',
    'Explain buoyancy',
    'How do steel ships float?',
    'What is titration?',
    'What are fractions?',
  ];

  @override
  void initState() {
    super.initState();
    // Initial welcome message from Dendy
    _messages.add(
      DendyChatMessage(
        text: "Hi! I'm Dendy, your science quest companion. Ask me anything about density, buoyancy, fractions, or physics experiments!",
        isUser: false,
      ),
    );
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

  void _sendMessage([String? textToSend]) {
    final query = (textToSend ?? _textController.text).trim();
    if (query.isEmpty) return;

    SoundService.playClick();
    _stopListening();

    setState(() {
      _messages.add(DendyChatMessage(text: query, isUser: true));
      _textController.clear();
    });

    _scrollToBottom();

    // Generate rule-based NLP response
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final responseText = DendyNlpService().getResponse(query);
      setState(() {
        _messages.add(DendyChatMessage(text: responseText, isUser: false));
      });
      SoundService.playStarPop();
      _scrollToBottom();

      // Automatically speak answer if read aloud is desired or user can click speak button
      final student = Locator.studentRepository.getCurrentStudent();
      final lang = student?.language ?? 'en';
      Locator.readAloudService.speak(responseText, languageCode: lang);
    });
  }

  void _toggleSpeechRecognition() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    if (!kIsWeb) return;

    try {
      if (html.SpeechRecognition.supported) {
        final student = Locator.studentRepository.getCurrentStudent();
        final lang = student?.language ?? 'en';
        final langCode = lang == 'ta' ? 'ta-IN' : (lang == 'hi' ? 'hi-IN' : 'en-US');

        final recognition = html.SpeechRecognition();
        recognition.continuous = false;
        recognition.interimResults = true;
        recognition.lang = langCode;

        recognition.onStart.listen((_) {
          if (mounted) setState(() => _isListening = true);
        });

        recognition.onResult.listen((event) {
          try {
            final results = event.results;
            if (results != null && results.length > 0) {
              final item = results[results.length - 1];
              final transcript = item[0]?.transcript;
              if (transcript != null && transcript.toString().trim().isNotEmpty) {
                if (mounted) {
                  setState(() {
                    _textController.text = transcript.toString();
                  });
                }
              }
            }
          } catch (_) {}
        });

        recognition.onEnd.listen((_) {
          if (mounted) setState(() => _isListening = false);
        });

        recognition.onError.listen((_) {
          if (mounted) setState(() => _isListening = false);
        });

        _speechRecognition = recognition;
        recognition.start();
        SoundService.playClick();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition is not supported in this browser.')),
        );
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
                const DendyMascot(size: 38, mood: DendyMood.happy),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ASK DENDY',
                        style: TextStyle(
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
                            'Offline Science Companion',
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
                final prompt = _quickPrompts[index];
                return GestureDetector(
                  onTap: () => _sendMessage(prompt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ColorSystem.plum.withOpacity(0.18)),
                    ),
                    child: Center(
                      child: Text(
                        prompt,
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
                        hintText: _isListening ? 'Listening...' : 'Ask Dendy a question...',
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
