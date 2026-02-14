import 'package:equatable/equatable.dart';

class InvitedGuestImportModel extends Equatable {
  const InvitedGuestImportModel({required this.name, required this.phone, required this.instance});

  final String name;
  final String phone;
  final String instance;

  @override
  List<Object?> get props => [name, phone, instance];
}
