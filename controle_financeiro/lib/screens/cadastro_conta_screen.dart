import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/conta_bancaria.dart';
import '../services/data_service.dart';

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

  // Lista de bancos populares (pode ser expandida)
  final List<String> _bancos = [
    'Banco do Brasil',
    'Caixa Econômica Federal',
    'Itaú',
    'Bradesco',
    'Santander',
    'Nubank',
    'Inter',
    'C6 Bank',
    'BTG Pactual',
    'Sicoob',
    'Sicredi',
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

  void _adicionarConta() {
    if (_formKey.currentState!.validate()) {
      final banco = _mostrarCampoOutroBanco 
          ? _bancoController.text.trim() 
          : _bancoSelecionado!;
      
      final conta = ContaBancaria.nova(
        userId: 'user1', // Por enquanto um ID fixo
        nome: _nomeController.text.trim(),
        banco: banco,
        saldo: double.parse(_saldoController.text.replaceAll(',', '.')),
      );

      // Adicionar usando o serviço
      _dataService.adicionarConta(conta);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta adicionada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navegar para tela de transações
      Navigator.pushReplacementNamed(context, '/transacoes');
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
                'Configure sua primeira conta bancária para começar a controlar suas finanças',
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

              // Dropdown Banco
              DropdownButtonFormField<String>(
                value: _bancoSelecionado,
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
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Saldo inicial',
                  hintText: '0,00',
                  prefixText: 'R\$ ',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite o saldo inicial';
                  }
                  
                  try {
                    double.parse(value.replaceAll(',', '.'));
                  } catch (e) {
                    return 'Digite um valor válido';
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
