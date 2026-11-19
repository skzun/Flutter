import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'telas/login.dart';
import 'telas/home_produtor.dart';
import 'telas/home_vendedor.dart';
import 'telas/home_gerente.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final perfil = prefs.getString('perfil');

  Widget inicio = const TelaLogin();
  if (perfil == 'produtor') inicio = const HomeProdutor();
  if (perfil == 'vendedor') inicio = const HomeVendedor();
  if (perfil == 'gerente') inicio = const HomeGerente();

  runApp(MaterialApp(title: 'Trufas', home: inicio));
}
