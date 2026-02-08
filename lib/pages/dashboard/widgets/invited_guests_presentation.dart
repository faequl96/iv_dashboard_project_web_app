import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/widgets/add_invited_guest_portal.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/widgets/edit_message_portal.dart';
import 'package:iv_project_core/iv_project_core.dart';
import 'package:iv_project_model/iv_project_model.dart';
import 'package:iv_project_web_data/iv_project_web_data.dart';
import 'package:iv_project_widget_core/iv_project_widget_core.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

class InvitedGuestsPresentation extends StatefulWidget {
  const InvitedGuestsPresentation({super.key, required this.invitationId, required this.brideName, required this.groomName});

  final String invitationId;
  final String brideName;
  final String groomName;

  @override
  State<InvitedGuestsPresentation> createState() => _InvitedGuestsPresentationState();
}

class _InvitedGuestsPresentationState extends State<InvitedGuestsPresentation> {
  final _searchController = TextEditingController();
  final _messageController = TextEditingController();

  final _messages = [
    'Kepada Yth. \n{nama_tamu} \n\nDengan memohon rahmat dan ridha Tuhan Yang Maha Esa, kami bermaksud mengundang Anda untuk hadir pada hari bahagia kami. Pada momen istimewa ini, kami berharap dapat berbagi kebahagiaan dengan orang-orang terdekat yang memiliki tempat khusus dalam perjalanan hidup kami. \n\nDetail acara dapat Anda lihat melalui undangan digital berikut: \n{link_undangan} \n\nKehadiran {nama_tamu} akan melengkapi kebahagiaan kami dan menjadi doa restu yang sangat berarti. \n\nDengan penuh rasa syukur, \n{mempelai_wanita} & {mempelai_pria}',
    'Kepada Yth. \n{nama_tamu} \n\nDengan penuh rasa syukur dan kebahagiaan, kami mengundang Anda untuk menghadiri hari bersejarah dalam hidup kami. Setelah melalui perjalanan panjang penuh doa, harapan, dan ikhtiar, akhirnya kami akan memulai babak baru sebagai pasangan suami istri. \n\nAkan menjadi kebahagiaan tersendiri bagi kami apabila Anda, dapat hadir dan menyaksikan momen sakral ini. Kehadiran {nama_tamu} akan melengkapi kebahagiaan kami dan menjadi doa restu yang sangat berarti. \n\nDetail acara dapat Anda lihat melalui undangan digital berikut: \n{link_undangan} \n\nDengan penuh rasa syukur, \n{mempelai_wanita} & {mempelai_pria}',
    'Kepada Yth. \n{nama_tamu} \n\nDengan penuh kasih dan harapan, kami mengundang Anda untuk menjadi saksi awal kisah baru kami. Pada hari ketika dua hati dipersatukan dalam ikatan suci. \n\nAkan menjadi kebahagiaan tersendiri bagi kami apabila Anda, yang telah menjadi bagian dari cerita dan perjalanan kami, dapat hadir dan menyaksikan momen sakral ini. \n\nDetail acara dapat Anda lihat melalui undangan digital berikut: \n{link_undangan} \n\nKehadiran {nama_tamu} akan melengkapi kebahagiaan kami dan menjadi doa restu yang sangat berarti. \n\nDengan penuh rasa syukur, \n{mempelai_wanita} & {mempelai_pria}',
  ];

  final _activeTab = ValueNotifier(0);

  late final LocaleCubit _localeCubit;
  late final InvitedGuestCubit _invitedGuestCubit;

  @override
  void initState() {
    super.initState();

    _localeCubit = context.read<LocaleCubit>();
    _invitedGuestCubit = context.read<InvitedGuestCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _invitedGuestCubit.getsByInvitationId(widget.invitationId);

      _messageController.text = _messages[2];
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<InvitedGuestCubit, InvitedGuestState, bool>(
      selector: (state) => state.isLoadingGetsByInvitationId || state.isLoadingUpsert || state.isLoadingUpdateById,
      builder: (context, isLoading) {
        final isContainsError = _invitedGuestCubit.state.isContainsError;
        final invitedGuests = _invitedGuestCubit.state.invitedGuests ?? [];

        final inviteds = invitedGuests.where((e) => !e.nameInstance.contains('Guest')).toList();
        final guests = invitedGuests.where((e) => e.nameInstance.contains('Guest')).toList();

        return DefaultTabController(
          length: 2,
          child: Stack(
            alignment: .topCenter,
            children: [
              Padding(
                padding: const .only(top: 48),
                child: TabBarView(
                  children: [
                    Column(
                      children: [
                        if (isLoading)
                          Expanded(
                            child: ListView(
                              padding: const .only(top: 14, bottom: 8),
                              children: [for (int i = 0; i < 4; i++) const _RSVPItemSkeleton()],
                            ),
                          )
                        else if (isContainsError)
                          Expanded(
                            child: ListView(
                              padding: const .only(top: 14, bottom: 8),
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height - 100,
                                  child: RetryWidget(
                                    errorMessage: _localeCubit.state.languageCode == 'id'
                                        ? 'Oops. Gagal memuat data tamu undangan.'
                                        : 'Oops. Failed to fetch invited guest data',
                                    onRetry: () async {
                                      await _invitedGuestCubit.getsByInvitationId(widget.invitationId);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (inviteds.isNotEmpty)
                          Expanded(
                            child: _InvitedGuests(
                              items: inviteds,
                              invitationId: widget.invitationId,
                              brideName: widget.brideName,
                              groomName: widget.groomName,
                              messageController: _messageController,
                            ),
                          )
                        else
                          Expanded(
                            child: ListView(
                              padding: const .only(top: 14, bottom: 8),
                              children: [
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
                            ),
                          ),
                      ],
                    ),
                    ListView(
                      padding: const .only(top: 14, bottom: 8),
                      children: [
                        for (int i = 0; i < guests.length; i++)
                          _InvitedGuestItem(
                            index: i,
                            invitationId: widget.invitationId,
                            brideName: widget.brideName,
                            groomName: widget.groomName,
                            invitedGuest: guests[i],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Card(
                margin: EdgeInsets.zero,
                color: Colors.white,
                shape: const RoundedRectangleBorder(),
                child: TabBar(
                  onTap: (value) {
                    if (!isLoading) _activeTab.value = value;
                  },
                  labelColor: AppColor.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  dividerHeight: 0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 5,
                  indicator: const UnderlineTabIndicator(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                    borderSide: BorderSide(width: 6, color: AppColor.primaryColor),
                  ),
                  tabs: [
                    const Tab(
                      height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.drafts), SizedBox(width: 8), Text('Tamu Diundang')],
                      ),
                    ),
                    Tab(
                      height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people, color: isLoading ? Colors.grey.shade400 : AppColor.primaryColor),
                          const SizedBox(width: 8),
                          Text('Tamu Guest', style: TextStyle(color: isLoading ? Colors.grey.shade400 : null)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder(
                valueListenable: _activeTab,
                builder: (_, value, _) {
                  if (value != 0) return const SizedBox.shrink();
                  return Positioned(
                    bottom: 20,
                    child: Row(
                      children: [
                        const AddInvitedGuestPortal(),
                        const SizedBox(width: 10),
                        EditMessagePortal(controller: _messageController, messages: _messages),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InvitedGuests extends StatefulWidget {
  const _InvitedGuests({
    required this.items,
    required this.invitationId,
    required this.brideName,
    required this.groomName,
    required this.messageController,
  });

  final List<InvitedGuestResponse> items;
  final String invitationId;
  final String brideName;
  final String groomName;
  final TextEditingController messageController;

  @override
  State<_InvitedGuests> createState() => _InvitedGuestsState();
}

class _InvitedGuestsState extends State<_InvitedGuests> {
  final _searchController = TextEditingController();

  bool _isSearch = false;

  final List<InvitedGuestResponse> invitedGuests = [];

  @override
  void initState() {
    super.initState();

    invitedGuests.addAll(widget.items);
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const .only(top: 18, bottom: 8),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
          child: GeneralTextField(
            controller: _searchController,
            height: 46,
            autofocus: true,
            decoration: FieldDecoration(
              hintText: 'Cari : WhatsApp, Nama, Instansi',
              filled: true,
              fillColor: Colors.white,
              contentHorizontalPadding: 20,
              suffixIcons: () {
                if (_searchController.text.isEmpty) return [];
                return [SharedPersonalize.suffixClear(() => _searchController.clear())];
              },
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(50),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(50),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                _isSearch = true;
                invitedGuests.clear();
                final keyword = value.toLowerCase();
                bool isMatch(InvitedGuestResponse e) {
                  final isPhoneMatch = (e.phone ?? '').toLowerCase().contains(keyword);
                  final isNicknameMatch = e.nickname.toLowerCase().contains(keyword);
                  final isNameInstanceMatch = e.nameInstance.toLowerCase().contains(keyword);
                  return isPhoneMatch || isNicknameMatch || isNameInstanceMatch;
                }

                final matches = widget.items.where((e) => isMatch(e));
                invitedGuests.addAll(matches);
              } else {
                _isSearch = false;
                invitedGuests.clear();
                invitedGuests.addAll(widget.items);
              }

              setState(() {});
            },
          ),
        ),
        for (int i = 0; i < invitedGuests.length; i++)
          _InvitedGuestItem(
            index: _isSearch ? null : i,
            controller: widget.messageController,
            invitationId: widget.invitationId,
            brideName: widget.brideName,
            groomName: widget.groomName,
            invitedGuest: invitedGuests[i],
          ),
      ],
    );
  }
}

class _InvitedGuestItem extends StatelessWidget {
  const _InvitedGuestItem({
    this.index,
    required this.invitedGuest,
    required this.invitationId,
    required this.brideName,
    required this.groomName,
    this.controller,
  });

  final int? index;
  final InvitedGuestResponse invitedGuest;
  final String invitationId;
  final String brideName;
  final String groomName;
  final TextEditingController? controller;

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
                          '${index != null ? "${index! + 1}. " : ""}${invitedGuest.nameInstance == 'Guest' ? invitedGuest.nickname : invitedGuest.nameInstance.replaceAll('-', ' ').replaceAll('_', ' - ')}',
                          style: AppFonts.nunito(fontWeight: .w700, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  if (controller != null)
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
                              final message = controller!.text
                                  .replaceAll('{nama_tamu}', invitedGuest.nickname)
                                  .replaceAll(
                                    '{link_undangan}',
                                    'https://iv-project-web-app.vercel.app/?id=$invitationId&to=${invitedGuest.id}',
                                  )
                                  .replaceAll('{mempelai_wanita}', brideName)
                                  .replaceAll('{mempelai_pria}', groomName);
                              final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

                              if (await canLaunchUrl(.parse(url))) {
                                await launchUrl(.parse(url), mode: .externalApplication);
                              } else {
                                GeneralDialog.showValidateStateError(
                                  localeCubit.state.languageCode == 'id'
                                      ? 'Tidak dapat membuka WhatsApp'
                                      : 'Can\'t open WhatsApp',
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
                  invitedGuest.attendance! == true
                      ? Text(
                          localeCubit.state.languageCode == 'id' ? 'Hadir' : 'Present',
                          style: AppFonts.nunito(color: Colors.greenAccent.shade700, fontWeight: FontWeight.bold),
                        )
                      : Text(
                          localeCubit.state.languageCode == 'id' ? 'Tidak Hadir' : 'Not Present',
                          style: AppFonts.nunito(color: Colors.red, fontWeight: FontWeight.bold),
                        )
                else
                  Text(
                    invitedGuest.possiblePresence ?? '-',
                    style: AppFonts.nunito(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
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
