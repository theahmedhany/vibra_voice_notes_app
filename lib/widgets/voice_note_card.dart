import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../utils/responsive_helpers/size_provider.dart';
import '../utils/responsive_helpers/sizer_helper_extension.dart';
import '../cubit/voice_notes_cubit/voice_notes_cubit.dart';
import '../model/voice_note_model.dart';
import '../utils/constants/app_colors.dart';
import 'app_bottom_sheet.dart';
import 'audio_player_view.dart';
import 'play_pause_button.dart';

class VoiceNoteCard extends StatelessWidget {
  final VoiceNoteModel voiceNoteInfo;

  const VoiceNoteCard({super.key, required this.voiceNoteInfo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showAppBottomSheet(
          context,
          showCloseButton: true,
          builder: (p0) {
            return AudioPlayerView(
              path: voiceNoteInfo.path,
            );
          },
        );
      },
      onLongPressStart: (details) {
        final offset = details.globalPosition;
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy,
            MediaQuery.of(context).size.width - offset.dx,
            MediaQuery.of(context).size.height - offset.dy,
          ),
          items: [
            PopupMenuItem(
              onTap: () {
                context.read<VoiceNotesCubit>().deleteRecordFile(voiceNoteInfo);
              },
              child: Text(
                "Delete",
                style: TextStyle(
                  fontSize: context.setSp(16),
                  color: AppColors.kThirdColor,
                ),
              ),
            )
          ],
        );
      },
      child: SizeProvider(
        baseSize: const Size(70, 70),
        width: context.setWidth(70),
        height: context.setHeight(70),
        child: Builder(builder: (context) {
          return Padding(
            padding: EdgeInsets.only(bottom: context.setMinSize(12)),
            child: Container(
              height: context.sizeProvider.height,
              padding: EdgeInsets.all(context.setMinSize(16)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    AppColors.kSecondaryColor,
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: Text(
                            voiceNoteInfo.name,
                            style: TextStyle(
                              color: AppColors.kThirdColor,
                              fontSize: context.setSp(16),
                              fontWeight: FontWeight.bold,
                              height: 0,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            _formatDate(voiceNoteInfo.createAt),
                            style: TextStyle(
                              color: AppColors.kPrimaryColor,
                              fontSize: context.setSp(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PlayPauseButton(
                    isPlaying: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('hh:mm a - dd MMM yyyy').format(dateTime);
  }
}
