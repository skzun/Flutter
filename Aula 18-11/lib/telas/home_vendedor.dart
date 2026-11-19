import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api.dart';
import '../util.dart';
import 'navegar.dart';

class HomeVendedor extends StatefulWidget {
  const HomeVendedor({super.key});

  @override
  State<HomeVendedor> createState() => _HomeVendedorState();
}

class _HomeVendedorState extends State<HomeVendedor> {
  final Map<int, TextEditingController> _campos = {};

  int _id = 0;
  String _nome = '';
  List _producoes = [];
  Map? _ultimaCompra;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  TextEditingController _campo(int id) {
    if (!_campos.containsKey(id)) {
      _campos[id] = TextEditingController();
    }
    return _campos[id]!;
  }

  Future<void> _carregar() async {
    final prefs = await SharedPreferences.getInstance();
    _id = prefs.getInt('id') ?? 0;
    _nome = prefs.getString('nome') ?? '';

    try {
      final lista = await get('producao.php');

      if (!mounted) return;
      setState(() {
        _producoes = lista;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      mensagem(context, 'Nao foi possivel conectar no servidor');
    }
  }

  Future<void> _comprar(Map producao) async {
    final id = int.parse(producao['id'].toString());
    final quantidade = int.tryParse(_campo(id).text);

    if (quantidade == null || quantidade <= 0) {
      mensagem(context, 'Digite a quantidade de trufas');
      return;
    }

    try {
      final dados = await post('comprar.php', {
        'usuario_id': _id.toString(),
        'producao_id': id.toString(),
        'quantidade': quantidade.toString(),
      });

      if (!mounted) return;

      if (dados['erro'] != null) {
        mensagem(context, dados['erro']);
        return;
      }

      _campo(id).clear();
      setState(() => _ultimaCompra = dados);
      _carregar();
    } catch (e) {
      mensagem(context, 'Nao foi possivel conectar no servidor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendedor: $_nome'),
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
                if (_ultimaCompra != null) ...[
                  Text(
                    'Ultima compra: ${_ultimaCompra!['quantidade']} trufas de ${_ultimaCompra!['nome_produtor']}',
                  ),
                  Text('Valor: ${dinheiro(double.parse(_ultimaCompra!['total'].toString()))}'),
                  Text('Comissao (${_ultimaCompra!['comissao']}%): ${dinheiro(double.parse(_ultimaCompra!['valor_comissao'].toString()))}'),
                  Text(
                    'Total com comissao: ${dinheiro(double.parse(_ultimaCompra!['valor_final'].toString()))}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 30),
                ],

                const Text('Producoes disponiveis:'),
                if (_producoes.isEmpty) const Text('Nenhuma producao disponivel.'),

                for (final producao in _producoes) ...[
                  Text(
                    '${producao['nome_produtor']} - estoque: ${producao['estoque']}'
                    ' - ${dinheiro(double.parse(producao['valor_unitario'].toString()))} cada',
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _campo(int.parse(producao['id'].toString())),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Quantidade'),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _comprar(producao),
                        child: const Text('Comprar'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}
