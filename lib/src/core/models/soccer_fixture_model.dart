import 'package:score_pulse/src/core/domain/entities/league.dart';
import 'package:score_pulse/src/core/domain/mappers/mappers.dart';

import '../domain/entities/soccer_fixture.dart';
import 'teams_model.dart';

class SoccerFixtureModel extends SoccerFixture {
  const SoccerFixtureModel({
    required super.id,
    required super.teams,
    required super.statusText,
    required super.gameTimeAndStatusDisplayType,
    required super.fixtureLeague,
    super.startTime,
    super.gameTime,
    super.addedTime,
    super.gameTimeDisplay = '',
    super.roundNum,
    super.stageNum,
    super.seasonNum,
  });

  factory SoccerFixtureModel.fromJson(
    Map<String, dynamic> json, {
    required League fixtureLeague,
  }) => SoccerFixtureModel(
    id: json['id'],
    teams: TeamsModel.fromJson(json).toDomain(),
    fixtureLeague: fixtureLeague,
    statusText: json['statusText'] ?? '',
    gameTimeAndStatusDisplayType:
        (json['gameTimeAndStatusDisplayType'] as num).toInt(),
    startTime: json['startTime'] != null ? DateTime.tryParse(json['startTime']) : null,
    gameTime: (json['gameTime'] as num?)?.toInt(),
    addedTime: (json['addedTime'] as num?)?.toInt(),
    gameTimeDisplay: json['gameTimeDisplay'] ?? '',
    roundNum: json['roundNum'],
    stageNum: json['stageNum'],
    seasonNum: json['seasonNum'],
  );

  factory SoccerFixtureModel.fromApiFootball(Map<String, dynamic> json) {
    final statusShort = json['fixture']['status']['short'] ?? '';
    final elapsed = (json['fixture']['status']['elapsed'] as num?)?.toInt();
    
    return SoccerFixtureModel(
      id: json['fixture']['id'],
      teams: TeamsModel.fromApiFootball(json).toDomain(),
      fixtureLeague: League.light(
        id: json['league']['id'],
        name: json['league']['name'] ?? 'Unknown',
      ),
      statusText: statusShort,
      gameTimeAndStatusDisplayType: 1,
      startTime: json['fixture']['date'] != null ? DateTime.tryParse(json['fixture']['date']) : null,
      gameTime: elapsed,
      gameTimeDisplay: elapsed != null ? "$elapsed'" : statusShort,
    );
  }
}
