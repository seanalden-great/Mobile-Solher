import '../../models/affiliate_model.dart';

abstract class AffiliateState {}

class AffiliateInitial extends AffiliateState {}

class AffiliateLoading extends AffiliateState {}

class AffiliateDashboardLoaded extends AffiliateState {
  final AffiliateDashboardModel data;
  AffiliateDashboardLoaded(this.data);
}

class AffiliateActionSuccess extends AffiliateState {
  final String message;
  final bool refreshDashboard; // Flag agar UI otomatis refresh
  AffiliateActionSuccess(this.message, {this.refreshDashboard = false});
}

class AffiliateError extends AffiliateState {
  final String message;
  AffiliateError(this.message);
}

// State khusus jika user bukan afiliator (403 dari server)
class NotAnAffiliateState extends AffiliateState {}
