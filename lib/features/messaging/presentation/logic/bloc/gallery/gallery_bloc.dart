import 'package:chat/features/messaging/presentation/logic/bloc/gallery/gallery_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  GalleryBloc() : super(GalleryInitState());

  @override
  Stream<GalleryState> mapEventToState(GalleryEvent event) async* {
    if (event is GalleryChangeCurrentImageEvent)
      emit(GalleryChangeImageState(event.index));

  }
}
