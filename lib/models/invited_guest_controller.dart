import 'package:flutter/widgets.dart';

class InvitedGuestController {
  const InvitedGuestController({
    required this.name,
    required this.phone,
    required this.instance,
    required this.souvenir,
    required this.nominal,
  });

  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController instance;
  final TextEditingController souvenir;
  final TextEditingController nominal;
}
