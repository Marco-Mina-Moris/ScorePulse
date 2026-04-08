import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:score_pulse/src/core/models/country_model.dart';
import 'package:score_pulse/src/core/utils/app_constants.dart';

import '../../../../core/api/dio_helper.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/domain/entities/league.dart';
import '../../../../core/models/league_model.dart';
import '../../../../core/models/soccer_fixture_model.dart';
import '../../domain/use_cases/standings_usecase.dart';
import '../models/standings_model.dart';

abstract class SoccerDataSource {
  Future<List<LeagueModel>> getLeagues();

  Future<List<SoccerFixtureModel>> getCurrentRoundFixtures({
    required int competitionId,
  });

  Future<List<SoccerFixtureModel>> getFixturesByDate({required DateTime date});

  Future<StandingsModel> getStandings({required StandingsParams params});
}

class SoccerDataSourceImpl implements SoccerDataSource {
  final DioHelper dioHelper;

  SoccerDataSourceImpl({required this.dioHelper});

  @override
  Future<List<SoccerFixtureModel>> getCurrentRoundFixtures({
    required int competitionId,
  }) async {
    try {
      final response = await dioHelper.get(
        url: Endpoints.currentRoundFixtures,
        queryParams: {'competitions': competitionId},
      );
      return _getResult(response);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<LeagueModel>> getLeagues() async {
    try {
      final response = await dioHelper.get(
        url: Endpoints.leagues,
        queryParams: {'competitions': AppConstants.availableLeagues.join(',')},
      );
      final List<dynamic> result = response.data['competitions'];
      final countries = List<CountryModel>.from(
        response.data['countries'].map((item) => CountryModel.fromJson(item)),
      );
      final leagues = List<LeagueModel>.from(
        result.map(
          (item) => LeagueModel.fromJson(
            item,
            country: countries.firstWhere(
              (country) => country.id == item['countryId'],
            ),
          ),
        ),
      );
      return leagues;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<SoccerFixtureModel>> getFixturesByDate({required DateTime date}) async {
    try {
      final now = DateTime.now();
      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
      final dateStr = date.toIso8601String().split('T').first;

      if (isToday) {
        debugPrint('📅 [ScorePulse] Fetching fixtures for TODAY ($dateStr) via 365Scores');
        final response = await dioHelper.get(
          url: Endpoints.todayFixtures,
          queryParams: {
            'sports': 1,
            'startDate': dateStr,
            'endDate': dateStr,
          },
        );

        final allGames = response.data['games'] as List?;
        debugPrint('📊 [ScorePulse] 365Scores API returned ${allGames?.length ?? 0} total games');

        // Parse on isolate for large responses (>50 games)
        final List<SoccerFixtureModel> fixtures;
        if (allGames != null && allGames.length > 50) {
          fixtures = await compute(_parseFixturesIsolate, allGames.cast<Map<String, dynamic>>());
        } else {
          fixtures = _getAllResults(response);
        }

        debugPrint('✅ [ScorePulse] Parsed ${fixtures.length} fixtures from 365Scores');
        return fixtures;
      } else {
        debugPrint('📅 [ScorePulse] Fetching fixtures for DATE $dateStr via API-Football');
        final fullUrl = '${Endpoints.apiFootballBaseUrl}${Endpoints.apiFootballFixtures}';
        final response = await dioHelper.get(
          url: fullUrl,
          queryParams: {
            'date': dateStr,
          },
          options: Options(
            headers: {
              'x-apisports-key': Endpoints.apiFootballKey,
            },
          ),
        );

        final responseArray = response.data['response'] as List?;
        debugPrint('📊 [ScorePulse] API-Football returned ${responseArray?.length ?? 0} total games');
        
        final List<SoccerFixtureModel> fixtures = [];
        if (responseArray != null) {
          for (var item in responseArray) {
            try {
              final fixture = SoccerFixtureModel.fromApiFootball(item);
              // Optionally filter by available leagues, or just return them all
              fixtures.add(fixture);
            } catch (e) {
              debugPrint('⚠️ [ScorePulse] Skipping API-Football fixture parse error: $e');
            }
          }
        }
        
        debugPrint('✅ [ScorePulse] Parsed ${fixtures.length} fixtures from API-Football');
        return fixtures;
      }
    } catch (error) {
      debugPrint('❌ [ScorePulse] Error fetching fixtures: $error');
      rethrow;
    }
  }

  @override
  Future<StandingsModel> getStandings({required StandingsParams params}) async {
    try {
      final response = await dioHelper.get(
        url: Endpoints.standings,
        queryParams: params.toJson(),
      );
      final List<dynamic> result = response.data['standings'];
      final StandingsModel standings =
          result.isNotEmpty
              ? StandingsModel.fromJson(result.first)
              : const StandingsModel(standings: []);
      return standings;
    } catch (error) {
      rethrow;
    }
  }

  /// Returns ALL games from the API response (no league filter).
  List<SoccerFixtureModel> _getAllResults(Response response) {
    final List<dynamic> result = response.data['games'];
    return _parseFixtures(result.cast<Map<String, dynamic>>());
  }

  /// Returns only games from tracked leagues.
  List<SoccerFixtureModel> _getResult(Response response) {
    final List<dynamic> result = response.data['games'];

    final List<SoccerFixtureModel> fixtures = [];
    for (var fixture in result) {
      final competitionId = fixture['competitionId'] as int?;
      if (competitionId == null ||
          !AppConstants.availableLeagues.contains(competitionId)) {
        continue;
      }
      try {
        final model = SoccerFixtureModel.fromJson(
          fixture,
          fixtureLeague: League.light(
            id: competitionId,
            name: fixture['competitionDisplayName'] ?? 'Unknown',
          ),
        );
        fixtures.add(model);
      } catch (e) {
        debugPrint('⚠️ [ScorePulse] Skipping fixture ${fixture['id']}: $e');
      }
    }
    return fixtures;
  }
}

/// Shared parsing logic — works both on main thread and isolate.
List<SoccerFixtureModel> _parseFixtures(List<Map<String, dynamic>> games) {
  final List<SoccerFixtureModel> fixtures = [];
  for (var fixture in games) {
    try {
      final competitionId = (fixture['competitionId'] as num?)?.toInt() ?? 0;
      final model = SoccerFixtureModel.fromJson(
        fixture,
        fixtureLeague: League.light(
          id: competitionId,
          name: fixture['competitionDisplayName'] ?? 'Unknown',
        ),
      );
      fixtures.add(model);
    } catch (e) {
      // Skip malformed fixtures silently in isolate
    }
  }
  return fixtures;
}

/// Top-level function for compute() — runs on separate isolate.
List<SoccerFixtureModel> _parseFixturesIsolate(List<Map<String, dynamic>> games) {
  return _parseFixtures(games);
}
