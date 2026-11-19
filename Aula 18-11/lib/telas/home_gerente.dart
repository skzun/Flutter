import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api.dart';
import '../util.dart';
import 'navegar.dart';

class HomeGerente extends StatefulWidget {
  const HomeGerente({super.key});

  @override
  State<HomeGerente> createState() => _HomeGerenteState();
}

class _HomeGerenteState extends State<HomeGerente> {
  final _comissao = TextEditingController();

  int _id = 0;
  String _nome = '';
  int _totalProduzido = 0;
  int _totalVendido = 0;
  double _lucroMes = 0;
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
      final resumo = await get('resumo.php');
      final config = await get('comissao.php');

      if (!mounted) return;
      setState(() {
        _totalProduzido = resumo['total_produzido'];
        _totalVendido = resumo['total_vendido'];
        _lucroMes = double.parse(resumo['lucro_mes'].toString());
        _comissao.text = config['comissao'].toString();
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      mensagem(context, 'Nao foi possivel conectar no servidor');
    }
  }

  Future<void> _salvarComissao() async {
    try {
      final dados = await post('comissao.php', {
        'usuario_id': _id.toString(),
        'comissao': _comissao.text,
      });

      if (!mounted) return;

      if (dados['erro'] != null) {
        mensagem(context, dados['erro']);
        return;
      }

      mensagem(context, 'Comissao atualizada');
      _carregar();
    } catch (e) {
      mensagem(context, 'Nao foi possivel conectar no servidor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerente: $_nome'),
        actions: [
          TextButton(onPressed: _carregar, child: const Text('Atualizar')),
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
                Text('Total de trufas produzidas: $_totalProduzido'),
                Text('Total de trufas vendidas: $_totalVendido'),
                Text('Lucro da empresa no mes: ${dinheiro(_lucroMes)}'),
                const Divider(height: 30),

                const Text('Comissao atual do sistema (%):'),
                TextField(
                  controller: _comissao,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Comissao'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _salvarComissao,
                  child: const Text('Salvar comissao'),
                ),
                const Text('Vale apenas para novas vendas.'),
              ],
            ),
    );
  }
}
