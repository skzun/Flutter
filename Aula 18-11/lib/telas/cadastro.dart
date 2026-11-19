import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api.dart';
import 'navegar.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  String _perfil = 'produtor';

  Future<void> _salvar() async {
    if (_nome.text == '' || _email.text == '' || _senha.text == '') {
      mensagem(context, 'Preencha todos os campos');
      return;
    }

    try {
      final dados = await post('cadastro.php', {
        'nome': _nome.text.trim(),
        'email': _email.text.trim(),
        'senha': _senha.text,
        'perfil': _perfil,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nome,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            TextField(
              controller: _senha,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            Row(
              children: [
                const Text('Perfil: '),
                DropdownButton<String>(
                  value: _perfil,
                  items: const [
                    DropdownMenuItem(value: 'produtor', child: Text('Produtor')),
                    DropdownMenuItem(value: 'vendedor', child: Text('Vendedor')),
                  ],
                  onChanged: (valor) {
                    setState(() => _perfil = valor!);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvar,
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
