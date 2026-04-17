import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:score_pulse/src/core/extensions/nums.dart';
import 'package:score_pulse/src/core/utils/app_colors.dart';
import 'package:score_pulse/src/core/utils/app_constants.dart';
import 'package:score_pulse/src/features/soccer/domain/use_cases/standings_usecase.dart';

import '../../domain/entities/team_rank.dart';
import '../cubit/soccer_cubit.dart';
import '../cubit/soccer_state.dart';
import '../widgets/leagues_header.dart';
import '../widgets/standings_item.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key, this.competitionId});

  final int? competitionId;

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SoccerCubit>().getStandings(
        StandingsParams(
          leagueId: widget.competitionId ?? AppConstants.defaultLeagueId,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SoccerCubit>();
    final theme = Theme.of(context);

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        RectLeaguesHeader(
          leagues: cubit.availableLeagues,
          getFixtures: false,
          initialSelectedLeagueId:
              widget.competitionId ?? AppConstants.defaultLeagueId,
        ),
        SizedBox(height: 5.height),
        BlocBuilder<SoccerCubit, SoccerStates>(
          buildWhen: (previous, current) {
            return [
              SoccerStandingsLoaded,
              SoccerStandingsLoading,
              SoccerStandingsLoadFailure,
            ].contains(current.runtimeType);
          },
          builder: (context, state) {
            if (state is SoccerStandingsLoading) {
              return Center(
                child: LinearProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              );
            } else if (state is SoccerStandingsLoaded) {
              final groups = state.standings.groups ?? [];
              if (groups.isEmpty) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StandingsHeaders(),
                      SizedBox(height: 10.height),
                      ...List.generate(state.standings.standings.length, (
                        teamIndex,
                      ) {
                        final TeamRank team =
                            state.standings.standings[teamIndex];
                        return StandingsItem(
                          teamRank: team,
                          totalTeams: state.standings.standings.length,
                        );
                      }),
                      SizedBox(height: 10.height),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(groups.length, (groupIndex) {
                  final group = groups[groupIndex];
                  final groupTeams =
                      state.standings.standings
                          .where((team) => team.groupNum == group.number)
                          .toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.width,
                          vertical: 10.height,
                        ),
                        child: Text(
                          group.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.lightRed,
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const StandingsHeaders(),
                            SizedBox(height: 10.height),
                            ...List.generate(groupTeams.length, (teamIndex) {
                              final TeamRank team = groupTeams[teamIndex];
                              return StandingsItem(
                                teamRank: team,
                                totalTeams: groupTeams.length,
                                isGrouped: true,
                              );
                            }),
                            SizedBox(height: 20.height),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ],
    );
  }
}
