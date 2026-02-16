import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:iv_dashboard_project_web_app/pages/dashboard/widgets/general_title_app_bar.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/widgets/invited_guests_presentation.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/widgets/scan_qr_portal.dart';
import 'package:iv_project_core/iv_project_core.dart';

import 'package:iv_project_model/iv_project_model.dart';
import 'package:iv_project_web_data/iv_project_web_data.dart';
import 'package:iv_project_widget_core/iv_project_widget_core.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = true;
  bool _isContainsError = false;

  String? _invitationId;
  InvitationResponse? _invitation;

  late final LocaleCubit _localeCubit;
  late final InvitedGuestCubit _invitedGuestCubit;

  Future<void> _getInvitationById(String id) async {
    setState(() => _isLoading = true);
    _invitedGuestCubit.state.copyWith(isLoadingGetsByInvitationId: true).emitState();

    final url = Uri.parse('${ApiUrl.value}/invitation/id/$id');
    try {
      _isContainsError = false;
      final response = await http.get(url, headers: {'ngrok-skip-browser-warning': 'true'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _invitation = InvitationResponse.fromJson(data['data']);

        if (_invitation != null) {
          _localeCubit.set(
            _invitation!.invitationData.general.lang == LangType.en ? const Locale('en', 'US') : const Locale('id', 'ID'),
            reloadLangAssets: false,
          );
        }
      }
      setState(() => _isLoading = false);
    } catch (_) {
      _isContainsError = true;
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();

    _localeCubit = context.read<LocaleCubit>();
    _invitedGuestCubit = context.read<InvitedGuestCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _invitationId = Uri.base.queryParameters['id'];
      if (_invitationId == null) {
        setState(() => _isLoading = false);
        return;
      }
      await _getInvitationById(_invitationId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ColoredBox(
        color: ColorConverter.lighten(AppColor.primaryColor, 94),
        child: const Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 24 / 5.2, color: AppColor.primaryColor),
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;

    if (_isContainsError) {
      return SizedBox(
        height: size.height,
        child: RetryWidget(
          errorMessage: _localeCubit.state.languageCode == 'id'
              ? 'Oops. Gagal memuat undangan.'
              : 'Oops. Failed to fetch invitation',
          onRetry: () => _getInvitationById(_invitationId!),
        ),
      );
    }

    if (_invitationId == null || _invitation == null) {
      return SizedBox(
        height: size.height,
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Spacer(),
            Text(
              _localeCubit.state.languageCode == 'id' ? 'Undangan tidak ditemukan' : 'Invitation not found.',
              style: const TextStyle(fontSize: 18, fontWeight: .w800),
            ),
            const Spacer(),
            Text(
              _localeCubit.state.languageCode == 'id' ? 'Ingin membuat undanganmu sendiri?' : 'Want to make your own invitation?',
              style: const TextStyle(fontSize: 16, fontWeight: .w500),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: .center,
              children: [
                Text(
                  _localeCubit.state.languageCode == 'id' ? 'Unduh Aplikasi' : 'Download',
                  style: const TextStyle(fontSize: 16, fontWeight: .w800),
                ),
                const SizedBox(width: 6),
                Image.asset('assets/logos/in_vite_logo.png', height: 20, fit: .fitHeight),
                const SizedBox(width: 6),
                if (_localeCubit.state.languageCode == 'en') const Text('App', style: TextStyle(fontSize: 16, fontWeight: .w800)),
              ],
            ),
            GeneralEffectsButton(
              onTap: () {},
              height: 60,
              child: Image.asset('assets/get_it_on_google_play.png', height: 50, fit: .fitHeight),
            ),
            const SizedBox(height: 44),
          ],
        ),
      );
    }

    final invitationData = _invitation!.invitationData;

    return Stack(
      alignment: .topCenter,
      children: [
        SizedBox(
          height: size.height,
          width: size.width,
          child: ColoredBox(
            color: ColorConverter.lighten(AppColor.primaryColor, 94),
            child: Column(
              children: [
                const SizedBox(height: kToolbarHeight),
                Expanded(
                  child: InvitedGuestsPresentation(
                    invitationId: _invitationId!,
                    brideName: _invitation!.invitationData.bride.nickname,
                    groomName: _invitation!.invitationData.groom.nickname,
                  ),
                ),
              ],
            ),
          ),
        ),
        GeneralTitleAppBar(
          title: LayoutBuilder(
            builder: (_, constraints) => RunningText(
              text:
                  '\t\t${_localeCubit.state.languageCode == 'id' ? 'Dashboard Tamu Undangan Pernikahan' : 'Wedding Invited Guest Dashboard'} - ${invitationData.bride.nickname} & ${invitationData.groom.nickname}',
              textStyle: const TextStyle(fontSize: 16, fontWeight: .w700, color: Colors.white),
              constraints: constraints,
            ),
          ),
          leftAction: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const .only(topRight: .circular(20), bottomRight: .circular(20)),
              border: Border(
                top: BorderSide(color: ColorConverter.lighten(AppColor.primaryColor, 40), width: 2),
                right: BorderSide(color: ColorConverter.lighten(AppColor.primaryColor, 40), width: 2),
                bottom: BorderSide(color: ColorConverter.lighten(AppColor.primaryColor, 40), width: 2),
              ),
            ),
            child: Padding(
              padding: const .only(left: 14, right: 10, top: 7, bottom: 7),
              child: Image.asset('assets/logos/in_vite_logo.png', height: 24, fit: .fitHeight),
            ),
          ),
          rightAction: ScanQrPortal(
            onDetectCompleted: () {
              final invitedGuest = _invitedGuestCubit.state.invitedGuest;
              if (invitedGuest == null) return;
              final souvenir = invitedGuest.souvenir;

              ShowModal.bottomSheet(
                context,
                barrierColor: Colors.grey.shade700.withValues(alpha: .5),
                dismissible: false,
                header: BottomSheetHeader(
                  title: const HeaderTitle.handleBar(),
                  action: HeaderAction(
                    actionIcon: Icons.close_rounded,
                    iconColor: Colors.grey.shade600,
                    onTap: () => NavigationService.pop(),
                  ),
                ),
                decoration: BottomSheetDecoration(
                  color: ColorConverter.lighten(AppColor.primaryColor, 94),
                  borderRadius: const .only(topLeft: .circular(20), topRight: .circular(20)),
                ),
                contentBuilder: (_) => Padding(
                  padding: const .symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        _localeCubit.state.languageCode == 'id' ? 'Detail Tamu Undangan' : 'Invited Guest Detail',
                        style: const TextStyle(fontWeight: .w800, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            _localeCubit.state.languageCode == 'id' ? 'Nama :' : 'Name :',
                            style: const TextStyle(fontSize: 15),
                          ),
                          const Spacer(),
                          Text(invitedGuest.name, style: const TextStyle(fontSize: 15, fontWeight: .w500)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _localeCubit.state.languageCode == 'id' ? 'Instansi/Dari :' : 'Instance/From :',
                            style: const TextStyle(fontSize: 15),
                          ),
                          const Spacer(),
                          Text(
                            invitedGuest.nameInstance.split('_').last.replaceAll('-', ' '),
                            style: const TextStyle(fontSize: 15, fontWeight: .w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (invitedGuest.phone != null) ...[
                        Row(
                          children: [
                            const Text('WhatsApp :', style: TextStyle(fontSize: 15)),
                            const Spacer(),
                            Text(invitedGuest.phone!, style: const TextStyle(fontSize: 15, fontWeight: .w500)),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          const Text('Souvenir :', style: TextStyle(fontSize: 15)),
                          const Spacer(),
                          Text(
                            souvenir == null
                                ? '-'
                                : _localeCubit.state.languageCode == 'id'
                                ? 'Tipe - $souvenir'
                                : 'Type - $souvenir',
                            style: const TextStyle(fontSize: 15, fontWeight: .w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
