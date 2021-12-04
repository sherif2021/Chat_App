import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextFormFiled extends StatelessWidget {
  final String? Function(String? value)? validator;
  final String? label;
  final Icon? prefixIcon;

  final GlobalKey<FormState>? formKey;
  final Function onFieldSubmitted;
  final Function(String? newValue)? onSave;

  const CustomTextFormFiled(
      {Key? key,
      this.formKey,
      required this.onFieldSubmitted,
      this.onSave,
      this.validator,
      this.label,
      this.prefixIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: TextFormField(
        onFieldSubmitted: (v) => onFieldSubmitted(),
        maxLines: 1,
        keyboardType: TextInputType.phone,
        onSaved: onSave,
        validator: validator,
        decoration: InputDecoration(
            labelText: label,
            prefixIcon: prefixIcon,
            border: _textFiledBorder(context),
            errorBorder: _textFiledBorder(context),
            focusedBorder: _textFiledBorder(context),
            focusedErrorBorder: _textFiledBorder(context)),
      ),
    );
  }

  OutlineInputBorder _textFiledBorder(BuildContext context) =>
      OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).accentColor, width: 1),
          borderRadius: BorderRadius.circular(10));
}
