import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pokeapi/pokecard_entity.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String baseUrl = dotenv.env['URL'] ?? '';

  Future<List<PokecardEntity>> fetchCards() async {
    try {      final response = await http.get(
        Uri.parse('$baseUrl/cards'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['cards'] as List)
            .map((card) => PokecardEntity.fromJson(card))
            .toList();
      } else {
        throw Exception('Failed to load cards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load cards: $e');
    }
  }
}
