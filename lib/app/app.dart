import 'package:flutter/material.dart';
import 'package:mindful_links/features/home/view/home_page.dart';
import 'package:mindful_links/features/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return AppView();
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: MindfulLinksTheme.light, home: const HomePage());
  }
}
