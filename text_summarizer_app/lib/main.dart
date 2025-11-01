import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'gemini_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Summarizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TextGeneratorScreen(),
    );
  }
}

class TextGeneratorScreen extends StatefulWidget {
  const TextGeneratorScreen({super.key});

  @override
  State<TextGeneratorScreen> createState() => _TextGeneratorScreenState();
}

class _TextGeneratorScreenState extends State<TextGeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  String _generatedText = 'Output here...';
  bool _isLoading = false;
  final _gemini = GeminiApi(); // Replace with your API key


  Future<void> _generateText() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });


    try {
      final response = await _gemini.generateContent(_textController.text);
      setState(() {
        _textController.text = "";
        _generatedText = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _generatedText = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }


  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summarizer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [


          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : SingleChildScrollView(
                        child: Text(
                          _generatedText,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(fontSize: 25),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your prompt here...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _generateText(),
                  ),
                ),
                IconButton(
                  onPressed: _generateText,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
