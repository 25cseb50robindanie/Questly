import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';
import '../services/localization_service.dart';
import 'custom_button.dart';

class RevisionCard extends StatelessWidget {
  final String topicName;
  final int conceptsCount;
  final VoidCallback onStartRevision;

  const RevisionCard({
    Key? key,
    required this.topicName,
    required this.conceptsCount,
    required this.onStartRevision,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorSystem.plum, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: ColorSystem.plum.withOpacity(0.04),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.loop_rounded, color: ColorSystem.purple, size: 16),
              const SizedBox(width: 6),
              Text(
                l('quick_revision'),
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.purple,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l(topicName),
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorSystem.plum,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l('concepts_ready', args: {'count': '$conceptsCount'}),
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 11,
              color: ColorSystem.plum.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: l('start_revision').toUpperCase(),
            backgroundColor: ColorSystem.cream,
            textColor: ColorSystem.plum,
            onPressed: onStartRevision,
          ),
        ],
      ),
    );
  }
}
