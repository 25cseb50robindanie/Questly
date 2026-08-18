import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';
import 'vector_asset_helper.dart';

class ResourceCounter extends StatelessWidget {
  final IconData? icon;
  final Color iconColor;
  final Widget? iconWidget;
  final String value;
  final String label;

  const ResourceCounter({
    Key? key,
    this.icon,
    this.iconColor = ColorSystem.gold,
    this.iconWidget,
    required this.value,
    this.label = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget leadingWidget = iconWidget ??
        (icon != null
            ? Icon(icon, color: iconColor, size: 18)
            : VectorAssetHelper.questCoinIcon(size: 18));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorSystem.plum, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: ColorSystem.plum.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leadingWidget,
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: ColorSystem.plum,
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 10,
                color: ColorSystem.plum.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

