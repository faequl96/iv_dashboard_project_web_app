import 'package:flutter/material.dart';
import 'package:iv_project_core/iv_project_core.dart';

class GeneralTitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GeneralTitleAppBar({super.key, required this.title, this.leftAction, this.rightAction})
    : preferredSize = const Size.fromHeight(kToolbarHeight);

  final Widget title;
  final Widget? leftAction;
  final Widget? rightAction;

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    Widget? leftActionValue;
    if (leftAction != null) {
      leftActionValue = leftAction!;
    }

    List<Widget>? rightActionValue;
    if (rightAction != null) {
      rightActionValue = [rightAction!];
    }

    return SizedBox(
      height: kToolbarHeight,
      child: Card(
        color: AppColor.primaryColor,
        margin: const .all(0),
        shape: RoundedRectangleBorder(borderRadius: .circular(0)),
        elevation: 1,
        child: Row(
          children: [
            leftActionValue ?? const SizedBox.shrink(),
            Expanded(child: title),
            ...(rightActionValue ?? <Widget>[]),
          ],
        ),
      ),
    );
  }
}
