# 📱 Controle Financeiro - App Flutter

Um aplicativo simples de controle financeiro pessoal desenvolvido em Flutter para aprender os conceitos básicos da tecnologia.

## 🎯 Objetivo

Este projeto foi criado para entender como Flutter funciona na prática, implementando um caso de uso real de forma simples e didática.

## 📋 Funcionalidades Implementadas (Etapa 1)

### ✅ Layout + Funcionamento Básico
- [x] **Cadastro de usuário** - Tela para registro com nome, email e senha
- [x] **Cadastro de conta bancária** - Adicionar contas com nome, banco e saldo inicial
- [x] **Adicionar transações** - Formulário para entradas e saídas manuais
- [x] **Lista de transações** - Exibição simples das movimentações
- [x] **Resumo financeiro** - Saldo total, entradas e saídas do mês

## 🏗️ Arquitetura do Projeto

```
lib/
├── main.dart                 # Configuração principal e navegação
├── models/                   # Modelos de dados
│   ├── user.dart            # Modelo do usuário
│   ├── conta_bancaria.dart  # Modelo da conta bancária
│   └── transacao.dart       # Modelo das transações
├── screens/                  # Telas do aplicativo
│   ├── cadastro_usuario_screen.dart
│   ├── cadastro_conta_screen.dart
│   ├── transacoes_screen.dart
│   └── adicionar_transacao_screen.dart
├── services/                 # Serviços e lógica de negócio
│   └── data_service.dart    # Gerenciamento de dados em memória
└── widgets/                  # Componentes reutilizáveis (futuro)
```

## 🚀 Como Executar

1. **Pré-requisitos:**
   - Flutter SDK instalado
   - Dispositivo/emulador Android ou iOS configurado

2. **Clonar e executar:**
   ```bash
   cd controle_financeiro
   flutter pub get
   flutter run
   ```

## 🎨 Fluxo do Aplicativo

1. **Cadastro de Usuário** → Primeira tela para registro
2. **Cadastro de Conta** → Adicionar pelo menos uma conta bancária (opcional)
3. **Tela Principal** → Lista de transações com resumo financeiro
4. **Adicionar Transação** → Formulário para entradas e saídas

## 📱 Telas Principais

### 1. Cadastro de Usuário
- Nome completo, email e senha
- Validações básicas de formulário
- Navegação para cadastro de conta

### 2. Cadastro de Conta Bancária
- Nome da conta e banco (dropdown com opções populares)
- Saldo inicial
- Possibilidade de pular esta etapa

### 3. Tela de Transações
- Card com resumo financeiro (saldo total, entradas, saídas)
- Lista de transações ordenada por data
- Botão flutuante para adicionar nova transação
- Acesso ao gerenciamento de contas

### 4. Adicionar Transação
- Tipo: Entrada ou Saída (radio buttons)
- Descrição, valor, conta e categoria
- Seleção de data
- Categorias predefinidas para cada tipo

## 🔄 Próximas Etapas

### Etapa 2 - Integração com Banco de Dados
- [ ] Implementar SQLite ou Hive para persistência
- [ ] Relatórios simples (saldo, gastos do mês)
- [ ] Histórico de transações por período

### Etapa 3 - Recursos Nativos
- [ ] Exportar dados em CSV ou PDF
- [ ] Notificações quando ultrapassar limite de gastos
- [ ] Autenticação com senha ou biometria

## 🛠️ Tecnologias Utilizadas

- **Flutter** - Framework para desenvolvimento multiplataforma
- **Dart** - Linguagem de programação
- **Material Design** - Design system do Google

## 📚 Conceitos Flutter Aplicados

- **Widgets Stateful e Stateless**
- **Navegação entre telas** (Navigator)
- **Formulários e validação**
- **Gerenciamento de estado** simples
- **Arquitetura em camadas** (Models, Screens, Services)
- **Organização de projeto** Flutter

## 🤝 Como Contribuir

Este é um projeto educativo! Sugestões de melhorias são bem-vindas:

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📝 Notas de Desenvolvimento

- Os dados são armazenados apenas em memória (Etapa 1)
- Design simples e funcional para foco no aprendizado
- Validações básicas implementadas
- Código comentado para facilitar o entendimento
- Estrutura preparada para expansões futuras

---

**Desenvolvido para fins educativos** 🎓
