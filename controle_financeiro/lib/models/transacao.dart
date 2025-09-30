import '../utils/moeda_utils.dart';

enum TipoTransacao { entrada, saida }

class Transacao {
  final String id;
  final String contaId; // ID da conta bancária
  final String descricao;
  final double valor;
  final TipoTransacao tipo;
  final String categoria;
  final DateTime data;
  final DateTime dataCriacao;

  Transacao({
    required this.id,
    required this.contaId,
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.categoria,
    required this.data,
    required this.dataCriacao,
  });

  // Construtor para criar uma nova transação
  Transacao.nova({
    required this.contaId,
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.categoria,
    DateTime? data,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString(),
       data = data ?? DateTime.now(),
       dataCriacao = DateTime.now();

  // Converte para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contaId': contaId,
      'descricao': descricao,
      'valor': valor,
      'tipo': tipo.name,
      'categoria': categoria,
      'data': data.toIso8601String(),
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  // Cria Transacao a partir de Map
  factory Transacao.fromMap(Map<String, dynamic> map) {
    return Transacao(
      id: map['id'],
      contaId: map['contaId'],
      descricao: map['descricao'],
      valor: map['valor'].toDouble(),
      tipo: TipoTransacao.values.firstWhere((e) => e.name == map['tipo']),
      categoria: map['categoria'],
      data: DateTime.parse(map['data']),
      dataCriacao: DateTime.parse(map['dataCriacao']),
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
    return 'Transacao{id: $id, descricao: $descricao, valor: $valorFormatado, categoria: $categoria}';
  }
}
