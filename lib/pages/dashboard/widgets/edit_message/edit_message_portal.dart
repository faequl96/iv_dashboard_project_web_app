import 'package:flutter/material.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/widgets/edit_message/edit_message_content.dart';
import 'package:iv_project_core/iv_project_core.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class EditMessagePortal extends StatelessWidget {
  const EditMessagePortal({super.key, required this.controller, required this.messages});

  final TextEditingController controller;
  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    return GeneralEffectsButton(
      onTap: () {
        ShowModal.bottomSheet(
          context,
          barrierColor: Colors.grey.shade700.withValues(alpha: .5),
          header: BottomSheetHeader(
            title: const HeaderTitle.handleBar(),
            action: HeaderAction(
              actionIcon: Icons.close_rounded,
              iconColor: Colors.grey.shade600,
              onTap: () => NavigationService.pop(),
            ),
          ),
          decoration: BottomSheetDecoration(
            color: ColorConverter.lighten(AppColor.primaryColor, 94),
            borderRadius: const .only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          contentBuilder: (_) => EditMessageContent(controller: controller, messages: messages),
        );
      },
      padding: const .symmetric(horizontal: 20, vertical: 10),
      color: AppColor.primaryColor,
      splashColor: Colors.white,
      borderRadius: .circular(30),
      useInitialElevation: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Column(
            mainAxisAlignment: .center,
            children: [
              SizedBox(height: 3),
              Icon(Icons.message, size: 24, color: Colors.white),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            'Template Pesan',
            style: AppFonts.nunito(color: Colors.white, fontSize: 15, fontWeight: .w700),
          ),
        ],
      ),
    );
  }
}
