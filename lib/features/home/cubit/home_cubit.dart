import 'package:bloc/bloc.dart';
import 'package:mindful_links/core/build_config.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({bool? isDeveloperMode})
      : isDeveloperMode = isDeveloperMode ?? BuildConfig.isDeveloperOrDebug,
        super(const HomeState());

  final bool isDeveloperMode;

  List<HomeTab> get bottomNavItems {
    if (isDeveloperMode) {
      return HomeTab.values;
    }
    return HomeTab.values
        .where((tab) => tab != HomeTab.developerOption)
        .toList();
  }

  void setTab(HomeTab tab) => emit(HomeState(tab: tab));
}
