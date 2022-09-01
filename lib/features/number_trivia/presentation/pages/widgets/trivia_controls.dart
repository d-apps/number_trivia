import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_event.dart';

class TriviaControls extends StatelessWidget {

  TriviaControls({Key? key}): super(key: key);

  final controller = TextEditingController();
  String inputStr = "";

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Input a number"
          ),
          onChanged: (v) => inputStr = v,
          onSubmitted: (_) => dispatchConcrete(context),
        ),

        const SizedBox(height: 10),

        Row(
          children: [

            Expanded(
              child: ElevatedButton(
                child: Text('Search'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Theme.of(context).accentColor),
                ),
                onPressed: () => dispatchConcrete(context),
              ),
            ),

            const SizedBox(width: 10,),

            Expanded(
              child: ElevatedButton(
                child: Text('Get random trivia'),
                onPressed: () => dispatchRandom(context),
              ),
            )

          ],
        )

      ],
    );
  }

  void dispatchConcrete(BuildContext context) {

    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context)
      .add(GetTriviaForConcreteNumberEvent(inputStr));

  }

  void dispatchRandom(BuildContext context){

    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context)
        .add(GetTriviaForRandomNumberEvent());

  }

}
