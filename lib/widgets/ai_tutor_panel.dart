import 'dart:async';
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/student.dart';
import '../services/ai_tutor_service.dart';
import '../services/pending_reward_service.dart';
import 'custom_button.dart';
import 'dendy_mascot.dart';

class ChatMessage {
  final String text;
  final bool isStudent;

  ChatMessage({required this.text, required this.isStudent});
}

class AITutorPanel extends StatefulWidget {
  final Student student;
  final VoidCallback onClose;

  const AITutorPanel({
    Key? key,
    required this.student,
    required this.onClose,
  }) : super(key: key);

  @override
  _AITutorPanelState createState() => _AITutorPanelState();
}

class _AITutorPanelState extends State<AITutorPanel> {
  final List<ChatMessage> _messages = [];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  StreamSubscription<String>? _streamSub;

  bool _isConnected = false;
  String _dendySpeech = "Hi! Ask me any question about our current Density lesson.";
  DendyState _dendyState = DendyState.idle;
  bool _isGenerating = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    // Welcome message
    _messages.add(ChatMessage(text: _dendySpeech, isStudent: false));
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    final up = await Locator.aiTutorService.isAiAvailable();
    if (mounted) {
      setState(() {
        _isConnected = up;
      });
    }
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

  // Speak-to-talk trigger
  Future<void> _toggleVoiceAsk() async {
    if (_isGenerating) return;

    if (_isListening) {
      // Stop listening
      await Locator.speechToTextProvider.stopListening();
      setState(() {
        _isListening = false;
        _dendyState = DendyState.idle;
      });
      return;
    }

    setState(() {
      _isListening = true;
      _dendyState = DendyState.confused; // listening state (mascot thinking or confused)
      _dendySpeech = "Listening closely...";
    });

    await Locator.speechToTextProvider.startListening((text) {
      if (mounted) {
        setState(() {
          _isListening = false;
          _dendyState = DendyState.idle;
        });
        _sendQuestion(text);
      }
    });
  }

  // Handle message sending (voice or text fallback)
  void _sendQuestion(String query) {
    if (query.trim().isEmpty || _isGenerating) return;

    setState(() {
      _messages.add(ChatMessage(text: query, isStudent: true));
      _isGenerating = true;
      _dendyState = DendyState.confused; // thinking state
      _dendySpeech = "Thinking...";
    });
    _scrollToBottom();

    // Setup progressive stream accumulator
    String accumulatedText = "";
    final resIndex = _messages.length;
    setState(() {
      _messages.add(ChatMessage(text: "", isStudent: false));
    });

    final moduleId = widget.student.currentModuleId ?? "mod_density";
    final lessonId = widget.student.currentLessonId ?? "density_les1";

    _streamSub = Locator.aiTutorService
        .askDendyStream(question: query, moduleId: moduleId)
        .listen(
      (token) {
        accumulatedText += token;
        setState(() {
          _messages[resIndex] = ChatMessage(text: accumulatedText, isStudent: false);
          _dendySpeech = accumulatedText;
          _dendyState = DendyState.success; // speaking state
        });
        _scrollToBottom();
      },
      onError: (err) {
        setState(() {
          _messages[resIndex] = ChatMessage(text: "Error generating response.", isStudent: false);
          _isGenerating = false;
          _dendyState = DendyState.confused;
        });
      },
      onDone: () {
        setState(() {
          _isGenerating = false;
          _dendyState = DendyState.idle;
        });
        // Speak response out loud using TTS
        Locator.textToSpeechProvider.speak(accumulatedText, widget.student.language);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isCompact = screenHeight < 360;

    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: ColorSystem.cream,
        border: Border(
          left: BorderSide(color: ColorSystem.plum, width: 2),
        ),
      ),
      child: Column(
        children: [
          // Header (Tutor Dendy state + close)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: ColorSystem.plum, width: 1.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Status dot
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isConnected ? ColorSystem.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isConnected ? 'AI Connected' : 'AI Offline',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: ColorSystem.plum.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: ColorSystem.plum, size: 20),
                  onPressed: widget.onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Dendy speech header
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                DendyMascot(state: _dendyState, size: 54),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ColorSystem.plum, width: 1.5),
                    ),
                    child: Text(
                      _isListening ? "Listening closely..." : (_isGenerating ? "Thinking..." : "What would you like to know?"),
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: ColorSystem.plum,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Message conversation list
          Expanded(
            child: Container(
              color: Colors.white.withOpacity(0.35),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isStudent = msg.isStudent;

                  return Align(
                    alignment: isStudent ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isStudent ? ColorSystem.purple : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: isStudent ? const Radius.circular(12) : const Radius.circular(0),
                          bottomRight: isStudent ? const Radius.circular(0) : const Radius.circular(12),
                        ),
                        border: Border.all(
                          color: isStudent ? ColorSystem.purple : ColorSystem.plum,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isStudent ? Colors.white : ColorSystem.plum,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom ask row (Mic ask + typed text fallback input)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: ColorSystem.plum, width: 1.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Text field input
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: (text) {
                          _sendQuestion(text);
                          _textController.clear();
                        },
                        style: const TextStyle(fontFamily: 'Fredoka', fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Type your doubt here...',
                          hintStyle: TextStyle(color: ColorSystem.plum.withOpacity(0.4), fontSize: 11),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: ColorSystem.plum, width: 1.2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Send Button
                    GestureDetector(
                      onTap: () {
                        _sendQuestion(_textController.text);
                        _textController.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: ColorSystem.purple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Speak button Ask Dendy
                CustomButton(
                  text: _isListening ? 'STOP LISTENING' : '🎤 ASK DENDY',
                  backgroundColor: _isListening ? ColorSystem.pink : ColorSystem.gold,
                  textColor: ColorSystem.plum,
                  height: isCompact ? 32 : 36,
                  onPressed: _toggleVoiceAsk,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
