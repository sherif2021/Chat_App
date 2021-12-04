import 'package:chat/features/authentication/data/model/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class AppCubit extends HydratedCubit<AppState> {
  AppCubit()
      : super(AppState(
            darkModeEnable:
                SchedulerBinding.instance?.window.platformBrightness ==
                    Brightness.dark,
            language: 'en',
            authUserModel: AuthUserModel(verifyCodeId: '')));

  void toggleDarkMode() {
    emit(state.copyWith(darkModeEnable: !state.darkModeEnable));
  }

  void clearAuth(){
    emit(state.copyWith(
      authUserModel: AuthUserModel(verifyCodeId: '')
    ));
  }

  ThemeData getThemeData() => ThemeData(
        brightness: state.darkModeEnable ? Brightness.dark : Brightness.light,
        primaryColor: Color(0xFF212F7B),
        primaryColorDark: Color(0xFF212F7B),
      );

  void setVerificationId(String verificationId) {
    emit(state.copyWith(
        authUserModel:
            state.authUserModel.copyWith(verifyCodeId: verificationId)));
  }
  void setPhoneNumber(String phoneNumber) {
    Colors.transparent;
    emit(state.copyWith(
        authUserModel:
        state.authUserModel.copyWith(phoneNumber: phoneNumber)));
  }

  void setUserModel({required AuthUserModel userModel}) {
    emit(state.copyWith(authUserModel: userModel));
  }

  @override
  AppState? fromJson(Map<String, dynamic> json) => AppState.fromMap(json);

  @override
  Map<String, dynamic>? toJson(AppState state) => state.toMap();
}

class AppState {
  bool darkModeEnable;
  String language;
  AuthUserModel authUserModel;

  AppState(
      {required this.darkModeEnable,
      required this.language,
      required this.authUserModel});

  AppState copyWith({
    bool? darkModeEnable,
    String? language,
    AuthUserModel? authUserModel,
  }) {
    return new AppState(
      darkModeEnable: darkModeEnable ?? this.darkModeEnable,
      language: language ?? this.language,
      authUserModel: authUserModel ?? this.authUserModel,
    );
  }

  factory AppState.fromMap(Map<String, dynamic> map) {
    return new AppState(
      darkModeEnable: map['darkModeEnable'] as bool,
      language: map['language'] as String,
      authUserModel: AuthUserModel.fromMap(map['authUserModel']),
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'darkModeEnable': this.darkModeEnable,
      'language': this.language,
      'authUserModel': this.authUserModel.toMap(),
    } as Map<String, dynamic>;
  }
}
