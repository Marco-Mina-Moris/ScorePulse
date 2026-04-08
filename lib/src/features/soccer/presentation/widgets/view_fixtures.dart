import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:score_pulse/src/core/extensions/nums.dart';

import '../../../../config/app_route.dart';
import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/media_query.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import 'fixture_card.dart';
import 'live_fixtures_card.dart';
import 'no_fixtures_today.dart';
import 'view_all_tile.dart';

class ViewDayFixtures extends StatelessWidget {
  final List<SoccerFixture> fixtures;

  const ViewDayFixtures({super.key, required this.fixtures});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (fixtures.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(height: context.height / 2, child: const NoFixturesView()),
      );
    }

    return SliverList.builder(
      itemCount: fixtures.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // The header row
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: theme.colorScheme.primary),
                SizedBox(width: 5.width),
                Expanded(
                  child: Text(
                    AppStrings.fixtures,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                ViewAllTile(onTap: () => context.push(Routes.fixtures)),
              ],
            ),
          );
        }

        final fixtureIndex = index - 1;
        String formattedTime = 'TBD';
        final startTime = fixtures[fixtureIndex].startTime;
        if (startTime != null) {
          final localTime = startTime.toLocal();
          formattedTime = DateFormat('h:mm a').format(localTime);
        }
        
        return RepaintBoundary(
          child: Padding(
             padding: const EdgeInsets.only(bottom: 0),
             child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                context.push(Routes.fixtureDetails, extra: fixtures[fixtureIndex]);
              },
              child: FixtureCard(
                soccerFixture: fixtures[fixtureIndex],
                fixtureTime: formattedTime,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ViewLiveFixtures extends StatelessWidget {
  final List<SoccerFixture> fixtures;

  const ViewLiveFixtures({super.key, required this.fixtures});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: context.width,
      height: 280.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stream, color: AppColors.red),
              SizedBox(width: 5.width),
              Expanded(
                child: Text(
                  AppStrings.liveFixtures,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.height),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              cacheExtent: 300,
              itemBuilder: (context, index) {
                return RepaintBoundary(
                  child: InkWell(
                    onTap: () {
                      context.push(
                          Routes.fixtureDetails, extra: fixtures[index]);
                    },
                    child: LiveFixtureCard(soccerFixture: fixtures[index]),
                  ),
                );
              },
              separatorBuilder: (_, _) => SizedBox(width: 10.width),
              itemCount: fixtures.length,
            ),
          ),
        ],
      ),
    );
  }
}
