import 'package:equatable/equatable.dart';
import 'package:solher_mobile/models/address_model.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class FetchAddresses extends AddressEvent {}

class CreateAddressEvent extends AddressEvent {
  final AddressModel address;
  const CreateAddressEvent(this.address);

  @override
  List<Object?> get props => [address];
}

class UpdateAddressEvent extends AddressEvent {
  final int id;
  final AddressModel address;
  const UpdateAddressEvent(this.id, this.address);

  @override
  List<Object?> get props => [id, address];
}

class DeleteAddressEvent extends AddressEvent {
  final int id;
  const DeleteAddressEvent(this.id);

  @override
  List<Object?> get props => [id];
}
