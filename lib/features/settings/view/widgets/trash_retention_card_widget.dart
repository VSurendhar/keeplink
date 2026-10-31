import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindful_links/features/settings/bloc/app_settings_bloc.dart';
import 'package:mindful_links/features/settings/bloc/app_settings_event.dart';

class TrashRetentionCardWidget extends StatefulWidget {
  const TrashRetentionCardWidget({
    super.key,
    required this.savedRetentionPeriod,
  });

  final int savedRetentionPeriod;

  @override
  State<TrashRetentionCardWidget> createState() =>
      _TrashRetentionCardWidgetState();
}

class _TrashRetentionCardWidgetState extends State<TrashRetentionCardWidget> {
  late int _currentRetentionDays;

  @override
  void initState() {
    super.initState();
    _currentRetentionDays = widget.savedRetentionPeriod;
  }

  @override
  void didUpdateWidget(TrashRetentionCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync if the saved value was updated externally (e.g. after a successful save)
    if (oldWidget.savedRetentionPeriod != widget.savedRetentionPeriod) {
      _currentRetentionDays = widget.savedRetentionPeriod;
    }
  }

  @override
  Widget build(BuildContext context) {
    const sliderThumbColor = Color(0xFF7A3E26);
    const rangeLabelTextColor = Color(0xFF85736C);

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trash Retention',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9E8E85),
            ),
          ),
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
                '${_currentRetentionDays.round()} Days',
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
              thumbColor: sliderThumbColor,
              overlayColor: sliderThumbColor.withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              trackShape: const RoundedRectSliderTrackShape(),
              padding: EdgeInsets.zero,
            ),
            child: Slider(
              value: _currentRetentionDays.toDouble(),
              min: 1,
              max: 90,
              onChanged: (value) {
                setState(() {
                  _currentRetentionDays = value.toInt();
                });
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
          const SizedBox(height: 8),
          AnimatedSize(
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            duration: const Duration(milliseconds: 250),
            child:
                widget.savedRetentionPeriod.round() !=
                    _currentRetentionDays.round()
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _currentRetentionDays =
                                  widget.savedRetentionPeriod;
                            });
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF857B74)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB38E),
                            foregroundColor: const Color(0xFF7A4326),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            context.read<AppSettingsBloc>().add(
                              AppSettingsTrashRetentionChanged(
                                _currentRetentionDays.toInt(),
                              ),
                            );
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}
