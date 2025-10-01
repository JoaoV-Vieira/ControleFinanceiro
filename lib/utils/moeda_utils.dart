import 'package:intl/intl.dart';

class MoedaUtils {
  static final NumberFormat _formatadorMoeda = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  /// Formata um valor double para o padrão brasileiro: R$ 0.000,00
  static String formatarMoeda(double valor) {
    return _formatadorMoeda.format(valor);
  }

  /// Converte uma string no formato brasileiro para double
  /// Exemplo: "R$ 1.234,56" -> 1234.56
  static double? stringParaDouble(String valor) {
    if (valor.isEmpty) return null;
    
    try {
      // Remove o símbolo da moeda e espaços
      String valorLimpo = valor
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .trim();

      // Se estiver vazio após limpeza, retorna null
      if (valorLimpo.isEmpty) return null;

      // Se contém vírgula, trata como formato brasileiro
      if (valorLimpo.contains(',')) {
        // Separa parte inteira da decimal
        List<String> partes = valorLimpo.split(',');
        if (partes.length != 2) return null;

        String parteInteira = partes[0].replaceAll('.', ''); // Remove separadores de milhar
        String parteDecimal = partes[1];

        // Valida parte decimal (deve ter exatamente 2 dígitos)
        if (parteDecimal.length != 2) return null;

        String valorFinal = '$parteInteira.$parteDecimal';
        return double.parse(valorFinal);
      } else {
        // Se não contém vírgula, tenta converter diretamente
        return double.parse(valorLimpo.replaceAll('.', ''));
      }
    } catch (e) {
      return null;
    }
  }

  /// Formata valor para exibição em inputs (sem símbolo R$)
  /// Exemplo: 1234.56 -> "1.234,56"
  static String formatarParaInput(double valor) {
    final NumberFormat formatador = NumberFormat('#,##0.00', 'pt_BR');
    return formatador.format(valor);
  }

  /// Valida se uma string está no formato brasileiro válido
  static bool validarFormatoBrasileiro(String valor) {
    if (valor.isEmpty) return false;
    
    // Remove R$ e espaços para validação
    String valorLimpo = valor
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .trim();

    // Regex para formato brasileiro: 0.000,00 ou 000,00
    RegExp regex = RegExp(r'^\d{1,3}(\.\d{3})*,\d{2}$|^\d+,\d{2}$|^\d+$');
    return regex.hasMatch(valorLimpo);
  }

  /// Formata valor para transação (com sinal + ou -)
  static String formatarTransacao(double valor, bool isEntrada) {
    String sinal = isEntrada ? '+' : '-';
    String valorFormatado = formatarMoeda(valor.abs());
    return '$sinal $valorFormatado';
  }
}
