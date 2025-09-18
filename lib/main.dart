import 'package:flutter/material.dart';
import './question.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  var _questionIndex = 0;
  late final List<String> questions; // Declare with 'late'
  
  @override
  void initState() {
    super.initState();
    questions = const [
      'What\'s your favorite color?',
      'What\'s your favorite animal?',
      'What\'s your favorite instructor?',
    ];
  }

  void _answerQuestion() {
    setState(() {
      if (_questionIndex < questions.length - 1) {
        _questionIndex = _questionIndex + 1;
      } else {
        _questionIndex = 0; // Reset or handle end of questions
      }
    });
    print('Answer chosen');
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('First Demo App')),
        body: Column(
          children: [
            Question(questions[_questionIndex]),
            ElevatedButton(
              child: const Text('Answer 1'),
              onPressed: () {
                _answerQuestion();
                print('Answer 1 chosen');
              },
            ),
            ElevatedButton(
              child: const Text('Answer 2'),
              onPressed: () {
                _answerQuestion();
                print('Answer 2 chosen');
              },
            ),
            ElevatedButton(
              child: const Text('Answer 3'),
              onPressed: () {
                _answerQuestion();
                print('Answer 3 chosen');
              },
            ),
          ],
        ),
      ),
    );
  }
}
