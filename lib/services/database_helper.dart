import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/conta_bancaria.dart';
import '../models/transacao.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal() {
    // Inicializar sqflite_ffi para desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'controle_financeiro.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Tabela de usuários
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL
      )
    ''');

    // Tabela de contas bancárias
    await db.execute('''
      CREATE TABLE contas_bancarias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome_banco TEXT NOT NULL,
        tipo_conta TEXT NOT NULL,
        saldo REAL NOT NULL,
        usuario_id INTEGER NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
      )
    ''');

    // Tabela de transações
    await db.execute('''
      CREATE TABLE transacoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL,
        valor REAL NOT NULL,
        descricao TEXT NOT NULL,
        data TEXT NOT NULL,
        conta_id INTEGER NOT NULL,
        FOREIGN KEY (conta_id) REFERENCES contas_bancarias (id)
      )
    ''');
  }

  // ========== OPERAÇÕES DE USUÁRIO ==========
  
  Future<int> inserirUsuario(User usuario) async {
    final db = await database;
    return await db.insert('usuarios', usuario.toMap());
  }

  Future<User?> buscarUsuarioPorEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> listarUsuarios() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('usuarios');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // ========== OPERAÇÕES DE CONTA BANCÁRIA ==========
  
  Future<int> inserirContaBancaria(ContaBancaria conta) async {
    final db = await database;
    return await db.insert('contas_bancarias', conta.toMap());
  }

  Future<List<ContaBancaria>> listarContasBancarias() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('contas_bancarias');
    return List.generate(maps.length, (i) => ContaBancaria.fromMap(maps[i]));
  }

  Future<void> atualizarSaldoConta(int contaId, double novoSaldo) async {
    final db = await database;
    await db.update(
      'contas_bancarias',
      {'saldo': novoSaldo},
      where: 'id = ?',
      whereArgs: [contaId],
    );
  }

  Future<ContaBancaria?> buscarContaPorId(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contas_bancarias',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ContaBancaria.fromMap(maps.first);
    }
    return null;
  }

  Future<void> atualizarConta(ContaBancaria conta) async {
    final db = await database;
    await db.update(
      'contas_bancarias',
      conta.toMap(),
      where: 'id = ?',
      whereArgs: [conta.id],
    );
  }

  Future<void> excluirConta(int contaId) async {
    final db = await database;
    
    // Excluir primeiro as transações relacionadas
    await db.delete(
      'transacoes',
      where: 'conta_id = ?',
      whereArgs: [contaId],
    );
    
    // Depois excluir a conta
    await db.delete(
      'contas_bancarias',
      where: 'id = ?',
      whereArgs: [contaId],
    );
  }

  // ========== OPERAÇÕES DE TRANSAÇÃO ==========
  
  Future<int> inserirTransacao(Transacao transacao) async {
    final db = await database;
    return await db.insert('transacoes', transacao.toMap());
  }

  Future<List<Transacao>> listarTransacoes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transacoes',
      orderBy: 'data DESC',
    );
    return List.generate(maps.length, (i) => Transacao.fromMap(maps[i]));
  }

  Future<List<Transacao>> listarTransacoesPorConta(int contaId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transacoes',
      where: 'conta_id = ?',
      whereArgs: [contaId],
      orderBy: 'data DESC',
    );
    return List.generate(maps.length, (i) => Transacao.fromMap(maps[i]));
  }

  // ========== OPERAÇÕES FILTRADAS POR USUÁRIO ==========
  
  Future<List<ContaBancaria>> listarContasPorUsuario(int usuarioId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contas_bancarias',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
    return List.generate(maps.length, (i) => ContaBancaria.fromMap(maps[i]));
  }

  Future<List<Transacao>> listarTransacoesPorUsuario(int usuarioId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.* FROM transacoes t
      INNER JOIN contas_bancarias c ON t.conta_id = c.id
      WHERE c.usuario_id = ?
      ORDER BY t.data DESC
    ''', [usuarioId]);
    return List.generate(maps.length, (i) => Transacao.fromMap(maps[i]));
  }

  Future<List<Transacao>> listarTransacoesPorContaEUsuario(int contaId, int usuarioId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.* FROM transacoes t
      INNER JOIN contas_bancarias c ON t.conta_id = c.id
      WHERE t.conta_id = ? AND c.usuario_id = ?
      ORDER BY t.data DESC
    ''', [contaId, usuarioId]);
    return List.generate(maps.length, (i) => Transacao.fromMap(maps[i]));
  }

  // ========== OPERAÇÕES AUXILIARES ==========
  
  Future<void> limparTodosBancoDados() async {
    final db = await database;
    await db.delete('transacoes');
    await db.delete('contas_bancarias');
    await db.delete('usuarios');
  }

  Future<void> fecharBanco() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
