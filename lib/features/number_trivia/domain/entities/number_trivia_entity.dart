import 'package:equatable/equatable.dart';

class NumberTriviaEntity extends Equatable {

  final String text;
  final int number;

  NumberTriviaEntity({
    required this.text,
    required this.number,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [ text, number ];

}