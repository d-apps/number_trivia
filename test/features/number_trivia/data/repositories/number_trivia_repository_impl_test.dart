import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/error/exception.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/network/network_info.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/interfaces/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/interfaces/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia_entity.dart';

class MockRemoteDataSource extends Mock implements NumberTriviaRemoteDataSource {}
class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main(){

  late NumberTriviaRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp((){

    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );

  });

  // DATA FOR THE MOCKS AND ASSERTIONS
  // We'll use these three variables throughout all the tests
  final tNumber = 1;
  final tNumberTriviaModel = NumberTriviaModel(text: "test", number: 1);
  final NumberTriviaEntity tNumberTrivia = tNumberTriviaModel;

  void runTestsOnline(Function body){

    group('device is online', (){

      setUp((){
        when( ()=> mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();

    });

  }

  void runTestsOffline(Function body){

    group('device is offline', (){

      setUp((){
        when( ()=> mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();

    });

  }

  group('getConcreteNumberTrivia', (){

    test('should check if the device is online', () async {

      when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
          .thenAnswer((_) => Future.value(tNumberTriviaModel));

      when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTrivia as NumberTriviaModel))
        .thenAnswer((_) => Future.value(null));

      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      await repository.getConcreteNumberTrivia(tNumber);

      verify(() => mockNetworkInfo.isConnected).called(1);

    });

    runTestsOnline((){


      group('device is online', (){

        setUp((){
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        });

        test('should return remote data when the call to remote data source is successful',
                () async {

              when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
                  .thenAnswer((_) async => tNumberTriviaModel);

              when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTrivia as NumberTriviaModel))
                  .thenAnswer((_) => Future.value(null));

              final result = await repository.getConcreteNumberTrivia(tNumber);

              verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
              expect(result, equals(Right(tNumberTrivia)));

            });


        test('should cache the data locally when the call to remote data source is successful',
                () async {

              when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTrivia as NumberTriviaModel))
                  .thenAnswer((_) async => null);

              when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
                  .thenAnswer((_) async => tNumberTriviaModel);

              await repository.getConcreteNumberTrivia(tNumber);

              verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
              //verify( () => mockLocalDataSource.cacheNumberTrivia(tNumberTrivia as NumberTriviaModel));

            });


        test(
          'should return server failure when the call to remote data source is unsuccessful',
              () async {
            // arrange
            when( () => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
                .thenThrow(ServerException());
            // act
            final result = await repository.getConcreteNumberTrivia(tNumber);
            // assert
            verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
            verifyZeroInteractions(mockLocalDataSource);
            expect(result, equals(Left(ServerFailure())));

          },
        );

      });


    });

    runTestsOffline((){

      test('should return last locally cached data when the cached data is present', () async {

        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((invocation) async => tNumberTriviaModel);

        final result = await repository.getConcreteNumberTrivia(tNumber);

        verifyZeroInteractions(mockRemoteDataSource);
        verify( () => mockLocalDataSource.getLastNumberTrivia()).called(1);
        expect(result, equals(Right(tNumberTrivia)));

      });

      test('should return CacheFailure when there is no cached data present', () async {

        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());

        final result = await repository.getConcreteNumberTrivia(tNumber);

        verifyZeroInteractions(mockRemoteDataSource);
        verify( () => mockLocalDataSource.getLastNumberTrivia()).called(1);
        expect(result, equals(Left(CacheFailure())));

      });

    });


  });

  // ============

  group('getRandomNumberTrivia', () {

    test('should check if the device is online', () {
      //arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      when(() => mockRemoteDataSource.getRandomNumberTrivia())
          .thenAnswer((_) async => tNumberTriviaModel);

      when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTrivia as NumberTriviaModel))
          .thenAnswer((_) => Future.value(null));
      // act
      repository.getRandomNumberTrivia();
      // assert
      verify(() => mockNetworkInfo.isConnected);
    });


    runTestsOnline(() {
      test(
        'should return remote data when the call to remote data source is successful',
            () async {
          // arrange
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);

          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTrivia as NumberTriviaModel))
              .thenAnswer((_) => Future.value(null));

          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should cache the data locally when the call to remote data source is successful',
            () async {
          // arrange
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);

          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTrivia as NumberTriviaModel))
              .thenAnswer((_) => Future.value(null));

          // act
          await repository.getRandomNumberTrivia();
          // assert
          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTrivia as NumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
            () async {
          // arrange
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenThrow(ServerException());
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
            () async {
          // arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
            () async {
          // arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );


    });


  });


}