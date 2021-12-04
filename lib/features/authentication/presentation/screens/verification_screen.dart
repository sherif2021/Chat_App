import 'package:chat/core/app_cubit.dart';
import 'package:chat/features/authentication/presentation/logic/cubit/verification/verification_cubit.dart';
import 'package:chat/features/authentication/presentation/widgets/CustomTextFormField.dart';
import 'package:chat/utility/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerificationScreen extends StatelessWidget {
  final _validatorFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _onBackPressed(context);
        return Future.value(false);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => _onBackPressed(context),
          ),
        ),
        body: BlocListener<VerificationCubit, VerificationState>(
          listener: (context, state) {
            if (state is InvalidCodeState) {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: Text('Verification Error'),
                        content: Text(
                          'Failed to Verification your Phone Number, please make sure your code and try again later.',
                        ),
                        actions: [
                          Center(
                            child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel')),
                          )
                        ],
                      ));
            }
            if (state is VerificationCompletedState) {
              context.read<AppCubit>().setUserModel(userModel: state.userModel);
              Navigator.pushNamedAndRemoveUntil(
                  context, homeScreen, (route) => false);
            }
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFormFiled(
                    label: 'Verification Code',
                    prefixIcon: Icon(Icons.verified_user),
                    formKey: _validatorFormKey,
                    onSave: (value) {
                      context.read<VerificationCubit>().checkVerificationCode(
                          phoneNumber: context
                              .read<AppCubit>()
                              .state
                              .authUserModel
                              .phoneNumber!,
                          verificationId: context
                              .read<AppCubit>()
                              .state
                              .authUserModel
                              .verifyCodeId,
                          verificationCode: value!);
                    },
                    validator: (value) => value == null || value.length != 6
                        ? 'Verification Code is\'t match'
                        : null,
                    onFieldSubmitted: _checkValidator,
                  ),
                  SizedBox(
                    height: 50.h,
                  ),
                  SizedBox(
                      width: double.infinity,
                      height: 45.h,
                      child: BlocBuilder<VerificationCubit, VerificationState>(
                        buildWhen: (oldState, newState) =>
                            oldState is VerificationLoadingState ||
                            newState is VerificationLoadingState,
                        builder: (context, state) {
                          return ElevatedButton(
                              onPressed:
                                  state.runtimeType != VerificationLoadingState
                                      ? _checkValidator
                                      : null,
                              child: state is VerificationLoadingState
                                  ? Center(child: CircularProgressIndicator())
                                  : Text(
                                      'VERIFY',
                                    ));
                        },
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onBackPressed(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Confirm'),
              content: Text(
                'Are you sure to want Back?',
              ),
              actions: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            context.read<AppCubit>().setVerificationId('');
                            Navigator.pop(context);
                            Navigator.pushNamedAndRemoveUntil(
                                context, loginScreen, (route) => false);
                          },
                          child: Text('Yes')),
                      ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel')),
                    ],
                  ),
                )
              ],
            ));
  }

  void _checkValidator() {
    if (_validatorFormKey.currentState!.validate())
      _validatorFormKey.currentState!.save();
  }
}
