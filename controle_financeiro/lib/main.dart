import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_usuario_screen.dart';
import 'screens/cadastro_conta_screen.dart';
import 'screens/transacoes_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar o banco de dados
  await DatabaseHelper().database;
  
  runApp(const ControleFinanceiroApp());
}

class ControleFinanceiroApp extends StatelessWidget {
  const ControleFinanceiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle Financeiro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroUsuarioScreen(),
        '/contas': (context) => const CadastroContaScreen(),
        '/transacoes': (context) => const TransacoesScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
