import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyLoadingScreen extends StatelessWidget {
  const MyLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/loading.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SpinKitPouringHourGlassRefined(
              color: Color.fromARGB(255, 216, 210, 24),
              size: 200.0,
              duration: Duration(seconds: 2),
            ),
          ),
        ],
      ),
    );
  }
}
