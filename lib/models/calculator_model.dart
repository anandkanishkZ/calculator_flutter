class CalculatorModel {
  String _expression = '';

  String get expression => _expression;

  static const Set<String> _operators = {'+', '-', '*', '/', '%'};

  void input(String token) {
    if (token == 'C') {
      clear();
    } else if (token == '<-') {
      backspace();
    } else if (token == '=') {
      evaluate();
    } else if (_operators.contains(token)) {
      _appendOperator(token);
    } else if (token == '.') {
      _appendDecimal();
    } else {
      _appendDigit(token);
    }
  }

  void clear() {
    _expression = '';
  }

  void backspace() {
    if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
    }
  }

  void _appendDigit(String digit) {
    _expression += digit;
  }

  void _appendOperator(String op) {
    if (_expression.isEmpty) {
      if (op == '-') _expression = '-';
      return;
    }
    final last = _expression[_expression.length - 1];
    if (_operators.contains(last)) {
      _expression = _expression.substring(0, _expression.length - 1) + op;
    } else {
      _expression += op;
    }
  }

  void _appendDecimal() {
    if (_expression.isEmpty || _operators.contains(_expression[_expression.length - 1])) {
      _expression += '0.';
      return;
    }
    int i = _expression.length - 1;
    while (i >= 0 && !_operators.contains(_expression[i])) {
      if (_expression[i] == '.') return;
      i--;
    }
    _expression += '.';
  }

  String evaluate() {
    if (_expression.isEmpty) return '';
    try {
      var expr = _expression;
      while (expr.isNotEmpty && _operators.contains(expr[expr.length - 1])) {
        expr = expr.substring(0, expr.length - 1);
      }
      if (expr.isEmpty) return _expression;

      final tokens = _tokenize(expr);
      final rpn = _toRpn(tokens);
      final result = _evalRpn(rpn);
      _expression = _formatResult(result);
      return _expression;
    } catch (_) {
      _expression = 'Error';
      return _expression;
    }
  }

  List<String> _tokenize(String expr) {
    final tokens = <String>[];
    var buffer = '';
    for (int i = 0; i < expr.length; i++) {
      final c = expr[i];
      if (_operators.contains(c)) {
        if (c == '-' && (i == 0 || _operators.contains(expr[i - 1]))) {
          buffer += c;
        } else {
          if (buffer.isNotEmpty) {
            tokens.add(buffer);
            buffer = '';
          }
          tokens.add(c);
        }
      } else {
        buffer += c;
      }
    }
    if (buffer.isNotEmpty) tokens.add(buffer);
    return tokens;
  }

  int _precedence(String op) {
    if (op == '+' || op == '-') return 1;
    if (op == '*' || op == '/' || op == '%') return 2;
    return 0;
  }

  List<String> _toRpn(List<String> tokens) {
    final output = <String>[];
    final stack = <String>[];
    for (final t in tokens) {
      if (_operators.contains(t)) {
        while (stack.isNotEmpty && _precedence(stack.last) >= _precedence(t)) {
          output.add(stack.removeLast());
        }
        stack.add(t);
      } else {
        output.add(t);
      }
    }
    while (stack.isNotEmpty) {
      output.add(stack.removeLast());
    }
    return output;
  }

  double _evalRpn(List<String> rpn) {
    final stack = <double>[];
    for (final t in rpn) {
      if (_operators.contains(t)) {
        if (stack.length < 2) throw const FormatException('Invalid expression');
        final b = stack.removeLast();
        final a = stack.removeLast();
        switch (t) {
          case '+':
            stack.add(a + b);
            break;
          case '-':
            stack.add(a - b);
            break;
          case '*':
            stack.add(a * b);
            break;
          case '/':
            if (b == 0) throw const FormatException('Divide by zero');
            stack.add(a / b);
            break;
          case '%':
            if (b == 0) throw const FormatException('Modulo by zero');
            stack.add(a % b);
            break;
        }
      } else {
        stack.add(double.parse(t));
      }
    }
    if (stack.length != 1) throw const FormatException('Invalid expression');
    return stack.single;
  }

  String _formatResult(double value) {
    if (value.isNaN || value.isInfinite) return 'Error';
    if (value == value.truncateToDouble() && value.abs() < 1e16) {
      return value.toInt().toString();
    }
    var s = value.toStringAsFixed(10);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
    return s;
  }
}
