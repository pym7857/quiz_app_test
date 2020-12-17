import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:quiz_app_test/model/model_quiz.dart';
import 'package:quiz_app_test/screen/screen_result.dart';
import 'package:quiz_app_test/widget/widget_candidate.dart';

class QuizScreen extends StatefulWidget {
  List<Quiz> quizs;
  QuizScreen({this.quizs}); // 생성자를 통해 이전 화면으로부터 퀴즈 데이터를 넘겨받습니다.

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<int> _answers = [-1, -1, -1]; // 정답. 3문제니까 3개
  List<bool> _answerState = [false, false, false, false]; // 퀴즈 하나에 대하여 각 선택지가 선택되었는지를 bool형태로 기록하는 리스트.
  int _currentIndex = 0; // 현재 어떤 문제를 보고있는지
  SwiperController _controller = SwiperController(); // SwiperController: 다음문제로 넘어갈 수 있게 해주는 Controller

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size; // 미디어 쿼리를 이용해 사이즈 정보를 가져옵니다.
    double width = screenSize.width;
    double height = screenSize.height;
    return SafeArea( // SafeArea에 Scaffold를 넣는 방식으로 구성
      child: Scaffold(
        backgroundColor: Colors.deepPurple,
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.deepPurple),
            ),
            width: width * 0.85,
            height: height * 0.5,
            child: Swiper( // Swiper: 옆으로 자연스럽게 넘어가는것 구현
              controller: _controller,
              physics: NeverScrollableScrollPhysics(), // Swipe 모션을 통해 넘어가지 않습니다. 즉, 퀴즈를 스킵할 수 없도록 됩니다.
              loop: false,
              itemCount: widget.quizs.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildQuizCard(widget.quizs[index], width, height);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizCard(Quiz quiz, double width, double height) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // 경계선 radius
          border: Border.all(color: Colors.white), // 경계선 색깔
          color: Colors.white // 박스 색깔
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, width * 0.024, 0, width * 0.024),
            child: Text(
              'Q' + (_currentIndex + 1).toString() + '.',
              style: TextStyle(
                fontSize: width * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: width * 0.8,
            padding: EdgeInsets.only(top: width * 0.012),
            child: AutoSizeText( // AutoSizeText: 텍스트가 길어질 경우 아래로 넘치지 않도록 텍스트의 길이를 자동으로 줄여주는 기능
              quiz.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: width * 0.048,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(), // Expanded에 빈 컨테이너를 넣는 이유: 이후에 배치될 children들이 아래에서부터 배치되도록 하는 효과
          ),
          Column(
            children: _buildCandidates(width, quiz),
          ),
          Container(
            padding: EdgeInsets.all(width * 0.024),
            child: Center(
              child: ButtonTheme(
                minWidth: width * 0.5,
                height: height * 0.05,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: RaisedButton(
                  child: _currentIndex == widget.quizs.length - 1
                      ? Text('결과보기') // 현재 인덱스가 마지막 퀴즈를 가리킨다면 결과보기 글씨 보이기
                      : Text('다음문제'), // 아니면 다음문제 글씨 보이기
                  textColor: Colors.white, // 텍스트 색상
                  color: Colors.deepPurple, // 버튼 색상
                  onPressed: _answers[_currentIndex] == -1 // _answer가 -1이라는 것은 아직 정답 체크가 되지 않은 초기의 상태라는 뜻
                      ? null // 다음문제로 못 넘어가도록 막아주기
                      : () {
                          if (_currentIndex == widget.quizs.length - 1) { // 마지막 퀴즈라면 결과보기
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResultScreen( // 결과창 
                                  answers: _answers,
                                  quizs: widget.quizs,
                                ),
                              ),
                            );
                          } else { // 마지막 퀴즈가 아니라면
                            _answerState = [false, false, false, false]; // _answerState를 초기화
                            _currentIndex += 1; // _currentIndex를 증가
                            _controller.next(); // 이제, 다음문제로 넘어가기 가능
                          }
                        },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildCandidates(double width, Quiz quiz) {
    List<Widget> _children = [];
    for (int i = 0; i < 4; i++) {
      _children.add(
        CandWidget(
          index: i,
          text: quiz.candidates[i],
          width: width,
          answerState: _answerState[i],
          tap: () {
            setState(() {
              for (int j = 0; j < 4; j++) { // 반복문을 통해 전체 선택지를 확인하며, 
                                            // 지금의 선택지의 answerState를 true로 변경해주며
                                            // answer에 기록
                if (j == i) {
                  _answerState[j] = true;
                  _answers[_currentIndex] = j;
                  print(_answers[_currentIndex]); // 정상적으로 정답이 기록 되고 있는것을 확인할 수 있다.
                } else {
                  _answerState[j] = false;
                }
              }
            });
          },
        ),
      );
      _children.add(
        Padding(
          padding: EdgeInsets.all(width * 0.024),
        ),
      );
    }
    return _children;
  }
}