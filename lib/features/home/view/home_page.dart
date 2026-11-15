import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindful_links/features/dashboard/view/dashboard_page.dart';
import 'package:mindful_links/features/developer_options/developer_option_page.dart';
import 'package:mindful_links/features/folder/view/folder_page.dart';
import 'package:mindful_links/features/home/cubit/home_cubit.dart';
import 'package:mindful_links/features/home/cubit/home_state.dart';
import 'package:mindful_links/features/home/view/widgets/home_bottom_nav_bar.dart';
import 'package:mindful_links/features/settings/view/app_settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => HomeCubit(), child: const HomeView());
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select((HomeCubit cubit) => cubit.state.tab);
    final bottomNavItems = context.select(
      (HomeCubit cubit) => cubit.bottomNavItems,
    );

    final currentIndex = bottomNavItems.contains(selectedTab)
        ? bottomNavItems.indexOf(selectedTab)
        : 0;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: bottomNavItems.map(_pageForTab).toList(),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: HomeBottomNavBar(),
          ),
        ],
      ),
    );
  }

  static Widget _pageForTab(HomeTab tab) {
    return switch (tab) {
      HomeTab.home => const DashboardPage(),
      HomeTab.folder => const FolderPage(),
      HomeTab.settings => const AppSettingsPage(),
      HomeTab.developerOption => const DeveloperOptionPage(),
    };
  }
}
