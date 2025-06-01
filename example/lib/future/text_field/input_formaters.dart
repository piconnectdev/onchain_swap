import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:blockchain_utils/utils/numbers/utils/int_utils.dart';
import 'package:onchain_swap_example/app/price/utils.dart';
import 'package:onchain_swap_example/app/utils/string.dart';
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BigRangeTextInputFormatter extends TextInputFormatter {
  final BigInt min;
  final BigInt? max;

  BigRangeTextInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newString = newValue.text;

    if (newString.isNotEmpty) {
      final BigInt? enteredNumber = BigInt.tryParse(newString);
      if (enteredNumber != null) {
        if (enteredNumber < min) {
          return BigRetionalRangeTextInputFormatter._buildOldValue(oldValue);
        } else if (max != null && enteredNumber > max!) {
          return BigRetionalRangeTextInputFormatter._buildOldValue(oldValue);
        } else {
          newString = enteredNumber.toString();
        }
      } else {
        return BigRetionalRangeTextInputFormatter._buildOldValue(oldValue);
      }
    } else {
      newString = min.toString();
    }
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class RangeTextInputFormatter extends TextInputFormatter {
  final int min;
  final int? max;

  RangeTextInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newString = newValue.text;

    if (newString.isNotEmpty) {
      final int? enteredNumber = int.tryParse(newString);
      if (enteredNumber != null) {
        if (enteredNumber < min) {
          return BigRetionalRangeTextInputFormatter._buildOldValue(oldValue);
        } else if (max != null && enteredNumber > max!) {
          return BigRetionalRangeTextInputFormatter._buildOldValue(oldValue);
        } else {
          newString = enteredNumber.toString();
        }
      } else {
        return BigRetionalRangeTextInputFormatter._buildOldValue(oldValue);
      }
    } else {
      newString = min.toString();
    }
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class ValidIntegerTextInputFormatter extends TextInputFormatter {
  ValidIntegerTextInputFormatter();
  static TextEditingValue _buildOldValue(TextEditingValue oldValue) {
    final int? enteredNumber = IntUtils.tryParse(oldValue.text);
    if (enteredNumber == null) {
      return const TextEditingValue(
        text: "",
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    return oldValue;
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newString = newValue.text.trim();

    if (newString.isNotEmpty) {
      final int? enteredNumber = IntUtils.tryParse(newString);
      if (enteredNumber == null) {
        return _buildOldValue(oldValue);
      }
    } else {
      newString = '';
    }
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class BigRetionalRangeTextInputFormatter extends TextInputFormatter {
  final BigRational? min;
  final BigRational? max;
  final int? maxScale;
  final bool allowDecimal;
  final bool allowSign;
  final String sperator;

  BigRetionalRangeTextInputFormatter(
      {required this.min,
      this.max,
      this.maxScale,
      this.allowSign = true,
      this.allowDecimal = true,
      this.sperator = ','});

  static TextEditingValue _buildOldValue(TextEditingValue oldValue,
      {String sperator = ','}) {
    final String newString = oldValue.text.replaceAll(sperator, '');
    final BigRational? enteredNumber = BigRational.tryParseDecimaal(newString);
    if (enteredNumber == null) {
      return const TextEditingValue(
          text: "", selection: TextSelection.collapsed(offset: 0));
    }
    return oldValue;
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final String newString = newValue.text.replaceAll(sperator, '');
    if (newString.isNotEmpty) {
      final BigRational? enteredNumber =
          BigRational.tryParseDecimaal(newString);
      if (enteredNumber != null) {
        if (min != null && enteredNumber < min!) {
          return _buildOldValue(oldValue);
        } else if (max != null && enteredNumber > max!) {
          return _buildOldValue(oldValue);
        } else if (maxScale != null && enteredNumber.scale > maxScale!) {
          return _buildOldValue(oldValue);
        } else if (!allowDecimal &&
            (enteredNumber.isDecimal || newString.contains("."))) {
          return _buildOldValue(oldValue);
        } else if (!allowSign && enteredNumber.isNegative) {
          return _buildOldValue(oldValue);
        }
      } else {
        return _buildOldValue(oldValue);
      }
    }
    final newTxt = StrUtils.to3Digits(newString,
        allowEmptyFractional: true, separator: sperator);
    return TextEditingValue(
      text: newTxt,
      selection: TextSelection.collapsed(offset: newTxt.length),
    );
  }
}

class CurrencyTextEdittingController extends TextEditingController {
  String symbol;
  CurrencyTextEdittingController({this.symbol = '', super.text = ''});

  String getText() {
    return text.replaceAll(",", '');
  }

  void setSymbol(String symbol) {
    this.symbol = symbol.trim().toUpperCase();
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    assert(!value.composing.isValid ||
        !withComposing ||
        value.isComposingRangeValid);
    // If the composing range is out of range for the current text, ignore it to
    // preserve the tree integrity, otherwise in release mode a RangeError will
    // be thrown and this EditableText will be built with a broken subtree.
    final bool composingRegionOutOfRange =
        !value.isComposingRangeValid || !withComposing;

    if (composingRegionOutOfRange) {
      if (symbol.isEmpty) {
        return TextSpan(style: style, text: text);
      }
      return TextSpan(
        style: style,
        children: [
          TextSpan(style: style, text: text),
          if (text.isNotEmpty)
            WidgetSpan(
                child: Opacity(
                    opacity: 0.4,
                    child:
                        Text(" $symbol", style: context.textTheme.labelLarge))),
        ],
      );
    }

    final TextStyle composingStyle =
        style?.merge(const TextStyle(decoration: TextDecoration.underline)) ??
            const TextStyle(decoration: TextDecoration.underline);
    return TextSpan(
      style: style,
      children: <TextSpan>[
        TextSpan(text: value.composing.textBefore(value.text)),
        TextSpan(
            style: composingStyle,
            text: value.composing.textInside(value.text)),
        TextSpan(text: value.composing.textAfter(value.text)),
      ],
    );
  }
}

class DecodePriceTextInputFormater extends TextInputFormatter {
  const DecodePriceTextInputFormater({this.max, required this.decimal});
  final BigInt? max;
  final int decimal;
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.trim().isEmpty) {
      return newValue;
    }
    final pr = PriceUtils.tryDecodePrice(newValue.text, decimal);
    if (pr != null) {
      if (max == null) return newValue;
      if (pr <= max!) return newValue;
    }
    return oldValue;
  }
}
