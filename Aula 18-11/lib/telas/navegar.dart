import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
import 'home_produtor.dart';
import 'home_vendedor.dart';
import 'home_gerente.dart';

void mensagem(BuildContext context, String texto) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
}

void abrirHome(BuildContext context, String perfil) {
  Widget tela = const HomeVendedor();
  if (perfil == 'produtor') tela = const HomeProdutor();
  if (perfil == 'gerente') tela = const HomeGerente();

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => tela),
    (rota) => false,
  );
}

Future<void> sair(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  if (!context.mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const TelaLogin()),
    (rota) => false,
  );
}
