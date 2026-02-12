import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iv_dashboard_project_web_app/models/invited_guest_import_model.dart';
import 'package:iv_project_core/iv_project_core.dart';
import 'package:iv_project_widget_core/iv_project_widget_core.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class ImportInvitedGuest extends StatefulWidget {
  const ImportInvitedGuest({super.key, required this.onCompleted});

  final Function(List<InvitedGuestImportModel> values) onCompleted;

  @override
  State<ImportInvitedGuest> createState() => _ImportInvitedGuestState();
}

class _ImportInvitedGuestState extends State<ImportInvitedGuest> {
  late final LocaleCubit _localeCubit;

  Future<void> _downloadExcelAsset() async {
    final data = await rootBundle.load('assets/templates/formulir_tamu_undangan.xlsx');
    final bytes = data.buffer.asUint8List();
    await FileSaver.instance.saveFile(name: 'formulir_tamu_undangan', bytes: bytes, mimeType: MimeType.microsoftExcel);
  }

  Future<PlatformFile?> _pickExcelFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'xls'], withData: true);
    if (result == null) return null;
    return result.files.first;
  }

  Future<void> _importInvitedGuests() async {
    try {
      final file = await _pickExcelFile();
      final fileBytes = file?.bytes;
      if (fileBytes == null) {
        GeneralDialog.showValidateStateError(
          _localeCubit.state.languageCode == 'id' ? 'Tidak ada file yang dipilih' : 'No files selected',
          durationInSeconds: 5,
        );
        return;
      }

      final excel = Excel.decodeBytes(fileBytes);

      final sheet = excel.tables.keys.first;
      final rows = excel.tables[sheet]!.rows;

      bool isBreaked = false;
      List<InvitedGuestImportModel> invitedGuests = [];

      for (int i = 0; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        final name = row[0]?.value?.toString();
        final whatsapp = row[1]?.value?.toString();
        final instance = row[2]?.value?.toString() ?? '';
        final souvenir = row[3]?.value?.toString();

        if (name == null || whatsapp == null) {
          isBreaked = true;
          GeneralDialog.showValidateStateError('Semua kolom "Nama" dan "WhatsApp" wajib diisi', durationInSeconds: 5);
          break;
        }

        if (name.contains('cth') || instance.contains('cth') || whatsapp.contains('cth') || (souvenir ?? '').contains('cth')) {
          continue;
        }

        invitedGuests.add(InvitedGuestImportModel(name: name, phone: whatsapp, instance: instance, souvenir: souvenir));
      }

      if (isBreaked) {
        widget.onCompleted([]);
      } else {
        widget.onCompleted(invitedGuests);
      }
    } catch (e) {
      GeneralDialog.showValidateStateError('$e', durationInSeconds: 5);
    }
  }

  @override
  void initState() {
    super.initState();

    _localeCubit = context.read<LocaleCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: [
        Padding(
          padding: const .symmetric(horizontal: 16),
          child: CardContainer(
            color: Colors.white,
            borderRadius: 10,
            child: Padding(
              padding: const .all(14),
              child: Column(
                mainAxisSize: .min,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    _localeCubit.state.languageCode == 'id'
                        ? 'Import Tamu Undangan dari Excel'
                        : 'Import Invited Guest from Excel',
                    style: AppFonts.nunito(color: AppColor.primaryColor, fontSize: 17, fontWeight: .w800, height: 1.2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _localeCubit.state.languageCode == 'id'
                        ? 'Silahkan unduh dan isi Formulir tamu undangan dibawah ini.'
                        : 'Please download and fill out the guest invitation Form below.',
                    style: AppFonts.nunito(fontSize: 15),
                    textAlign: .center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _localeCubit.state.languageCode == 'id'
                        ? 'Jika telah mengisi, silahkan import Formulir tersebut.'
                        : 'If you have filled it in, please import the Form.',
                    style: AppFonts.nunito(fontSize: 15),
                    textAlign: .center,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: GeneralEffectsButton(
                          onTap: _downloadExcelAsset,
                          width: .maxFinite,
                          padding: const .symmetric(vertical: 10),
                          color: ColorConverter.lighten(AppColor.primaryColor, 96),
                          splashColor: Colors.white,
                          borderRadius: .circular(30),
                          border: .all(color: AppColor.primaryColor, width: 2),
                          useInitialElevation: true,
                          child: Row(
                            mainAxisSize: .min,
                            mainAxisAlignment: .center,
                            children: [
                              Text(
                                _localeCubit.state.languageCode == 'id' ? 'Unduh Form' : 'Download Form',
                                style: AppFonts.nunito(color: AppColor.primaryColor, fontSize: 15, fontWeight: .w800),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.download, color: AppColor.primaryColor),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GeneralEffectsButton(
                          onTap: _importInvitedGuests,
                          width: .maxFinite,
                          padding: const .symmetric(vertical: 12),
                          color: AppColor.primaryColor,
                          splashColor: Colors.white,
                          borderRadius: .circular(30),
                          useInitialElevation: true,
                          child: Center(
                            child: Text(
                              _localeCubit.state.languageCode == 'id' ? 'Import Form' : 'Import Form',
                              style: AppFonts.nunito(color: Colors.white, fontSize: 15, fontWeight: .w800),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GeneralEffectsButton(
          onTap: () => widget.onCompleted([]),
          // width: .maxFinite,
          padding: const .symmetric(vertical: 10, horizontal: 28),
          color: ColorConverter.lighten(Colors.orange, 96),
          splashColor: Colors.white,
          borderRadius: .circular(30),
          border: .all(color: Colors.orange, width: 2),
          useInitialElevation: true,
          child: Row(
            mainAxisSize: .min,
            mainAxisAlignment: .center,
            children: [
              Text(
                _localeCubit.state.languageCode == 'id' ? 'Lewati Import' : 'Lewati Import',
                style: AppFonts.nunito(color: Colors.orange, fontSize: 15, fontWeight: .w800),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.input_rounded, color: Colors.orange),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
