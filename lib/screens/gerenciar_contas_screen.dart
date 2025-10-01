import 'package:flutter/material.dart';
import '../models/conta_bancaria.dart';
import '../services/data_service.dart';
import '../utils/moeda_utils.dart';
import 'cadastro_conta_screen.dart';

class GerenciarContasScreen extends StatefulWidget {
  const GerenciarContasScreen({super.key});

  @override
  State<GerenciarContasScreen> createState() => _GerenciarContasScreenState();
}

class _GerenciarContasScreenState extends State<GerenciarContasScreen> {
  final DataService _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Contas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _adicionarNovaConta,
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Adicionar Nova Conta',
          ),
        ],
      ),
      body: FutureBuilder<List<ContaBancaria>>(
        future: _dataService.contas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar contas: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          final contas = snapshot.data ?? [];

          if (contas.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: contas.length,
              itemBuilder: (context, index) {
                final conta = contas[index];
                return _buildContaCard(conta);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarNovaConta,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma conta cadastrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cadastre sua primeira conta bancária\npara começar a gerenciar suas finanças',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _adicionarNovaConta,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Conta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContaCard(ContaBancaria conta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 20,
                  child: Text(
                    conta.nomeBanco.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conta.nomeBanco,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        conta.tipoConta,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, conta),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'excluir',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Excluir'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldo atual',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conta.saldoFormatado,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: conta.saldo >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, ContaBancaria conta) {
    switch (action) {
      case 'editar':
        _editarConta(conta);
        break;
      case 'excluir':
        _confirmarExclusao(conta);
        break;
    }
  }

  void _editarConta(ContaBancaria conta) {
    showDialog(
      context: context,
      builder: (context) => _EditarContaDialog(conta: conta),
    ).then((resultado) {
      if (resultado == true) {
        setState(() {});
      }
    });
  }

  void _confirmarExclusao(ContaBancaria conta) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Conta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Deseja realmente excluir esta conta?'),
              const SizedBox(height: 8),
              Text(
                '${conta.nomeBanco} - ${conta.tipoConta}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta ação não pode ser desfeita e todas as transações relacionadas também serão removidas.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => _excluirConta(conta),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _excluirConta(ContaBancaria conta) async {
    Navigator.of(context).pop(); // Fechar dialog

    try {
      final sucesso = await _dataService.excluirConta(conta.id!);
      
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta excluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao excluir conta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir conta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _adicionarNovaConta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CadastroContaScreen(),
      ),
    ).then((_) {
      setState(() {});
    });
  }
}

class _EditarContaDialog extends StatefulWidget {
  final ContaBancaria conta;

  const _EditarContaDialog({required this.conta});

  @override
  State<_EditarContaDialog> createState() => _EditarContaDialogState();
}

class _EditarContaDialogState extends State<_EditarContaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeBancoController;
  late final TextEditingController _tipoContaController;
  late final TextEditingController _saldoController;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _nomeBancoController = TextEditingController(text: widget.conta.nomeBanco);
    _tipoContaController = TextEditingController(text: widget.conta.tipoConta);
    _saldoController = TextEditingController(text: MoedaUtils.formatarMoeda(widget.conta.saldo));
  }

  @override
  void dispose() {
    _nomeBancoController.dispose();
    _tipoContaController.dispose();
    _saldoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Conta'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeBancoController,
              decoration: const InputDecoration(
                labelText: 'Nome do Banco',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome do banco';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tipoContaController,
              decoration: const InputDecoration(
                labelText: 'Tipo da Conta',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o tipo da conta';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _saldoController,
              decoration: const InputDecoration(
                labelText: 'Saldo',
                border: OutlineInputBorder(),
                prefixText: 'R\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o saldo';
                }
                final saldo = MoedaUtils.stringParaDouble(value);
                if (saldo == null) {
                  return 'Valor inválido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _salvarEdicao,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _salvarEdicao() async {
    if (_formKey.currentState!.validate()) {
      try {
        final novoSaldo = MoedaUtils.stringParaDouble(_saldoController.text) ?? 0.0;
        
        final contaAtualizada = ContaBancaria(
          id: widget.conta.id,
          usuarioId: widget.conta.usuarioId,
          nomeBanco: _nomeBancoController.text.trim(),
          tipoConta: _tipoContaController.text.trim(),
          saldo: novoSaldo,
        );
        
        final sucesso = await _dataService.atualizarConta(contaAtualizada);

        Navigator.of(context).pop(true);

        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conta atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao atualizar conta'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar conta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
