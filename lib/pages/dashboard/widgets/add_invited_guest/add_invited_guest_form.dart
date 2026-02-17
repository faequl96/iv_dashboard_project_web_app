import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iv_dashboard_project_web_app/models/invited_guest_controller.dart';
import 'package:iv_dashboard_project_web_app/models/invited_guest_form_cache.dart';
import 'package:iv_dashboard_project_web_app/models/invited_guest_form_duplicated.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/cubit/invited_guest_form_cubit.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/widgets/default_text_field.dart';
import 'package:iv_project_core/iv_project_core.dart';
import 'package:iv_project_web_data/iv_project_web_data.dart';
import 'package:iv_project_widget_core/iv_project_widget_core.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

const _storageSouvenirValuesKey = 'SOUVENIR_VALUES';

class AddInvitedGuestForm extends StatefulWidget {
  const AddInvitedGuestForm({super.key, required this.scrollController, required this.invitationId, required this.controllers});

  final ScrollController scrollController;
  final String invitationId;
  final List<InvitedGuestController> controllers;

  @override
  State<AddInvitedGuestForm> createState() => _AddInvitedGuestFormState();
}

class _AddInvitedGuestFormState extends State<AddInvitedGuestForm> {
  final _souvenirValuesController = TextEditingController();

  late final InvitedGuestCubit _invitedGuestCubit;
  late final InvitedGuestFormCubit _invitedGuestFormCubit;

  final _rebuildForms = <ValueNotifier<int>>[];
  final _guestUniqueIds = <String>[];
  final _duplicateUniqueIds = <String>[];
  final _duplicateIndexs = <int>[];

  void _setRebuildForms() {
    _rebuildForms.clear();
    for (final _ in widget.controllers) {
      _rebuildForms.add(ValueNotifier(0));
    }
  }

  void _setCache() {
    List<InvitedGuestFormCache> invitedGuests = [];
    for (final controller in widget.controllers) {
      if (controller.name.text.isNotEmpty ||
          controller.phone.text.isNotEmpty ||
          controller.instance.text.isNotEmpty ||
          controller.souvenir.text.isNotEmpty) {
        invitedGuests.add(
          InvitedGuestFormCache(
            name: controller.name.text,
            phone: controller.phone.text,
            instance: controller.instance.text,
            souvenir: controller.souvenir.text,
            nominal: controller.nominal.text,
          ),
        );
      }
    }

    _invitedGuestFormCubit.invitedGuestsCreateCache(invitedGuests);
  }

  void _set(int formIndex, {bool isInitial = false}) {
    if (!isInitial) {
      for (final index in _duplicateIndexs) {
        if (formIndex != index) _rebuildForms[index].value += 1;
      }
    }
    _duplicateIndexs.clear();
    _duplicateUniqueIds.clear();
    final duplicateds = <InvitedGuestFormDuplicated>[];
    for (int i = 0; i < widget.controllers.length; i++) {
      final controller = widget.controllers[i];
      if (controller.name.text.isEmpty || controller.phone.text.isEmpty) continue;
      final uniqueId = '${controller.name.text}_${controller.phone.text}'.toLowerCase();
      if (duplicateds.map((e) => e.uniqueId).contains(uniqueId)) {
        for (final item in duplicateds) {
          if (item.uniqueId == uniqueId) {
            _duplicateUniqueIds.add(item.uniqueId);
            _duplicateIndexs.add(item.index);
          }
        }
        _duplicateUniqueIds.add(uniqueId);
        _duplicateIndexs.add(i);
      } else {
        duplicateds.add(InvitedGuestFormDuplicated(index: i, uniqueId: uniqueId, id: ''));
      }
    }

    if (!isInitial) _setCache();
  }

  @override
  void initState() {
    super.initState();

    _invitedGuestCubit = context.read<InvitedGuestCubit>();
    _invitedGuestFormCubit = context.read<InvitedGuestFormCubit>();

    _setRebuildForms();

    _set(0, isInitial: true);

    final souvenirValues = StorageService.getString(_storageSouvenirValuesKey) ?? '';
    if (souvenirValues.isEmpty) {
      final souvenirsValuesString = 'Gelas, Tumbler, Dompet, Gantungan Kunci';
      StorageService.setString(_storageSouvenirValuesKey, souvenirsValuesString);
      _souvenirValuesController.text = souvenirsValuesString;
    } else {
      _souvenirValuesController.text = StorageService.getString(_storageSouvenirValuesKey) ?? '';
    }

    final guestResponseUniqueIds = (_invitedGuestCubit.state.invitedGuests ?? [])
        .where((e) => !e.nameInstance.contains('Guest'))
        .map((e) => e.uniqueId)
        .toList();

    for (final guestUniqueId in guestResponseUniqueIds) {
      if (guestUniqueId != null) _guestUniqueIds.add(guestUniqueId.toLowerCase());
    }
  }

  @override
  void dispose() {
    _souvenirValuesController.dispose();

    for (final item in _rebuildForms) {
      item.dispose();
    }

    _rebuildForms.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      children: [
        const SizedBox(height: 18),
        Padding(
          padding: const .symmetric(horizontal: 14),
          child: GeneralTextField(
            controller: _souvenirValuesController,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
            decoration: FieldDecoration(
              labelText: 'Sesuaikan Souvenir Template',
              fillColor: ColorConverter.lighten(AppColor.primaryColor, 96),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26, width: 1),
                borderRadius: .all(Radius.circular(12)),
              ),
              disabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26, width: 1),
                borderRadius: .all(Radius.circular(12)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26, width: 1),
                borderRadius: .all(Radius.circular(12)),
              ),
            ),
            maxLines: 2,
            onChanged: (value) {
              StorageService.setString(_storageSouvenirValuesKey, value);
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: 14),
        for (int i = 0; i < widget.controllers.length; i++) ...[
          FormField(
            key: widget.controllers[i].idKey,
            index: i,
            invitationId: widget.invitationId,
            formControllersLength: widget.controllers.length,
            formController: widget.controllers[i],
            souvenirs: _souvenirValuesController.text.split(', '),
            rebuild: _rebuildForms[i],
            duplicateUniqueIds: _duplicateUniqueIds,
            existingGuestUniqueIds: _guestUniqueIds,
            onChangeName: (_) => _set(i),
            onChangePhone: (_) => _set(i),
            onChangeInstance: (_) => _set(i),
            onChangeSouvenir: (_) => _set(i),
            onDelete: (value) {
              widget.controllers[i].name.dispose();
              widget.controllers[i].phone.dispose();
              widget.controllers[i].instance.dispose();
              widget.controllers[i].souvenir.dispose();
              widget.controllers[i].nominal.dispose();

              widget.controllers.removeAt(value);
              _setRebuildForms();
              _setCache();
              setState(() {});
            },
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 14),
        Center(
          child: GeneralEffectsButton(
            onTap: () {
              widget.controllers.add(
                InvitedGuestController(
                  name: TextEditingController(),
                  phone: TextEditingController(),
                  instance: TextEditingController(),
                  souvenir: TextEditingController(),
                  nominal: TextEditingController(),
                ),
              );
              _setRebuildForms();
              setState(() {});

              Future.delayed(const Duration(milliseconds: 50), () {
                widget.scrollController.animateTo(
                  widget.scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.ease,
                );
              });
            },
            padding: const .only(top: 8, left: 14, right: 22, bottom: 8),
            color: AppColor.primaryColor,
            borderRadius: .circular(30),
            useInitialElevation: true,
            child: const Row(
              mainAxisSize: .min,
              children: [
                Icon(Icons.add, size: 26, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Tambah Form Tamu',
                  style: TextStyle(fontWeight: .bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class FormField extends StatelessWidget {
  const FormField({
    super.key,
    required this.index,
    required this.invitationId,
    required this.formControllersLength,
    required this.formController,
    required this.rebuild,
    required this.souvenirs,
    required this.duplicateUniqueIds,
    required this.existingGuestUniqueIds,
    required this.onChangeName,
    required this.onChangePhone,
    required this.onChangeInstance,
    required this.onChangeSouvenir,
    required this.onDelete,
  });

  final int index;
  final String invitationId;
  final int formControllersLength;
  final InvitedGuestController formController;
  final List<String> souvenirs;
  final ValueNotifier<int> rebuild;
  final List<String> duplicateUniqueIds;
  final List<String> existingGuestUniqueIds;
  final void Function(String value) onChangeName;
  final void Function(String value) onChangePhone;
  final void Function(String value) onChangeInstance;
  final void Function(String value) onChangeSouvenir;
  final void Function(int value) onDelete;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: rebuild,
      builder: (_, value, _) {
        final isExist = existingGuestUniqueIds.contains(
          '${formController.name.text}_${formController.phone.text}_$invitationId'.toLowerCase(),
        );
        final isDuplicate = duplicateUniqueIds.contains('${formController.name.text}_${formController.phone.text}'.toLowerCase());

        return Padding(
          padding: const .symmetric(horizontal: 14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isExist || isDuplicate ? Colors.white : null,
              gradient: isExist || isDuplicate
                  ? null
                  : LinearGradient(
                      begin: .topCenter,
                      end: .bottomCenter,
                      colors: [ColorConverter.lighten(AppColor.primaryColor, 90), Colors.white],
                      stops: const [.1, .5],
                    ),
              boxShadow: const [BoxShadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.black12)],
              border: .all(
                width: isExist || isDuplicate ? 2 : 1,
                color: isExist
                    ? ColorConverter.lighten(Colors.red)
                    : isDuplicate
                    ? Colors.amber.shade600
                    : Colors.black.withValues(alpha: .2),
              ),
              borderRadius: .circular(12),
            ),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const .symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      if (isExist)
                        Expanded(
                          child: Text(
                            'Tamu dengan Nama dan WhatsApp ini sudah ada',
                            style: TextStyle(color: ColorConverter.lighten(Colors.red), fontWeight: .bold),
                          ),
                        )
                      else if (isDuplicate)
                        Expanded(
                          child: Text(
                            'Terdapat duplikasi Form Tamu dengan Nama dan WhatsApp ini',
                            style: TextStyle(color: Colors.amber.shade600, fontWeight: .bold),
                          ),
                        )
                      else
                        Expanded(
                          child: Text('Form Tamu ${index + 1}', style: const TextStyle(fontWeight: .bold)),
                        ),
                      const SizedBox(width: 12),
                      if (formControllersLength > 1)
                        GeneralEffectsButton(
                          onTap: () => onDelete(index),
                          padding: const .all(4),
                          color: ColorConverter.lighten(Colors.red, 40),
                          splashColor: Colors.white,
                          borderRadius: .circular(30),
                          child: const Icon(Icons.remove_rounded, size: 20, color: Colors.white),
                        )
                      else
                        const SizedBox(height: 28),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const .symmetric(horizontal: 10),
                  child: DefaultTextField(
                    textEditingController: formController.name,
                    labelTextBuilder: () => 'Nama',
                    validation: true,
                    mandatory: true,
                    onChanged: (value) {
                      onChangeName(value);
                      rebuild.value += 1;
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const .symmetric(horizontal: 10),
                  child: DefaultTextField(
                    textEditingController: formController.phone,
                    labelTextBuilder: () => 'WhatsApp',
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validation: true,
                    mandatory: true,
                    onChanged: (value) {
                      onChangePhone(value);
                      rebuild.value += 1;
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const .symmetric(horizontal: 10),
                  child: DefaultTextField(
                    textEditingController: formController.instance,
                    labelTextBuilder: () => 'Keluarga/Teman Di',
                    validation: true,
                    mandatory: true,
                    onChanged: (value) {
                      onChangeInstance(value);
                      rebuild.value += 1;
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const .symmetric(horizontal: 10),
                  child: OverlaySuggestionField(
                    fieldBuilder: (_, controller, focusNode) {
                      return DefaultTextField(
                        textEditingController: controller,
                        focusNode: focusNode,
                        labelTextBuilder: () => 'Souvenir',
                        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^a-zA-Z0-9 ]'))],
                        validation: false,
                        onChanged: (value) {
                          onChangeSouvenir(value);
                          rebuild.value += 1;
                        },
                      );
                    },
                    dispose: false,
                    controller: formController.souvenir,
                    debouncer: .zero,
                    decoration: OverlayDecoration(
                      maxHeight: 300,
                      padding: const .symmetric(vertical: 12),
                      clipBehavior: Clip.hardEdge,
                    ),
                    suggestionItemDecoration: SuggestionItemDecoration(
                      padding: const .symmetric(vertical: 8, horizontal: 14),
                      evenColor: Colors.white,
                      oddColor: Colors.grey.shade100,
                    ),
                    onSelected: (value) => formController.souvenir.text = value,
                    suggestions: (keyword) async {
                      return keyword.isEmpty
                          ? souvenirs
                          : souvenirs.where((e) => e.toLowerCase().contains(keyword.toLowerCase())).toList();
                    },
                    itemBuilder: (_, value) => Text(value, style: const TextStyle(height: 1.4)),
                    loadingBuilder: (context) => SizedBox(
                      height: 24,
                      child: Center(child: SharedPersonalize.loadingWidget(size: 24, color: AppColor.primaryColor)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
