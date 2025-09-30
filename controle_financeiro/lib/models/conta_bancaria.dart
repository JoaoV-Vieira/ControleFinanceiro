import '../utils/moeda_utils.dart';

class ContaBancaria {
  final String id;
  final String userId; // ID do usuário proprietário
  final String nome;
  final String banco;
  final double saldo;
  final DateTime dataCriacao;

  ContaBancaria({
    required this.id,
    required this.userId,
    required this.nome,
    required this.banco,
    required this.saldo,
    required this.dataCriacao,
  });

  // Construtor para criar uma nova conta
  ContaBancaria.nova({
    required this.userId,
    required this.nome,
    required this.banco,
    required this.saldo,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString(),
       dataCriacao = DateTime.now();

  // Converte para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'nome': nome,
      'banco': banco,
      'saldo': saldo,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  // Cria ContaBancaria a partir de Map
  factory ContaBancaria.fromMap(Map<String, dynamic> map) {
    return ContaBancaria(
      id: map['id'],
      userId: map['userId'],
      nome: map['nome'],
      banco: map['banco'],
      saldo: map['saldo'].toDouble(),
      dataCriacao: DateTime.parse(map['dataCriacao']),
    );
  }

  // Cria uma cópia da conta com saldo atualizado
  ContaBancaria copyWith({double? novoSaldo}) {
    return ContaBancaria(
      id: id,
      userId: userId,
      nome: nome,
      banco: banco,
      saldo: novoSaldo ?? saldo,
      dataCriacao: dataCriacao,
    );
  }

  // Getter para saldo formatado no padrão brasileiro
  String get saldoFormatado => MoedaUtils.formatarMoeda(saldo);

  @override
  String toString() {
    return 'ContaBancaria{id: $id, nome: $nome, banco: $banco, saldo: $saldoFormatado}';
  }
}
