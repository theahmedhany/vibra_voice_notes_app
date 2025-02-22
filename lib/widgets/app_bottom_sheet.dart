import 'package:flutter/material.dart';
import '../utils/responsive_helpers/sizer_helper_extension.dart';
import '../utils/constants/app_colors.dart';

Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required Widget Function(BuildContext) builder,
  bool showCloseButton = false,
}) async {
  return await showModalBottomSheet<T?>(
    context: context,
    backgroundColor: AppColors.kSecondaryColor,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: Padding(
          padding: EdgeInsets.all(context.setMinSize(22)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCloseButton)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: context.setMinSize(8)),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.cancel,
                        color: AppColors.kBackgroundColor,
                        size: context.setMinSize(24),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: context.setHeight(32)),
              builder(context),
            ],
          ),
        ),
      );
    },
  );
}
