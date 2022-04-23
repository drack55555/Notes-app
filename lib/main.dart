import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notesapp/constant/route.dart';
import 'package:notesapp/services/auth_service.dart';
import 'package:notesapp/views/login_view.dart';
import 'package:notesapp/views/notes/create_update_note_view.dart';
import 'package:notesapp/views/notes/notes_view.dart';
import 'package:notesapp/views/register_view.dart';
import 'package:notesapp/views/verify_email_view.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized(); //firebase suru mai he initialized hojayega 
  runApp(MaterialApp(               // onButtonPressed p initialize krne se phle and better 
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',        //way hai for case ki agar boht firebase related
      theme: ThemeData(             //onpressbutton hai to baar baar initialize ka
        primarySwatch: Colors.green,    //tension ni.
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context)=> const LoginView(),
        registerRoute: (context)=> const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}
    //All details for Register will be here in RegisterView.....
    //All details for Login will be here in LoginView.....


    //Now Homepage p he register and login ka rahega..login/register jo krna kro....
// class HomePage extends StatelessWidget {
//   const HomePage({ Key? key }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: AuthService.firebase().initialize(),            //register screen bnana tha(line 6 in MAIN.dart)...
//         builder: (context, snapshot) {      //ye phle hojao phir aage ka build kro  //jab future finished ho chuka work krna
//           switch(snapshot.connectionState){  
//             case ConnectionState.done:      //jab initialize ho chuka to kaam kro ab
//               final user= AuthService.firebase().currUser;
//               if(user != null){
//                 if(user.isEmailVerified){
//                   return const NotesView();
//                 }
//                 else{
//                   return const VerifyEmailView();
//                 }
//               }
//               else{
//                 return const LoginView();
//               }
//             default: return const CircularProgressIndicator();
//           }
          
//         }
//       );
//   }
// }



//             //agar ye 'this' ni daalenge to error dega dart because hmlog phone button use kr k boolean return 
//             // type ko bool return krne se rok rhe hai to mtlb bool return ni ho rha so kaise function ko
//             // bool return type diye hai...so to solve this issue we use 'this'....


class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _controller;

  @override
  void initState() { //in init state we intantiate our Controller..
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
      _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Testing bloc'),
        ),
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: (context, state) {
            _controller.clear();
          },
          builder: (context, state) {
            final invalidValue = (state is CounterStateInvalidNumber) ? state.invalidValue : '';
            return Column(
              children: [
                Text('Current Value => ${state.value}'),
                Visibility(   // control the visibility of that error msg ...
                  child: Text('Invalid Input: $invalidValue') ,
                  visible: state is CounterStateInvalidNumber,
                ), 
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Enter a number here'),
                  keyboardType:   TextInputType.number,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: (){
                        context.read<CounterBloc>().add(DecrementEvent(_controller.text));
                      },
                      child: const Text('-'),
                    ),
                    TextButton(
                      onPressed: (){
                        context.read<CounterBloc>().add(IncrementEvent(_controller.text));
                      },
                      child: const Text('+'),
                    ),
                  ],
                ),
              ],
            );
          },
        )
      ),
    );  
  }


}

@immutable //basic state for bloc..and we'll use 2 substate in it for actual bloc..
abstract class CounterState{
  final int value;
  const CounterState(this.value);
}

class CounterStateValid extends CounterState{
  const  CounterStateValid(int value) : super(value); 

}


class CounterStateInvalidNumber extends CounterState{
  final String invalidValue;

  const  CounterStateInvalidNumber({
    required this.invalidValue,
    required int previousValue,
  }): super(previousValue); 
}

@immutable
abstract class CounterEvent{
  final String value;
  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent{
  const IncrementEvent(String value) : super(value);

}

class DecrementEvent extends CounterEvent{
  const DecrementEvent(String value) : super(value);

}


class CounterBloc extends Bloc<CounterEvent, CounterState>{
  CounterBloc() : super(const CounterStateValid(0)){
    on<IncrementEvent>( (event, emit) {
      final interger = int.tryParse(event.value);
      if(interger == null){
        emit(CounterStateInvalidNumber(invalidValue: event.value, previousValue: state.value));
      }
      else {
        emit(CounterStateValid(state.value + interger));
      }
    });

    on<DecrementEvent>( (event, emit) {
      final interger = int.tryParse(event.value);
      if(interger == null){
        emit(CounterStateInvalidNumber(invalidValue: event.value, previousValue: state.value));
      }
      else {
        emit(CounterStateValid(state.value - interger));
      }
    });
  }
}