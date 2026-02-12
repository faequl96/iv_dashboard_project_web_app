import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iv_dashboard_project_web_app/models/invited_guest_controller.dart';
import 'package:iv_dashboard_project_web_app/models/invited_guest_form_cache.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/cubit/invited_guest_form_cubit.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/widgets/default_text_field.dart';
import 'package:iv_project_core/iv_project_core.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class InvitedGuestForm extends StatefulWidget {
  const InvitedGuestForm({super.key, this.isEdit = false, required this.controllers});

  final bool isEdit;
  final List<InvitedGuestController> controllers;

  @override
  State<InvitedGuestForm> createState() => _InvitedGuestFormState();
}

class _InvitedGuestFormState extends State<InvitedGuestForm> {
  final _scrollController = ScrollController();

  late final InvitedGuestFormCubit _invitedGuestFormCubit;

  void _setCache() {
    List<InvitedGuestFormCache> invitedGuests = [];
    for (final controller in widget.controllers) {
      invitedGuests.add(
        InvitedGuestFormCache(
          name: controller.name.text,
          phone: controller.phone.text,
          instance: controller.instance.text,
          souvenir: controller.souvenir.text,
        ),
      );
    }
    if (!widget.isEdit) _invitedGuestFormCubit.invitedGuestsCreateCache(invitedGuests);
    if (widget.isEdit) _invitedGuestFormCubit.invitedGuestsEditCache(invitedGuests);
  }

  @override
  void initState() {
    super.initState();

    _invitedGuestFormCubit = context.read<InvitedGuestFormCubit>();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height - 100,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const SizedBox(height: 14),
            for (int i = 0; i < widget.controllers.length; i++) ...[
              _FormField(
                index: i,
                formController: widget.controllers[i],
                onChangeName: (_) => _setCache(),
                onChangePhone: (_) => _setCache(),
                onChangeInstance: (_) => _setCache(),
                onChangeSouvenir: (_) => _setCache(),
                onDelete: (value) => setState(() => widget.controllers.removeAt(value)),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 14),
            GeneralEffectsButton(
              onTap: () {
                widget.controllers.add(
                  InvitedGuestController(
                    name: TextEditingController(),
                    phone: TextEditingController(),
                    instance: TextEditingController(),
                    souvenir: TextEditingController(),
                  ),
                );
                setState(() {});

                Future.delayed(const Duration(milliseconds: 50), () {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.ease,
                  );
                });
              },
              padding: const EdgeInsets.only(top: 8, left: 12, right: 18, bottom: 8),
              color: AppColor.primaryColor,
              borderRadius: BorderRadius.circular(30),
              useInitialElevation: true,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 26, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Tambah Tamu Undangan',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.index,
    required this.formController,
    required this.onChangeName,
    required this.onChangePhone,
    required this.onChangeInstance,
    required this.onChangeSouvenir,
    required this.onDelete,
  });

  final int index;
  final InvitedGuestController formController;
  final void Function(String value) onChangeName;
  final void Function(String value) onChangePhone;
  final void Function(String value) onChangeInstance;
  final void Function(String value) onChangeSouvenir;
  final void Function(int value) onDelete;

  @override
  Widget build(BuildContext context) {
    const souvenirs = ['Gelas', 'Tumbler', 'Dompet', 'Gantungan Kunci'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Tamu Undangan ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  GeneralEffectsButton(
                    onTap: () => onDelete(index),
                    padding: const EdgeInsets.all(4),
                    color: Colors.grey.shade400,
                    splashColor: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    child: const Icon(Icons.close, size: 20, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DefaultTextField(
                textEditingController: formController.name,
                labelTextBuilder: () => 'Nama',
                validation: true,
                mandatory: true,
                onChanged: onChangeName,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DefaultTextField(
                textEditingController: formController.phone,
                labelTextBuilder: () => 'Whatsapp',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validation: true,
                mandatory: true,
                onChanged: onChangePhone,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DefaultTextField(
                textEditingController: formController.instance,
                labelTextBuilder: () => 'Keluarga/Teman Dari',
                onChanged: onChangeInstance,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: OverlaySuggestionField(
                fieldBuilder: (_, controller, focusNode) {
                  return DefaultTextField(
                    textEditingController: controller,
                    focusNode: focusNode,
                    labelTextBuilder: () => 'Souvenir',
                    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^a-zA-Z0-9 ]'))],
                    validation: false,
                    // mandatory: true,
                    onChanged: onChangeSouvenir,
                  );
                },
                dispose: false,
                controller: formController.souvenir,
                debouncer: Duration.zero,
                decoration: OverlayDecoration(
                  maxHeight: 300,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  clipBehavior: Clip.hardEdge,
                ),
                suggestionItemDecoration: SuggestionItemDecoration(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  evenColor: Colors.white,
                  oddColor: Colors.grey.shade100,
                ),
                onSelected: (value) => formController.souvenir.text = value,
                suggestions: (keyword) async => keyword.isEmpty
                    ? souvenirs
                    : souvenirs.where((e) => e.toLowerCase().contains(keyword.toLowerCase())).toList(),
                itemBuilder: (_, value) => Text(value, style: const TextStyle(height: 1.4)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
