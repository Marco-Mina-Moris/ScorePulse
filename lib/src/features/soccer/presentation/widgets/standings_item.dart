import 'package:flutter/material.dart';
import 'package:score_pulse/src/core/extensions/nums.dart';
import 'package:score_pulse/src/core/extensions/strings.dart';
import 'package:score_pulse/src/core/utils/app_colors.dart';

import '../../../../core/widgets/custom_image.dart';
import '../../domain/entities/team_rank.dart';
import 'standings_form.dart';

class StandingsItem extends StatelessWidget {
  final TeamRank teamRank;
  final int totalTeams;
  final bool isGrouped;

  const StandingsItem({
    super.key,
    required this.teamRank,
    required this.totalTeams,
    this.isGrouped = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<String> headersNumbers = [
      '${teamRank.stats.played}',
      '${teamRank.stats.win}',
      '${teamRank.stats.draw}',
      '${teamRank.stats.lose}',
      '${teamRank.stats.scored}',
      '${teamRank.stats.received}',
      '${teamRank.goalsDiff}',
      '${teamRank.points}',
    ];

    Color? rankBackground(int rank, int totalTeams) {
      if (isGrouped) return theme.colorScheme.surface;
      if (rank == 1) return AppColors.green;
      if (rank == 2) return AppColors.blue;
      if (rank == 3) return AppColors.purple;
      if (rank > totalTeams - 3) return AppColors.red;
      return theme.colorScheme.surface;
    }

    final Color rankColor =
        isGrouped
            ? theme.colorScheme.onSurface
            : (teamRank.rank <= 3 || teamRank.rank > totalTeams - 3)
            ? Colors.white
            : theme.colorScheme.onSurface;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.height, horizontal: 10.width),
      child: Row(
        children: [
          SizedBox(
            width: 200.width,
            child: Row(
              children: [
                SizedBox(
                  width: 18.radius,
                  height: 18.radius,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: rankBackground(teamRank.rank, totalTeams),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      teamRank.rank.toString(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: rankColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.width),
                CustomImage(
                  width: 20.radius,
                  height: 20.radius,
                  imageUrl: teamRank.team.logo,
                ),
                SizedBox(width: 10.width),
                Flexible(
                  child: Text(
                    teamRank.team.name.teamName,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(
              headersNumbers.length,
              (index) => SizedBox(
                width: 25.width,
                child: Text(
                  headersNumbers[index],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.width),
          StandingsForm(form: teamRank.form),
        ],
      ),
    );
  }
}

class StandingsHeaders extends StatelessWidget {
  const StandingsHeaders({super.key});
  static const List<String> _headers = [
    'PL',
    'W',
    'D',
    'L',
    'GF',
    'GA',
    'GD',
    'Pts',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.outline.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        children: [
          SizedBox(
            width: 200.width,
            child: Row(
              children: [
                Text(
                  '#',
                  textAlign: TextAlign.center,
                  style: _getHeaderTextStyle(context),
                ),
                SizedBox(width: 18.width),
                Text('Team name', style: _getHeaderTextStyle(context)),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(
              _headers.length,
              (index) => SizedBox(
                width: 25.width,
                child: Text(
                  _headers[index],
                  textAlign: TextAlign.center,
                  style: _getHeaderTextStyle(context),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 100.width,
            child: Text(
              'Form',
              textAlign: TextAlign.center,
              style: _getHeaderTextStyle(context),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle? _getHeaderTextStyle(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold);
  }
}
