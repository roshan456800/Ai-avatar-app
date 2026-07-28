import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  GeminiService();

  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  static const String _model = 'gemini-2.5-flash';

  Future<String> generateResponse(String prompt) async {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key not found in .env');
    }

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey',
    );

    final response = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": prompt,
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.8,
          "topP": 0.95,
          "topK": 40,
          "maxOutputTokens": 512,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini API Error (${response.statusCode}): ${response.body}',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    try {
      return data["candidates"][0]["content"]["parts"][0]["text"]
          .toString()
          .trim();
    } catch (_) {
      throw Exception('No response received from Gemini.');
    }
  }
}
