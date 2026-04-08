import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/league.dart';
import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/use_cases/day_fixtures_usecase.dart';
import '../../domain/use_cases/leagues_usecase.dart';
import '../../domain/use_cases/live_fixtures_usecase.dart';
import '../../domain/use_cases/standings_usecase.dart';
import 'soccer_state.dart';

class SoccerCubit extends Cubit<SoccerStates> {
  final CurrentRoundFixturesUseCase currentRoundFixturesUseCase;
  final LeaguesUseCase leaguesUseCase;
  final TodayFixturesUseCase todayFixturesUseCase;
  final StandingsUseCase standingUseCase;

  SoccerCubit({
    required this.currentRoundFixturesUseCase,
    required this.leaguesUseCase,
    required this.todayFixturesUseCase,
    required this.standingUseCase,
  }) : super(ScoreInitial());

  List<League> availableLeagues = [];
  DateTime selectedDate = DateTime.now();

  // In-memory cache: dateString → fixtures
  final Map<String, List<SoccerFixture>> _fixturesCache = {};
  CancelToken? _activeCancelToken;

  Future<void> initialize() async {
    // Run both initial calls in parallel to save time
    await Future.wait([
      getLeagues(),
      getFixturesForDate(),
    ]);
  }

  Future<List<League>> getLeagues() async {
    if (availableLeagues.isNotEmpty) return availableLeagues;

    emit(SoccerLeaguesLoading());
    final leagues = await leaguesUseCase(NoParams());
    leagues.fold((left) => emit(SoccerLeaguesLoadFailure(left.message)), (
      right,
    ) {
      availableLeagues = right;
      emit(SoccerLeaguesLoaded(availableLeagues));
    });
    return availableLeagues;
  }

  Future<void> getCurrentRoundFixtures({required int competitionId}) async {
    emit(SoccerCurrentRoundFixturesLoading());
    final fixtures = await currentRoundFixturesUseCase(competitionId);
    fixtures.fold(
      (left) => emit(
        SoccerCurrentRoundFixturesLoadFailure(
          left.message,
          competitionId: competitionId,
        ),
      ),
      (right) => emit(SoccerCurrentRoundFixturesLoaded(right)),
    );
  }

  Future<void> getFixturesForDate({
    DateTime? date,
    bool isTimerLoading = false,
  }) async {
    if (date != null) selectedDate = date;
    final dateStr = selectedDate.toIso8601String().split('T').first;

    // Cancel any in-flight request
    _activeCancelToken?.cancel('Date changed');
    _activeCancelToken = CancelToken();

    // Check in-memory cache first (skip for timer refreshes to get fresh data)
    if (!isTimerLoading && _fixturesCache.containsKey(dateStr)) {
      debugPrint('⚡ [Cubit] Cache hit for $dateStr (${_fixturesCache[dateStr]!.length} fixtures)');
      final cached = _fixturesCache[dateStr]!;
      final liveFixtures = cached.where((f) => f.status.isLive).toList();
      emit(SoccerTodayFixturesLoaded(
        todayFixtures: cached,
        liveFixtures: liveFixtures,
      ));
      return;
    }

    debugPrint('🔄 [Cubit] getFixturesForDate → selectedDate=$dateStr');
    print("Fetching fixtures for: $dateStr");
    emit(SoccerTodayFixturesLoading(isTimerLoading: isTimerLoading));

    final todayFixtures = await todayFixturesUseCase(selectedDate);
    todayFixtures.fold(
      (left) {
        debugPrint('❌ [Cubit] Fixtures load failed: ${left.message}');
        emit(SoccerTodayFixturesLoadFailure(left.message));
      },
      (right) {
        debugPrint('✅ [Cubit] Got ${right.length} fixtures for $dateStr');
        print("Got ${right.length} fixtures for: $dateStr");
        // Cache the result
        _fixturesCache[dateStr] = right;
        // Limit cache size to 7 days
        if (_fixturesCache.length > 7) {
          _fixturesCache.remove(_fixturesCache.keys.first);
        }
        final liveFixtures = right.where((fixture) => fixture.status.isLive);
        emit(
          SoccerTodayFixturesLoaded(
            todayFixtures: right,
            liveFixtures: liveFixtures.toList(),
          ),
        );
      },
    );
  }

  Future<void> getTodayFixtures({bool isTimerLoading = false}) async {
    return getFixturesForDate(isTimerLoading: isTimerLoading);
  }

  void goToPreviousDay() {
    final prev = selectedDate.subtract(const Duration(days: 1));
    debugPrint('⬅️ [Cubit] goToPreviousDay → ${prev.toIso8601String().split('T').first}');
    print("Date changed to: ${prev.toIso8601String().split('T').first}");
    getFixturesForDate(date: prev);
  }

  void goToNextDay() {
    final next = selectedDate.add(const Duration(days: 1));
    debugPrint('➡️ [Cubit] goToNextDay → ${next.toIso8601String().split('T').first}');
    print("Date changed to: ${next.toIso8601String().split('T').first}");
    getFixturesForDate(date: next);
  }

  Future<void> getStandings(StandingsParams params) async {
    emit(SoccerStandingsLoading());
    final standings = await standingUseCase(params);
    standings.fold(
      (left) => emit(SoccerStandingsLoadFailure(left.message)),
      (right) => emit(SoccerStandingsLoaded(right)),
    );
  }

  @override
  Future<void> close() {
    _activeCancelToken?.cancel('Cubit closed');
    _fixturesCache.clear();
    return super.close();
  }
}
