import 'package:bloc/bloc.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  final bottomNavItems = HomeTab.values;

  void setTab(HomeTab tab) => emit(HomeState(tab: tab));
}
