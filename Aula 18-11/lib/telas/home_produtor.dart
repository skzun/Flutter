import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api.dart';
import '../util.dart';
import 'navegar.dart';

class HomeProdutor extends StatefulWidget {
  const HomeProdutor({super.key});

  @override
  State<HomeProdutor> createState() => _HomeProdutorState();
}

class _HomeProdutorState extends State<HomeProdutor> {
  final _quantidade = TextEditingController();
  final _valor = TextEditingController();

  int _id = 0;
  String _nome = '';
  double _comissao = 0;
  List _producoes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final prefs = await SharedPreferences.getInstance();
    _id = prefs.getInt('id') ?? 0;
    _nome = prefs.getString('nome') ?? '';

    try {
      final config = await get('comissao.php');
      final lista = await get('producao.php?usuario_id=$_id');

      if (!mounted) return;
      setState(() {
        _comissao = double.parse(config['comissao'].toString());
        _producoes = lista;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      mensagem(context, 'Nao foi possivel conectar no servidor');
    }
  }

  Future<void> _registrar() async {
    final quantidade = int.tryParse(_quantidade.text);
    final valor = double.tryParse(_valor.text);

    if (quantidade == null || valor == null) {
      mensagem(context, 'Digite a quantidade e o valor');
      return;
    }

    try {
      final dados = await post('producao.php', {
        'usuario_id': _id.toString(),
        'quantidade': quantidade.toString(),
        'valor_unitario': valor.toString(),
      });

      if (!mounted) return;

      if (dados['erro'] != null) {
        mensagem(context, dados['erro']);
        return;
      }

      _quantidade.clear();
      _valor.clear();
      _carregar();
    } catch (e) {
      mensagem(context, 'Nao foi possivel conectar no servidor');
    }
  }

  double _soma(String campo) {
    double soma = 0;
    for (final producao in _producoes) {
      soma += double.parse(producao[campo].toString());
    }
    return soma;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produtor: $_nome'),
        actions: [
          TextButton(
            onPressed: () => sair(context),
            child: const Text('Sair'),
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Comissao atual do sistema: ${_comissao.toStringAsFixed(2)}%'),
                TextField(
                  controller: _quantidade,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantidade de trufas'),
                ),
                TextField(
                  controller: _valor,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Valor unitario'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _registrar,
                  child: const Text('Registrar producao'),
                ),
                const Divider(height: 30),

                Text('Total: ${dinheiro(_soma('total'))}'),
                Text('Comissao: ${dinheiro(_soma('valor_comissao'))}'),
                Text('Valor final: ${dinheiro(_soma('valor_final'))}'),
                const Divider(height: 30),

                const Text('Minhas producoes:'),
                for (final producao in _producoes)
                  Text(
                    '${producao['quantidade']} trufas x ${dinheiro(double.parse(producao['valor_unitario'].toString()))}'
                    ' = ${dinheiro(double.parse(producao['total'].toString()))}'
                    ' (com comissao: ${dinheiro(double.parse(producao['valor_final'].toString()))})',
                  ),
              ],
            ),
    );
  }
}
