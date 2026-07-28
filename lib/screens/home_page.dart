import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../services/gemini_service.dart';
import '../services/elevenlabs_service.dart';
import '../widgets/anime_avatar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GeminiService _geminiService = GeminiService();
  final ElevenLabsService _elevenLabsService = ElevenLabsService();

  final AudioPlayer _audioPlayer = AudioPlayer();

  final TextEditingController _controller = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [];

  bool _isLoading = false;
  bool _isTalking = false;

  File? _audioFile;

  @override
  void initState() {
    super.initState();

    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;

      final playing = state.playing;

      if (_isTalking != playing) {
        setState(() {
          _isTalking = playing;
        });
      }

      if (state.processingState == ProcessingState.completed) {
        _audioPlayer.stop();
      }
    });
  }

  Future<void> _sendMessage() async {
    final prompt = _controller.text.trim();

    if (prompt.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({
        "role": "user",
        "text": prompt,
      });

      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final reply =
          await _geminiService.generateResponse(prompt);

      if (!mounted) return;

      setState(() {
        _messages.add({
          "role": "assistant",
          "text": reply,
        });
      });

      _scrollToBottom();

      await _generateSpeech(reply);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add({
          "role": "assistant",
          "text": "Error: $e",
        });
      });

      _scrollToBottom();
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateSpeech(String text) async {
    try {
      _audioFile =
          await _elevenLabsService.textToSpeech(text);

      if (_audioFile == null) return;

      await _playAudio(_audioFile!);
    } catch (e) {
      debugPrint("Speech generation failed: $e");
    }
  }

  Future<void> _playAudio(File file) async {
    try {
      await _audioPlayer.stop();

      await _audioPlayer.setFilePath(file.path);

      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Audio playback failed: $e");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildBubble({
    required bool isUser,
    required String text,
  }) {
    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: 12,
        ),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(
          maxWidth: 300,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.deepPurple
              : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Talking Avatar"),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Center(
              child: AnimeAvatar(
                isTalking: _isTalking,
                imagePath: "assets/images/anime_girl.png",
                size: 250,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];

                    return _buildBubble(
                      isUser: message["role"] == "user",
                      text: message["text"] ?? "",
                    );
                  },
                ),
              ),
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Thinking...",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

            const Divider(
              height: 1,
              color: Colors.white12,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Ask me anything...",
                        hintStyle: const TextStyle(
                          color: Colors.white54,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade900,
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  FloatingActionButton(
                    heroTag: "send_button",
                    mini: true,
                    backgroundColor: Colors.deepPurple,
                    onPressed:
                        _isLoading ? null : _sendMessage,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();

    _audioPlayer.dispose();

    super.dispose();
  }
}
