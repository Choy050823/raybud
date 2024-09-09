import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  late YoutubePlayerController controller;
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    const url = 'https://youtu.be/IW7oU6O3Atc?si=pP3kIvN78zFrqfRc';
    controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(url)!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    // Lock the screen to landscape at the start
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    // Hide system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Add listener to detect full-screen changes
    controller.addListener(() {
      if (controller.value.isFullScreen != isFullScreen) {
        setState(() {
          isFullScreen = controller.value.isFullScreen;
          if (isFullScreen) {
            // If entering full screen, keep landscape orientation
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeRight,
              DeviceOrientation.landscapeLeft,
            ]);
          } else {
            // Stay in landscape mode even after exiting full screen
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeRight,
              DeviceOrientation.landscapeLeft,
            ]);
          }
        });
      }
    });

    controller.addListener(() {
      if (controller.value.playerState == PlayerState.ended) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Handle the case where there's no route to pop
              Navigator.pushReplacementNamed(
                  context, '/'); // Or your home page route
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();

    // Reset orientation to portrait when the page is closed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Show system UI again
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: controller,
            showVideoProgressIndicator: true,
            onReady: () {
              controller.addListener(() {
                if (controller.value.isFullScreen != isFullScreen) {
                  setState(() {
                    isFullScreen = controller.value.isFullScreen;
                  });
                }
              });
            },
          ),
          builder: (context, player) {
            return Stack(
              children: [
                Positioned.fill(child: player),
              ],
            );
          },
        ),
      ),
    );
  }
}
