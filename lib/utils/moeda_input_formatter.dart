import 'package:flutter/services.dart';

/// Formatador de entrada para valores monetários no padrão brasileiro
/// Permite apenas números, vírgulas e pontos
/// Formata automaticamente enquanto o usuário digita
class MoedaBrasileiraInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove todos os caracteres que não são dígitos, vírgula ou ponto
    String digits = newValue.text.replaceAll(RegExp(r'[^\d,.]'), '');

    // Limita a apenas um separador decimal (vírgula)
    if (digits.contains(',')) {
      List<String> parts = digits.split(',');
      if (parts.length > 2) {
        // Se há mais de uma vírgula, mantém apenas a primeira
        digits = '${parts[0]},${parts.sublist(1).join('')}';
      }
      
      // Limita casas decimais a 2
      if (parts.length == 2 && parts[1].length > 2) {
        digits = '${parts[0]},${parts[1].substring(0, 2)}';
      }
    }

    // Remove pontos se houver vírgula (ponto só é separador de milhar)
    if (digits.contains(',') && digits.contains('.')) {
      int virguleIndex = digits.lastIndexOf(',');
      String beforeComma = digits.substring(0, virguleIndex);
      String afterComma = digits.substring(virguleIndex);
      
      // Remove pontos da parte decimal
      afterComma = afterComma.replaceAll('.', '');
      digits = beforeComma + afterComma;
    }

    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(
        offset: digits.length,
      ),
    );
  }
}

/// Formatador mais restritivo que aceita apenas o padrão brasileiro válido
class MoedaBrasileiraEstritaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text;
    
    // Regex para validar formato brasileiro: 1.234,56 ou 1234,56 ou 1234
    RegExp validPattern = RegExp(r'^\d{1,3}(\.\d{3})*(?:,\d{0,2})?$|^\d+(?:,\d{0,2})?$');
    
    if (validPattern.hasMatch(text)) {
      return newValue;
    } else {
      // Se não é válido, mantém o valor anterior
      return oldValue;
    }
  }
}
