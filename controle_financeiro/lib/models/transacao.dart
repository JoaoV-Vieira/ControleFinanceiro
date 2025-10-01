import '../utils/moeda_utils.dart';

enum TipoTransacao { entrada, saida }

class Transacao {
  final int? id; // Pode ser null para novas transações (auto-increment do SQLite)
  final int contaId; // ID da conta bancária
  final String descricao;
  final double valor;
  final TipoTransacao tipo;
  final DateTime data;

  Transacao({
    this.id,
    required this.contaId,
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.data,
  });

  // Construtor para criar uma nova transação (sem ID)
  Transacao.nova({
    required this.contaId,
    required this.descricao,
    required this.valor,
    required this.tipo,
    DateTime? data,
  }) : id = null,
       data = data ?? DateTime.now();

  // Converte para Map (compatível com SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'conta_id': contaId,
      'descricao': descricao,
      'valor': valor,
      'tipo': tipo.name,
      'data': data.toIso8601String(),
    };
  }

  // Cria Transacao a partir de Map (do SQLite)
  factory Transacao.fromMap(Map<String, dynamic> map) {
    return Transacao(
      id: map['id'],
      contaId: map['conta_id'],
      descricao: map['descricao'],
      valor: (map['valor'] as num).toDouble(),
      tipo: TipoTransacao.values.firstWhere((e) => e.name == map['tipo']),
      data: DateTime.parse(map['data']),
    );
  }

  // Getter para exibir o valor formatado no padrão brasileiro
  String get valorFormatado {
    return MoedaUtils.formatarTransacao(valor, isEntrada);
  }

  // Getter para cor baseada no tipo
  bool get isEntrada => tipo == TipoTransacao.entrada;

  @override
  String toString() {
    return 'Transacao{id: $id, descricao: $descricao, valor: $valorFormatado}';
  }
}
