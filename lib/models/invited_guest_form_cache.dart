import 'package:equatable/equatable.dart';

class InvitedGuestFormCache extends Equatable {
  const InvitedGuestFormCache({required this.name, required this.phone, required this.instance, required this.souvenir});

  final String name;
  final String phone;
  final String instance;
  final String souvenir;

  @override
  List<Object?> get props => [name, phone, instance, souvenir];
}
