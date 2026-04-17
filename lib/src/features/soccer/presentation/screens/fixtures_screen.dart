import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:score_pulse/src/core/extensions/nums.dart';

import '../cubit/soccer_cubit.dart';
import '../cubit/soccer_state.dart';
import '../widgets/grouped_fixtures_list.dart';
import '../widgets/leagues_header.dart';
import '../widgets/no_fixtures_today.dart';

class FixturesScreen extends StatefulWidget {
  const FixturesScreen({super.key, this.competitionId});

  final int? competitionId;

  @override
  State<FixturesScreen> createState() => _FixturesScreenState();
}

class _FixturesScreenState extends State<FixturesScreen> {
  int? initialSelectedLeagueId;

  @override
  void initState() {
    super.initState();
    initialSelectedLeagueId = widget.competitionId;
    final availableLeagues = context.read<SoccerCubit>().availableLeagues;
    if (availableLeagues.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialSelectedLeagueId == null) {
        context.read<SoccerCubit>().getTodayFixtures();
      } else {
        context.read<SoccerCubit>().getCurrentRoundFixtures(
          competitionId: initialSelectedLeagueId!,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final SoccerCubit cubit = context.read<SoccerCubit>();
    final theme = Theme.of(context);

    return BlocBuilder<SoccerCubit, SoccerStates>(
      buildWhen: (previous, current) {
        return [
          SoccerTodayFixturesLoading,
          SoccerTodayFixturesLoadFailure,
          SoccerTodayFixturesLoaded,
          SoccerCurrentRoundFixturesLoading,
          SoccerCurrentRoundFixturesLoadFailure,
          SoccerCurrentRoundFixturesLoaded,
        ].contains(current.runtimeType);
      },
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            RectLeaguesHeader(
              leagues: cubit.availableLeagues,
              getFixtures: true,
              initialSelectedLeagueId: initialSelectedLeagueId,
              prefixIcon: _getPrefixIcon(theme),
              onPrefixIconTap: context.read<SoccerCubit>().getTodayFixtures,
            ),
            SizedBox(height: 10.height),
            if (state is SoccerCurrentRoundFixturesLoading ||
                state is SoccerTodayFixturesLoading)
              LinearProgressIndicator(color: theme.colorScheme.primary)
            else if (state is SoccerCurrentRoundFixturesLoaded &&
                state.fixtures.isNotEmpty)
              Expanded(
                child: GroupedFixturesList(
                  fixtures: state.fixtures,
                  showLeagueLogo: true,
                ),
              )
            else if (state is SoccerTodayFixturesLoaded &&
                state.todayFixtures.isNotEmpty)
              Expanded(
                child: GroupedFixturesList(
                  fixtures: state.todayFixtures,
                  showLeagueLogo: true,
                ),
              )
            else if (state is SoccerCurrentRoundFixturesLoaded &&
                state.fixtures.isEmpty)
              const NoFixturesView()
            else if (state is SoccerTodayFixturesLoaded &&
                state.todayFixtures.isEmpty)
              const NoFixturesView()
            else
              const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Widget _getPrefixIcon(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
        ),
        border: Border.all(color: theme.colorScheme.surface, width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(Icons.public, color: theme.colorScheme.onPrimary),
    );
  }
}
