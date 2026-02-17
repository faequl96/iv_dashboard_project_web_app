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

class EditInvitedGuestForm extends StatefulWidget {
  const EditInvitedGuestForm({
    super.key,
    required this.scrollController,
    required this.invitationId,
    required this.nameInstances,
    required this.controllers,
    required this.onChangeDuplicateIds,
  });

  final ScrollController scrollController;
  final String invitationId;
  final List<String> nameInstances;
  final List<InvitedGuestController> controllers;
  final void Function(List<String> values) onChangeDuplicateIds;

  @override
  State<EditInvitedGuestForm> createState() => _EditInvitedGuestFormState();
}

class _EditInvitedGuestFormState extends State<EditInvitedGuestForm> {
  final _souvenirValuesController = TextEditingController();

  late final InvitedGuestCubit _invitedGuestCubit;
  late final InvitedGuestFormCubit _invitedGuestFormCubit;

  final _rebuildForms = <ValueNotifier<int>>[];
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
          controller.souvenir.text.isNotEmpty ||
          controller.nominal.text.isNotEmpty) {
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

    _invitedGuestFormCubit.invitedGuestsEditCache(invitedGuests);
  }

  void _set(int formIndex, {bool isInitial = false}) {
    if (!isInitial) {
      for (final index in _duplicateIndexs) {
        if (formIndex != index) _rebuildForms[index].value += 1;
      }
    }
    final guestIds = (_invitedGuestCubit.state.invitedGuests ?? []).map((e) => e.id).toList();
    final guestIdValues = <String>[];
    _duplicateIndexs.clear();
    _duplicateUniqueIds.clear();
    final duplicateds = <InvitedGuestFormDuplicated>[];
    for (int i = 0; i < widget.controllers.length; i++) {
      final controller = widget.controllers[i];
      final id = guestIds[i];
      final uniqueId = '${controller.name.text}_${controller.phone.text}'.toLowerCase();
      if (duplicateds.map((e) => e.uniqueId).contains(uniqueId)) {
        for (final item in duplicateds) {
          if (item.uniqueId == uniqueId) {
            guestIdValues.add(item.id);
            _duplicateUniqueIds.add(item.uniqueId);
            _duplicateIndexs.add(item.index);
          }
        }
        guestIdValues.add(id);
        _duplicateUniqueIds.add(uniqueId);
        _duplicateIndexs.add(i);
      } else {
        duplicateds.add(InvitedGuestFormDuplicated(index: i, id: id, uniqueId: uniqueId));
      }
    }

    widget.onChangeDuplicateIds(guestIdValues);

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
    return ListView.builder(
      controller: widget.scrollController,
      itemCount: widget.controllers.length + 2,
      itemBuilder: (_, index) {
        if (index == 0) {
          return _SouvenirTemplateChanger(
            controller: _souvenirValuesController,
            onChange: (value) {
              StorageService.setString(_storageSouvenirValuesKey, value);
              setState(() {});
            },
          );
        }

        if (index == widget.controllers.length + 1) return const SizedBox(height: 20);

        final idx = index - 1;
        return FormField(
          key: widget.controllers[index].idKey,
          index: idx,
          invitationId: widget.invitationId,
          nameInstance: widget.nameInstances[idx],
          formControllersLength: widget.controllers.length,
          formController: widget.controllers[idx],
          souvenirs: _souvenirValuesController.text.split(', '),
          rebuild: _rebuildForms[idx],
          duplicateUniqueIds: _duplicateUniqueIds,
          onChangeName: (_) => _set(idx),
          onChangePhone: (_) => _set(idx),
          onChangeInstance: (_) => _set(idx),
          onChangeSouvenir: (_) => _set(idx),
          onChangeNominal: (_) => _set(idx),
        );
      },
    );
  }
}

class _SouvenirTemplateChanger extends StatelessWidget {
  const _SouvenirTemplateChanger({required this.controller, required this.onChange});

  final TextEditingController controller;
  final void Function(String value) onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 18),
        Padding(
          padding: const .symmetric(horizontal: 14),
          child: GeneralTextField(
            controller: controller,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
            decoration: FieldDecoration(
              labelText: 'Sesuaikan Souvenir Template',
              fillColor: ColorConverter.lighten(AppColor.primaryColor, 96),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26, width: 1),
                borderRadius: .all(.circular(12)),
              ),
              disabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26, width: 1),
                borderRadius: .all(.circular(12)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26, width: 1),
                borderRadius: .all(.circular(12)),
              ),
            ),
            maxLines: 2,
            onChanged: onChange,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

class FormField extends StatelessWidget {
  const FormField({
    super.key,
    required this.index,
    required this.invitationId,
    required this.nameInstance,
    required this.formControllersLength,
    required this.formController,
    required this.rebuild,
    required this.souvenirs,
    required this.duplicateUniqueIds,
    required this.onChangeName,
    required this.onChangePhone,
    required this.onChangeInstance,
    required this.onChangeSouvenir,
    required this.onChangeNominal,
  });

  final int index;
  final String invitationId;
  final String nameInstance;
  final int formControllersLength;
  final InvitedGuestController formController;
  final List<String> souvenirs;
  final ValueNotifier<int> rebuild;
  final List<String> duplicateUniqueIds;
  final void Function(String value) onChangeName;
  final void Function(String value) onChangePhone;
  final void Function(String value) onChangeInstance;
  final void Function(String value) onChangeSouvenir;
  final void Function(String value) onChangeNominal;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: rebuild,
      builder: (_, value, _) {
        final isDuplicate = duplicateUniqueIds.contains('${formController.name.text}_${formController.phone.text}'.toLowerCase());

        return Padding(
          padding: const .only(left: 14, right: 14, bottom: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDuplicate ? Colors.white : null,
              gradient: isDuplicate
                  ? null
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [ColorConverter.lighten(AppColor.primaryColor, 90), Colors.white],
                      stops: const [.1, .5],
                    ),
              boxShadow: const [BoxShadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.black12)],
              border: .all(
                width: isDuplicate ? 2 : 1,
                color: isDuplicate ? Colors.amber.shade600 : Colors.black.withValues(alpha: .2),
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
                      if (isDuplicate)
                        Expanded(
                          child: Text(
                            'Terdapat duplikasi Form Tamu dengan Nama dan WhatsApp ini',
                            style: TextStyle(color: Colors.amber.shade600, fontWeight: .bold),
                          ),
                        )
                      else
                        Expanded(
                          child: Text('${index + 1}. $nameInstance', style: const TextStyle(fontWeight: .bold)),
                        ),
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
                    debouncer: Duration.zero,
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
                const SizedBox(height: 8),
                Padding(
                  padding: const .symmetric(horizontal: 10),
                  child: DefaultTextField(
                    textEditingController: formController.nominal,
                    labelTextBuilder: () => 'Nominal',
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validation: false,
                    onChanged: (value) {
                      onChangeNominal(value);
                      rebuild.value += 1;
                    },
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
