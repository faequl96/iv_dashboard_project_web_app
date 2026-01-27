import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iv_project_core/iv_project_core.dart';
import 'package:iv_project_model/iv_project_model.dart';
import 'package:iv_project_web_data/iv_project_web_data.dart';
import 'package:iv_project_widget_core/iv_project_widget_core.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

class InvitedGuestsPresentation extends StatefulWidget {
  const InvitedGuestsPresentation({
    super.key,
    required this.controller,
    required this.invitationId,
    required this.brideName,
    required this.groomName,
  });

  final TextEditingController controller;
  final String invitationId;
  final String brideName;
  final String groomName;

  @override
  State<InvitedGuestsPresentation> createState() => _InvitedGuestsPresentationState();
}

class _InvitedGuestsPresentationState extends State<InvitedGuestsPresentation> {
  String? _invitationId;

  late final LocaleCubit _localeCubit;
  late final InvitedGuestCubit _invitedGuestCubit;

  @override
  void initState() {
    super.initState();

    _localeCubit = context.read<LocaleCubit>();
    _invitedGuestCubit = context.read<InvitedGuestCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _invitationId = Uri.base.queryParameters['id'];
      if (_invitationId != null) await _invitedGuestCubit.getsByInvitationId(_invitationId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<InvitedGuestCubit, InvitedGuestState, bool>(
      selector: (state) => state.isLoadingGetsByInvitationId || state.isLoadingUpsert || state.isLoadingUpdateById,
      builder: (context, isLoading) {
        final isContainsError = _invitedGuestCubit.state.isContainsError;
        final invitedGuests = _invitedGuestCubit.state.invitedGuests ?? [];

        return ListView(
          padding: const .only(top: 14, bottom: 8),
          children: [
            if (isLoading) ...[
              for (int i = 0; i < 4; i++) const _RSVPItemSkeleton(),
            ] else if (isContainsError) ...[
              SizedBox(
                height: MediaQuery.of(context).size.height - 100,
                child: RetryWidget(
                  errorMessage: _localeCubit.state.languageCode == 'id'
                      ? 'Oops. Gagal memuat undangan.'
                      : 'Oops. Failed to fetch invitation',
                  onRetry: () async {
                    if (_invitationId != null) await _invitedGuestCubit.getsByInvitationId(_invitationId!);
                  },
                ),
              ),
            ] else if (invitedGuests.isNotEmpty) ...[
              for (int i = 0; i < invitedGuests.length; i++)
                _InvitedGuestItem(
                  controller: widget.controller,
                  invitationId: widget.invitationId,
                  brideName: widget.brideName,
                  groomName: widget.groomName,
                  invitedGuest: invitedGuests[i],
                ),
            ] else ...[
              SizedBox(
                height: MediaQuery.of(context).size.height - 100,
                child: Center(
                  child: Text(
                    _localeCubit.state.languageCode == 'id'
                        ? 'Tamu undangan belum ditambahkan'
                        : 'Invited guests have not been added',
                    style: AppFonts.nunito(fontSize: 15, fontWeight: .w700),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _InvitedGuestItem extends StatelessWidget {
  const _InvitedGuestItem({
    required this.invitedGuest,
    required this.invitationId,
    required this.brideName,
    required this.groomName,
    required this.controller,
  });

  final TextEditingController controller;
  final String invitationId;
  final String brideName;
  final String groomName;
  final InvitedGuestResponse invitedGuest;

  @override
  Widget build(BuildContext context) {
    final localeCubit = context.read<LocaleCubit>();

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
                          '${invitedGuest.nickname} - ${invitedGuest.nameInstance.split('_').last.replaceAll('-', ' ')}',
                          style: AppFonts.nunito(fontWeight: .w700, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const .only(right: 8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: ColorConverter.lighten(AppColor.primaryColor, 75),
                        borderRadius: .circular(20),
                      ),
                      child: Padding(
                        padding: const .symmetric(vertical: 3, horizontal: 4),
                        child: GeneralEffectsButton(
                          onTap: () async {
                            final phone = invitedGuest.phone;
                            if (phone == null) return;
                            final phoneNumber = phone[0] == '0' ? phone.replaceFirst('0', '62') : phone;
                            final message = controller.text
                                .replaceAll('{nama_tamu}', invitedGuest.nickname)
                                .replaceAll('{link_undangan}', '${Uri.base.origin}?id=$invitationId&to=${invitedGuest.id}')
                                .replaceAll('{mempelai_wanita}', brideName)
                                .replaceAll('{mempelai_pria}', groomName);
                            final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

                            if (await canLaunchUrl(.parse(url))) {
                              await launchUrl(.parse(url), mode: .externalApplication);
                            } else {
                              GeneralDialog.showValidateStateError(
                                localeCubit.state.languageCode == 'id' ? 'Tidak dapat membuka WhatsApp' : 'Can\'t open WhatsApp',
                                durationInSeconds: 5,
                              );
                            }
                          },
                          padding: const .symmetric(horizontal: 20, vertical: 5),
                          color: AppColor.primaryColor,
                          splashColor: Colors.white,
                          borderRadius: .circular(30),
                          child: Text(
                            localeCubit.state.languageCode == 'id' ? 'Kirim' : 'Send',
                            style: AppFonts.nunito(color: Colors.white, fontWeight: .w700),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (invitedGuest.phone != null)
            Padding(
              padding: const .symmetric(horizontal: 14),
              child: Row(
                children: [
                  Text('WhatsApp :', style: AppFonts.nunito()),
                  const Spacer(),
                  Text(invitedGuest.phone!, style: AppFonts.nunito()),
                ],
              ),
            ),
          if (invitedGuest.souvenir != null)
            Padding(
              padding: const .symmetric(horizontal: 14),
              child: Row(
                children: [
                  Text('Souvenir :', style: AppFonts.nunito()),
                  const Spacer(),
                  Text(
                    localeCubit.state.languageCode == 'id'
                        ? 'Tipe - ${invitedGuest.souvenir!}'
                        : 'Type - ${invitedGuest.souvenir!}',
                    style: AppFonts.nunito(),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const .symmetric(horizontal: 14),
            child: Row(
              children: [
                Text(localeCubit.state.languageCode == 'id' ? 'Kehadiran :' : 'Attendance :', style: AppFonts.nunito()),
                const Spacer(),
                if (invitedGuest.attendance != null)
                  Text(
                    invitedGuest.attendance! == true
                        ? localeCubit.state.languageCode == 'id'
                              ? 'Hadir'
                              : 'Present'
                        : localeCubit.state.languageCode == 'id'
                        ? 'Tidak Hadir'
                        : 'Not Present',
                    style: AppFonts.nunito(),
                  )
                else
                  Text(invitedGuest.possiblePresence ?? '-', style: AppFonts.nunito()),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _RSVPItemSkeleton extends StatelessWidget {
  const _RSVPItemSkeleton();

  @override
  Widget build(BuildContext context) {
    final localeCubit = context.read<LocaleCubit>();

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
                        child: Row(
                          children: [
                            SkeletonBox(width: Random().nextInt(50) + 70, height: 15),
                            Text('', style: AppFonts.nunito(fontWeight: .w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const .only(right: 8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: ColorConverter.lighten(AppColor.primaryColor, 75),
                        borderRadius: .circular(20),
                      ),
                      child: const Padding(
                        padding: .symmetric(vertical: 3, horizontal: 4),
                        child: SkeletonBox(width: 72, height: 30, borderRadius: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const .symmetric(horizontal: 14),
            child: Row(
              children: [
                Text('WhatsApp :', style: AppFonts.nunito()),
                const Spacer(),
                SkeletonBox(width: Random().nextInt(20) + 80, height: 14),
              ],
            ),
          ),
          Padding(
            padding: const .symmetric(horizontal: 14),
            child: Row(
              children: [
                Text('Souvenir :', style: AppFonts.nunito()),
                const Spacer(),
                const SkeletonBox(width: 50, height: 14),
              ],
            ),
          ),
          Padding(
            padding: const .symmetric(horizontal: 14),
            child: Row(
              children: [
                Text(localeCubit.state.languageCode == 'id' ? 'Kehadiran :' : 'Attendance :', style: AppFonts.nunito()),
                const Spacer(),
                SkeletonBox(width: Random().nextInt(50) + 50, height: 14),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
