import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/transacao.dart';
import '../models/conta_bancaria.dart';
import '../utils/moeda_utils.dart';
import 'adicionar_transacao_screen.dart';
import 'cadastro_conta_screen.dart';

class TransacoesScreen extends StatefulWidget {
  const TransacoesScreen({super.key});

  @override
  State<TransacoesScreen> createState() => _TransacoesScreenState();
}

class _TransacoesScreenState extends State<TransacoesScreen> {
  final DataService _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _getNomeUsuario(),
          builder: (context, snapshot) {
            final nome = snapshot.data ?? 'Controle Financeiro';
            return Text('Olá, $nome!');
          },
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String value) {
              switch (value) {
                case 'nova_conta':
                  _irParaCadastrarConta();
                  break;
                case 'gerenciar_contas':
                  _irParaGerenciarContas();
                  break;
                case 'logout':
                  _fazerLogout();
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'nova_conta',
                  child: Row(
                    children: [
                      Icon(Icons.add_card, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Nova Conta'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'gerenciar_contas',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Gerenciar Contas'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Sair'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _carregarDadosCompletos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar dados: ${snapshot.error}'),
            );
          }

          final dados = snapshot.data!;
          final contas = dados['contas'] as List<ContaBancaria>;
          final transacoes = dados['transacoes'] as List<Transacao>;
          final saldoTotal = dados['saldoTotal'] as double;
          final entradasMes = dados['entradasMes'] as double;
          final saidasMes = dados['saidasMes'] as double;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: Column(
              children: [
                // Cards de resumo
                _buildResumoCards(saldoTotal, entradasMes, saidasMes),
                
                // Lista de transações
                Expanded(
                  child: transacoes.isEmpty
                      ? _buildEmptyState()
                      : _buildTransactionsList(transacoes, contas),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarTransacao,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<Map<String, dynamic>> _carregarDadosCompletos() async {
    final contas = await _dataService.contas;
    final transacoes = await _dataService.transacoes;
    final saldoTotal = await _dataService.saldoTotal;
    final entradasMes = await _dataService.getEntradasMes();
    final saidasMes = await _dataService.getSaidasMes();

    return {
      'contas': contas,
      'transacoes': transacoes,
      'saldoTotal': saldoTotal,
      'entradasMes': entradasMes,
      'saidasMes': saidasMes,
    };
  }

  Widget _buildResumoCards(double saldoTotal, double entradasMes, double saidasMes) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Card do saldo total
          Card(
            elevation: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'Saldo Total',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    MoedaUtils.formatarMoeda(saldoTotal),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: saldoTotal >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Cards de entrada e saída
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Entradas',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          MoedaUtils.formatarMoeda(entradasMes),
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Saídas',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          MoedaUtils.formatarMoeda(saidasMes),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma transação ainda',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicione sua primeira transação tocando no botão +',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<Transacao> transacoes, List<ContaBancaria> contas) {
    // Ordenar transações por data (mais recentes primeiro)
    final transacoesOrdenadas = List<Transacao>.from(transacoes)
      ..sort((a, b) => b.data.compareTo(a.data));

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: transacoesOrdenadas.length,
      itemBuilder: (context, index) {
        final transacao = transacoesOrdenadas[index];
        final conta = contas.firstWhere(
          (c) => c.id == transacao.contaId,
          orElse: () => ContaBancaria(
            id: 0,
            usuarioId: 0,
            nomeBanco: 'Conta Removida',
            tipoConta: '',
            saldo: 0,
          ),
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: transacao.isEntrada ? Colors.green : Colors.red,
              child: Icon(
                transacao.isEntrada ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.white,
              ),
            ),
            title: Text(transacao.descricao),
            subtitle: Text('${conta.nomeCompleto} • ${_formatarData(transacao.data)}'),
            trailing: Text(
              transacao.valorFormatado,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transacao.isEntrada ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  void _adicionarTransacao() async {
    final contas = await _dataService.contas;
    
    if (contas.isEmpty) {
      // Se não há contas, mostrar dialog para criar uma
      _mostrarDialogSemConta();
      return;
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdicionarTransacaoScreen(contas: contas),
        ),
      ).then((_) {
        // Atualizar a tela quando voltar
        setState(() {});
      });
    }
  }

  void _mostrarDialogSemConta() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nenhuma Conta Cadastrada'),
          content: const Text(
            'Para adicionar transações, você precisa primeiro cadastrar uma conta bancária.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CadastroContaScreen(),
                  ),
                ).then((_) {
                  // Atualizar a tela quando voltar
                  setState(() {});
                });
              },
              child: const Text('Cadastrar Conta'),
            ),
          ],
        );
      },
    );
  }

  Future<String> _getNomeUsuario() async {
    final usuario = _dataService.usuarioAtual;
    return usuario?.nome ?? 'Usuário';
  }

  void _irParaCadastrarConta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CadastroContaScreen(),
      ),
    ).then((_) {
      // Atualizar a tela quando voltar
      setState(() {});
    });
  }

  void _fazerLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Deseja realmente sair?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _dataService.logout();
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  void _irParaGerenciarContas() {
    Navigator.pushNamed(context, '/gerenciar-contas').then((_) {
      // Atualizar a tela quando voltar
      setState(() {});
    });
  }
}
