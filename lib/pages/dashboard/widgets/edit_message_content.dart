import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iv_project_core/iv_project_core.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class EditMessageContent extends StatefulWidget {
  const EditMessageContent({super.key, required this.controller, required this.messages});

  final TextEditingController controller;
  final List<String> messages;

  @override
  State<EditMessageContent> createState() => _EditMessageContentState();
}

class _EditMessageContentState extends State<EditMessageContent> {
  final _controller = TextEditingController();

  String? _selectedMessage;

  @override
  void initState() {
    super.initState();

    _controller.text = widget.controller.text;
  }

  @override
  Widget build(BuildContext context) {
    final localeCubit = context.read<LocaleCubit>();

    return Column(
      mainAxisSize: .min,
      children: [
        Padding(
          padding: const .symmetric(horizontal: 14),
          child: GeneralTextField(
            controller: _controller,
            maxLines: 7,
            style: AppFonts.inter(color: Colors.black, fontSize: 14),
            decoration: FieldDecoration(
              labelText: localeCubit.state.languageCode == 'id' ? 'Template Pesan' : 'Message Template',
              labelStyle: const TextStyle(color: Colors.black87),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26, width: 1),
                borderRadius: .all(Radius.circular(8)),
              ),
              disabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26, width: 1),
                borderRadius: .all(Radius.circular(8)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26, width: 1),
                borderRadius: .all(Radius.circular(8)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          localeCubit.state.languageCode == 'id' ? 'Pilih Beberapa Template Dibawah Ini' : 'Select Some Templates Below',
          style: AppFonts.nunito(fontWeight: .w800, fontSize: 15),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 360,
          child: ListView.builder(
            padding: const .only(left: 14, right: 14, bottom: 10),
            itemCount: widget.messages.length,
            itemBuilder: (_, index) {
              final message = widget.messages[index];
              return Card(
                margin: const .symmetric(vertical: 4),
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.black12),
                ),
                child: Padding(
                  padding: const .all(14),
                  child: Stack(
                    alignment: .topRight,
                    children: [
                      Text(message, style: AppFonts.nunito()),
                      GeneralEffectsButton(
                        onTap: () {
                          _controller.text = message;
                          _selectedMessage = message;
                        },
                        padding: const .symmetric(horizontal: 16, vertical: 8),
                        color: AppColor.primaryColor,
                        splashColor: Colors.white,
                        borderRadius: .circular(30),
                        useInitialElevation: true,
                        child: Text(
                          localeCubit.state.languageCode == 'id' ? 'Gunakan Template Ini' : 'Use This Template',
                          style: AppFonts.nunito(color: Colors.white, fontWeight: .w700),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const .all(14),
          child: GeneralEffectsButton(
            onTap: () {
              if (_selectedMessage != null) widget.controller.text = _selectedMessage!;
              NavigationService.pop();
            },
            width: .maxFinite,
            padding: const .symmetric(vertical: 14),
            color: AppColor.primaryColor,
            splashColor: Colors.white,
            borderRadius: .circular(30),
            useInitialElevation: true,
            child: Center(
              child: Text(
                'OK',
                style: AppFonts.nunito(color: Colors.white, fontSize: 15, fontWeight: .w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
