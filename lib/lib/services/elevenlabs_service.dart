import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ElevenLabsService {
  ElevenLabsService();

  final String _apiKey =
      dotenv.env['ELEVENLABS_API_KEY'] ?? '';

  static const String _voiceId = "21m00Tcm4TlvDq8ikWAM";

  Future<File> textToSpeech(String text) async {
    if (_apiKey.isEmpty) {
      throw Exception("ElevenLabs API key not found.");
    }

    final uri = Uri.parse(
      "https://api.elevenlabs.io/v1/text-to-speech/$_voiceId",
    );

    final response = await http.post(
      uri,
      headers: {
        "Accept": "audio/mpeg",
        "Content-Type": "application/json",
        "xi-api-key": _apiKey,
      },
      body: '''
{
  "text":"${text.replaceAll('"', '\\"')}",
  "model_id":"eleven_multilingual_v2",
  "voice_settings":{
    "stability":0.55,
    "similarity_boost":0.80,
    "style":0.30,
    "use_speaker_boost":true
  }
}
''',
    );

    if (response.statusCode != 200) {
      throw Exception(
        "ElevenLabs Error (${response.statusCode}): ${response.body}",
      );
    }

    final tempDir = await getTemporaryDirectory();

    final file = File(
      "${tempDir.path}/speech.mp3",
    );

    await file.writeAsBytes(response.bodyBytes);

    return file;
  }
}
