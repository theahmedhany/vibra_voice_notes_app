import 'package:flutter/material.dart';
import '../utils/responsive_helpers/sizer_helper_extension.dart';
import '../manager/audio_player_controller/audio_player_controller.dart';
import '../utils/constants/app_colors.dart';

import 'play_pause_button.dart';

class AudioPlayerView extends StatefulWidget {
  final String path;
  const AudioPlayerView({
    super.key,
    required this.path,
  });

  @override
  State<AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView> {
  final audioPlayerController = AudioPlayerController();
  late final Future loadAudio;
  double? sliderTempValue;

  @override
  void initState() {
    loadAudio = audioPlayerController.loadAudio(widget.path);
    super.initState();
  }

  @override
  void dispose() {
    audioPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadAudio,
      builder: (context, snapshot) {
        final audioDuration = audioPlayerController.durationInMill.toDouble();

        return StreamBuilder(
          stream: audioPlayerController.progressStream,
          builder: (context, snapshot) {
            double progress = (snapshot.data ?? 0).toDouble();

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Slider(
                  value: sliderTempValue ?? progress.clamp(0, audioDuration),
                  min: 0,
                  max: audioDuration,
                  onChanged: (value) {
                    setState(() {
                      sliderTempValue = value;
                    });
                  },
                  onChangeStart: (value) {
                    audioPlayerController.pause();
                  },
                  onChangeEnd: (value) {
                    audioPlayerController.seek(value.toInt());
                    sliderTempValue = null;
                    audioPlayerController.play();
                  },
                  activeColor: AppColors.kPrimaryColor,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.setMinSize(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatToDateTime(progress.toInt()),
                        style: TextStyle(
                          fontSize: context.setSp(14),
                          color: AppColors.kBackgroundColor,
                        ),
                      ),
                      Text(
                        _formatToDateTime(audioDuration.toInt()),
                        style: TextStyle(
                          fontSize: context.setSp(14),
                          color: AppColors.kBackgroundColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.setHeight(28)),
                StreamBuilder(
                  stream: audioPlayerController.playStatusStream,
                  builder: (context, snapshot) {
                    final bool isPlaying = snapshot.data ?? false;
                    return PlayPauseButton(
                      isPlaying: isPlaying,
                      onTap: () {
                        if (isPlaying) {
                          audioPlayerController.pause();
                        } else {
                          audioPlayerController.play();
                        }
                      },
                    );
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

  String _formatToDateTime(int durationInMill) {
    final int minutes = durationInMill ~/ Duration.millisecondsPerMinute;

    final int seconds = (durationInMill % Duration.millisecondsPerMinute) ~/
        Duration.millisecondsPerSecond;

    return '${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}';
  }
}
