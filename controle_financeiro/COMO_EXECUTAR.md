# 🚀 Como Executar o App de Controle Financeiro

## 📋 Pré-requisitos
- Flutter SDK instalado e configurado
- Navegador web (Chrome, Edge, Firefox, etc.)

## 🌐 Executar na Web (Recomendado)

### Opção 1: Servidor Web Local
```bash
# Navegar para a pasta do projeto
cd controle_financeiro

# Executar na web com servidor local
flutter run -d web-server --web-port=8080
```
**Acesse:** http://localhost:8080

### Opção 2: Compilar e Executar
```bash
# Navegar para a pasta do projeto
cd controle_financeiro

# Habilitar suporte web (caso não tenha feito)
flutter config --enable-web

# Executar na web
flutter run -d web
```

## 💻 Executar no Desktop (Windows)

```bash
# Habilitar suporte para desktop
flutter config --enable-windows-desktop

# Criar suporte para desktop (se necessário)
flutter create . --platforms windows

# Executar no desktop
flutter run -d windows
```

## 🔧 Comandos Úteis

### Verificar dispositivos disponíveis
```bash
flutter devices
```

### Compilar para web (build de produção)
```bash
flutter build web
```
Os arquivos compilados ficam em `build/web/`

### Limpar cache e dependências
```bash
flutter clean
flutter pub get
```

### Executar testes
```bash
flutter test
```

## 🎯 Fluxo de Uso do App

1. **Tela de Login** (inicial)
   - Use qualquer email válido e senha com 6+ caracteres
   - Ou clique em "Cadastrar nova conta"

2. **Cadastro de Usuário** (se escolher cadastrar)
   - Preencha nome, email e senha
   - Será direcionado para cadastro de conta bancária

3. **Cadastro de Conta Bancária** (opcional)
   - Adicione uma conta ou pule esta etapa
   - Será direcionado para tela principal

4. **Tela Principal (Transações)**
   - Visualize o resumo financeiro
   - Adicione entradas e saídas com o botão +
   - Gerencie contas bancárias no ícone do cabeçalho

## 🐛 Solução de Problemas

### Erro de SDK não encontrado
- **Solução:** Use a execução web: `flutter run -d web-server`

### Porta em uso
- **Solução:** Use outra porta: `flutter run -d web-server --web-port=8081`

### Problemas de dependências
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Hot Reload não funcionando
- Pressione `r` no terminal para reload manual
- Pressione `R` para restart completo

## 📱 URLs e Portas

- **Desenvolvimento Web:** http://localhost:8080
- **Hot Reload:** Automático no modo debug
- **DevTools:** Link aparece no terminal após inicialização

## 💡 Dicas

- Use **Ctrl+C** no terminal para parar o servidor
- O app salva dados apenas em memória (Etapa 1)
- Refresh da página limpa todos os dados
- Use o DevTools do Flutter para debugging avançado

---

**Desenvolvido com Flutter 💙**
