class CalculatorModel {
  String _first = '';
  String _operator = '';
  String _second = '';
  bool _showResult = false;

  String get expression {
    if (_showResult) return _first;
    return _first + _operator + _second;
  }

  void input(String token) {
    if (token == 'C') {
      clear();
    } else if (token == '<-') {
      backspace();
    } else if (token == '=') {
      evaluate();
    } else if (_isOperator(token)) {
      _pressOperator(token);
    } else {
      _pressDigit(token);
    }
  }

  void clear() {
    _first = '';
    _operator = '';
    _second = '';
    _showResult = false;
  }

  void backspace() {
    if (_showResult) {
      clear();
      return;
    }
    if (_second.isNotEmpty) {
      _second = _second.substring(0, _second.length - 1);
    } else if (_operator.isNotEmpty) {
      _operator = '';
    } else if (_first.isNotEmpty) {
      _first = _first.substring(0, _first.length - 1);
    }
  }

  bool _isOperator(String token) {
    return token == '+' || token == '-' || token == '*' || token == '/' || token == '%';
  }

  void _pressDigit(String digit) {
    if (_showResult) {
      clear();
    }
    if (_operator.isEmpty) {
      if (digit == '.' && _first.contains('.')) return;
      _first += digit;
    } else {
      if (digit == '.' && _second.contains('.')) return;
      _second += digit;
    }
  }

  void _pressOperator(String op) {
    if (_showResult) {
      _operator = op;
      _second = '';
      _showResult = false;
      return;
    }
    if (_first.isEmpty) {
      if (op == '-') _first = '-';
      return;
    }
    if (_second.isNotEmpty) {
      evaluate();
      _operator = op;
      _second = '';
      _showResult = false;
    } else {
      _operator = op;
    }
  }

  String evaluate() {
    if (_first.isEmpty || _operator.isEmpty || _second.isEmpty) {
      return expression;
    }

    final a = double.tryParse(_first);
    final b = double.tryParse(_second);
    if (a == null || b == null) {
      _first = 'Error';
      _operator = '';
      _second = '';
      _showResult = true;
      return _first;
    }

    double result;
    switch (_operator) {
      case '+':
        result = a + b;
        break;
      case '-':
        result = a - b;
        break;
      case '*':
        result = a * b;
        break;
      case '/':
        if (b == 0) return _setError();
        result = a / b;
        break;
      case '%':
        if (b == 0) return _setError();
        result = a % b;
        break;
      default:
        return expression;
    }

    _first = _format(result);
    _operator = '';
    _second = '';
    _showResult = true;
    return _first;
  }

  String _setError() {
    _first = 'Error';
    _operator = '';
    _second = '';
    _showResult = true;
    return _first;
  }

  String _format(double value) {
    if (value.isNaN || value.isInfinite) return 'Error';
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }
}
