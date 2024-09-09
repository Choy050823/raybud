import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  late YoutubePlayerController controller;

  @override
  void deactivate() {
    controller.pause(); // Pause the video before navigating away
    super.deactivate();
  }

  @override
  void dispose() {
    controller.dispose(); // Dispose of the controller to free resources
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    const url = 'https://youtu.be/IW7oU6O3Atc?si=pP3kIvN78zFrqfRc';
    controller = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(url)!,
        flags: const YoutubePlayerFlags(
          mute: false,
          loop: false,
          autoPlay: false,
        ));
  }

  void _forceStopAndGoBack(BuildContext context) {
    // Forcefully stop the video or any animations
    if (controller.value.isPlaying) {
      controller.pause(); // Pause the video if playing
    }

    // After stopping the animation, navigate back
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pop(context); // Safely pop after the frame completes
    });
  }

  @override
  Widget build(BuildContext context) => YoutubePlayerBuilder(
      player: YoutubePlayer(controller: controller),
      builder: (context, player) => Scaffold(
          appBar: AppBar(
            title: const Text('Exercise Video'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _forceStopAndGoBack(context); // Force stop and navigate back
              },
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Center(
                  // Rotating the video player 90 degrees clockwise
                  child: Transform.rotate(
                    angle: 1.5708, // 90 degrees in radians (π/2)
                    child: AspectRatio(
                      aspectRatio: 16 / 9, // Maintain video aspect ratio
                      child: player,
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _forceStopAndGoBack(context); // Force stop and navigate back
            },
            child: const Icon(Icons.stop),
          )));
}
