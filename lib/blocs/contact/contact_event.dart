abstract class ContactEvent {}

class SubmitContactFormEvent extends ContactEvent {
  final String name;
  final String email;
  final String phone;
  final String description;

  SubmitContactFormEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.description,
  });
}

class FetchContactHistoryEvent extends ContactEvent {}
