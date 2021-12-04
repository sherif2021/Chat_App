
import 'package:bloc/bloc.dart';
import 'package:chat/features/authentication/data/model/UserModel.dart';
import 'package:chat/features/authentication/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository authRepository;

  LoginCubit({required this.authRepository}) : super(LoginInitial());

  void login({required String phoneNumber}){
    emit(LoginLoadingState());

    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        emit(FiledToLoginWthPhoneState(error: e.message));
      },
      codeSent: (String verificationId, int? resendToken) async {
        emit(SendVerifyingCodeState(verificationId: verificationId));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        emit(SendVerifyingCodeState(verificationId: verificationId));
      },
    );
  }
}
