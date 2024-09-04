import 'package:flutter/material.dart';

class ChartContainer extends StatelessWidget {
  final Color color;
  final String title;
  final Widget chart;

  const ChartContainer({
    super.key,
    required this.title,
    required this.color,
    required this.chart,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.90,
        height: MediaQuery.of(context).size.width * 0.95 * 0.65,
        padding: const EdgeInsets.fromLTRB(20, 0, 10, 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Expanded(
                child: Container(
              padding: const EdgeInsets.only(top: 8),
              child: chart,
            ))
          ],
        ),
      ),
    );
  }
}
