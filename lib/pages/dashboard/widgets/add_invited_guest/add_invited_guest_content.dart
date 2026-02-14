import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iv_dashboard_project_web_app/models/invited_guest_controller.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/cubit/invited_guest_form_cubit.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/widgets/add_invited_guest/import_invited_guest.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/widgets/add_invited_guest/add_invited_guest_form.dart';
import 'package:iv_project_core/iv_project_core.dart';
import 'package:iv_project_model/iv_project_model.dart';
import 'package:iv_project_web_data/iv_project_web_data.dart';
import 'package:iv_project_widget_core/iv_project_widget_core.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class AddInvitedGuestContent extends StatefulWidget {
  const AddInvitedGuestContent({super.key});

  @override
  State<AddInvitedGuestContent> createState() => _AddInvitedGuestContentState();
}

class _AddInvitedGuestContentState extends State<AddInvitedGuestContent> {
  String? _invitationId;

  final _scrollController = ScrollController();

  final _invitedGuestControllers = <InvitedGuestController>[];

  late final InvitedGuestCubit _invitedGuestCubit;
  late final InvitedGuestFormCubit _invitedGuestFormCubit;
  late final LocaleCubit _localeCubit;

  Future<void> _upsertInvitedGuests() async {
    try {
      bool isBreaked = false;
      List<CreateInvitedGuestRequest> invitedGuestRequests = [];
      for (int i = 0; i < _invitedGuestControllers.length; i++) {
        final controller = _invitedGuestControllers[i];
        if (controller.name.text.isEmpty || controller.phone.text.isEmpty || controller.instance.text.isEmpty) {
          GeneralDialog.showValidateStateError('Field mandatory tidak boleh kosong', durationInSeconds: 5);
          await Future.delayed(const Duration(milliseconds: 200));
          _scrollController.jumpTo(18 + 60 + 14 + (272 * (i.toDouble())));
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
        invitedGuestRequests.add(
          CreateInvitedGuestRequest(
            invitationId: _invitationId!,
            name: controller.name.text,
            phone: controller.phone.text,
            nameInstance: '${controller.name.text.replaceAll(' ', '-')}_${controller.instance.text.replaceAll(' ', '-')}',
            souvenir: controller.souvenir.text.isEmpty ? null : controller.souvenir.text,
          ),
        );
      }

      if (isBreaked) return;
      if (invitedGuestRequests.isEmpty) {
        GeneralDialog.showValidateStateError('Minimal isi satu Form Tamu', durationInSeconds: 5);
        return;
      }

      final success = await _invitedGuestCubit.upsertCreate(BulkCreateInvitedGuestRequest(invitedGuests: invitedGuestRequests));
      if (success) {
        _invitedGuestFormCubit.invitedGuestsCreateCache([]);
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

    if (!_invitedGuestFormCubit.state.isCreateImportedView) {
      final invitedGuestsCache = _invitedGuestFormCubit.state.invitedGuestsCreateCache;
      if (invitedGuestsCache.isNotEmpty) {
        for (int i = 0; i < invitedGuestsCache.length; i++) {
          _invitedGuestControllers.add(
            InvitedGuestController(
              name: TextEditingController(),
              phone: TextEditingController(),
              instance: TextEditingController(),
              souvenir: TextEditingController(),
              nominal: TextEditingController(),
            ),
          );
          _invitedGuestControllers[i].name.text = invitedGuestsCache[i].name;
          _invitedGuestControllers[i].phone.text = invitedGuestsCache[i].phone;
          _invitedGuestControllers[i].instance.text = invitedGuestsCache[i].instance;
          _invitedGuestControllers[i].souvenir.text = invitedGuestsCache[i].souvenir;
        }
      } else {
        _invitedGuestFormCubit.isCreateImportedView(true);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<InvitedGuestFormCubit, InvitedGuestFormState, bool>(
      selector: (state) => state.isCreateImportedView,
      builder: (context, isCreateImportedView) {
        if (isCreateImportedView) {
          return ImportInvitedGuest(
            invitationId: _invitationId ?? '',
            onCompleted: (values) {
              if (values.isEmpty) {
                _invitedGuestControllers.add(
                  InvitedGuestController(
                    name: TextEditingController(),
                    phone: TextEditingController(),
                    instance: TextEditingController(),
                    souvenir: TextEditingController(),
                    nominal: TextEditingController(),
                  ),
                );
              } else {
                for (int i = 0; i < values.length; i++) {
                  _invitedGuestControllers.add(
                    InvitedGuestController(
                      name: TextEditingController(),
                      phone: TextEditingController(),
                      instance: TextEditingController(),
                      souvenir: TextEditingController(),
                      nominal: TextEditingController(),
                    ),
                  );
                  _invitedGuestControllers[i].name.text = values[i].name;
                  _invitedGuestControllers[i].phone.text = values[i].phone;
                  _invitedGuestControllers[i].instance.text = values[i].instance;
                }
              }

              _invitedGuestFormCubit.isCreateImportedView(false);
            },
          );
        }

        final size = MediaQuery.of(context).size;

        return SizedBox(
          height: size.height - 80,
          child: Column(
            mainAxisSize: .min,
            children: [
              Flexible(
                child: AddInvitedGuestForm(
                  scrollController: _scrollController,
                  invitationId: _invitationId ?? '',
                  controllers: _invitedGuestControllers,
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
                              _localeCubit.state.languageCode == 'id' ? 'Upsert Tamu Undangan' : 'Upsert Invited Guests',
                              style: AppFonts.nunito(color: Colors.white, fontSize: 15, fontWeight: .w800),
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
      },
    );
  }
}
