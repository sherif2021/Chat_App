part of 'login_cubit.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoadingState extends LoginState {}

class FiledToLoginWthPhoneState extends LoginState {
  final String? error;

  FiledToLoginWthPhoneState({this.error});
}

class SendVerifyingCodeState extends LoginState {
  final String verificationId;

  SendVerifyingCodeState({required this.verificationId});
}

class VerificationCodeSentState extends LoginState {}

class VerificationCompletedState extends LoginState {
  final AuthUserModel userModel;

  VerificationCompletedState({required this.userModel});
}
