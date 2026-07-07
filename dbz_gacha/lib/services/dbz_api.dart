import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/perso.dart';

class DbzApi {
  static const String baseUrl =
      'https://dragonball-api.com/api/characters';

  Future<List<Perso>> getAllCharacters() async {
    List<Perso> allPersos = [];

    int page = 1;
    int totalPages = 1;

    do {
      final response = await http.get(
        Uri.parse('$baseUrl?page=$page&limit=10'),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur API page $page');
      }

      final data = jsonDecode(response.body);

      final List items = data['items'];

      allPersos.addAll(
        items.map((e) => Perso.fromJson(e)).toList(),
      );

      totalPages = data['meta']['totalPages'];
      page++;

    } while (page <= totalPages);

    return allPersos;
  }
}