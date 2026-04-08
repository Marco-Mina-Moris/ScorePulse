import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/domain/entities/league.dart';
import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/domain/mappers/mappers.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/response_status.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/standings.dart';
import '../../domain/repositories/soccer_repository.dart';
import '../../domain/use_cases/standings_usecase.dart';
import '../datasources/soccer_data_source.dart';

class SoccerRepositoryImpl implements SoccerRepository {
  final SoccerDataSource soccerDataSource;
  final NetworkInfo networkInfo;

  SoccerRepositoryImpl({
    required this.soccerDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<SoccerFixture>>> getCurrentRoundFixtures({
    required int competitionId,
  }) async {
    try {
      final result = await soccerDataSource.getCurrentRoundFixtures(
        competitionId: competitionId,
      );
      final List<SoccerFixture> fixtures =
          result.map((fixture) => fixture.toDomain()).toList();
      return Right(fixtures);
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionError || 
          error.type == DioExceptionType.connectionTimeout) {
        return Left(DataSource.networkConnectError.getFailure());
      }
      return Left(ErrorHandler.handle(error).failure);
    } catch (error) {
      return Left(Failure(code: -1, message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<League>>> getLeagues() async {
    try {
      final result = await soccerDataSource.getLeagues();
      final List<League> leagues =
          result.map((league) => league.toDomain()).toList();
      return Right(leagues);
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionError || 
          error.type == DioExceptionType.connectionTimeout) {
        return Left(DataSource.networkConnectError.getFailure());
      }
      return Left(ErrorHandler.handle(error).failure);
    } catch (error) {
      return Left(Failure(code: -1, message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SoccerFixture>>> getFixturesByDate({
    required DateTime date,
  }) async {
    try {
      final result = await soccerDataSource.getFixturesByDate(date: date);
      final List<SoccerFixture> fixtures =
          result.map((fixture) => fixture.toDomain()).toList();
      return Right(fixtures);
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionError || 
          error.type == DioExceptionType.connectionTimeout) {
        return Left(DataSource.networkConnectError.getFailure());
      }
      return Left(ErrorHandler.handle(error).failure);
    } catch (error) {
      return Left(Failure(code: -1, message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, Standings>> getStandings({
    required StandingsParams params,
  }) async {
    try {
      final result = await soccerDataSource.getStandings(params: params);
      final Standings standings = result;
      return Right(standings);
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionError || 
          error.type == DioExceptionType.connectionTimeout) {
        return Left(DataSource.networkConnectError.getFailure());
      }
      return Left(ErrorHandler.handle(error).failure);
    } catch (error) {
      return Left(Failure(code: -1, message: error.toString()));
    }
  }
}
