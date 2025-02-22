import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/responsive_helpers/sizer_helper_extension.dart';
import '../manager/audio_recorder_manager/audio_recorder_controller.dart';
import '../utils/constants/app_colors.dart';

class AudioWavesView extends StatefulWidget {
  const AudioWavesView({super.key});

  @override
  State<AudioWavesView> createState() => _AudioWavesViewState();
}

class _AudioWavesViewState extends State<AudioWavesView> {
  final ScrollController scrollController = ScrollController();

  List<double> amplitudes = [];
  late StreamSubscription<double> amplitudeSubscription;

  double wavesMaxHeight = 50;
  final double minimumAmpl = -50;

  @override
  void initState() {
    amplitudeSubscription =
        context.read<AudioRecorderController>().amplitudeStream.listen((amp) {
      setState(() {
        amplitudes.add(amp);
      });

      if (scrollController.positions.isNotEmpty) {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            curve: Curves.linear, duration: const Duration(milliseconds: 160));
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    amplitudeSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: wavesMaxHeight,
      child: ListView.builder(
        controller: scrollController,
        itemCount: amplitudes.length,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          double amplitude = amplitudes[index].clamp(minimumAmpl + 1, 0);

          double amplPercentage = 1 - (amplitude / minimumAmpl).abs();

          double waveHeight = wavesMaxHeight * amplPercentage;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: context.setMinSize(2)),
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: waveHeight),
                duration: const Duration(milliseconds: 120),
                curve: Curves.decelerate,
                builder: (context, animatedWaveHeight, child) {
                  return SizedBox(
                    height: animatedWaveHeight,
                    width: context.setWidth(8),
                    child: child,
                  );
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.kPrimaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
