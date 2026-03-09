// ignore_for_file: prefer_const_declarations

import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey;
  OpenAIService(this.apiKey);

  Future<Map<String, dynamic>?> extractProductAndQty(String text) async {
    final url = 'https://api.openai.com/v1/chat/completions';
    final prompt =
        'Extract the product name and quantity from this grocery shopping command: "$text". '
        'Return a JSON object with keys "product" and "qty". If no quantity is mentioned, use 1.';
    final body = {
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'system', 'content': 'You are a helpful assistant for grocery shopping.'},
        {'role': 'user', 'content': prompt},
      ],
      'max_tokens': 50,
      'temperature': 0.0,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      try {
        final jsonResult = jsonDecode(content);
        return jsonResult is Map<String, dynamic> ? jsonResult : null;
      } catch (_) {
        // fallback: try to parse product and qty from plain text
        final match = RegExp(r'product\s*[:=]\s*([\w\s]+),?\s*qty\s*[:=]\s*(\d+)').firstMatch(content);
        if (match != null) {
          return {
            'product': match.group(1)?.trim(),
            'qty': int.tryParse(match.group(2) ?? '1') ?? 1,
          };
        }
      }
    }
    return null;
  }
}
