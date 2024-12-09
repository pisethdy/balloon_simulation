import 'package:flutter/material.dart';
import '../widgets/animated_balloon.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Flexible(child: Text("Balloon Animation")),
      ),
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth < 1280 ? constraints.maxWidth : 1280,
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: AnimatedBalloonWidget(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
