import 'package:equatable/equatable.dart';

class InvitedGuestFormCache extends Equatable {
  const InvitedGuestFormCache({
    required this.name,
    required this.phone,
    required this.instance,
    required this.souvenir,
    required this.nominal,
  });

  final String name;
  final String phone;
  final String instance;
  final String souvenir;
  final String nominal;

  @override
  List<Object?> get props => [name, phone, instance, souvenir, nominal];
}
