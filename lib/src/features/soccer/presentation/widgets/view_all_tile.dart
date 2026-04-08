import 'package:flutter/material.dart';
import 'package:score_pulse/src/core/extensions/nums.dart';

import '../../../../core/utils/app_strings.dart';

class ViewAllTile extends StatelessWidget {
  final VoidCallback onTap;

  const ViewAllTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 25.height,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          padding: EdgeInsets.symmetric(horizontal: 10.width),
          surfaceTintColor: theme.colorScheme.outline,
          foregroundColor: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        child: Row(
          children: [
            Text(
              AppStrings.viewAll,
              style: theme.textTheme.labelLarge,
            ),
            SizedBox(width: 2.width),
            Icon(
              Icons.arrow_forward_ios_sharp,
              size: 12.radius,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
