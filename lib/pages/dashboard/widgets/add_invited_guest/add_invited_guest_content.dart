import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iv_dashboard_project_web_app/models/invited_guest_controller.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/cubit/invited_guest_form_cubit.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/widgets/add_invited_guest/import_invited_guest.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/widgets/add_invited_guest/invited_guest_form.dart';
import 'package:iv_project_core/iv_project_core.dart';
import 'package:iv_project_web_data/iv_project_web_data.dart';

class AddInvitedGuestContent extends StatefulWidget {
  const AddInvitedGuestContent({super.key});

  @override
  State<AddInvitedGuestContent> createState() => _AddInvitedGuestContentState();
}

class _AddInvitedGuestContentState extends State<AddInvitedGuestContent> {
  String? _invitationId;

  final _invitedGuestControllers = <InvitedGuestController>[];

  late final InvitedGuestCubit _invitedGuestCubit;
  late final InvitedGuestFormCubit _invitedGuestFormCubit;
  late final LocaleCubit _localeCubit;

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
            ),
          );
          _invitedGuestControllers[i].name.text = invitedGuestsCache[i].name;
          _invitedGuestControllers[i].phone.text = invitedGuestsCache[i].phone;
          _invitedGuestControllers[i].instance.text = invitedGuestsCache[i].instance;
          _invitedGuestControllers[i].souvenir.text = invitedGuestsCache[i].souvenir;
        }
      } else {
        _invitedGuestControllers.add(
          InvitedGuestController(
            name: TextEditingController(),
            phone: TextEditingController(),
            instance: TextEditingController(),
            souvenir: TextEditingController(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<InvitedGuestFormCubit, InvitedGuestFormState, bool>(
      selector: (state) => state.isCreateImportedView,
      builder: (context, isCreateImportedView) {
        if (isCreateImportedView) {
          return ImportInvitedGuest(
            onCompleted: (values) {
              if (values.isEmpty) {
                _invitedGuestControllers.add(
                  InvitedGuestController(
                    name: TextEditingController(),
                    phone: TextEditingController(),
                    instance: TextEditingController(),
                    souvenir: TextEditingController(),
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
                    ),
                  );
                  _invitedGuestControllers[i].name.text = values[i].name;
                  _invitedGuestControllers[i].phone.text = values[i].phone;
                  _invitedGuestControllers[i].instance.text = values[i].instance ?? '';
                  _invitedGuestControllers[i].souvenir.text = values[i].souvenir ?? '';
                }
              }

              _invitedGuestFormCubit.isCreateImportedView(false);
            },
          );
        }

        return InvitedGuestForm(controllers: _invitedGuestControllers);
      },
    );
  }
}
