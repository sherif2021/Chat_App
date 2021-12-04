
import 'package:bloc/bloc.dart';
import 'package:chat/features/authentication/data/model/UserModel.dart';
import 'package:chat/features/authentication/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'verification_state.dart';

class VerificationCubit extends Cubit<VerificationState> {
  final AuthRepository authRepository;

  VerificationCubit({required this.authRepository})
      : super(VerificationInitial());

  void checkVerificationCode(
      {required String phoneNumber,
      required String verificationId,
      required String verificationCode}) {

    emit(VerificationLoadingState());

    final authCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: verificationCode);

    FirebaseAuth.instance
        .signInWithCredential(authCredential)
        .then((UserCredential userCredential) async {
      if (userCredential.user != null) {
        final user = await authRepository.login(
            uid: userCredential.user!.uid, phoneNumber: phoneNumber);

        if (user == null)
          emit(InvalidCodeState());
        else
          emit(VerificationCompletedState(userModel: user));
      } else
        emit(InvalidCodeState());
    }).catchError((e) {
      emit(InvalidCodeState());
    });

  }
}
