import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../utils/responsive_helpers/sizer_helper_extension.dart';
import '../utils/constants/app_colors.dart';

class PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final Function()? onTap;

  const PlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      color: AppColors.kPrimaryColor,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: context.setWidth(56),
          height: context.setHeight(56),
          padding: EdgeInsets.only(
            left: isPlaying ? 0 : context.setMinSize(3),
          ),
          child: isPlaying
              ? Center(
                  child: SvgPicture.asset(
                    width: context.setWidth(22),
                    height: context.setWidth(22),
                    colorFilter: ColorFilter.mode(
                      AppColors.kBackgroundColor,
                      BlendMode.srcIn,
                    ),
                    'assets/images/pause.svg',
                  ),
                )
              : Center(
                  child: SvgPicture.asset(
                    width: context.setWidth(24),
                    height: context.setWidth(24),
                    colorFilter: ColorFilter.mode(
                      AppColors.kBackgroundColor,
                      BlendMode.srcIn,
                    ),
                    'assets/images/play.svg',
                  ),
                ),
        ),
      ),
    );
  }
}
