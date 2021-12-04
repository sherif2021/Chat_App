import 'package:chat/core/app_cubit.dart';
import 'package:chat/utility/app_router.dart';
import 'package:chat/utility/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fcm_config/fcm_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FCMConfig.instance.init();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppCubit(),
      child: BlocBuilder<AppCubit, AppState>(
        buildWhen: (oldState, newState) =>
            oldState.darkModeEnable != newState.darkModeEnable,
        builder: (context, state) {
          final userAuthModel = context.read<AppCubit>().state.authUserModel;

          return ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: () => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Chat',
              theme: context.read<AppCubit>().getThemeData(),
              onGenerateRoute: _appRouter.onGenerateRoute,
              initialRoute:
                  userAuthModel.uid != null && userAuthModel.uid!.isNotEmpty
                      ? homeScreen
                      : userAuthModel.verifyCodeId.isNotEmpty
                          ? verificationScreen
                          : loginScreen,
            ),
          );
        },
      ),
    );
  }
}
