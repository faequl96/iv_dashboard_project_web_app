import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iv_project_core/iv_project_core.dart';
import 'package:iv_project_widget_core/iv_project_widget_core.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class DefaultTextField extends StatelessWidget {
  const DefaultTextField({
    super.key,
    required this.textEditingController,
    this.focusNode,
    this.labelTextBuilder,
    this.hintText,
    this.hintStyle,
    this.inputFormatters,
    this.maxLines = 1,
    this.enabled = true,
    this.validation = true,
    this.mandatory = false,
    this.filled = true,
    this.onChanged,
    this.validator,
  });

  final TextEditingController textEditingController;
  final FocusNode? focusNode;
  final String Function()? labelTextBuilder;
  final String? hintText;
  final TextStyle? hintStyle;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final bool enabled;
  final bool validation;
  final bool mandatory;
  final bool filled;
  final void Function(String value)? onChanged;
  final TextFieldValidator Function(String)? validator;

  @override
  Widget build(BuildContext context) {
    return GeneralTextField(
      controller: textEditingController,
      focusNode: focusNode,
      enabled: enabled,
      height: 46,
      decoration: FieldDecoration(
        labelText: labelTextBuilder?.call(),
        hintText: hintText,
        hintStyle: hintStyle,
        filled: filled,
        fillColor: Colors.white,
        floatingLabelBehavior: (maxLines ?? 1) > 1 ? FloatingLabelBehavior.always : FloatingLabelBehavior.auto,
        suffixIcons: () {
          if (!enabled) return [];
          if (!mandatory) {
            if (textEditingController.text.isEmpty) return [];
            return [SharedPersonalize.suffixClear(() => textEditingController.reset())];
          }
          if (textEditingController.text.isEmpty) return [SharedPersonalize.suffixMandatory];
          return [SharedPersonalize.suffixClear(() => textEditingController.reset())];
        },
      ),
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      onChanged: (value) => onChanged?.call(value),
      validator: (value) {
        if (!validation) return TextFieldValidator.success();
        if (validator != null) {
          final validatorValue = validator!(value);
          if (validatorValue.isSuccess == false) return validatorValue;
        }
        if (value.isEmpty) return SharedPersonalize.fieldCanNotEmpty();
        return TextFieldValidator.success();
      },
    );
  }
}
