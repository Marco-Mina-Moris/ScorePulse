import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:score_pulse/src/config/app_route.dart';

import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_fonts.dart';
import 'fixture_card.dart';

class GroupedFixturesList extends StatelessWidget {
  final List<SoccerFixture> fixtures;
  final bool showLeagueLogo;

  const GroupedFixturesList({
    super.key,
    required this.fixtures,
    this.showLeagueLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    final groupedItems = _buildGroupedFixtures(fixtures);
    final theme = Theme.of(context);

    return ListView.builder(
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final item = groupedItems[index];
        if (item is String) {
          // Date header
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Text(
              item,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeights.semiBold,
                color: AppColors.lightRed,
              ),
            ),
          );
        } else if (item is SoccerFixture) {
          // Fixture card
          final gameTime = item.startTime.toString();
          final localTime = DateTime.parse(gameTime).toLocal();
          final formattedTime = DateFormat('h:mm a').format(localTime);

          return InkWell(
            onTap: () {
              context.push(Routes.fixtureDetails, extra: item);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: FixtureCard(
                soccerFixture: item,
                fixtureTime: formattedTime,
                showLeagueLogo: showLeagueLogo,
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  List<dynamic> _buildGroupedFixtures(List<SoccerFixture> fixtures) {
    fixtures.sort((a, b) {
      if (a.startTime == null || b.startTime == null) return 0;
      return a.startTime!.compareTo(b.startTime!);
    });

    final List<dynamic> groupedList = [];
    String? lastDate;

    final now = DateTime.now();

    for (var fixture in fixtures) {
      if (fixture.startTime == null) continue;

      final localDate = fixture.startTime!.toLocal();
      final isSameYear = localDate.year == now.year;

      final fixtureDate = DateFormat(
        isSameYear ? 'EEEE, MMM d' : 'EEEE, MMM d, yyyy',
      ).format(localDate);

      if (lastDate != fixtureDate) {
        groupedList.add(fixtureDate);
        lastDate = fixtureDate;
      }
      groupedList.add(fixture);
    }

    return groupedList;
  }
}
