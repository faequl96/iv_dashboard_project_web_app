import 'package:flutter/material.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/widgets/add_invited_guest/add_invited_guest_content.dart';
import 'package:iv_project_core/iv_project_core.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class EditInvitedGuestPortal extends StatelessWidget {
  const EditInvitedGuestPortal({super.key});

  @override
  Widget build(BuildContext context) {
    return GeneralEffectsButton(
      onTap: () {
        ShowModal.bottomSheet(
          context,
          barrierColor: Colors.grey.shade700.withValues(alpha: .5),
          header: BottomSheetHeader(
            useHandleBar: true,
            handleColor: Colors.grey.shade500,
            action: HeaderAction(
              actionIcon: Icons.close_rounded,
              iconColor: Colors.grey.shade600,
              onTap: () => NavigationService.pop(),
            ),
          ),
          decoration: BottomSheetDecoration(
            color: Colors.white,
            borderRadius: const .only(topLeft: .circular(20), topRight: .circular(20)),
          ),
          contentBuilder: (_) => const AddInvitedGuestContent(),
        );
      },
      padding: const .all(10),
      color: Colors.blue,
      splashColor: Colors.white,
      borderRadius: .circular(30),
      useInitialElevation: true,
      child: const Icon(Icons.edit, size: 28, color: Colors.white),
    );
  }
}
