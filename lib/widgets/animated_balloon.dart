import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AnimatedBalloonWidget extends StatefulWidget {
  @override
  _AnimatedBalloonWidgetState createState() => _AnimatedBalloonWidgetState();
}

class _AnimatedBalloonWidgetState extends State<AnimatedBalloonWidget> with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;

  late AnimationController _controllerLeftBalloon;
  late AnimationController _controllerRightBalloon;
  late AnimationController _controllerRotate;
  late AnimationController _controllerPulse;
  late AnimationController _controllerBird;

  late Animation<double> _animationFloatUpLeftBalloon;
  late Animation<double> _animationFloatUpRightBalloon;
  late Animation<double> _animationRotate;
  late Animation<double> _animationPulse;
  late Animation<double> _animationBird;

  bool _isInflatingLeftBalloon = false;
  bool _isInflatingRightBalloon = false;
  bool _isBurstingLeftBalloon = false;
  bool _isBurstingRightBalloon = false;

  // Balloon positions
  Offset _leftBalloonPosition = Offset(100, 300);
  Offset _rightBalloonPosition = Offset(300, 300);

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Balloon animation controllers
    _controllerLeftBalloon = AnimationController(duration: const Duration(seconds: 4), vsync: this);
    _controllerRightBalloon = AnimationController(duration: const Duration(seconds: 8), vsync: this);
    _controllerRotate = AnimationController(duration: const Duration(seconds: 8), vsync: this);
    _controllerPulse = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _controllerBird = AnimationController(duration: const Duration(seconds: 15), vsync: this);

    // Float-up animations with different speeds
    _animationFloatUpLeftBalloon = Tween<double>(begin: 300.0, end: 50.0).animate(
      CurvedAnimation(parent: _controllerLeftBalloon, curve: Curves.easeInOutCubic),
    );

    _animationFloatUpRightBalloon = Tween<double>(begin: 300.0, end: 50.0).animate(
      CurvedAnimation(parent: _controllerRightBalloon, curve: Curves.easeInOutCubic),
    );

    // Rotation and pulse animations
    _animationRotate = Tween(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _controllerRotate, curve: Curves.easeInOut),
    );

    _animationPulse = Tween(begin: 1.0, end: 1.01).animate(
      CurvedAnimation(parent: _controllerPulse, curve: Curves.easeInOutSine),
    );

    // Bird animation for horizontal movement
    _animationBird = Tween<double>(begin: -0.2, end: 1.2).animate(
      CurvedAnimation(parent: _controllerBird, curve: Curves.linear),
    );

    // Start repeating animations
    _controllerRotate.repeat(reverse: true);
    _controllerPulse.repeat();
    _controllerBird.repeat();

    // Status listeners for balloons to handle burst and reset
    _controllerLeftBalloon.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        burstBalloon(isLeft: true);
      }
    });
    _controllerRightBalloon.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        burstBalloon(isLeft: false);
      }
    });
  }

  void burstBalloon({required bool isLeft}) async {
    setState(() {
      if (isLeft) {
        _isBurstingLeftBalloon = true;
      } else {
        _isBurstingRightBalloon = true;
      }
    });
    await _audioPlayer.play(AssetSource('sounds/balloon_burst.mp3'));
    Future.delayed(Duration(milliseconds: 500), () {
      resetBalloon(isLeft: isLeft);
    });
  }

  void resetBalloon({required bool isLeft}) {
    setState(() {
      if (isLeft) {
        _isInflatingLeftBalloon = false;
        _isBurstingLeftBalloon = false;
        _controllerLeftBalloon.reset();
        _leftBalloonPosition = Offset(100, 300); // Reset position
      } else {
        _isInflatingRightBalloon = false;
        _isBurstingRightBalloon = false;
        _controllerRightBalloon.reset();
        _rightBalloonPosition = Offset(300, 300); // Reset position
      }
    });
  }

  void startInflation({required bool isLeft}) async {
    if (isLeft && !_isInflatingLeftBalloon) {
      _isInflatingLeftBalloon = true;
      await _audioPlayer.play(AssetSource('sounds/balloon_inflate.mp3'));
      _controllerLeftBalloon.forward();
    } else if (!isLeft && !_isInflatingRightBalloon) {
      _isInflatingRightBalloon = true;
      await _audioPlayer.play(AssetSource('sounds/balloon_inflate.mp3'));
      _controllerRightBalloon.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent[100],
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _controllerLeftBalloon,
          _controllerRightBalloon,
          _controllerRotate,
          _controllerPulse,
          _controllerBird,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Cloud in the background
              Positioned(
                top: -50,
                left: (MediaQuery.of(context).size.width - 700) / 2,
                child: SizedBox(
                  width: 700,
                  height: 300,
                  child: Image.asset(
                    'assets/images/cloud.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Bird moving horizontally
              Positioned(
                top: 10,
                left: _animationBird.value * MediaQuery.of(context).size.width,
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.asset(
                    'assets/images/bird.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Left Balloon (Draggable)
              Positioned(
                left: _leftBalloonPosition.dx,
                top: _animationFloatUpLeftBalloon.value,
                child: DraggableBalloon(
                  onDragUpdate: (details) {
                    setState(() {
                      _leftBalloonPosition += details.delta;
                    });
                  },
                  onTap: () => startInflation(isLeft: true),
                  isBursting: _isBurstingLeftBalloon,
                  balloonImage: 'assets/images/BeginningGoogleFlutter-Balloon.png',
                  burstImage: 'assets/images/burst.png',
                  sizeAnimation: _animationFloatUpLeftBalloon,
                  rotateAnimation: _animationRotate,
                  pulseAnimation: _animationPulse,
                ),
              ),

              // Right Balloon (Draggable)
              Positioned(
                left: _rightBalloonPosition.dx,
                top: _animationFloatUpRightBalloon.value,
                child: DraggableBalloon(
                  onDragUpdate: (details) {
                    setState(() {
                      _rightBalloonPosition += details.delta;
                    });
                  },
                  onTap: () => startInflation(isLeft: false),
                  isBursting: _isBurstingRightBalloon,
                  balloonImage: 'assets/images/new_balloon.png',
                  burstImage: 'assets/images/new_burst.png',
                  sizeAnimation: _animationFloatUpRightBalloon,
                  rotateAnimation: _animationRotate,
                  pulseAnimation: _animationPulse,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DraggableBalloon extends StatelessWidget {
  final Function(DragUpdateDetails) onDragUpdate;
  final VoidCallback onTap;
  final bool isBursting;
  final String balloonImage;
  final String burstImage;
  final Animation<double> sizeAnimation;
  final Animation<double> rotateAnimation;
  final Animation<double> pulseAnimation;

  const DraggableBalloon({
    Key? key,
    required this.onDragUpdate,
    required this.onTap,
    required this.isBursting,
    required this.balloonImage,
    required this.burstImage,
    required this.sizeAnimation,
    required this.rotateAnimation,
    required this.pulseAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = sizeAnimation.value;

    return GestureDetector(
      onPanUpdate: onDragUpdate,
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shadow below the balloon
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.02, // Adjust width to be longer
              height: size * 0.005, // Keep height smaller for an oval effect
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20), // Rounded edges for a smooth oval
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          if (isBursting)
            Image.asset(
              burstImage,
              height: size,
              width: size,
            )
          else
            Transform.rotate(
              angle: rotateAnimation.value,
              child: Transform.scale(
                scale: pulseAnimation.value,
                child: Image.asset(
                  balloonImage,
                  height: size,
                  width: size,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
