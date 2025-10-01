import '../models/user.dart';
import '../models/conta_bancaria.dart';
import '../models/transacao.dart';
import 'database_helper.dart';

// Serviço para gerenciar dados usando SQLite
class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  User? _usuarioAtual;

  // Getters
  User? get usuarioAtual => _usuarioAtual;

  // ========== MÉTODOS DE USUÁRIO ==========
  
  Future<bool> cadastrarUsuario(User usuario) async {
    try {
      await _dbHelper.inserirUsuario(usuario);
      return true;
    } catch (e) {
      return false; // Email já existe ou outro erro
    }
  }

  Future<bool> loginUsuario(String email, String senha) async {
    final usuario = await _dbHelper.buscarUsuarioPorEmail(email);
    if (usuario != null && usuario.senha == senha) {
      _usuarioAtual = usuario;
      return true;
    }
    return false;
  }

  void setUsuario(User usuario) {
    _usuarioAtual = usuario;
  }

  void logout() {
    _usuarioAtual = null;
  }

  // ========== MÉTODOS DE CONTA BANCÁRIA ==========
  
  Future<bool> adicionarConta(ContaBancaria conta) async {
    try {
      await _dbHelper.inserirContaBancaria(conta);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<ContaBancaria>> get contas async {
    return await _dbHelper.listarContasBancarias();
  }

  Future<void> atualizarSaldoConta(int contaId, double novoSaldo) async {
    await _dbHelper.atualizarSaldoConta(contaId, novoSaldo);
  }

  Future<ContaBancaria?> getContaPorId(int contaId) async {
    return await _dbHelper.buscarContaPorId(contaId);
  }

  // ========== MÉTODOS DE TRANSAÇÃO ==========
  
  Future<bool> adicionarTransacao(Transacao transacao) async {
    try {
      await _dbHelper.inserirTransacao(transacao);
      
      // Atualizar saldo da conta automaticamente
      final conta = await getContaPorId(transacao.contaId);
      if (conta != null) {
        final novoSaldo = transacao.isEntrada 
            ? conta.saldo + transacao.valor
            : conta.saldo - transacao.valor;
        await atualizarSaldoConta(transacao.contaId, novoSaldo);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Transacao>> get transacoes async {
    return await _dbHelper.listarTransacoes();
  }

  Future<List<Transacao>> getTransacoesPorConta(int contaId) async {
    return await _dbHelper.listarTransacoesPorConta(contaId);
  }

  // ========== CÁLCULOS FINANCEIROS ==========
  
  Future<double> get saldoTotal async {
    final contasList = await contas;
    return contasList.fold<double>(0.0, (total, conta) => total + conta.saldo);
  }

  Future<double> getEntradasMes([DateTime? mes]) async {
    final data = mes ?? DateTime.now();
    final inicioMes = DateTime(data.year, data.month, 1);
    final fimMes = DateTime(data.year, data.month + 1, 0);
    
    final todasTransacoes = await transacoes;
    return todasTransacoes
        .where((t) => t.tipo == TipoTransacao.entrada && 
                     t.data.isAfter(inicioMes.subtract(const Duration(days: 1))) &&
                     t.data.isBefore(fimMes.add(const Duration(days: 1))))
        .fold<double>(0.0, (total, t) => total + t.valor);
  }

  Future<double> getSaidasMes([DateTime? mes]) async {
    final data = mes ?? DateTime.now();
    final inicioMes = DateTime(data.year, data.month, 1);
    final fimMes = DateTime(data.year, data.month + 1, 0);
    
    final todasTransacoes = await transacoes;
    return todasTransacoes
        .where((t) => t.tipo == TipoTransacao.saida && 
                     t.data.isAfter(inicioMes.subtract(const Duration(days: 1))) &&
                     t.data.isBefore(fimMes.add(const Duration(days: 1))))
        .fold<double>(0.0, (total, t) => total + t.valor);
  }

  // ========== MÉTODOS AUXILIARES ==========
  
  Future<void> limparDados() async {
    _usuarioAtual = null;
    await _dbHelper.limparTodosBancoDados();
  }

  Future<void> fecharBanco() async {
    await _dbHelper.fecharBanco();
  }
}
