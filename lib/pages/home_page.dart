import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../utils/responsive_helpers/size_provider.dart';
import '../utils/responsive_helpers/sizer_helper_extension.dart';
import '../cubit/voice_notes_cubit/voice_notes_cubit.dart';
import '../manager/audio_recorder_manager/audio_recorder_file_helper.dart';
import '../model/voice_note_model.dart';
import '../utils/constants/app_colors.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/audio_recorder_view.dart';
import '../widgets/voice_note_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VoiceNotesCubit(
        AudioRecorderFileHelper(),
      ),
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final PagingController<int, VoiceNoteModel> pagingController =
      PagingController<int, VoiceNoteModel>(
          firstPageKey: 1, invisibleItemsThreshold: 6);

  @override
  void initState() {
    pagingController.addPageRequestListener(
      (pageKey) {
        context.read<VoiceNotesCubit>().getAllVoiceNotes(pageKey);
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  void onDataFetched(VoiceNotesFetched state) {
    final data = state.voiceNotes;

    final isLastPage = data.isEmpty ||
        data.length < context.read<VoiceNotesCubit>().fetchLimit;
    if (isLastPage) {
      pagingController.appendLastPage(data);
    } else {
      final nextPageKey = (pagingController.nextPageKey ?? 0) + 1;
      pagingController.appendPage(data, nextPageKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(
              'assets/images/background.png',
            ),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: context.setHeight(8),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: context.setMinSize(18)),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/master/logo.png',
                            width: context.setWidth(32),
                          ),
                          SizedBox(width: context.setWidth(8)),
                          Text(
                            "Vibra",
                            style: TextStyle(
                              fontSize: context.setSp(22),
                              color: AppColors.kThirdColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: context.setHeight(16),
                    ),
                    Expanded(
                      child: BlocListener<VoiceNotesCubit, VoiceNotesState>(
                        listener: (context, state) {
                          if (state is VoiceNotesError) {
                            pagingController.error = state.message;
                          } else if (state is VoiceNotesFetched) {
                            onDataFetched(state);
                          } else if (state is VoiceNoteDeleted) {
                            final List<VoiceNoteModel> voiceNotes = List.from(
                                pagingController.value.itemList ?? []);
                            voiceNotes.remove(state.voiceNoteModel);
                            pagingController.itemList = voiceNotes;
                          } else if (state is VoiceNoteAdded) {
                            final List<VoiceNoteModel> newItems =
                                List.from(pagingController.itemList ?? []);
                            newItems.insert(0, state.voiceNoteModel);
                            pagingController.itemList = newItems;
                          }
                        },
                        child: PagedListView<int, VoiceNoteModel>(
                          pagingController: pagingController,
                          padding: EdgeInsets.only(
                            right: context.setMinSize(20),
                            left: context.setMinSize(20),
                            bottom: context.setMinSize(80),
                          ),
                          builderDelegate: PagedChildBuilderDelegate(
                            noItemsFoundIndicatorBuilder: (context) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    fit: BoxFit.contain,
                                    "assets/images/no_voice_notes.svg",
                                    width: context.setWidth(200),
                                    height: context.setHeight(200),
                                    placeholderBuilder: (context) {
                                      return SizedBox(
                                        width: context.setWidth(200),
                                        height: context.setHeight(200),
                                      );
                                    },
                                  ),
                                  Text(
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    "No voice notes have been recorded yet.",
                                    style: TextStyle(
                                      color: AppColors.kPrimaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.setSp(17),
                                    ),
                                  ),
                                ],
                              );
                            },
                            firstPageErrorIndicatorBuilder: (context) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      pagingController.error.toString(),
                                    ),
                                    SizedBox(
                                      height: context.setHeight(8),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        pagingController
                                            .retryLastFailedRequest();
                                      },
                                      child: Text(
                                        "Retry",
                                        style: TextStyle(
                                          fontSize: context.setSp(16),
                                          color: AppColors.kThirdColor,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                            firstPageProgressIndicatorBuilder: (context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            newPageProgressIndicatorBuilder: (context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            noMoreItemsIndicatorBuilder: (context) {
                              return const SizedBox.shrink();
                            },
                            itemBuilder: (context, item, index) {
                              return VoiceNoteCard(voiceNoteInfo: item);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: context.setWidth(128),
                height: context.setHeight(50),
                decoration: BoxDecoration(
                  color: AppColors.kBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(context.setMinSize(50)),
                    topLeft: Radius.circular(context.setMinSize(50)),
                  ),
                ),
              ),
            ),
            const Positioned(
              bottom: 22,
              child: _AddRecordButton(),
            )
          ],
        ),
      ),
    );
  }
}

class _AddRecordButton extends StatelessWidget {
  const _AddRecordButton();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: AppColors.kPrimaryColor,
        child: InkWell(
          splashColor: AppColors.kBackgroundColor.withValues(alpha: 0.4),
          onTap: () async {
            final VoiceNoteModel? newVoiceNote = await showAppBottomSheet(
              context,
              builder: (context) {
                return const AudioRecorderView();
              },
            );

            if (newVoiceNote != null && context.mounted) {
              context.read<VoiceNotesCubit>().addToVoiceNotes(newVoiceNote);
            }
          },
          child: SizeProvider(
            baseSize: const Size(64, 56),
            width: context.setWidth(64),
            height: context.setHeight(56),
            child: Builder(builder: (context) {
              return SizedBox(
                width: context.sizeProvider.width,
                height: context.sizeProvider.height,
                child: Center(
                  child: SvgPicture.asset(
                    width: context.setWidth(28),
                    height: context.setHeight(28),
                    colorFilter: ColorFilter.mode(
                      AppColors.kBackgroundColor,
                      BlendMode.srcIn,
                    ),
                    'assets/images/microphone.svg',
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
