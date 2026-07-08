import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteService {
  Future<Map<String, String>> fetchQuote() async {
    try {
      final response = await http
          .get(Uri.parse('https://zenquotes.io/api/random'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final quote = data.first;
        return {
          'quote': quote['q'] ?? 'Hemat pangkal kaya, catat pangkal paham.',
          'author': quote['a'] ?? 'Monev',
        };
      }
    } catch (_) {
      // Kalau gagal (nggak ada internet, API down, dll), pakai fallback di bawah
    }

    return {
      'quote': 'Hemat pangkal kaya, catat pangkal paham.',
      'author': 'Monev',
    };
  }
}