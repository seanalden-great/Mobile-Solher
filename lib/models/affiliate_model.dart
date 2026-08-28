// class AffiliateDashboardModel {
//   final String? referralCode;
//   final num activeBalance;
//   final num pendingBalance;
//   final num totalEarned;
//   final List<AffiliateTransaction> transactions;

//   AffiliateDashboardModel({
//     this.referralCode,
//     required this.activeBalance,
//     required this.pendingBalance,
//     required this.totalEarned,
//     required this.transactions,
//   });

//   factory AffiliateDashboardModel.fromJson(Map<String, dynamic> json) {
//     var list = json['transactions'] as List? ?? [];
//     List<AffiliateTransaction> txList =
//         list.map((i) => AffiliateTransaction.fromJson(i)).toList();

//     return AffiliateDashboardModel(
//       referralCode: json['referral_code'],
//       activeBalance: json['active_balance'] ?? 0,
//       pendingBalance: json['pending_balance'] ?? 0,
//       totalEarned: json['total_earned'] ?? 0,
//       transactions: txList,
//     );
//   }
// }

// class AffiliateTransaction {
//   final int id;
//   final String createdAt;
//   final String commissionStatus;
//   final num commissionEarned;

//   AffiliateTransaction({
//     required this.id,
//     required this.createdAt,
//     required this.commissionStatus,
//     required this.commissionEarned,
//   });

//   factory AffiliateTransaction.fromJson(Map<String, dynamic> json) {
//     return AffiliateTransaction(
//       id: json['id'],
//       createdAt: json['created_at'] ?? '',
//       commissionStatus: json['commission_status'] ?? '',
//       commissionEarned: json['commission_earned'] ?? 0,
//     );
//   }
// }

class AffiliateDashboardModel {
  final String? referralCode;
  final num activeBalance;
  final num pendingBalance;
  final num totalEarned;
  final List<AffiliateTransaction> transactions;

  AffiliateDashboardModel({
    this.referralCode,
    required this.activeBalance,
    required this.pendingBalance,
    required this.totalEarned,
    required this.transactions,
  });

  factory AffiliateDashboardModel.fromJson(Map<String, dynamic> json) {
    var list = json['transactions'] as List? ?? [];
    List<AffiliateTransaction> txList =
        list.map((i) => AffiliateTransaction.fromJson(i)).toList();

    // 👇 FUNGSI PENYELAMAT: Memaksa apapun format dari Laravel (String/Int) menjadi num
    num parseNum(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val;
      return num.tryParse(val.toString()) ?? 0;
    }

    return AffiliateDashboardModel(
      referralCode: json['referral_code']?.toString(),
      activeBalance: parseNum(json['active_balance']),
      pendingBalance: parseNum(json['pending_balance']),
      totalEarned: parseNum(json['total_earned']),
      transactions: txList,
    );
  }
}

class AffiliateTransaction {
  final int id;
  final String createdAt;
  final String commissionStatus;
  final num commissionEarned;

  AffiliateTransaction({
    required this.id,
    required this.createdAt,
    required this.commissionStatus,
    required this.commissionEarned,
  });

  factory AffiliateTransaction.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val;
      return num.tryParse(val.toString()) ?? 0;
    }

    return AffiliateTransaction(
      // Mencegah error jika ID dari Laravel turun sebagai String
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      commissionStatus: json['commission_status']?.toString() ?? '',
      commissionEarned: parseNum(json['commission_earned']),
    );
  }
}
