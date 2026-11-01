import 'package:flutter/material.dart';
import 'package:mindful_links/core/data/database/url_store_switcher.dart';
import 'package:mindful_links/developer_options/developer_options_service.dart';
import 'package:mindful_links/features/add_new_link/view/add_new_link_page.dart';
import 'package:mindful_links/features/home/constants/constants.dart';
import 'package:mindful_links/features/settings/view/app_settings_page.dart';
import 'package:mindful_links/features/theme/colors.dart';
import 'package:mindful_links/features/theme/theme.dart';
import 'package:mindful_links/utils/utils.dart';

class DeveloperOptionPage extends StatefulWidget {
  const DeveloperOptionPage({super.key});

  @override
  State<DeveloperOptionPage> createState() => _DeveloperOptionPageState();
}

class _DeveloperOptionPageState extends State<DeveloperOptionPage> {
  @override
  Widget build(BuildContext context) {
    final isMock = UrlStoreSwitcher.isMock;

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: paddingForBottomNavBar,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSectionHeader('Data Store'),
              _buildStoreToggleCard(isMock: isMock),
              const SizedBox(height: 24),
              _buildSectionHeader('Pages'),
              _buildButton(
                title: 'Settings page',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AppSettingsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildButton(
                title: 'Add Link URL Page',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AddNewLinkPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Setup & Seeding'),
              _buildButton(
                title: 'Initialize Database Setup',
                onPressed: () => DeveloperOptionsService.initialDatabaseSetup(),
              ),
              const SizedBox(height: 12),
              _buildButton(
                title: 'Initialize App Settings',
                onPressed: () => DeveloperOptionsService.initialAppSettings(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9E8E85),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreToggleCard({required bool isMock}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE5DF), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D2926).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mock URL Store',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: MindfulLinkColors.headerTitleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isMock
                      ? 'Using in-memory mock store'
                      : 'Using real database store',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: MindfulLinkColors.headerSubTitleColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isMock,
            activeThumbColor: MindfulLinksTheme.primaryDark,
            onChanged: (bool value) {
              setState(() {
                if (value) {
                  UrlStoreSwitcher.useMock();
                } else {
                  UrlStoreSwitcher.useReal();
                }
              });
              Utils.showToast(
                value
                    ? 'Switched to Mock URL Store'
                    : 'Switched to Database URL Store',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String title,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: MindfulLinksTheme.primary,
          foregroundColor: const Color(0xFF7A4326),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
