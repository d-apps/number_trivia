import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_reader.dart';

void main(){

  final tNumberTriviaModel = NumberTriviaModel(number: 1, text: "test");

  test(
      'should be a subclass of NumberTrivia entity',
  () async {
    // assert
    expect(tNumberTriviaModel, isA<NumberTrivia>());
  });

  group('fromJson', (){

    test('should retur a valid model the  the JSON number is an integer', (){

       final Map<String, dynamic> jsonMap = json.decode(fixtureTrivia());
       final result = NumberTriviaModel.fromJson(jsonMap);
       expect(result, tNumberTriviaModel);

    });

    test(
      'should return a valid model when the JSON number is regarded as a double',
          () async {
        // arrange
        final Map<String, dynamic> jsonMap = json.decode(fixtureTriviaDouble());
        // act
        final result = NumberTriviaModel.fromJson(jsonMap);
        // assert
        expect(result, tNumberTriviaModel);
      },
    );

  });

  group('toJson', (){

    test('should return a JSON map containing the proper data', (){

      final result = tNumberTriviaModel.toJson();
      final expectedJsonMap = {
        "text": "test",
        "number": 1,
      };
      expect(result, expectedJsonMap);

    });

  });

}