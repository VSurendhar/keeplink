import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindful_links/features/dashboard/view/dashboard_page.dart';
import 'package:mindful_links/features/folder/view/folder_page.dart';
import 'package:mindful_links/features/home/cubit/home_cubit.dart';
import 'package:mindful_links/features/home/view/widgets/home_bottom_nav_bar.dart';
import 'package:mindful_links/features/settings/view/settings_page.dart';

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
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: selectedTab.index,
            children: const [DashboardPage(), FolderPage(), SettingsPage()],
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: HomeBottomNavBar(),
          ),
        ],
      ),
    );
  }
}
