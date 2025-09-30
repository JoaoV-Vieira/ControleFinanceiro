class User {
  final String id;
  final String nome;
  final String email;
  final String senha;
  final DateTime dataCadastro;

  User({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.dataCadastro,
  });

  // Construtor para criar um novo usuário com ID gerado automaticamente
  User.novo({
    required this.nome,
    required this.email,
    required this.senha,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString(),
       dataCadastro = DateTime.now();

  // Converte para Map (útil para salvar no banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'dataCadastro': dataCadastro.toIso8601String(),
    };
  }

  // Cria User a partir de Map (útil para carregar do banco de dados)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      senha: map['senha'],
      dataCadastro: DateTime.parse(map['dataCadastro']),
    );
  }

  @override
  String toString() {
    return 'User{id: $id, nome: $nome, email: $email}';
  }
}
