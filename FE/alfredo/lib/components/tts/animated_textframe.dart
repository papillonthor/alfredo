import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedTextFrame extends StatefulWidget {
  final Function onTextTap;
  const AnimatedTextFrame({super.key, required this.onTextTap});

  @override
  AnimatedTextFrameState createState() => AnimatedTextFrameState();
}

class AnimatedTextFrameState extends State<AnimatedTextFrame> {
  late List<String> stringList;
  late String displayedText;
  bool isApiTextDisplayed = false; // 현재 표시되는 텍스트가 API 텍스트인지 여부

  @override
  void initState() {
    super.initState();
    setupTextList();
    displayedText = stringList.first;
  }

  void setupTextList() {
    DateTime now = DateTime.now();
    int hour = now.hour; // 현지 시간대의 시간을 사용

    if (hour >= 0 && hour < 6) {
      stringList = [
        '아직 어둠이 깊은 시간입니다. 오늘의 첫 번째 할 일을 차분히 준비해볼까요?',
        '조용한 새벽, 하루를 계획하며 차 한 잔 어떠신가요?',
        '이른 새벽입니다. 오늘 하루의 목표를 설정해보세요.',
      ];
    } else if (hour >= 6 && hour < 12) {
      stringList = [
        '좋은 아침입니다! 오늘의 첫 번째 할 일을 시작해보세요!',
        '활기찬 아침입니다. 중요한 일정부터 시작해볼까요?',
        '커피 한 잔과 함께, 오늘의 일정을 확인해보세요.',
      ];
    } else if (hour >= 12 && hour < 18) {
      stringList = [
        '식사는 잘 하셨습니까? 오후 일정을 점검해보세요.',
        '활기찬 오후입니다. 중요한 일을 처리할 시간입니다!',
        '일을 하다 지치셨다면 잠시 휴식을 취하며 재충전하세요.',
      ];
    } else {
      stringList = [
        '하루를 마무리할 시간입니다. 오늘의 성과를 정리해보세요.',
        '편안한 저녁입니다. 내일의 일정을 미리 계획해보세요.',
        '오늘 하루도 수고 많으셨습니다. 남은 시간을 편안하게 보내세요.',
      ];
    }
  }

  void changeText() {
    final newText = stringList[Random().nextInt(stringList.length)];
    setState(() {
      displayedText = newText;
      isApiTextDisplayed = false; // 로컬 리스트로 변경 시 상태 해제
    });
  }

  // API로부터 받은 새 텍스트로 업데이트
  void updateText(String newText) {
    setState(() {
      displayedText = newText;
      isApiTextDisplayed = true; // API 텍스트가 표시 중임을 설정
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTextTap(); // 사용자 정의 콜백 실행
        changeText(); // 텍스트 변경 함수 실행
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Text(
            displayedText,
            style: const TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }
}
