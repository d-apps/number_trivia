import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:number_trivia/core/network/network_info.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/implementations/number_trivia_remote_data_source_impl.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/interfaces/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/number_trivia/data/datasources/implementations/number_trivia_local_data_source_impl.dart';
import 'features/number_trivia/data/datasources/interfaces/number_trivia_local_data_source.dart';
import 'package:http/http.dart' as http;

final sl = GetIt.instance;

Future<void> init() async {

  //! Features - Number Trivia
  // Bloc
  sl.registerFactory(() => NumberTriviaBloc(
      getRandomNumberTrivia: sl(),
      getConcreteNumberTrivia: sl(),
      inputConverter: sl()
  ));
  // Use cases
  sl.registerLazySingleton(() => GetConcreteNumberTrivia(sl()));
  sl.registerLazySingleton(() => GetRandomNumberTrivia(sl()));
  // Repository
  sl.registerLazySingleton<NumberTriviaRepository>(() => NumberTriviaRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl()
  ));
  // Data sources
  sl.registerLazySingleton<NumberTriviaRemoteDataSource>(() => NumberTriviaRemoteDataSourceImpl(client: sl()));
  sl.registerLazySingleton<NumberTriviaLocalDataSource>(() => NumberTriviaLocalDataSourceImpl(sharedPreferences: sl()));

  //! Core
  sl.registerLazySingleton(() => InputConverter());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(connectionChecker: sl()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());

}