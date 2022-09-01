import 'package:equatable/equatable.dart';

abstract class NumberTriviaEvent extends Equatable {

  final List p;
  NumberTriviaEvent(this.p);

  @override
  // TODO: implement props
  List<Object?> get props => p;

}

class GetTriviaForConcreteNumberEvent extends NumberTriviaEvent {

  final String numberString;
  GetTriviaForConcreteNumberEvent(this.numberString) : super([numberString]);

}

class GetTriviaForRandomNumberEvent extends NumberTriviaEvent {
  GetTriviaForRandomNumberEvent(): super([]);
}