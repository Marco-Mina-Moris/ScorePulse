import 'package:score_pulse/src/container_injector.dart';
import 'package:score_pulse/src/core/api/dio_helper.dart';
import 'package:score_pulse/src/core/network/network_info.dart';
import 'package:score_pulse/src/features/soccer/data/datasources/soccer_data_source.dart';
import 'package:score_pulse/src/features/soccer/data/repositories/soccer_repository_impl.dart';
import 'package:score_pulse/src/features/soccer/domain/use_cases/day_fixtures_usecase.dart';
import 'package:score_pulse/src/features/soccer/domain/use_cases/leagues_usecase.dart';
import 'package:score_pulse/src/features/soccer/domain/use_cases/live_fixtures_usecase.dart';
import 'package:score_pulse/src/features/soccer/domain/use_cases/standings_usecase.dart';
import 'package:score_pulse/src/features/soccer/presentation/cubit/soccer_cubit.dart';


void initSoccer() {
  sl.registerLazySingleton<SoccerDataSourceImpl>(
    () => SoccerDataSourceImpl(dioHelper: sl<DioHelper>()),
  );
  sl.registerLazySingleton<SoccerRepositoryImpl>(
    () => SoccerRepositoryImpl(
      networkInfo: sl<NetworkInfoImpl>(),
      soccerDataSource: sl<SoccerDataSourceImpl>(),
    ),
  );
  sl.registerLazySingleton<CurrentRoundFixturesUseCase>(
    () => CurrentRoundFixturesUseCase(
      soccerRepository: sl<SoccerRepositoryImpl>(),
    ),
  );
  sl.registerLazySingleton<LeaguesUseCase>(
    () => LeaguesUseCase(
      soccerRepository: sl<SoccerRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<TodayFixturesUseCase>(
    () => TodayFixturesUseCase(
      soccerRepository: sl<SoccerRepositoryImpl>(),
    ),
  );
  sl.registerLazySingleton<StandingsUseCase>(
    () => StandingsUseCase(
      soccerRepository: sl<SoccerRepositoryImpl>(),
    ),
  );
  sl.registerFactory<SoccerCubit>(
    () => SoccerCubit(
      currentRoundFixturesUseCase: sl<CurrentRoundFixturesUseCase>(),
      leaguesUseCase: sl<LeaguesUseCase>(),
      todayFixturesUseCase: sl<TodayFixturesUseCase>(),
      standingUseCase: sl<StandingsUseCase>(),
    ),
  );
}
