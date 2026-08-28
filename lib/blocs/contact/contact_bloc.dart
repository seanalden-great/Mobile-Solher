import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/contact_model.dart';
import 'contact_event.dart';
import 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final Dio   _dio = Dio(BaseOptions(baseUrl: 'https://back.solher.co.id/api'));

  ContactBloc() : super(ContactInitial()) {
    on<SubmitContactFormEvent>((event, emit) async {
      emit(ContactSubmitLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token'); // Sesuaikan key token Anda

        final headers = token != null && token.isNotEmpty
            ? {'Authorization': 'Bearer $token', 'Accept': 'application/json'}
            : {'Accept': 'application/json'};

        final response = await _dio.post(
          '/contact',
          data: {
            'name': event.name,
            'email': event.email,
            'phone': event.phone,
            'description': event.description,
          },
          options: Options(headers: headers),
        );

        emit(ContactSubmitSuccess(
            response.data['message'] ?? 'Pesan berhasil dikirim!'));
      } on DioException catch (e) {
        emit(ContactSubmitError(
            e.response?.data['message'] ?? 'Gagal mengirim pesan. Coba lagi.'));
      } catch (e) {
        emit(ContactSubmitError('Terjadi kesalahan sistem.'));
      }
    });

    on<FetchContactHistoryEvent>((event, emit) async {
      emit(ContactHistoryLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        if (token == null || token.isEmpty) {
          emit(ContactHistoryError('Silakan login terlebih dahulu.'));
          return;
        }

        final response = await _dio.get(
          '/user/contact-history',
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          }),
        );

        List<ContactModel> histories = (response.data as List)
            .map((i) => ContactModel.fromJson(i))
            .toList();

        emit(ContactHistoryLoaded(histories));
      } on DioException catch (e) {
        emit(ContactHistoryError(
            e.response?.data['message'] ?? 'Gagal memuat riwayat.'));
      } catch (e) {
        emit(ContactHistoryError('Terjadi kesalahan sistem.'));
      }
    });
  }
}
