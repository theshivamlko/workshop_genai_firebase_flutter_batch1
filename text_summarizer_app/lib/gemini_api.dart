import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiApi {
  GenerativeModel? _model;

  String apiKey="<API-KEY-HERE>";

  Future<String> generateContent(String prompt) async {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      if (response.text == null) {
        throw Exception('No response text generated');
      }
      return response.text!;
    } catch (e) {
      throw Exception('Failed to generate content: $e');
    }
  }


}
