import '../utils/moeda_utils.dart';

class ContaBancaria {
  final int? id; // Pode ser null para novas contas (auto-increment do SQLite)
  final int usuarioId; // ID do usuário proprietário
  final String nomeBanco;
  final String tipoConta;
  final double saldo;

  ContaBancaria({
    this.id,
    required this.usuarioId,
    required this.nomeBanco,
    required this.tipoConta,
    required this.saldo,
  });

  // Construtor para criar uma nova conta (sem ID)
  ContaBancaria.nova({
    required this.usuarioId,
    required this.nomeBanco,
    required this.tipoConta,
    required this.saldo,
  }) : id = null;

  // Converte para Map (compatível com SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'usuario_id': usuarioId,
      'nome_banco': nomeBanco,
      'tipo_conta': tipoConta,
      'saldo': saldo,
    };
  }

  // Cria ContaBancaria a partir de Map (do SQLite)
  factory ContaBancaria.fromMap(Map<String, dynamic> map) {
    return ContaBancaria(
      id: map['id'],
      usuarioId: map['usuario_id'],
      nomeBanco: map['nome_banco'],
      tipoConta: map['tipo_conta'],
      saldo: (map['saldo'] as num).toDouble(),
    );
  }

  // Cria uma cópia da conta com saldo atualizado
  ContaBancaria copyWith({double? novoSaldo}) {
    return ContaBancaria(
      id: id,
      usuarioId: usuarioId,
      nomeBanco: nomeBanco,
      tipoConta: tipoConta,
      saldo: novoSaldo ?? saldo,
    );
  }

  // Getter para saldo formatado no padrão brasileiro
  String get saldoFormatado => MoedaUtils.formatarMoeda(saldo);

  // Getter para nome completo
  String get nomeCompleto => '$nomeBanco - $tipoConta';

  @override
  String toString() {
    return 'ContaBancaria{id: $id, nomeBanco: $nomeBanco, tipoConta: $tipoConta, saldo: $saldoFormatado}';
  }
}
