import 'package:chat/features/authentication/presentation/logic/cubit/login/login_cubit.dart';
import 'package:chat/features/authentication/presentation/logic/cubit/verification/verification_cubit.dart';
import 'package:chat/features/messaging/data/model/attachment_model.dart';
import 'package:chat/features/messaging/data/model/user_model.dart';
import 'package:chat/features/messaging/presentation/logic/bloc/gallery/gallery_bloc.dart';
import 'package:chat/features/messaging/presentation/logic/bloc/home/home_bloc.dart';
import 'package:chat/features/messaging/presentation/logic/bloc/message/message_bloc.dart';
import 'package:chat/features/messaging/presentation/logic/bloc/video_calling/video_calling_bloc.dart';
import 'package:chat/features/messaging/presentation/screens/home_screen.dart';
import 'package:chat/features/authentication/presentation/screens/login_screen.dart';
import 'package:chat/features/authentication/presentation/screens/verification_screen.dart';
import 'package:chat/features/authentication/repository/auth_repository.dart';
import 'package:chat/features/messaging/presentation/screens/images_gallery_screen.dart';
import 'package:chat/features/messaging/presentation/screens/message_screen.dart';
import 'package:chat/features/messaging/presentation/screens/video_call_screen.dart';
import 'package:chat/features/messaging/repository/messaging_repository.dart';
import 'package:chat/features/profile/presentation/logic/cubit/profile_cubit.dart';
import 'package:chat/features/profile/presentation/screens/profile_screen.dart';
import 'package:chat/features/profile/repository/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'constants.dart';

class AppRouter {
  final _authRepository = AuthRepository();
  final _messagingRepository = MessagingRepository();
  HomeBloc? _homeBloc;

  Route? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => LoginCubit(authRepository: _authRepository),
            child: LoginScreen(),
          ),
        );

      case verificationScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                VerificationCubit(authRepository: _authRepository),
            child: VerificationScreen(),
          ),
        );

      case homeScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) {
              if (_homeBloc == null)
                _homeBloc = HomeBloc(messagingRepository: _messagingRepository);
              return _homeBloc!;
            },
            child: HomeScreen(),
          ),
        );

      case messageScreen:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (_) => MessageBloc(
                      user: (routeSettings.arguments as UserModel),
                      messagingRepository: _messagingRepository)),
              BlocProvider.value(
                value: _homeBloc!,
              ),
            ],
            child: MessageScreen(routeSettings.arguments as UserModel),
          ),
        );
      case imagesGalleryScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_,)=> GalleryBloc(),
            child: ImagesGalleryScreen(
              attachments: (routeSettings.arguments as List)[0] as List<AttachmentModel>,
              selectedImage: (routeSettings.arguments as List)[1] as int,
            ),
          ),
        );

      case videoCallingScreen:
        final args = routeSettings.arguments as Map;

        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => VideoCallingBloc(
                  messagingRepository: _messagingRepository,
                  uid: args['uid'],
                  isInComing: args['incoming'],
                ),
              ),
              BlocProvider.value(
                value: _homeBloc!,
              ),
            ],
            child: VideoCallingScreen(
              uid: args['uid'],
              name: args['name'],
              pic: args['pic'],
              isInComing: args['incoming'],
            ),
          ),
        );
      case profileScreen:
        return MaterialPageRoute(
          builder: (_) => RepositoryProvider(
            create: (_) => ProfileRepository(),
            child: BlocProvider(
              create: (context) => ProfileCubit(
                  profileRepository: context.read<ProfileRepository>()),
              child: ProfileScreen(),
            ),
          ),
        );

      default:
        return null;
    }
  }
}
