import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/soccer_repository.dart';

class TodayFixturesUseCase implements UseCase<List<SoccerFixture>, DateTime> {
  final SoccerRepository soccerRepository;

  TodayFixturesUseCase({required this.soccerRepository});

  @override
  Future<Either<Failure, List<SoccerFixture>>> call(DateTime date) async {
    return await soccerRepository.getFixturesByDate(date: date);
  }
}
