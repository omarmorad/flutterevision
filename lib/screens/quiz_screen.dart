import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../data/quiz_data.dart';
import '../widgets/quiz_timer.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  List<int> _selectedAnswers = [];
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List.filled(quizQuestions.length, -1);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _selectAnswer(int answerIndex) {
    if (_isAnswered) return;
    
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answerIndex;
      _isAnswered = true;
    });

    // Auto advance after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < quizQuestions.length - 1) {
      _slideController.reset();
      _fadeController.reset();
      
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
      });
      
      _slideController.forward();
      _fadeController.forward();
    } else {
      _finishQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _slideController.reset();
      _fadeController.reset();
      
      setState(() {
        _currentQuestionIndex--;
        _isAnswered = _selectedAnswers[_currentQuestionIndex] != -1;
      });
      
      _slideController.forward();
      _fadeController.forward();
    }
  }

  void _finishQuiz() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          selectedAnswers: _selectedAnswers,
          questions: quizQuestions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = quizQuestions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / quizQuestions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Flutter Quiz',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Timer
          QuizTimer(
            totalTimeInSeconds: 12 * 60, // 12 minutes
            onTimeUp: _finishQuiz,
          ),
          
          // Progress indicator
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${_currentQuestionIndex + 1}/${quizQuestions.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6C63FF),
                  ),
                  minHeight: 6,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Question and answers
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          currentQuestion.question,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                            height: 1.4,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Answer options
                      Expanded(
                        child: ListView.builder(
                          itemCount: currentQuestion.options.length,
                          itemBuilder: (context, index) {
                            final isSelected = _selectedAnswers[_currentQuestionIndex] == index;
                            final isCorrect = index == currentQuestion.correctAnswerIndex;
                            
                            Color backgroundColor = Colors.white;
                            Color borderColor = Colors.grey[300]!;
                            Color textColor = const Color(0xFF2D3748);
                            
                            if (_isAnswered) {
                              if (isSelected) {
                                backgroundColor = isCorrect 
                                    ? const Color(0xFF48BB78) 
                                    : const Color(0xFFE53E3E);
                                borderColor = backgroundColor;
                                textColor = Colors.white;
                              } else if (isCorrect) {
                                backgroundColor = const Color(0xFF48BB78);
                                borderColor = backgroundColor;
                                textColor = Colors.white;
                              }
                            } else if (isSelected) {
                              backgroundColor = const Color(0xFF6C63FF).withOpacity(0.1);
                              borderColor = const Color(0xFF6C63FF);
                            }
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _selectAnswer(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: borderColor, width: 2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: textColor.withOpacity(0.5),
                                              width: 2,
                                            ),
                                            color: isSelected ? textColor : Colors.transparent,
                                          ),
                                          child: isSelected
                                              ? Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: backgroundColor,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            currentQuestion.options[index],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                        if (_isAnswered && isCorrect)
                                          Icon(
                                            Icons.check_circle,
                                            color: textColor,
                                            size: 20,
                                          ),
                                        if (_isAnswered && isSelected && !isCorrect)
                                          Icon(
                                            Icons.cancel,
                                            color: textColor,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _previousQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isAnswered ? _nextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentQuestionIndex == quizQuestions.length - 1
                          ? 'Finish Quiz'
                          : 'Next Question',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}