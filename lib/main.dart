import 'package:flutter/material.dart';
import './question.dart';
import './answer.dart';

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
  final _questions = const [{
    'text': 'What\'s your favorite color?',
    'answers': ['Black', 'Red', 'Green', 'Blue'],
  },
  {
    'text': 'What\'s your favorite animal?',
    'answers': ['Rabbit', 'Snake', 'Elephant', 'Lion'],
  },
  {
    'text': 'What\'s your favorite instructor?',
    'answers': ['Max', 'Manu', 'Angela', 'Stephen'],
  },
  {
    'text': 'What\'s your favorite food?',
    'answers': ['Pizza', 'Burger', 'Salad', 'Pasta'],
  },
  ];

  void _answerQuestion() {
    setState(() {
      if (_questionIndex < _questions.length - 1) {
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
            Question(_questions[_questionIndex]['text'] as String),
            ...(_questions[_questionIndex]['answers'] as List<String>)
                .map((answer) {
              return Answer(_answerQuestion, answer);
            }).toList(),
          ],
        ),
      ),
    );
  }
}
