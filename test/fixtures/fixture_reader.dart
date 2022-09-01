import 'dart:io';

String fixtureTrivia() => File('test/fixtures/trivia.json').readAsStringSync();
String fixtureTriviaDouble() => File('test/fixtures/trivia_double.json').readAsStringSync();
String fixtureTriviaCache() => File('test/fixtures/trivia_cache.json').readAsStringSync();