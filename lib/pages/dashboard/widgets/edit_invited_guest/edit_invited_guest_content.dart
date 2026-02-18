import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iv_dashboard_project_web_app/models/invited_guest_controller.dart';
import 'package:iv_dashboard_project_web_app/models/invited_guest_edit_change.dart';
import 'package:iv_dashboard_project_web_app/models/invited_guest_form_cache.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/cubit/invited_guest_form_cubit.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/widgets/edit_invited_guest/edit_invited_guest_changes.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/widgets/edit_invited_guest/edit_invited_guest_form.dart';
import 'package:iv_project_core/iv_project_core.dart';
import 'package:iv_project_model/iv_project_model.dart';
import 'package:iv_project_web_data/iv_project_web_data.dart';
import 'package:iv_project_widget_core/iv_project_widget_core.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class EditInvitedGuestContent extends StatefulWidget {
  const EditInvitedGuestContent({super.key});

  @override
  State<EditInvitedGuestContent> createState() => _EditInvitedGuestContentState();
}

class _EditInvitedGuestContentState extends State<EditInvitedGuestContent> {
  String? _invitationId;

  final _scrollController = ScrollController();

  final _invitedGuestControllers = <InvitedGuestController>[];

  late final InvitedGuestCubit _invitedGuestCubit;
  late final InvitedGuestFormCubit _invitedGuestFormCubit;
  late final LocaleCubit _localeCubit;

  final _invitedGuestsNameInstance = <String>[];
  final _duplicatedInvitedGuestIds = <String>[];

  Future<void> _upsertInvitedGuests() async {
    try {
      final invitedGuests = _invitedGuestCubit.state.invitedGuests ?? [];
      bool isBreaked = false;
      List<EditInvitedGuestRequest> invitedGuestRequests = [];
      for (int i = 0; i < invitedGuests.length; i++) {
        final controller = _invitedGuestControllers[i];
        if (controller.name.text.isEmpty || controller.phone.text.isEmpty || controller.instance.text.isEmpty) {
          GeneralDialog.showValidateStateError('Field mandatory tidak boleh kosong', durationInSeconds: 5);
          await Future.delayed(const Duration(milliseconds: 200));
          _scrollController.jumpTo(18 + 60 + 14 + (326 * (i.toDouble())));
          await Future.delayed(const Duration(milliseconds: 50));
          if (controller.name.text.isEmpty) {
            controller.name.text = ' ';
            controller.name.clear();
          }
          if (controller.phone.text.isEmpty) {
            controller.phone.text = ' ';
            controller.phone.clear();
          }
          if (controller.instance.text.isEmpty) {
            controller.instance.text = ' ';
            controller.instance.clear();
          }
          isBreaked = true;
          break;
        }

        final nominal = controller.nominal.text;
        if (!_duplicatedInvitedGuestIds.contains(invitedGuests[i].id)) {
          invitedGuestRequests.add(
            EditInvitedGuestRequest(
              id: invitedGuests[i].id,
              invitationId: _invitationId!,
              name: controller.name.text,
              phone: controller.phone.text,
              nameInstance: '${controller.name.text.replaceAll(' ', '-')}_${controller.instance.text.replaceAll(' ', '-')}',
              souvenir: controller.souvenir.text.isEmpty ? null : controller.souvenir.text,
              nominal: nominal.isEmpty ? null : int.tryParse(nominal) ?? 0,
            ),
          );
        }
      }

      if (isBreaked) return;

      final requests = <EditInvitedGuestRequest>[];
      final invitedGuestEditChanges = <InvitedGuestEditChange>[];
      for (int i = 0; i < invitedGuestRequests.length; i++) {
        final invitedGuestRequest = invitedGuestRequests[i];
        final invitedGuest = invitedGuests.singleWhere((e) => e.id == invitedGuestRequest.id);
        final invitedGuestRequestInstance = invitedGuestRequest.nameInstance.split('_').last.replaceAll('-', ' ');
        final invitedGuestInstance = invitedGuest.nameInstance.split('_').last.replaceAll('-', ' ');

        if (invitedGuestRequest.name != invitedGuest.name ||
            invitedGuestRequest.phone != invitedGuest.phone ||
            invitedGuestRequestInstance != invitedGuestInstance ||
            invitedGuestRequest.souvenir != invitedGuest.souvenir ||
            invitedGuestRequest.nominal != invitedGuest.nominal) {
          final invitedGuestChange = InvitedGuestEditChange(
            nameInstance: invitedGuest.nameInstance.replaceAll('-', ' ').replaceAll('_', ' - '),
            name: invitedGuestRequest.name != invitedGuest.name ? '${invitedGuest.name}_${invitedGuestRequest.name}' : null,
            phone: invitedGuestRequest.phone != invitedGuest.phone
                ? '${invitedGuest.phone ?? '-'}_${invitedGuestRequest.phone}'
                : null,
            instance: invitedGuestRequestInstance != invitedGuestInstance
                ? '${invitedGuestInstance}_$invitedGuestRequestInstance'
                : null,
            souvenir: invitedGuestRequest.souvenir != invitedGuest.souvenir
                ? '${invitedGuest.souvenir ?? '-'}_${invitedGuestRequest.souvenir ?? '-'}'
                : null,
            nominal: invitedGuestRequest.nominal != invitedGuest.nominal
                ? '${invitedGuest.nominal ?? '-'}_${invitedGuestRequest.nominal ?? '-'}'
                : null,
          );

          invitedGuestEditChanges.add(invitedGuestChange);

          requests.add(invitedGuestRequest);
        }
      }

      if (invitedGuestEditChanges.isEmpty) {
        GeneralDialog.showValidateStateError('Minimal edit satu Form Tamu', durationInSeconds: 5);
        return;
      }

      final confirmed = await ShowModal.bottomSheet<bool?>(
        context,
        barrierColor: Colors.grey.shade700.withValues(alpha: .5),
        dismissible: false,
        enableDrag: false,
        header: BottomSheetHeader(
          title: const HeaderTitle(
            icon: Icons.notes,
            iconSize: 22,
            iconColor: AppColor.primaryColor,
            title: 'Ringkasan Perubahan',
          ),
          action: HeaderAction(
            actionIcon: Icons.close_rounded,
            iconColor: Colors.grey.shade600,
            onTap: () => NavigationService.pop(),
          ),
        ),
        decoration: BottomSheetDecoration(
          color: Colors.white,
          // backgroundContentColor: ColorConverter.lighten(AppColor.primaryColor, 96),
          borderRadius: const .only(topLeft: .circular(20), topRight: .circular(20)),
        ),
        contentBuilder: (_) => EditInvitedGuestChanges(items: invitedGuestEditChanges),
      );

      if (confirmed != true) return;

      final success = await _invitedGuestCubit.upsertEdit(BulkEditInvitedGuestRequest(invitedGuests: invitedGuestRequests));
      if (success) {
        _invitedGuestFormCubit.invitedGuestsEditCache([]);
        NavigationService.pop();
      }
    } catch (e) {
      GeneralDialog.showValidateStateError('$e', durationInSeconds: 5);
    }
  }

  @override
  void initState() {
    super.initState();

    _invitationId = Uri.base.queryParameters['id'];

    _invitedGuestCubit = context.read<InvitedGuestCubit>();
    _invitedGuestFormCubit = context.read<InvitedGuestFormCubit>();
    _localeCubit = context.read<LocaleCubit>();

    final invitedGuestsCache = _invitedGuestFormCubit.state.invitedGuestsEditCache;

    if (invitedGuestsCache.isNotEmpty) {
      for (int i = 0; i < invitedGuestsCache.length; i++) {
        final invitedGuest = invitedGuestsCache[i];
        final nameInstance = '${invitedGuest.name} - ${invitedGuest.instance}';
        _invitedGuestsNameInstance.add(nameInstance);
        _invitedGuestControllers.add(
          InvitedGuestController(
            id: invitedGuest.id,
            name: TextEditingController(text: invitedGuest.name),
            phone: TextEditingController(text: invitedGuest.phone),
            instance: TextEditingController(text: invitedGuest.instance),
            souvenir: TextEditingController(text: invitedGuest.souvenir),
            nominal: TextEditingController(text: invitedGuest.nominal),
          ),
        );
      }
    } else {
      final invitedGuests = _invitedGuestCubit.state.invitedGuests ?? [];
      if (invitedGuests.isNotEmpty) {
        final cache = <InvitedGuestFormCache>[];
        for (int i = 0; i < invitedGuests.length; i++) {
          final invitedGuest = invitedGuests[i];
          final nameInstance = '${invitedGuest.name} - ${invitedGuest.nameInstance.split('_').last.replaceAll('-', ' ')}';
          _invitedGuestsNameInstance.add(nameInstance);
          _invitedGuestControllers.add(
            InvitedGuestController(
              id: invitedGuest.id,
              name: TextEditingController(text: invitedGuest.name),
              phone: TextEditingController(text: invitedGuest.phone ?? ''),
              instance: TextEditingController(text: invitedGuest.nameInstance.split('_').last.replaceAll('-', ' ')),
              souvenir: TextEditingController(text: invitedGuest.souvenir ?? ''),
              nominal: TextEditingController(text: '${(invitedGuest.nominal ?? '')}'),
            ),
          );

          final invitedGuestController = _invitedGuestControllers[i];
          cache.add(
            InvitedGuestFormCache(
              id: invitedGuest.id,
              name: invitedGuestController.name.text,
              phone: invitedGuestController.phone.text,
              instance: invitedGuestController.instance.text,
              souvenir: invitedGuestController.souvenir.text,
              nominal: invitedGuestController.nominal.text,
            ),
          );
        }

        _invitedGuestFormCubit.invitedGuestsEditCache(cache);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();

    _scrollController.dispose();

    for (int i = 0; i < _invitedGuestControllers.length; i++) {
      final controller = _invitedGuestControllers[i];
      controller.name.dispose();
      controller.phone.dispose();
      controller.instance.dispose();
      controller.souvenir.dispose();
      controller.nominal.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(GlobalContextService.value).size;

    return SizedBox(
      height: size.height - 80,
      child: Column(
        children: [
          Expanded(
            child: EditInvitedGuestForm(
              scrollController: _scrollController,
              invitationId: _invitationId ?? '',
              nameInstances: _invitedGuestsNameInstance,
              controllers: _invitedGuestControllers,
              onChangeDuplicateIds: (values) {
                _duplicatedInvitedGuestIds.clear();
                _duplicatedInvitedGuestIds.addAll(values);
              },
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(offset: const Offset(0, -3), color: Colors.black.withValues(alpha: .08), blurRadius: 3)],
            ),
            child: Padding(
              padding: const .only(left: 16, right: 16, top: 12, bottom: 12),
              child: BlocSelector<InvitedGuestCubit, InvitedGuestState, bool>(
                selector: (state) => state.isLoadingUpsert,
                builder: (context, isLoading) {
                  return GeneralEffectsButton(
                    onTap: _upsertInvitedGuests,
                    isDisabled: isLoading,
                    width: .maxFinite,
                    padding: const .symmetric(vertical: 14),
                    color: AppColor.primaryColor,
                    splashColor: Colors.white,
                    borderRadius: .circular(30),
                    useInitialElevation: true,
                    child: Row(
                      mainAxisAlignment: .center,
                      children: [
                        if (isLoading) ...[
                          SharedPersonalize.loadingWidget(size: 20, color: Colors.white),
                          const SizedBox(width: 10),
                        ] else ...[
                          const Icon(Icons.upload_sharp, size: 20, color: Colors.white),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          _localeCubit.state.languageCode == 'id' ? 'Update Tamu Undangan' : 'Update Invited Guests',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: .w800),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
