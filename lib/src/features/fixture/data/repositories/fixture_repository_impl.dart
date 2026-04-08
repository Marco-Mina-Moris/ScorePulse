import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:score_pulse/src/features/fixture/domain/entities/fixture_details.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/response_status.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/statistics.dart';
import '../../domain/repositories/fixture_repository.dart';
import '../data_sources/fixture_data_source.dart';

class FixtureRepositoryImpl implements FixtureRepository {
  final NetworkInfo networkInfo;
  final FixtureDataSource fixtureDataSource;

  FixtureRepositoryImpl({
    required this.networkInfo,
    required this.fixtureDataSource,
  });

  @override
  Future<Either<Failure, FixtureDetails>> getFixtureDetails(
    int fixtureId,
  ) async {
    try {
      final result = await fixtureDataSource.getFixtureDetails(fixtureId);
      return Right(result);
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
  Future<Either<Failure, Statistics>> getStatistics(int fixtureId) async {
    try {
      final result = await fixtureDataSource.getStatistics(fixtureId);
      return Right(result);
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
