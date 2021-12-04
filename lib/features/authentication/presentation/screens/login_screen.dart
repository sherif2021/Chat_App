import 'package:chat/core/app_cubit.dart';
import 'package:chat/features/authentication/presentation/logic/cubit/login/login_cubit.dart';
import 'package:chat/features/authentication/presentation/widgets/CustomTextFormField.dart';
import 'package:chat/utility/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatelessWidget {
  final _validatorFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is FiledToLoginWthPhoneState)
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: Text('Auth Error'),
                        content: Text(
                          'Failed to send the Verification Code to your Phone Number, please make sure and try again later. \n' +
                              '${state.error ?? ''}',
                        ),
                        actions: [
                          Center(
                            child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel')),
                          )
                        ],
                      ));
            if (state is SendVerifyingCodeState) {
              context.read<AppCubit>().setVerificationId(state.verificationId);
              Navigator.pushNamed(context, verificationScreen);
            }
            if (state is VerificationCompletedState) {
              context.read<AppCubit>().setUserModel(userModel: state.userModel);
              Navigator.pushNamedAndRemoveUntil(
                  context, homeScreen, (route) => false);
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 150.w,
                    height: 150.h,
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Text('Chat App',
                      style: Theme.of(context).textTheme.headline3),
                  SizedBox(
                    height: 30.h,
                  ),
                  CustomTextFormFiled(
                      label: 'Phone',
                      prefixIcon: Icon(Icons.phone),
                      formKey: _validatorFormKey,
                      validator: (value) => value == null ||
                              !RegExp(r'^(?:[+0][1-9])?[0-9]{10,15}$')
                                  .hasMatch(value)
                          ? 'Phone isn\'t match'
                          : null,
                      onSave: (value) {
                        context.read<AppCubit>().setPhoneNumber(value!);

                        context.read<LoginCubit>().login(phoneNumber: value);
                      },
                      onFieldSubmitted: _checkValidator),
                  SizedBox(
                    height: 200.h,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 45.h,
                    child: BlocBuilder<LoginCubit, LoginState>(
                      buildWhen: (oldState, newState) =>
                          oldState is LoginLoadingState ||
                          newState is LoginLoadingState,
                      builder: (context, state) {
                        return ElevatedButton(
                            onPressed: state.runtimeType != LoginLoadingState
                                ? _checkValidator
                                : null,
                            child: state is LoginLoadingState
                                ? Center(child: CircularProgressIndicator())
                                : Text(
                                    'SEND CODE',
                                  ));
                      },
                    ),
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _checkValidator() {
    if (_validatorFormKey.currentState!.validate())
      _validatorFormKey.currentState!.save();
  }
}
