import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:perplexity_app/SearchResponse.dart';
import 'package:url_launcher/url_launcher.dart';

import 'default_options.dart';
import 'gemini_ai_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  DefaultFirebaseOptions.loadFirebaseApp(dotenv.env);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perplexity AI Search',
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
  SearchResponse? response;

  List<String> chatHistory = [];

  Future<void> _generateText() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    chatHistory.add(_textController.text);
    response = await GeminiAiServices.generateContent(
      "Be a Helpful Assistant",
      _textController.text,
        chatHistory: chatHistory
    );
    chatHistory.add(response?.textResponse ?? "");

    setState(() {
      _generatedText = response?.textResponse ?? "";
      _isLoading = false;
    });
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
        title: const Text('Perplexity AI Search'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : ListView.builder(
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.black,
                                  ),
                                ),
                                child: Text(chatHistory[index]),
                              ),
                            );
                          },
                          itemCount: chatHistory.length,
                        ),
                ),
              ),
            ),

            Row(
              children: [
                Icon(Icons.web_outlined),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Sources",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      launchUrl(Uri.parse(response?.links![index].url ?? ""));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text(
                          response?.links![index].pageTitle ?? "",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: response?.links?.length ?? 0,
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
      ),
    );
  }
}
