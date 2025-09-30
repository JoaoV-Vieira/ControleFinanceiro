import 'package:flutter/material.dart';
import '../models/transacao.dart';
import '../models/conta_bancaria.dart';
import '../services/data_service.dart';
import '../utils/moeda_utils.dart';
import 'adicionar_transacao_screen.dart';

class TransacoesScreen extends StatefulWidget {
  const TransacoesScreen({super.key});

  @override
  State<TransacoesScreen> createState() => _TransacoesScreenState();
}

class _TransacoesScreenState extends State<TransacoesScreen> {
  final DataService _dataService = DataService();

  // Getters que usam o serviço de dados
  List<ContaBancaria> get contas => _dataService.contas;
  List<Transacao> get transacoes => _dataService.transacoes;
  double get saldoTotal => _dataService.saldoTotal;
  double get entradasMes => _dataService.getEntradasMes();
  double get saidasMes => _dataService.getSaidasMes();

  void _adicionarTransacao() async {
    if (contas.isEmpty) {
      // Se não há contas, mostrar dialog para criar uma
      _mostrarDialogSemConta();
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdicionarTransacaoScreen(contas: contas),
      ),
    );

    if (result != null && result is Transacao) {
      setState(() {
        _dataService.adicionarTransacao(result);
      });
    }
  }

  void _mostrarDialogSemConta() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nenhuma conta cadastrada'),
        content: const Text('Você precisa cadastrar pelo menos uma conta bancária antes de adicionar transações.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/contas');
            },
            child: const Text('Adicionar Conta'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle Financeiro'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance),
            onPressed: () {
              Navigator.pushNamed(context, '/contas');
            },
            tooltip: 'Gerenciar Contas',
          ),
        ],
      ),
      body: Column(
        children: [
          // Card com resumo financeiro
          Container(
            margin: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Saldo Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_balance_wallet, color: Colors.blue),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            const Text(
                              'Saldo Total',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              MoedaUtils.formatarMoeda(saldoTotal),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: saldoTotal >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Entradas e Saídas do mês
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Entradas
                        Column(
                          children: [
                            const Icon(Icons.arrow_upward, color: Colors.green),
                            const Text('Entradas'),
                            Text(
                              MoedaUtils.formatarMoeda(entradasMes),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        
                        // Saídas
                        Column(
                          children: [
                            const Icon(Icons.arrow_downward, color: Colors.red),
                            const Text('Saídas'),
                            Text(
                              MoedaUtils.formatarMoeda(saidasMes),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Lista de transações
          Expanded(
            child: transacoes.isEmpty
                ? _buildEmptyState()
                : _buildTransacoesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarTransacao,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Nenhuma transação encontrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Toque no botão + para adicionar sua primeira transação',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransacoesList() {
    // Ordenar transações por data (mais recente primeiro)
    final transacoesOrdenadas = List<Transacao>.from(transacoes)
      ..sort((a, b) => b.data.compareTo(a.data));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transacoesOrdenadas.length,
      itemBuilder: (context, index) {
        final transacao = transacoesOrdenadas[index];
        final conta = _dataService.getContaPorId(transacao.contaId) ?? 
          ContaBancaria(
            id: '',
            userId: '',
            nome: 'Conta Removida',
            banco: '',
            saldo: 0,
            dataCriacao: DateTime.now(),
          );

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: transacao.isEntrada ? Colors.green : Colors.red,
              child: Icon(
                transacao.isEntrada ? Icons.add : Icons.remove,
                color: Colors.white,
              ),
            ),
            title: Text(
              transacao.descricao,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${conta.nome} • ${transacao.categoria}'),
                Text(
                  '${transacao.data.day.toString().padLeft(2, '0')}/'
                  '${transacao.data.month.toString().padLeft(2, '0')}/'
                  '${transacao.data.year}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Text(
              transacao.valorFormatado,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: transacao.isEntrada ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }
}
