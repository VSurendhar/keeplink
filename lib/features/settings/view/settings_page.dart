import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mindful_links/features/home/constants/constants.dart';
import 'package:mindful_links/features/theme/colors.dart';
import 'package:mindful_links/features/theme/theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'English (US)';
  double _retentionDays = 30;
  late double _savedRetentionDays = _retentionDays;

  final List<String> _languages = const [
    'English (US)',
    'English (UK)',
    'Spanish',
    'French',
    'German',
    'Japanese',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MindfulLinksTheme.secondaryLight,
      appBar: AppBar(
        backgroundColor: MindfulLinksTheme.secondaryLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'MindfulLinks',
          style: TextStyle(
            color: MindfulLinkColors.appBarTitleColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Symbols.delete,
              color: MindfulLinkColors.appBarTitleColor,
              size: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: MindfulLinkColors.headerTitleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your digital library preferences.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: MindfulLinkColors.headerSubTitleColor,
                ),
              ),
              const SizedBox(height: 32),

              // Appearance Card
              _buildCard(
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
                          iconColor: Color(0xFF895032),
                          backgroundColor: Color(0x33FFB38E),
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
                        _buildThemeToggle(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Localization Card
              _buildCard(
                onTap: _showLanguageSelectionSheet,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Localization'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildIconBadge(
                          icon: Icons.language_rounded,
                          iconColor: Color(0xFF895032),
                          backgroundColor: Color(0x33FFB38E),
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
                                _selectedLanguage,
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
              ),
              const SizedBox(height: 16),

              // Data & Backup Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Data & Backup'),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      icon: Icons.file_upload_outlined,
                      label: 'Export Bookmarks',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      icon: Icons.file_download_outlined,
                      label: 'Import Bookmarks',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Trash Retention Card
              _buildCard(
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
                          '${_retentionDays.toInt()} Days',
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
                        trackHeight: 3.5,
                        activeTrackColor: const Color(0xFFC7B8AD),
                        inactiveTrackColor: const Color(0xFFEFE6DF),
                        thumbColor: const Color(0xFF7A3E26),
                        overlayColor: const Color(
                          0xFF7A3E26,
                        ).withValues(alpha: 0.1),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                        trackShape: const RoundedRectSliderTrackShape(),
                        padding: EdgeInsets.zero,
                      ),
                      child: Slider(
                        value: _retentionDays,
                        min: 1,
                        max: 90,
                        onChanged: (val) {
                          setState(() {
                            _retentionDays = val;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1 day',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF85736C),
                          ),
                        ),
                        Text(
                          '90 days',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF85736C),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    AnimatedSize(
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      duration: Duration(milliseconds: 250),
                      child:
                          _retentionDays.round() != _savedRetentionDays.round()
                          ? Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _savedRetentionDays = _retentionDays;
                                      });
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Color(0xFF857B74),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  SizedBox(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFFFB38E),
                                        foregroundColor: Color(0xFF7A4326),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _savedRetentionDays = _retentionDays;
                                        });
                                      },
                                      child: const Text(
                                        'Save',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildEraseDataCard(),
              Container(
                decoration: BoxDecoration(color: Colors.black),
                child: const SizedBox(height: paddingForBottomNavBar),
              ),
            ],
          ),
        ),
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

  Widget _buildThemeToggle() {
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
              if (_isDarkMode) {
                setState(() => _isDarkMode = false);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: !_isDarkMode ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: !_isDarkMode
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
                  color: !_isDarkMode ? Color(0xFF1E1B18) : Color(0xFF52443D),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (!_isDarkMode) {
                setState(() => _isDarkMode = true);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isDarkMode
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
                  color: !_isDarkMode ? Color(0xFF1E1B18) : Color(0xFF52443D),
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
              Icon(icon, size: 20, color: Color(0xFF1E1B18)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1E1B18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEraseDataCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showEraseDataConfirmation,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x33BA1A1A), width: 1),
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
                  Symbols.delete_forever,
                  color: Color(0xFFBA1A1A),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Erase All Data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFBA1A1A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelectionSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0D5CE),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E1B18),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ..._languages.map((lang) {
                  final isSelected = lang == _selectedLanguage;
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(
                      lang,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? const Color(0xFF7A3E26)
                            : MindfulLinksTheme.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF7A3E26),
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedLanguage = lang;
                      });
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEraseDataConfirmation() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Erase All Data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC83838),
                  ),
                ),
                SizedBox(height: 16),
                const Text(
                  'Are you sure you want to erase all your saved bookmarks, folders, and tags?\nThis action cannot be undone.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF52443D)),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFF857B74)),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC83838),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Erase'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
