import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_state.dart';
import '../../../../injection_container.dart';
import 'widgets/widgets.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Number Trivia"),
        centerTitle: true,
      ),
      body: BlocProvider<NumberTriviaBloc>(
        create: (context) => sl<NumberTriviaBloc>(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // Top
                  BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                    builder: (context, state) {

                      if (state is EmptyState) {
                        return MessageDisplay(message: 'Start searching!');
                      }

                      else if(state is ErrorState){

                        return MessageDisplay(message: state.message);

                      } else if(state is LoadingState){

                        return LoadingWidget();

                      } else if(state is LoadedState) {

                        return TriviaDisplay(numberTrivia: state.trivia);

                      } else {
                        return SizedBox.shrink();
                      }

                    },
                  ),

                  const SizedBox(height: 10,),

                  // Bottom half
                  TriviaControls(),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}



