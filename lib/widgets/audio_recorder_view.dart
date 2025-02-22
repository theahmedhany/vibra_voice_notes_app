import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';
import '../utils/responsive_helpers/sizer_helper_extension.dart';
import '../manager/audio_recorder_manager/audio_recorder_controller.dart';
import '../manager/audio_recorder_manager/audio_recorder_file_helper.dart';
import '../utils/constants/app_colors.dart';
import 'play_pause_button.dart';

import 'audio_waves_view.dart';

class AudioRecorderView extends StatelessWidget {
  const AudioRecorderView({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AudioRecorderController>(
      create: (context) => AudioRecorderController(
        AudioRecorderFileHelper(),
        (message) {
          print(message);
        },
      ),
      child: const _AudioRecorderViewBody(),
    );
  }
}

class _AudioRecorderViewBody extends StatefulWidget {
  const _AudioRecorderViewBody();

  @override
  State<_AudioRecorderViewBody> createState() => _AudioRecorderViewBodyState();
}

class _AudioRecorderViewBodyState extends State<_AudioRecorderViewBody> {
  late final AudioRecorderController audioRecorderService;

  @override
  void initState() {
    audioRecorderService = context.read<AudioRecorderController>();
    audioRecorderService.start();
    super.initState();
  }

  @override
  void dispose() {
    audioRecorderService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          const AudioWavesView(),
          SizedBox(height: context.setHeight(28)),
          const _TimerText(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  context.read<AudioRecorderController>().stop(
                    (voiceNoteModel) {
                      if (voiceNoteModel == null) {
                        Navigator.pop(context);
                      } else {
                        context
                            .read<AudioRecorderController>()
                            .delete(voiceNoteModel.path)
                            .then(
                          (value) {
                            Navigator.pop(context);
                          },
                        );
                      }
                    },
                  );
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: AppColors.kRedColor,
                    fontSize: context.setSp(16),
                  ),
                ),
              ),
              StreamBuilder(
                stream: audioRecorderService.recordStateStream,
                builder: (context, snapshot) {
                  return PlayPauseButton(
                    isPlaying: snapshot.data == RecordState.record,
                    onTap: () {
                      if (snapshot.data == RecordState.pause) {
                        audioRecorderService.resume();
                      } else {
                        audioRecorderService.pause();
                      }
                    },
                  );
                },
              ),
              TextButton(
                onPressed: () {
                  context.read<AudioRecorderController>().stop(
                    (voiceNoteModel) {
                      Navigator.pop(context, voiceNoteModel);
                    },
                  );
                },
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: AppColors.kThirdColor,
                    fontSize: context.setSp(16),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _TimerText extends StatelessWidget {
  const _TimerText();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.setMinSize(8),
        bottom: context.setMinSize(12),
        right: context.setMinSize(8),
        left: context.setMinSize(18),
      ),
      child: StreamBuilder(
        initialData: 0,
        stream: context.read<AudioRecorderController>().recordDurationOutput,
        builder: (context, snapshot) {
          final durationInSec = snapshot.data ?? 0;

          final int minutes = durationInSec ~/ 60;
          final int seconds = durationInSec % 60;

          return Text(
            '${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: AppColors.kBackgroundColor,
              fontSize: context.setSp(16),
            ),
          );
        },
      ),
    );
  }
}
