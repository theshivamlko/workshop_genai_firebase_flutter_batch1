import 'dart:ffi';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

import 'SearchResponse.dart';

class GeminiAiServices {
  static final String modalName = 'gemini-2.5-flash';


  static final String _systemInstruction = """
        Act as helpful assistant perform and Follow the instructions give by user strictly.

      Analyze if tool is required and Use the following tools or list of tools if needed:
      
      1. googleSearch: TO search content on Web
      
      If no tool required treat normal text response.
      If tools is triggered the combine result of user query along with result return from tools
       
        """;

  /* Free Tier available */
  static Future<SearchResponse> generateContent(
    String prompt,
    String userQuery, {
    Uint8List? fileAsBytes,
        List<String>? chatHistory
  }) async {
    try {
      final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
        model: modalName,
        systemInstruction: Content.system(_systemInstruction),
        generationConfig: GenerationConfig(
          responseModalities: [ResponseModalities.text],
        ),
        tools: [
          Tool.googleSearch()
        ],
      );
      final textPrompt = TextPart(prompt);
      final userPrompt = TextPart(userQuery);
      InlineDataPart? inlineDataPart;

      if (fileAsBytes != null) {
        inlineDataPart = InlineDataPart("text/plain", fileAsBytes);
      }



      List<TextPart> history=[];

      for (var message in chatHistory ?? []) {
        final textPart = TextPart(message);
        history.add(textPart);
      }

      final content = [
        Content.multi([
          textPrompt,
          userPrompt,
          if (inlineDataPart != null) inlineDataPart,
          ...history
        ]),
      ];



      print("generateContent content: ${content.first.parts.length}");
      final response = await _model.generateContent(content);

      final functionCalls = response.functionCalls.toList();

      print("generateContent response: ${response.text}");
      print(
        "generateContent functionCalls: ${functionCalls.map((e) => e.name).toList()}",
      );

      if (functionCalls.isNotEmpty) {

        return SearchResponse(response.text!);
      } else {

        final groundingMetadata = response.candidates.first.groundingMetadata;

        List<WebLink> links=[];

        if(groundingMetadata!=null){

         final groundingChunks= groundingMetadata.groundingChunks;
          for (var chunk in groundingChunks) {
            final title = chunk.web?.title;
            final url = chunk.web?.uri;

            if((url??"").isNotEmpty) {
              WebLink webLink= WebLink(title ?? "No Title", url!);
              links.add( webLink);
            }

          }

        }

        return SearchResponse( response.text ?? "",links: links);
      }
    } catch (e, stackTrace) {
      print("generateContent Error generating content: $e");
      print(stackTrace);
      rethrow;
    }
  }





}
