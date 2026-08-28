abstract class AffiliateEvent {}

class FetchAffiliateDashboard extends AffiliateEvent {}

class ApplyAffiliateEvent extends AffiliateEvent {
  final String socialMediaUrl;
  final String reason;
  ApplyAffiliateEvent({required this.socialMediaUrl, required this.reason});
}

class WithdrawAffiliateEvent extends AffiliateEvent {
  final String method;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final num amount;

  WithdrawAffiliateEvent({
    required this.method,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.amount,
  });
}
