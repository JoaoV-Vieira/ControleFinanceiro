class User {
  final int? id; // Pode ser null para novos usuários (auto-increment do SQLite)
  final String nome;
  final String email;
  final String senha;

  User({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
  });

  // Construtor para criar um novo usuário (sem ID)
  User.novo({
    required this.nome,
    required this.email,
    required this.senha,
  }) : id = null;

  // Converte para Map (compatível com SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
    };
  }

  // Cria User a partir de Map (do SQLite)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      senha: map['senha'],
    );
  }

  @override
  String toString() {
    return 'User{id: $id, nome: $nome, email: $email}';
  }
}
