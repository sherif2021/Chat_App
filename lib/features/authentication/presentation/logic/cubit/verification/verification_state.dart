part of 'verification_cubit.dart';

@immutable
abstract class VerificationState {}

class VerificationInitial extends VerificationState {}

class VerificationLoadingState extends VerificationState {}

class InvalidCodeState extends VerificationState {}

class VerificationCompletedState extends VerificationState {
  final AuthUserModel userModel;

  VerificationCompletedState({required this.userModel});
}
