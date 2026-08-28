import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/affiliate_model.dart';
import 'affiliate_event.dart';
import 'affiliate_state.dart';

class AffiliateBloc extends Bloc<AffiliateEvent, AffiliateState> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://back.solher.co.id/api'));

  AffiliateBloc() : super(AffiliateInitial()) {
    // --- LOAD DASHBOARD ---
    on<FetchAffiliateDashboard>((event, emit) async {
      emit(AffiliateLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        final response = await _dio.get('/affiliate/dashboard',
            options: Options(headers: {'Authorization': 'Bearer $token'}));

        final data = AffiliateDashboardModel.fromJson(response.data['data']);
        emit(AffiliateDashboardLoaded(data));
      } on DioException catch (e) {
        if (e.response?.statusCode == 403) {
          emit(NotAnAffiliateState());
        } else {
          emit(AffiliateError(
              e.response?.data['message'] ?? 'Gagal memuat dasbor afiliasi.'));
        }
      } catch (e) {
        emit(AffiliateError('Terjadi kesalahan sistem.'));
      }
    });

    // --- APPLY AFFILIATE ---
    on<ApplyAffiliateEvent>((event, emit) async {
      emit(AffiliateLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        final response = await _dio.post('/affiliate/apply',
            data: {
              'social_media_url': event.socialMediaUrl,
              'reason': event.reason,
            },
            options: Options(headers: {'Authorization': 'Bearer $token'}));

        emit(AffiliateActionSuccess(response.data['message']));
        emit(NotAnAffiliateState()); // Kembalikan ke form setelah apply
      } on DioException catch (e) {
        emit(AffiliateError(
            e.response?.data['message'] ?? 'Gagal mendaftar afiliasi.'));
        emit(NotAnAffiliateState());
      }
    });

    // --- WITHDRAW FUNDS ---
    on<WithdrawAffiliateEvent>((event, emit) async {
      emit(AffiliateLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        final response = await _dio.post('/affiliate/withdraw',
            data: {
              'withdrawal_method': event.method,
              'bank_name': event.bankName,
              'account_number': event.accountNumber,
              'account_name': event.accountName,
              'amount': event.amount,
            },
            options: Options(headers: {'Authorization': 'Bearer $token'}));

        emit(AffiliateActionSuccess(response.data['message'],
            refreshDashboard: true));
      } on DioException catch (e) {
        emit(AffiliateError(
            e.response?.data['message'] ?? 'Gagal menarik dana.'));
        add(FetchAffiliateDashboard()); // Refresh state sebelumnya
      }
    });
  }
}
