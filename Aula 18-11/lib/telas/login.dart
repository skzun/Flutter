import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api.dart';
import 'cadastro.dart';
import 'navegar.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _carregando = false;

  Future<void> _entrar() async {
    if (_email.text == '' || _senha.text == '') {
      mensagem(context, 'Preencha o e-mail e a senha');
      return;
    }

    setState(() => _carregando = true);

    try {
      final dados = await post('login.php', {
        'email': _email.text.trim(),
        'senha': _senha.text,
      });

      if (!mounted) return;

      if (dados['erro'] != null) {
        mensagem(context, dados['erro']);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('id', dados['id']);
      await prefs.setString('nome', dados['nome']);
      await prefs.setString('perfil', dados['perfil']);

      if (!mounted) return;
      abrirHome(context, dados['perfil']);
    } catch (e) {
      if (!mounted) return;
      mensagem(context, 'Nao foi possivel conectar no servidor');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Trufas', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 20),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            TextField(
              controller: _senha,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _carregando ? null : _entrar,
              child: const Text('Entrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaCadastro()),
                );
              },
              child: const Text('Criar conta'),
            ),
          ],
        ),
      ),
    );
  }
}
