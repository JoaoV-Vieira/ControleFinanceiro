import 'package:flutter/material.dart';
import '../models/conta_bancaria.dart';
import '../services/data_service.dart';
import '../utils/moeda_utils.dart';
import '../utils/moeda_input_formatter.dart';

class CadastroContaScreen extends StatefulWidget {
  const CadastroContaScreen({super.key});

  @override
  State<CadastroContaScreen> createState() => _CadastroContaScreenState();
}

class _CadastroContaScreenState extends State<CadastroContaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _bancoController = TextEditingController();
  final _saldoController = TextEditingController();
  final DataService _dataService = DataService();

  final List<String> _bancos = [
    'Banco do Enriquecimento Fácil',
    'Banco do Brasil',
    'Caixa Econômica Federal',
    'Bradesco',
    'Santander',
    'Nubank',
    'Outro'
  ];

  String? _bancoSelecionado;
  bool _mostrarCampoOutroBanco = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _bancoController.dispose();
    _saldoController.dispose();
    super.dispose();
  }

  void _adicionarConta() async {
    if (_formKey.currentState!.validate()) {
      // Verificar se há usuário logado
      final usuarioLogado = _dataService.usuarioAtual;
      if (usuarioLogado?.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro: Usuário não está logado'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final nomeBanco = _mostrarCampoOutroBanco 
          ? _bancoController.text.trim() 
          : _bancoSelecionado!;
      
      final conta = ContaBancaria.nova(
        usuarioId: usuarioLogado!.id!, // ID do usuário logado
        nomeBanco: nomeBanco,
        tipoConta: _nomeController.text.trim(),
        saldo: MoedaUtils.stringParaDouble(_saldoController.text) ?? 0.0,
      );

      final sucesso = await _dataService.adicionarConta(conta);

      if (mounted) {
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conta adicionada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/transacoes'); // Ir para tela Transações
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao salvar conta'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _pularCadastro() {
    Navigator.pushReplacementNamed(context, '/transacoes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Conta Bancária'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _pularCadastro,
            child: const Text(
              'Pular',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Ícone
              const Icon(
                Icons.account_balance,
                size: 64,
                color: Colors.green,
              ),
              
              const SizedBox(height: 10),
              
              const Text(
                'Cadastre primeiro uma conta bancária para adicionar uma transação',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 30),

              // Campo Nome da Conta
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da conta',
                  hintText: 'Ex: Conta Corrente, Poupança...',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite o nome da conta';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),

              // Dropdown Bancos
              DropdownButtonFormField<String>(
                initialValue: _bancoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Banco',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                items: _bancos.map((banco) {
                  return DropdownMenuItem(
                    value: banco,
                    child: Text(banco),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _bancoSelecionado = value;
                    _mostrarCampoOutroBanco = value == 'Outro';
                    if (!_mostrarCampoOutroBanco) {
                      _bancoController.clear();
                    }
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione um banco';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),

              // Campo para outro banco (se selecionado)
              if (_mostrarCampoOutroBanco)
                Column(
                  children: [
                    TextFormField(
                      controller: _bancoController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do banco',
                        prefixIcon: Icon(Icons.edit),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_mostrarCampoOutroBanco && 
                            (value == null || value.trim().isEmpty)) {
                          return 'Por favor, digite o nome do banco';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Campo Saldo Inicial
              TextFormField(
                controller: _saldoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  MoedaBrasileiraInputFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Saldo inicial',
                  hintText: '1.234,56',
                  helperText: 'Use vírgula para decimais (ex: 1.234,56)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite o saldo inicial';
                  }
                  
                  final valor = MoedaUtils.stringParaDouble(value);
                  if (valor == null) {
                    return 'Digite um valor válido (ex: 1.234,56)';
                  }
                  
                  return null;
                },
              ),
              
              const SizedBox(height: 32),

              // Botão Adicionar
              ElevatedButton(
                onPressed: _adicionarConta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Adicionar Conta',
                  style: TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 16),

              // Botão Pular (texto)
              TextButton(
                onPressed: _pularCadastro,
                child: const Text(
                  'Pular por enquanto',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
