import 'package:flutter/material.dart';
import 'package:mindful_links/core/data/hive/models/app_settings.dart';
import 'package:mindful_links/features/theme/theme.dart';

class LanguageSelectionSheetWidget extends StatelessWidget {
  const LanguageSelectionSheetWidget({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    const selectedOptionColor = Color(0xFF7A3E26);

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
            ...AppLanguage.values.map((lang) {
              final isSelected = lang == selectedLanguage;
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  lang.value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? selectedOptionColor
                        : MindfulLinksTheme.textPrimary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: selectedOptionColor,
                      )
                    : null,
                onTap: () {
                  onLanguageChanged(lang);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

