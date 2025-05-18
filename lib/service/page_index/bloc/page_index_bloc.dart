import 'package:flutter_bloc/flutter_bloc.dart';

import 'page_index_event.dart';
import 'page_index_state.dart';

class PageIndexBloc extends Bloc<PageIndexEvent, PageIndexState> {
  PageIndexBloc() : super(const PageIndexState(0)) {
    on<ChangePageIndex>((event, emit) {
      emit(PageIndexState(event.index));
    });
  }
}
