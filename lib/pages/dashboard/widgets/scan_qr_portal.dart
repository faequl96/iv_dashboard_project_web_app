import 'package:flutter/material.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/widgets/scan_qr_content.dart';
import 'package:iv_project_core/iv_project_core.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class ScanQrPortal extends StatelessWidget {
  const ScanQrPortal({super.key, required this.onDetectCompleted});

  final void Function() onDetectCompleted;

  @override
  Widget build(BuildContext context) {
    return GeneralEffectsButton(
      onTap: () async {
        await ShowModal.bottomSheet(
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
            borderRadius: const .only(topLeft: .circular(20), topRight: .circular(20)),
          ),
          contentBuilder: (_) => const Padding(padding: .only(left: 14, right: 14, bottom: 20), child: ScanQrContent()),
        );

        onDetectCompleted();
      },
      padding: const .symmetric(horizontal: 16, vertical: 8),
      color: AppColor.primaryColor,
      splashColor: Colors.white,
      borderRadius: const .only(topLeft: .circular(20), bottomLeft: .circular(20)),
      border: Border(
        top: BorderSide(color: ColorConverter.lighten(AppColor.primaryColor, 40), width: 2),
        left: BorderSide(color: ColorConverter.lighten(AppColor.primaryColor, 40), width: 2),
        bottom: BorderSide(color: ColorConverter.lighten(AppColor.primaryColor, 40), width: 2),
      ),
      child: Text(
        'Scan QR',
        style: AppFonts.nunito(color: Colors.white, fontSize: 15, fontWeight: .w700),
      ),
    );
  }
}
