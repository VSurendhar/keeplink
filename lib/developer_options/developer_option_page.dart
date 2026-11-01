import 'package:flutter/material.dart';
import 'package:mindful_links/features/home/constants/constants.dart';
import 'package:mindful_links/features/settings/view/app_settings_page.dart';
import 'package:mindful_links/features/theme/colors.dart';
import 'package:mindful_links/features/theme/theme.dart';

class DeveloperOptionPage extends StatelessWidget {
  const DeveloperOptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: MindfulLinksTheme.secondaryLight,
      appBar: AppBar(
        backgroundColor: MindfulLinksTheme.secondaryLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Developer Option',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: MindfulLinkColors.headerTitleColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: paddingForBottomNavBar),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Developer Option',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: MindfulLinkColors.headerTitleColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Screen Width: ${screenWidth.toStringAsFixed(1)} dp',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: MindfulLinkColors.headerSubTitleColor,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: MindfulLinksTheme.primary,
                    foregroundColor: const Color(0xFF7A4326),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AppSettingsPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Settings page',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
