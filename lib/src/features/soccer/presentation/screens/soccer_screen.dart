import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:score_pulse/src/core/extensions/nums.dart';
import 'package:score_pulse/src/features/soccer/presentation/widgets/error_dialog.dart';
import 'package:score_pulse/src/features/soccer/presentation/widgets/no_fixtures_today.dart';

import '../../../../core/widgets/shimmer_loading.dart';
import '../cubit/soccer_cubit.dart';
import '../cubit/soccer_state.dart';
import '../widgets/date_navigator.dart';
import '../widgets/view_fixtures.dart';

class SoccerScreen extends StatefulWidget {
  const SoccerScreen({super.key});

  @override
  State<SoccerScreen> createState() => _SoccerScreenState();
}

class _SoccerScreenState extends State<SoccerScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  void _activateTimerFetching() {
    _timer ??= Timer.periodic(const Duration(minutes: 1), (timer) {
      context.read<SoccerCubit>().getFixturesForDate(isTimerLoading: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SoccerCubit, SoccerStates>(
      listener: (context, state) {
        if (state is SoccerCurrentRoundFixturesLoadFailure) {
          ErrorDialog.show(
            context: context,
            message: state.message,
            onRetry: () {
              if (state.competitionId != null) {
                context.read<SoccerCubit>().getCurrentRoundFixtures(
                  competitionId: state.competitionId!,
                );
              }
            },
          );
        }
        if (state is SoccerTodayFixturesLoadFailure) {
          ErrorDialog.show(
            context: context,
            message: state.message,
            onRetry: context.read<SoccerCubit>().getTodayFixtures,
          );
        }
        if (state is SoccerLeaguesLoadFailure) {
          ErrorDialog.show(
            context: context,
            message: state.message,
            onRetry: context.read<SoccerCubit>().getLeagues,
          );
        }
        if (state is SoccerTodayFixturesLoaded) {
          if (state.liveFixtures.isNotEmpty) {
            _activateTimerFetching();
          } else {
            _timer?.cancel();
          }
        }
      },
      child: RefreshIndicator(
        onRefresh: context.read<SoccerCubit>().getTodayFixtures,
        child: BlocBuilder<SoccerCubit, SoccerStates>(
          buildWhen: (context, state) {
            if (state is SoccerTodayFixturesLoading && !state.isTimerLoading) {
              return true;
            }
            return [
              SoccerTodayFixturesLoaded,
              SoccerTodayFixturesLoadFailure,
            ].contains(state.runtimeType);
          },
          builder: (context, state) {
            int fixtureCount = 0;
            if (state is SoccerTodayFixturesLoaded) {
              fixtureCount = state.todayFixtures.length;
            }
            print("UI rebuilding with: $fixtureCount fixtures");
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 20,
                      end: 20,
                      top: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DateNavigator(),
                        const SizedBox(height: 20),
                        if (state is SoccerTodayFixturesLoading)
                          const FixtureShimmerList(),
                        if (state is SoccerTodayFixturesLoaded &&
                            state.todayFixtures.isEmpty)
                          const NoFixturesView(),
                        if (state is SoccerTodayFixturesLoaded &&
                            state.liveFixtures.isNotEmpty) ...[
                          ViewLiveFixtures(fixtures: state.liveFixtures),
                          SizedBox(height: 10.height),
                        ],
                      ],
                    ),
                  ),
                ),
                if (state is SoccerTodayFixturesLoaded &&
                    state.todayFixtures.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 20,
                      end: 20,
                      bottom: 20,
                    ),
                    sliver: ViewDayFixtures(fixtures: state.todayFixtures),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
