import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watibot/core/theme/app_theme.dart';

class AuthOtpField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;

  const AuthOtpField({
    super.key,
    required this.onChanged,
    required this.onCompleted,
  });

  @override
  State<AuthOtpField> createState() => _AuthOtpFieldState();
}

class _AuthOtpFieldState extends State<AuthOtpField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  final int _length = 6;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_length, (_) => TextEditingController());
    _focusNodes = List.generate(_length, (_) => FocusNode());

    for (int i = 0; i < _length; i++) {
      _focusNodes[i].addListener(() {
        setState(() {}); // Rebuild for border color change
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length > 1) {
      // Handle paste
      final pasteText = value;
      int start = index;
      for (int i = 0; i < pasteText.length && start + i < _length; i++) {
        _controllers[start + i].text = pasteText[i];
      }
      
      final nextIndex = start + pasteText.length;
      if (nextIndex < _length) {
        _focusNodes[nextIndex].requestFocus();
      } else {
        _focusNodes[_length - 1].unfocus();
      }
    } else if (value.length == 1) {
      if (index < _length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    _triggerChange();
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
        _triggerChange();
      }
    }
  }

  void _triggerChange() {
    final otp = _controllers.map((c) => c.text).join();
    widget.onChanged(otp);
    if (otp.length == _length) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        _length,
        (index) => SizedBox(
          width: 48,
          height: 56,
          child: KeyboardListener(
            focusNode: FocusNode(), // Dummy focus node for listener
            onKeyEvent: (event) => _onKeyEvent(event, index),
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) => _onChanged(value, index),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                counterText: "",
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _focusNodes[index].hasFocus
                        ? AppTheme.primaryColor
                        : AppTheme.borderColor,
                    width: _focusNodes[index].hasFocus ? 2 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
