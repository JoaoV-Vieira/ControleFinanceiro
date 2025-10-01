import 'package:flutter/material.dart';
import '../models/transacao.dart';
import '../models/conta_bancaria.dart';
import '../services/data_service.dart';
import '../utils/moeda_utils.dart';
import '../utils/moeda_input_formatter.dart';

class AdicionarTransacaoScreen extends StatefulWidget {
  final List<ContaBancaria> contas;
  
  const AdicionarTransacaoScreen({
    super.key,
    required this.contas,
  });

  @override
  State<AdicionarTransacaoScreen> createState() => _AdicionarTransacaoScreenState();
}

class _AdicionarTransacaoScreenState extends State<AdicionarTransacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  TipoTransacao _tipoTransacao = TipoTransacao.saida;
  int? _contaSelecionada;
  String? _categoriaSelecionada;
  DateTime _dataSelecionada = DateTime.now();

  // Categorias para entradas e saídas
  final List<String> _categoriasEntrada = [
    'Salário',
    'Freelance',
    'Investimentos',
    'Vendas',
    'Presente',
    'Outros'
  ];

  final List<String> _categoriasSaida = [
    'Alimentação',
    'Transporte',
    'Moradia',
    'Saúde',
    'Educação',
    'Lazer',
    'Compras',
    'Contas',
    'Outros'
  ];

  List<String> get _categorias {
    return _tipoTransacao == TipoTransacao.entrada 
        ? _categoriasEntrada 
        : _categoriasSaida;
  }

  @override
  void initState() {
    super.initState();
    if (widget.contas.isNotEmpty) {
      _contaSelecionada = widget.contas.first.id;
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
    }
  }

  void _salvarTransacao() async {
    if (_formKey.currentState!.validate()) {
      final transacao = Transacao.nova(
        contaId: _contaSelecionada!,
        descricao: _descricaoController.text.trim(),
        valor: MoedaUtils.stringParaDouble(_valorController.text) ?? 0.0,
        tipo: _tipoTransacao,
        data: _dataSelecionada,
      );

      // Salvar no banco de dados
      final dataService = DataService();
      final sucesso = await dataService.adicionarTransacao(transacao);

      if (mounted) {
        if (sucesso) {
          Navigator.pop(context, transacao);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao salvar transação'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Transação'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seleção do tipo de transação
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo de Transação',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<TipoTransacao>(
                              title: const Text('Entrada'),
                              value: TipoTransacao.entrada,
                              groupValue: _tipoTransacao,
                              activeColor: Colors.green,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (value) {
                                setState(() {
                                  _tipoTransacao = value!;
                                  _categoriaSelecionada = null; // Reset categoria
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<TipoTransacao>(
                              title: const Text('Saída'),
                              value: TipoTransacao.saida,
                              groupValue: _tipoTransacao,
                              activeColor: Colors.red,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (value) {
                                setState(() {
                                  _tipoTransacao = value!;
                                  _categoriaSelecionada = null; // Reset categoria
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Campo Descrição
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Ex: Almoço no restaurante',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite uma descrição';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo Valor
              TextFormField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  MoedaBrasileiraInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Valor',
                  hintText: '1.234,56',
                  helperText: 'Use vírgula para decimais (ex: 1.234,56)',
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: _tipoTransacao == TipoTransacao.entrada 
                        ? Colors.green 
                        : Colors.red,
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite o valor';
                  }
                  
                  final valor = MoedaUtils.stringParaDouble(value);
                  if (valor == null) {
                    return 'Digite um valor válido (ex: 1.234,56)';
                  }
                  if (valor <= 0) {
                    return 'O valor deve ser maior que zero';
                  }
                  
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Dropdown Conta
              DropdownButtonFormField<int>(
                value: _contaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Conta',
                  prefixIcon: Icon(Icons.account_balance),
                  border: OutlineInputBorder(),
                ),
                items: widget.contas.map((conta) {
                  return DropdownMenuItem(
                    value: conta.id,
                    child: Text('${conta.nomeBanco} (${conta.tipoConta})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _contaSelecionada = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione uma conta';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Dropdown Categoria
              DropdownButtonFormField<String>(
                initialValue: _categoriaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _categorias.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSelecionada = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione uma categoria';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Seleção de Data
              InkWell(
                onTap: _selecionarData,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        'Data: ${_dataSelecionada.day.toString().padLeft(2, '0')}/'
                        '${_dataSelecionada.month.toString().padLeft(2, '0')}/'
                        '${_dataSelecionada.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Botão Salvar
              ElevatedButton(
                onPressed: _salvarTransacao,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tipoTransacao == TipoTransacao.entrada 
                      ? Colors.green 
                      : Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _tipoTransacao == TipoTransacao.entrada 
                      ? 'Adicionar Entrada'
                      : 'Adicionar Saída',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
