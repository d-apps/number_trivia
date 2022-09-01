import 'package:equatable/equatable.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

abstract class NumberTriviaState extends Equatable {

  final List p;
  NumberTriviaState([this.p = const []]);

  @override
  // TODO: implement props
  List<Object?> get props => p;
}

class EmptyState extends NumberTriviaState {}
class LoadingState extends NumberTriviaState {}

class LoadedState extends NumberTriviaState {

  final NumberTrivia trivia;

  LoadedState({required this.trivia}) : super([trivia]);
}

class ErrorState extends NumberTriviaState {

  final String message;

  ErrorState({required this.message}): super([message]);
}