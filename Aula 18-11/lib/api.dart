import 'dart:convert';

import 'package:http/http.dart' as http;

const String baseUrl = 'http://localhost:8000/trufas/backend/api';

Future<dynamic> post(String caminho, Map<String, String> dados) async {
  final resposta = await http.post(Uri.parse('$baseUrl/$caminho'), body: dados);
  return jsonDecode(resposta.body);
}

Future<dynamic> get(String caminho) async {
  final resposta = await http.get(Uri.parse('$baseUrl/$caminho'));
  return jsonDecode(resposta.body);
}
