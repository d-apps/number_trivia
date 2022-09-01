
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/network/network_info.dart';

class MockInternetConnectionChecker extends Mock implements InternetConnectionChecker {}

void main(){
  late NetworkInfoImpl networkInfo;
  late MockInternetConnectionChecker mockInternetConnectionChecker;

  setUp((){
    mockInternetConnectionChecker = MockInternetConnectionChecker();
    networkInfo = NetworkInfoImpl(connectionChecker: mockInternetConnectionChecker);
  });

  group('isConnected', (){

    test('should forward the call to DataConnectionChecker.hasConnection',
            () async {

            final tHasConnectionFuture = Future.value(true);

            when( () => mockInternetConnectionChecker.hasConnection)
              .thenAnswer((_) => tHasConnectionFuture);

            // NOTICE: We're NOT awaiting the result
            final result = networkInfo.isConnected;

            verify( () => mockInternetConnectionChecker.hasConnection);

              // Utilizing Dart's default referential equality.
              // Only references to the same object are equal.
              expect(result, tHasConnectionFuture);

            });


  });

}