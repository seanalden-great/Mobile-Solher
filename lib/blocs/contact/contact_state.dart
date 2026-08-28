import '../../models/contact_model.dart';

abstract class ContactState {}

class ContactInitial extends ContactState {}

// State untuk proses pengiriman formulir
class ContactSubmitLoading extends ContactState {}

class ContactSubmitSuccess extends ContactState {
  final String message;
  ContactSubmitSuccess(this.message);
}

class ContactSubmitError extends ContactState {
  final String message;
  ContactSubmitError(this.message);
}

// State untuk memuat riwayat
class ContactHistoryLoading extends ContactState {}

class ContactHistoryLoaded extends ContactState {
  final List<ContactModel> histories;
  ContactHistoryLoaded(this.histories);
}

class ContactHistoryError extends ContactState {
  final String message;
  ContactHistoryError(this.message);
}
