import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:keep_links/core/data/database/url_store.dart';
import 'package:keep_links/core/data/hive/models/app_settings.dart';
import 'package:keep_links/common/widgets/save_button.dart';
import 'package:keep_links/features/home/constants/constants.dart';
import 'package:keep_links/features/settings/bloc/app_settings_bloc.dart';
import 'package:keep_links/features/settings/bloc/app_settings_event.dart';
import 'package:keep_links/features/settings/bloc/app_settings_state.dart';
import 'package:keep_links/features/settings/service/app_settings_service.dart';
import 'package:keep_links/features/settings/view/widgets/export_bottom_sheet_widget.dart';
import 'package:keep_links/features/settings/view/widgets/import_bottom_sheet_widget.dart';
import 'package:keep_links/features/settings/view/widgets/language_selection_sheet_widget.dart';
import 'package:keep_links/features/settings/view/widgets/move_all_to_trash_confirmation_widget.dart';
import 'package:keep_links/features/theme/colors.dart';
import 'package:keep_links/features/theme/theme.dart';
import 'package:keep_links/utils/utils.dart';

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppSettingsBloc(
        appSettingsService: GetIt.instance.get<AppSettingsService>(),
        urlStoreProvider: GetIt.instance.get<UrlStore>,
      ),
      child: AppSettingsView(),
    );
  }
}

class AppSettingsView extends StatelessWidget {
  const AppSettingsView({super.key});

  /// Nothing is deleted from the trash automatically in version 1, so the card
  /// is hidden.
  static const bool _showTrashRetentionCard = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppSettingsBloc, AppSettingsState>(
      listenWhen: (previous, current) =>
          current.action != null && previous.action != current.action,
      listener: (context, state) {
        final action = state.action;
        if (action == null) return;

        if (action is ShowLanguageSheet) {
          _showLanguageSelectionSheet(
            context,
            selectedLanguage: state.newAppSettings.appLanguage,
          );
        } else if (action is ShowToast) {
          Utils.showToast(action.message);
        } else if (action is ShowMoveAllToTrashDialog) {
          _showMoveAllToTrashConfirmation(context);
        } else if (action is ShowExportSheet) {
          _showExportBottomSheet(context, action.count);
        } else if (action is ShowImportSheet) {
          _showImportBottomSheet(context);
        }

        // Clear the action immediately so the same action can be re-triggered.
        context.read<AppSettingsBloc>().add(const ActionHandled());
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: KeepLinksTheme.secondaryLight,
          appBar: AppBar(
            backgroundColor: KeepLinksTheme.secondaryLight,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: Text(
              'Keep Links',
              style: TextStyle(
                color: KeepLinksColors.appBarTitleColor,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SaveButton(
                  isEnabled: state.hasUnsavedChanges,
                  isLoading: state.isSaving,
                  onPressed: () {
                    context.read<AppSettingsBloc>().add(
                      const SaveSettingsRequested(),
                    );
                  },
                ),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: KeepLinksColors.headerTitleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your digital library preferences.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: KeepLinksColors.headerSubTitleColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildAppearanceCard(
                    context,
                    isDarkMode: state.newAppSettings.appTheme == AppTheme.dark,
                  ),
                  const SizedBox(height: 16),
                  _buildLocalizationCard(
                    context,
                    languageValue: state.newAppSettings.appLanguage.value,
                  ),
                  const SizedBox(height: 16),
                  _buildDataBackupCard(context),
                  const SizedBox(height: 16),
                  if (_showTrashRetentionCard) ...[
                    _buildTrashRetentionCard(
                      context,
                      retentionPeriod: state.newAppSettings.retentionPeriod,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildMoveAllToTrashCard(context),
                  const SizedBox(height: paddingForBottomNavBar),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppearanceCard(
    BuildContext context, {
    required bool isDarkMode,
  }) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Appearance'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildIconBadge(
                icon: Icons.palette_outlined,
                iconColor: const Color(0xFF895032),
                backgroundColor: const Color(0x33FFB38E),
              ),
              const SizedBox(width: 12),
              const Text(
                'Theme',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1E1B18),
                ),
              ),
              const Spacer(),
              _buildThemeToggle(
                isDarkMode: isDarkMode,
                onAppThemeToggle: (appTheme) {
                  context.read<AppSettingsBloc>().add(ThemeChanged(appTheme));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocalizationCard(
    BuildContext context, {
    required String languageValue,
  }) {
    return _buildCard(
      onTap: () {
        context.read<AppSettingsBloc>().add(const ShowLanguageSheetRequested());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Localization'),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildIconBadge(
                icon: Icons.language_rounded,
                iconColor: const Color(0xFF895032),
                backgroundColor: const Color(0x33FFB38E),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Language',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1E1B18),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      languageValue,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF857B74),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFD7C2B9),
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataBackupCard(BuildContext context) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Data & Backup'),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.file_upload_outlined,
            label: 'Export URLs',
            onTap: () {
              context.read<AppSettingsBloc>().add(const ExportUrlsRequested());
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.file_download_outlined,
            label: 'Import URLs',
            onTap: () {
              context.read<AppSettingsBloc>().add(const ImportUrlsRequested());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrashRetentionCard(
    BuildContext context, {
    required int retentionPeriod,
  }) {
    const sliderThumbColor = Color(0xFF7A3E26);
    const rangeLabelTextColor = Color(0xFF85736C);

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Trash Retention'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Auto-delete after',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF52443D),
                ),
              ),
              Text(
                '$retentionPeriod Days',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF895032),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: const Color(0xFFC7B8AD),
              inactiveTrackColor: const Color(0xFFEFE6DF),
              thumbColor: sliderThumbColor,
              overlayColor: sliderThumbColor.withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              trackShape: const RoundedRectSliderTrackShape(),
              padding: EdgeInsets.zero,
            ),
            child: Slider(
              value: retentionPeriod.toDouble(),
              min: 1,
              max: 90,
              onChanged: (value) {
                final days = value.toInt();
                if (days == retentionPeriod) return;
                context.read<AppSettingsBloc>().add(
                  TrashRetentionChanged(days),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 day',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: rangeLabelTextColor,
                ),
              ),
              Text(
                '90 days',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: rangeLabelTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, VoidCallback? onTap}) {
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D2926).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: content,
        ),
      );
    }
    return content;
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF9E8E85),
      ),
    );
  }

  Widget _buildIconBadge({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: iconColor, size: 16),
    );
  }

  Widget _buildThemeToggle({
    required bool isDarkMode,
    required Function(AppTheme) onAppThemeToggle,
  }) {
    const activeTextColor = Color(0xFF1E1B18);
    const inactiveTextColor = Color(0xFF52443D);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBF2ED),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              onAppThemeToggle(AppTheme.light);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: !isDarkMode ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: !isDarkMode
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                'Light',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: !isDarkMode ? activeTextColor : inactiveTextColor,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              onAppThemeToggle(AppTheme.dark);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDarkMode
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                'Dark',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? activeTextColor : inactiveTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    const buttonContentColor = Color(0xFF1E1B18);

    return Material(
      color: const Color(0xFFFAF0E8),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: buttonContentColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: buttonContentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoveAllToTrashCard(BuildContext context) {
    const dangerActionColor = Color(0xFFBA1A1A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.read<AppSettingsBloc>().add(
            const ShowMoveAllToTrashDialogRequested(),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: dangerActionColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE4E1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Symbols.delete,
                  color: dangerActionColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Move All Links to Trash',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: dangerActionColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelectionSheet(
    BuildContext context, {
    required AppLanguage selectedLanguage,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => LanguageSelectionSheetWidget(
        selectedLanguage: selectedLanguage,
        onLanguageChanged: (appLanguage) {
          context.read<AppSettingsBloc>().add(LanguageChanged(appLanguage));
        },
      ),
    );
  }

  void _showMoveAllToTrashConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => MoveAllToTrashConfirmationWidget(
        onConfirm: () {
          context.read<AppSettingsBloc>().add(const MoveAllToTrashRequested());
        },
      ),
    );
  }

  void _showExportBottomSheet(BuildContext context, int count) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ExportBottomSheetWidget(
        count: count,
        onExport: () {
          context.read<AppSettingsBloc>().add(const ExportUrlsConfirmed());
        },
      ),
    );
  }

  void _showImportBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ImportBottomSheetWidget(
        onImport: () {
          context.read<AppSettingsBloc>().add(const ImportUrlsConfirmed());
        },
      ),
    );
  }
}
