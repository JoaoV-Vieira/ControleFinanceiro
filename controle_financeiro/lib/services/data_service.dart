import '../models/user.dart';
import '../models/conta_bancaria.dart';
import '../models/transacao.dart';

// Serviço simples para gerenciar dados em memória
// Na Etapa 2, será substituído por integração com banco de dados
class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // Dados em memória
  User? _usuarioAtual;
  final List<ContaBancaria> _contas = [];
  final List<Transacao> _transacoes = [];

  // Getters
  User? get usuarioAtual => _usuarioAtual;
  List<ContaBancaria> get contas => List.unmodifiable(_contas);
  List<Transacao> get transacoes => List.unmodifiable(_transacoes);

  // Métodos para usuário
  void setUsuario(User usuario) {
    _usuarioAtual = usuario;
  }

  // Métodos para contas
  void adicionarConta(ContaBancaria conta) {
    _contas.add(conta);
  }

  void atualizarSaldoConta(String contaId, double novoSaldo) {
    final index = _contas.indexWhere((c) => c.id == contaId);
    if (index != -1) {
      _contas[index] = _contas[index].copyWith(novoSaldo: novoSaldo);
    }
  }

  ContaBancaria? getContaPorId(String contaId) {
    try {
      return _contas.firstWhere((c) => c.id == contaId);
    } catch (e) {
      return null;
    }
  }

  // Métodos para transações
  void adicionarTransacao(Transacao transacao) {
    _transacoes.add(transacao);
    
    // Atualizar saldo da conta automaticamente
    final conta = getContaPorId(transacao.contaId);
    if (conta != null) {
      final novoSaldo = transacao.isEntrada 
          ? conta.saldo + transacao.valor
          : conta.saldo - transacao.valor;
      atualizarSaldoConta(transacao.contaId, novoSaldo);
    }
  }

  // Cálculos financeiros
  double get saldoTotal {
    return _contas.fold(0.0, (total, conta) => total + conta.saldo);
  }

  double getEntradasMes([DateTime? mes]) {
    final data = mes ?? DateTime.now();
    final inicioMes = DateTime(data.year, data.month, 1);
    final fimMes = DateTime(data.year, data.month + 1, 0);
    
    return _transacoes
        .where((t) => t.tipo == TipoTransacao.entrada && 
                     t.data.isAfter(inicioMes.subtract(const Duration(days: 1))) &&
                     t.data.isBefore(fimMes.add(const Duration(days: 1))))
        .fold(0.0, (total, t) => total + t.valor);
  }

  double getSaidasMes([DateTime? mes]) {
    final data = mes ?? DateTime.now();
    final inicioMes = DateTime(data.year, data.month, 1);
    final fimMes = DateTime(data.year, data.month + 1, 0);
    
    return _transacoes
        .where((t) => t.tipo == TipoTransacao.saida && 
                     t.data.isAfter(inicioMes.subtract(const Duration(days: 1))) &&
                     t.data.isBefore(fimMes.add(const Duration(days: 1))))
        .fold(0.0, (total, t) => total + t.valor);
  }

  // Método para limpar todos os dados (útil para testes)
  void limparDados() {
    _usuarioAtual = null;
    _contas.clear();
    _transacoes.clear();
  }
}
