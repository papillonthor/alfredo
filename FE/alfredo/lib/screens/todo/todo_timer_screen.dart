import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class TodoTimerScreen extends StatefulWidget {
  final int initialTimeInSeconds;
  const TodoTimerScreen({super.key, required this.initialTimeInSeconds});

  @override
  _TodoTimerScreenState createState() => _TodoTimerScreenState();
}

class _TodoTimerScreenState extends State<TodoTimerScreen> {
  late int _currentTimeInSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTimeInSeconds = widget.initialTimeInSeconds;
  }

  void startTimer() {
    if (_timer != null && _timer!.isActive) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTimeInSeconds++;
        });
      }
    });
  }

  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  void resetTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    setState(() {
      _currentTimeInSeconds = widget.initialTimeInSeconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    int hours = _currentTimeInSeconds ~/ 3600;
    int minutes = (_currentTimeInSeconds % 3600) ~/ 60;
    int seconds = _currentTimeInSeconds % 60;

    return WillPopScope(
      onWillPop: () async {
        stopTimer();
        Navigator.pop(context, _currentTimeInSeconds);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D2338),
          foregroundColor: Colors.white,
          title: const Text('수행시간'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              stopTimer();
              Navigator.pop(context, _currentTimeInSeconds);
            },
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/mainback1.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height),
                  painter: ClockPainter(
                      seconds: seconds, minutes: minutes, hours: hours),
                ),
              ),
              Positioned(
                top: 50,
                right: 20,
                child: Text(
                  '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 100,
                left: MediaQuery.of(context).size.width / 5.4,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: startTimer,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text('시작',
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: stopTimer,
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('정지',
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: resetTimer,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      child: const Text('리셋',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }
}

class ClockPainter extends CustomPainter {
  final int seconds;
  final int minutes;
  final int hours;

  ClockPainter(
      {required this.seconds, required this.minutes, required this.hours});

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    Offset center = Offset(centerX, centerY);
    double radius = math.min(size.width, size.height) / 2 * 0.9;

    final backgroundPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color.fromARGB(255, 233, 209, 148), // 중심 색상
          Color(0xFFF2E9E9), // 바깥쪽 색상
        ],
        radius: 0.9,
      ).createShader(Rect.fromCircle(
        center: center,
        radius: radius,
      ))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);

    final ringPaint = Paint()
      ..shader = const SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: math.pi * 2,
        colors: [
          Color(0xFFA67C00), // 시작 색상
          Color(0xFFE1C681), // 끝 색상
          Color(0xFFA67C00), // 다시 시작 색상으로 돌아가서 연속적인 느낌을 줌
        ],
        stops: [0.0, 0.5, 1.0], // 각 색상의 위치
      ).createShader(Rect.fromCircle(
        center: center,
        radius: radius,
      ))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius, ringPaint);

    final tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5;
    for (var i = 0; i < 60; i++) {
      final tickLength = i % 5 == 0 ? 20 : 10;
      final tickMarkStart = radius - tickLength;
      final angle = (i * 6) * math.pi / 180;
      final x1 = centerX + radius * math.cos(angle - math.pi / 2);
      final y1 = centerY + radius * math.sin(angle - math.pi / 2);
      final x2 = centerX + tickMarkStart * math.cos(angle - math.pi / 2);
      final y2 = centerY + tickMarkStart * math.sin(angle - math.pi / 2);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }

    final numerals = [
      'XII',
      'I',
      'II',
      'III',
      'IV',
      'V',
      'VI',
      'VII',
      'VIII',
      'IX',
      'X',
      'XI'
    ];
    const textStyle = TextStyle(color: Colors.black, fontSize: 24);
    final textPainter = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 + 270) * math.pi / 180;
      textPainter.text = TextSpan(text: numerals[i], style: textStyle);
      textPainter.layout();
      final x =
          centerX + (radius - 40) * math.cos(angle) - textPainter.width / 2;
      final y =
          centerY + (radius - 40) * math.sin(angle) - textPainter.height / 2;
      textPainter.paint(canvas, Offset(x, y));
    }

    final secondHandLength = radius * 0.8;
    final minuteHandLength = radius * 0.7;
    final hourHandLength = radius * 0.5;
    final secondAngle = (seconds * 6 + 270) * math.pi / 180;
    final minuteAngle = (minutes * 6 + seconds * 0.1 + 270) * math.pi / 180;
    final hourAngle = (hours * 30 + minutes * 0.5 + 270) * math.pi / 180;
    canvas.drawLine(
        center,
        Offset(centerX + secondHandLength * math.cos(secondAngle),
            centerY + secondHandLength * math.sin(secondAngle)),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2);
    canvas.drawLine(
        center,
        Offset(centerX + minuteHandLength * math.cos(minuteAngle),
            centerY + minuteHandLength * math.sin(minuteAngle)),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 4);
    canvas.drawLine(
        center,
        Offset(centerX + hourHandLength * math.cos(hourAngle),
            centerY + hourHandLength * math.sin(hourAngle)),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 6);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}


// import 'dart:async';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';

// class TodoTimerScreen extends StatefulWidget {
//   final int initialTimeInSeconds;
//   const TodoTimerScreen({super.key, required this.initialTimeInSeconds});

//   @override
//   _TodoTimerScreenState createState() => _TodoTimerScreenState();
// }

// class _TodoTimerScreenState extends State<TodoTimerScreen> {
//   late int _currentTimeInSeconds;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _currentTimeInSeconds = widget.initialTimeInSeconds; // 초기 시간 설정
//   }

//   void startTimer() {
//     if (_timer != null && _timer!.isActive) return;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted) {
//         setState(() {
//           _currentTimeInSeconds++; // 시간 증가
//         });
//       }
//     });
//   }

//   void stopTimer() {
//     if (_timer != null) {
//       _timer!.cancel();
//       _timer = null;
//     }
//   }

//   void resetTimer() {
//     if (_timer != null) {
//       _timer!.cancel();
//       _timer = null;
//     }
//     setState(() {
//       _currentTimeInSeconds = widget.initialTimeInSeconds; // 시간을 초기 시간으로 리셋
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     int hours = _currentTimeInSeconds ~/ 3600;
//     int minutes = (_currentTimeInSeconds % 3600) ~/ 60;
//     int seconds = _currentTimeInSeconds % 60;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('수행시간'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             stopTimer();
//             Navigator.pop(context, _currentTimeInSeconds);
//           },
//         ),
//       ),
//       body: Stack(
//         children: [
//           Align(
//             alignment: Alignment.center,
//             child: CustomPaint(
//               size: Size(MediaQuery.of(context).size.width,
//                   MediaQuery.of(context).size.height),
//               painter: ClockPainter(
//                   seconds: seconds, minutes: minutes, hours: hours),
//             ),
//           ),
//           Positioned(
//             top: 50,
//             right: 20,
//             child: Text(
//               '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Positioned(
//             bottom: 100,
//             left: MediaQuery.of(context).size.width / 2 - 150,
//             child: Row(
//               children: [
//                 ElevatedButton(
//                   onPressed: startTimer,
//                   style:
//                       ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                   child:
//                       const Text('시작', style: TextStyle(color: Colors.white)),
//                 ),
//                 const SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: stopTimer,
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                   child:
//                       const Text('정지', style: TextStyle(color: Colors.white)),
//                 ),
//                 const SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: resetTimer,
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//                   child:
//                       const Text('리셋', style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     stopTimer();
//     super.dispose();
//   }
// }

// class ClockPainter extends CustomPainter {
//   final int seconds;
//   final int minutes;
//   final int hours;

//   ClockPainter(
//       {required this.seconds, required this.minutes, required this.hours});

//   @override
//   void paint(Canvas canvas, Size size) {
//     double centerX = size.width / 2;
//     double centerY = size.height / 2;
//     Offset center = Offset(centerX, centerY);
//     double radius = math.min(size.width, size.height) / 2 * 0.9;
//     const tickMarkLength = 10.0;
//     final tickPaint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 2;

//     // Draw the tick marks.
//     for (var i = 0; i < 60; i++) {
//       final tickLength = i % 5 == 0 ? 20 : 10;
//       final tickMarkStart = radius - tickLength;
//       final angle = (i * 6) * math.pi / 180;

//       final x1 = centerX + radius * math.cos(angle - math.pi / 2);
//       final y1 = centerY + radius * math.sin(angle - math.pi / 2);
//       final x2 = centerX + tickMarkStart * math.cos(angle - math.pi / 2);
//       final y2 = centerY + tickMarkStart * math.sin(angle - math.pi / 2);

//       canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
//     }

//     // Draw the Roman numerals.
//     final textPainter = TextPainter(
//         textAlign: TextAlign.center, textDirection: TextDirection.ltr);
//     const textStyle = TextStyle(color: Colors.black, fontSize: 24);
//     final numerals = [
//       'XII',
//       'I',
//       'II',
//       'III',
//       'IV',
//       'V',
//       'VI',
//       'VII',
//       'VIII',
//       'IX',
//       'X',
//       'XI'
//     ];
//     for (var i = 0; i < 12; i++) {
//       final angle = (i * 30 + 270) * math.pi / 180;
//       final numeral = numerals[i];
//       textPainter.text = TextSpan(text: numeral, style: textStyle);
//       textPainter.layout();
//       final x =
//           centerX + (radius - 40) * math.cos(angle) - textPainter.width / 2;
//       final y =
//           centerY + (radius - 40) * math.sin(angle) - textPainter.height / 2;
//       textPainter.paint(canvas, Offset(x, y));
//     }

//     // Draw hands
//     final secondHandLength = radius * 0.8;
//     final minuteHandLength = radius * 0.7;
//     final hourHandLength = radius * 0.5;

//     final secondAngle = (seconds * 6 + 270) * math.pi / 180;
//     final minuteAngle = (minutes * 6 + seconds * 0.1 + 270) * math.pi / 180;
//     final hourAngle = (hours * 30 + minutes * 0.5 + 270) * math.pi / 180;

//     final secondHandX = centerX + secondHandLength * math.cos(secondAngle);
//     final secondHandY = centerY + secondHandLength * math.sin(secondAngle);
//     final minuteHandX = centerX + minuteHandLength * math.cos(minuteAngle);
//     final minuteHandY = centerY + minuteHandLength * math.sin(minuteAngle);
//     final hourHandX = centerX + hourHandLength * math.cos(hourAngle);
//     final hourHandY = centerY + hourHandLength * math.sin(hourAngle);

//     canvas.drawLine(
//         center,
//         Offset(secondHandX, secondHandY),
//         Paint()
//           ..color = Colors.red
//           ..strokeWidth = 2);
//     canvas.drawLine(
//         center,
//         Offset(minuteHandX, minuteHandY),
//         Paint()
//           ..color = Colors.black
//           ..strokeWidth = 4);
//     canvas.drawLine(
//         center,
//         Offset(hourHandX, hourHandY),
//         Paint()
//           ..color = Colors.black
//           ..strokeWidth = 6);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }



// import 'dart:async';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';

// class TodoTimerScreen extends StatefulWidget {
//   final int initialTimeInSeconds;
//   const TodoTimerScreen({super.key, required this.initialTimeInSeconds});

//   @override
//   _TodoTimerScreenState createState() => _TodoTimerScreenState();
// }

// class _TodoTimerScreenState extends State<TodoTimerScreen> {
//   late int _currentTimeInSeconds;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _currentTimeInSeconds = widget.initialTimeInSeconds;
//   }

//   void startTimer() {
//     if (_timer != null && _timer!.isActive) return;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted) {
//         setState(() {
//           _currentTimeInSeconds++;
//         });
//       }
//     });
//   }

//   void stopTimer() {
//     if (_timer != null) {
//       _timer!.cancel();
//       _timer = null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     int hours = _currentTimeInSeconds ~/ 3600;
//     int minutes = (_currentTimeInSeconds % 3600) ~/ 60;
//     int seconds = _currentTimeInSeconds % 60;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('수행시간'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             stopTimer();
//             Navigator.pop(context, _currentTimeInSeconds);
//           },
//         ),
//       ),
//       body: Stack(
//         children: [
//           Align(
//             alignment: Alignment.center,
//             child: CustomPaint(
//               size: Size(MediaQuery.of(context).size.width,
//                   MediaQuery.of(context).size.height),
//               painter: ClockPainter(
//                   seconds: seconds, minutes: minutes, hours: hours),
//             ),
//           ),
//           Positioned(
//             top: 50,
//             right: 20,
//             child: Text(
//               '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Positioned(
//             bottom: 100,
//             left: MediaQuery.of(context).size.width / 2 - 100,
//             child: Row(
//               children: [
//                 ElevatedButton(
//                   onPressed: startTimer,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                   ),
//                   child: const Text(
//                     '시작',
//                     style: TextStyle(
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: stopTimer,
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                   child: const Text(
//                     '정지',
//                     style: TextStyle(
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     stopTimer();
//     super.dispose();
//   }
// }

// class ClockPainter extends CustomPainter {
//   final int seconds;
//   final int minutes;
//   final int hours;

//   ClockPainter(
//       {required this.seconds, required this.minutes, required this.hours});

//   @override
//   void paint(Canvas canvas, Size size) {
//     double centerX = size.width / 2;
//     double centerY = size.height / 2;
//     Offset center = Offset(centerX, centerY);
//     double radius = math.min(size.width, size.height) / 2 * 0.9;
//     const tickMarkLength = 10.0;
//     final tickPaint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 2;

//     // Draw the tick marks.
//     for (var i = 0; i < 60; i++) {
//       final tickLength = i % 5 == 0 ? 20 : 10;
//       final tickMarkStart = radius - tickLength;
//       final angle = (i * 6) * math.pi / 180;

//       final x1 = centerX + radius * math.cos(angle - math.pi / 2);
//       final y1 = centerY + radius * math.sin(angle - math.pi / 2);
//       final x2 = centerX + tickMarkStart * math.cos(angle - math.pi / 2);
//       final y2 = centerY + tickMarkStart * math.sin(angle - math.pi / 2);

//       canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
//     }

//     // Draw the Roman numerals.
//     final textPainter = TextPainter(
//         textAlign: TextAlign.center, textDirection: TextDirection.ltr);
//     const textStyle = TextStyle(color: Colors.black, fontSize: 24);
//     final numerals = [
//       'XII',
//       'I',
//       'II',
//       'III',
//       'IV',
//       'V',
//       'VI',
//       'VII',
//       'VIII',
//       'IX',
//       'X',
//       'XI'
//     ];
//     for (var i = 0; i < 12; i++) {
//       final angle = (i * 30 + 270) * math.pi / 180;
//       final numeral = numerals[i];
//       textPainter.text = TextSpan(text: numeral, style: textStyle);
//       textPainter.layout();
//       final x =
//           centerX + (radius - 40) * math.cos(angle) - textPainter.width / 2;
//       final y =
//           centerY + (radius - 40) * math.sin(angle) - textPainter.height / 2;
//       textPainter.paint(canvas, Offset(x, y));
//     }

//     // Draw hands
//     final secondHandLength = radius * 0.8;
//     final minuteHandLength = radius * 0.7;
//     final hourHandLength = radius * 0.5;

//     final secondAngle = (seconds * 6 + 270) * math.pi / 180;
//     final minuteAngle = (minutes * 6 + seconds * 0.1 + 270) * math.pi / 180;
//     final hourAngle = (hours * 30 + minutes * 0.5 + 270) * math.pi / 180;

//     final secondHandX = centerX + secondHandLength * math.cos(secondAngle);
//     final secondHandY = centerY + secondHandLength * math.sin(secondAngle);
//     final minuteHandX = centerX + minuteHandLength * math.cos(minuteAngle);
//     final minuteHandY = centerY + minuteHandLength * math.sin(minuteAngle);
//     final hourHandX = centerX + hourHandLength * math.cos(hourAngle);
//     final hourHandY = centerY + hourHandLength * math.sin(hourAngle);

//     canvas.drawLine(
//         center,
//         Offset(secondHandX, secondHandY),
//         Paint()
//           ..color = Colors.red
//           ..strokeWidth = 2);
//     canvas.drawLine(
//         center,
//         Offset(minuteHandX, minuteHandY),
//         Paint()
//           ..color = Colors.black
//           ..strokeWidth = 4);
//     canvas.drawLine(
//         center,
//         Offset(hourHandX, hourHandY),
//         Paint()
//           ..color = Colors.black
//           ..strokeWidth = 6);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }



// import 'dart:async';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';

// class TodoTimerScreen extends StatefulWidget {
//   final int initialTimeInSeconds;
//   const TodoTimerScreen({super.key, required this.initialTimeInSeconds});

//   @override
//   _TodoTimerScreenState createState() => _TodoTimerScreenState();
// }

// class _TodoTimerScreenState extends State<TodoTimerScreen> {
//   late int _currentTimeInSeconds;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _currentTimeInSeconds = widget.initialTimeInSeconds;
//   }

//   void startTimer() {
//     if (_timer != null && _timer!.isActive) return;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted) {
//         setState(() {
//           _currentTimeInSeconds++;
//         });
//       }
//     });
//   }

//   void stopTimer() {
//     if (_timer != null) {
//       _timer!.cancel();
//       _timer = null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     int hours = _currentTimeInSeconds ~/ 3600;
//     int minutes = (_currentTimeInSeconds % 3600) ~/ 60;
//     int seconds = _currentTimeInSeconds % 60;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('스탑워치'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             stopTimer();
//             Navigator.pop(context, _currentTimeInSeconds);
//           },
//         ),
//       ),
//       body: Stack(
//         children: [
//           Align(
//             alignment: Alignment.center,
//             child: CustomPaint(
//               size: Size(MediaQuery.of(context).size.width,
//                   MediaQuery.of(context).size.height),
//               painter: ClockPainter(seconds: seconds),
//             ),
//           ),
//           Positioned(
//             top: 50,
//             right: 20,
//             child: Text(
//               '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Positioned(
//             bottom: 100,
//             left: MediaQuery.of(context).size.width / 2 - 100,
//             child: Row(
//               children: [
//                 ElevatedButton(
//                   onPressed: startTimer,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                   ),
//                   child: const Text(
//                     '시작',
//                     style: TextStyle(
//                       color: Colors.white, // 텍스트 색상을 하얀색으로 설정
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: stopTimer,
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                   child: const Text(
//                     '정지',
//                     style: TextStyle(
//                       color: Colors.white, // 텍스트 색상을 하얀색으로 설정
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     stopTimer(); // Ensure the timer is stopped on dispose
//     super.dispose();
//   }
// }

// class ClockPainter extends CustomPainter {
//   final int seconds;

//   ClockPainter({required this.seconds});

//   @override
//   void paint(Canvas canvas, Size size) {
//     double centerX = size.width / 2;
//     double centerY = size.height / 2;
//     Offset center = Offset(centerX, centerY);
//     double radius = size.width / 4;

//     canvas.drawCircle(
//         center, radius, Paint()..color = const Color.fromARGB(0, 0, 0, 0));

//     double secondX =
//         centerX + radius * math.cos((seconds * 6 - 90) * math.pi / 180);
//     double secondY =
//         centerY + radius * math.sin((seconds * 6 - 90) * math.pi / 180);

//     canvas.drawLine(
//         center,
//         Offset(secondX, secondY),
//         Paint()
//           ..color = Colors.red
//           ..strokeWidth = 2);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }



// import 'dart:async';
// import 'package:flutter/material.dart';

// class TodoTimerScreen extends StatefulWidget {
//   final int initialTimeInSeconds; // 초 단위로 초기 시간을 받습니다.
//   const TodoTimerScreen({super.key, required this.initialTimeInSeconds});

//   @override
//   _TodoTimerScreenState createState() => _TodoTimerScreenState();
// }

// class _TodoTimerScreenState extends State<TodoTimerScreen> {
//   late int _currentTimeInSeconds;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _currentTimeInSeconds = widget.initialTimeInSeconds;
//   }

//   void startTimer() {
//     // 타이머가 이미 실행 중이지 않은지 확인
//     if (_timer != null && _timer!.isActive) {
//       return;
//     }
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         _currentTimeInSeconds++;
//       });
//     });
//   }

//   void stopTimer() {
//     // _timer가 null이 아닐 때만 cancel 호출
//     _timer?.cancel();
//     _timer = null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     int hours = _currentTimeInSeconds ~/ 3600;
//     int minutes = (_currentTimeInSeconds % 3600) ~/ 60;
//     int seconds = _currentTimeInSeconds % 60;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('스탑워치'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             stopTimer(); // 타이머 중지
//             Navigator.pop(
//                 context, _currentTimeInSeconds); // 현재 시간을 반환하며 이전 화면으로 돌아감
//           },
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
//               style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: startTimer,
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//               child: const Text('시작'),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: stopTimer,
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               child: const Text('정지'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     stopTimer(); // 위젯이 파괴될 때 타이머를 중지합니다.
//     super.dispose();
//   }
// }
