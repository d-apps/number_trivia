import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/error/exception.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/implementations/number_trivia_remote_data_source_impl.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/interfaces/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main(){

  late NumberTriviaRemoteDataSourceImpl remoteDataSource;
  late MockHttpClient mockHttpClient;

  setUp((){

    mockHttpClient = MockHttpClient();
    remoteDataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);

  });

  final tNumber = 1;
  final concreteUrl = 'http://numbersapi.com/$tNumber';
  final randomUrl = 'http://numbersapi.com/random';

  final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixtureTrivia()));

  void setUpMockHttpClientSuccess200(String url) {
    when(() => mockHttpClient.get(Uri.parse(url), headers: any(named: 'headers'))).thenAnswer(
          (_) async => http.Response(fixtureTrivia(), 200),
    );
  }

  void setUpMockHttpClientFailure404(String url) {
    when(() => mockHttpClient.get(Uri.parse(url), headers: any(named: 'headers'))).thenAnswer(
          (_) async => http.Response('Something went wrong', 404),
    );
  }

  group('getConcreteNumberTrivia', (){

    test('should preform a GET request on a URL with number being the endpoint and with application/json header', (){

      setUpMockHttpClientSuccess200(concreteUrl);

      remoteDataSource.getConcreteNumberTrivia(tNumber);

      verify( () => mockHttpClient.get(
        Uri.parse(concreteUrl),
        headers: {'Content-Type': 'application/json'},
      ));


    });

    test('should return NumberTrivia when the response code is 200 (success)', () async {

      setUpMockHttpClientSuccess200(concreteUrl);

      final result = await remoteDataSource.getConcreteNumberTrivia(tNumber);

      expect(result, equals(tNumberTriviaModel));


    });

    test('should throw a ServerException when the response code is 404 or other', (){

      setUpMockHttpClientFailure404(concreteUrl);

      final call = remoteDataSource.getConcreteNumberTrivia;

      expect( () => call(tNumber), throwsA(TypeMatcher<ServerException>()));

    });

  });

  group('getRandomNumberTrivia', (){

    test('should preform a GET request on a URL with number being the endpoint and with application/json header', (){

      setUpMockHttpClientSuccess200(randomUrl);

      remoteDataSource.getRandomNumberTrivia();

      verify( () => mockHttpClient.get(
        Uri.parse(randomUrl),
        headers: {'Content-Type': 'application/json'},
      ));


    });

    test('should return NumberTrivia when the response code is 200 (success)', () async {

      setUpMockHttpClientSuccess200(randomUrl);

      final result = await remoteDataSource.getRandomNumberTrivia();

      expect(result, equals(tNumberTriviaModel));


    });

    test('should throw a ServerException when the response code is 404 or other', (){

      setUpMockHttpClientFailure404(randomUrl);

      final call = remoteDataSource.getRandomNumberTrivia;

      expect( () => call(), throwsA(TypeMatcher<ServerException>()));

    });

  });

}