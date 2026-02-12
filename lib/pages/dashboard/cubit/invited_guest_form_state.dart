part of 'invited_guest_form_cubit.dart';

class InvitedGuestFormState extends Equatable {
  const InvitedGuestFormState({
    this.isCreateImportedView = true,
    this.invitedGuestsCreateCache = const [],
    this.invitedGuestsEditCache = const [],
  });

  final bool isCreateImportedView;
  final List<InvitedGuestFormCache> invitedGuestsCreateCache;
  final List<InvitedGuestFormCache> invitedGuestsEditCache;

  InvitedGuestFormState copyWith({
    bool? isCreateImportedView,
    List<InvitedGuestFormCache>? invitedGuestsCreateCache,
    List<InvitedGuestFormCache>? invitedGuestsEditCache,
  }) {
    return InvitedGuestFormState(
      isCreateImportedView: isCreateImportedView ?? this.isCreateImportedView,
      invitedGuestsCreateCache: invitedGuestsCreateCache ?? this.invitedGuestsCreateCache,
      invitedGuestsEditCache: invitedGuestsEditCache ?? this.invitedGuestsEditCache,
    );
  }

  void emitState() => GlobalContextService.value.read<InvitedGuestFormCubit>().emitState(this);

  @override
  List<Object?> get props => [isCreateImportedView, invitedGuestsCreateCache, invitedGuestsEditCache];
}
