import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iv_dashboard_project_web_app/models/invited_guest_edit_change.dart';
import 'package:iv_project_core/iv_project_core.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class EditInvitedGuestChanges extends StatelessWidget {
  const EditInvitedGuestChanges({super.key, required this.items});

  final List<InvitedGuestEditChange> items;

  @override
  Widget build(BuildContext context) {
    final langCode = context.read<LocaleCubit>().state.languageCode;

    final size = MediaQuery.of(context).size;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: size.height - 80),
      child: Column(
        mainAxisSize: .min,
        children: [
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (_, index) => _Item(index: index, item: items[index]),
            ),
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(offset: const Offset(0, -3), color: Colors.black.withValues(alpha: .08), blurRadius: 3)],
            ),
            child: Padding(
              padding: const .only(left: 16, right: 16, top: 12, bottom: 12),
              child: GeneralEffectsButton(
                onTap: () => Navigator.pop(context, true),
                width: .maxFinite,
                padding: const .symmetric(vertical: 14),
                color: AppColor.primaryColor,
                splashColor: Colors.white,
                borderRadius: .circular(30),
                useInitialElevation: true,
                child: Text(
                  langCode == 'id' ? 'Konfirmasi' : 'Confirm',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: .w800),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.index, required this.item});

  final int index;
  final InvitedGuestEditChange item;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const Border(top: BorderSide(width: .5, color: Colors.black12)),
      margin: const .symmetric(vertical: 4),
      color: Colors.white,
      elevation: 1,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          const SizedBox(height: 6),
          Padding(
            padding: const .only(right: 0),
            child: SizedBox(
              width: .maxFinite,
              child: Stack(
                alignment: .centerRight,
                children: [
                  SizedBox(
                    width: .maxFinite,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColor.primaryColor, ColorConverter.lighten(AppColor.primaryColor, 75)],
                          stops: const [.4, .8],
                        ),
                      ),
                      child: Padding(
                        padding: const .only(left: 14, top: 4, bottom: 4),
                        child: Text(
                          '${index + 1}. ${item.nameInstance}',
                          style: const TextStyle(fontWeight: .w700, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (item.name != null)
            Padding(
              padding: const .symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Text('Nama :', style: TextStyle()),
                  const Spacer(),
                  Text(item.name!, style: const TextStyle()),
                ],
              ),
            ),
          if (item.phone != null)
            Padding(
              padding: const .symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Text('WhatsApp :', style: TextStyle()),
                  const Spacer(),
                  Text(item.phone!, style: const TextStyle()),
                ],
              ),
            ),
          if (item.instance != null)
            Padding(
              padding: const .symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Text('Keluarga/Teman Di :', style: TextStyle()),
                  const Spacer(),
                  Text(item.instance!, style: const TextStyle()),
                ],
              ),
            ),
          if (item.souvenir != null)
            Padding(
              padding: const .symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Text('Souvenir :', style: TextStyle()),
                  const Spacer(),
                  Text(item.souvenir!, style: const TextStyle()),
                ],
              ),
            ),
          if (item.nominal != null)
            Padding(
              padding: const .symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Text('Nominal :', style: TextStyle()),
                  const Spacer(),
                  Text(item.nominal!, style: const TextStyle()),
                ],
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
