import 'package:equatable/equatable.dart';

class InvitedGuestImportModel extends Equatable {
  const InvitedGuestImportModel({required this.name, required this.phone, this.instance, this.souvenir});

  final String name;
  final String phone;
  final String? instance;
  final String? souvenir;

  @override
  List<Object?> get props => [name, phone, instance, souvenir];
}
