import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:wolfie_sign/utils/logger.dart';

class EnvelopeService {
  static const String baseUrl = 'http://localhost:5000';

  Future<dynamic> batchUpdateEnvelopeStatus(List<String> envelopeIds) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/batch_envelope_status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'envelope_ids': envelopeIds}),
      );

      final data = jsonDecode(response.body);

      if (data is Map && data.containsKey('consent_url')) {
        final url = Uri.parse(data['consent_url']);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
        return null;
      }

      return data;
    } catch (e) {
      logger.e('Error updating envelope status: $e');
      return null;
    }
  }

  Future<dynamic> createEnvelopes({
    required String content,
    required String ccEmail,
    required String ccName,
    required String title,
    required List<Map<String, dynamic>> signers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/batch_create_envelopes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'content': content,
          'cc_email': ccEmail,
          'cc_name': ccName,
          'title': title,
          'signers': signers,
        }),
      );

      final data = jsonDecode(response.body);

      if (data is Map && data.containsKey('consent_url')) {
        final url = Uri.parse(data['consent_url']);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
        return null;
      }

      return data['envelope_ids'];
    } catch (e) {
      logger.e('Error creating envelopes: $e');
      return null;
    }
  }
}
