import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/error/exception.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/implementations/number_trivia_local_data_source_impl.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/interfaces/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main(){

  late NumberTriviaLocalDataSource localDataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp((){
    mockSharedPreferences = MockSharedPreferences();
    localDataSource = NumberTriviaLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences
    );
  });

    group('getLastNumberTrivia', (){

      final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixtureTriviaCache()));

      test('should return NumberTrivia from SharedPreferences when there is one in the cache', 
              () async {

        when(() => mockSharedPreferences.getString(any()))
            .thenReturn(fixtureTriviaCache());
        
        final result = await localDataSource.getLastNumberTrivia();

        verify( ()=> mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
        expect(result, equals(tNumberTriviaModel));

      });

      test('should throw a CacheException when there is not a cached value', (){

        when(() => mockSharedPreferences.getString(any()))
              .thenReturn(null);

        // Not calling the method here, just storing it inside a call variable
        final call = localDataSource.getLastNumberTrivia;

        expect(() => call(), throwsA(TypeMatcher<CacheException>()));

      });



    });

    group('cacheNumberTrivia', (){

      final tNumberTriviaModel =
      NumberTriviaModel(number: 1, text: 'test');

      test('should call SharedPreferences to cache the data', (){

        localDataSource.cacheNumberTrivia(tNumberTriviaModel);

        final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
        verify(() => mockSharedPreferences.setString(CACHED_NUMBER_TRIVIA, expectedJsonString));


      });

    });



}