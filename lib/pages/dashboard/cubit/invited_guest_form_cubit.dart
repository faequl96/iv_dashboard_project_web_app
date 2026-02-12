import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iv_dashboard_project_web_app/models/invited_guest_form_cache.dart';
import 'package:iv_project_core/iv_project_core.dart';

part 'invited_guest_form_state.dart';

class InvitedGuestFormCubit extends Cubit<InvitedGuestFormState> {
  InvitedGuestFormCubit() : super(const InvitedGuestFormState());

  void emitState(InvitedGuestFormState state) => emit(state);

  void isCreateImportedView(bool value) => emit(state.copyWith(isCreateImportedView: value));
  void invitedGuestsCreateCache(List<InvitedGuestFormCache> value) => emit(state.copyWith(invitedGuestsCreateCache: value));
  void invitedGuestsEditCache(List<InvitedGuestFormCache> value) => emit(state.copyWith(invitedGuestsEditCache: value));
}
