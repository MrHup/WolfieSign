import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wolfie_sign/secrets.dart';
import 'package:wolfie_sign/utils/logger.dart';

class OpenAIService {
  static const String baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String apiKey = OPENAI_KEY;

  Future<String?> generateDocumentContent(
      String prompt, String currentContent) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a document editing assistant. Use HTML if needed. If given a contract/legal document, refer to the signer as "\$SIGNER\$" and the requester as "\$SENDER\$".'
            },
            {
              'role': 'user',
              'content':
                  '$prompt\n$currentContent\nAnswer with the document content only.'
            }
          ],
        }),
      );

      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } catch (e) {
      logger.e('Error generating document content: $e');
      return null;
    }
  }
}
