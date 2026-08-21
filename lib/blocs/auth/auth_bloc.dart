import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solher_mobile/models/user_model.dart';
import 'package:solher_mobile/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {

    // 👇 [BARU] LOGIKA PENGECEKAN SESI SAAT APP DIBUKA 👇
    on<CheckLoginStatusEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJsonString = prefs.getString('user_data');

      if (token != null && userJsonString != null) {
        try {
          // Parse string JSON kembali menjadi UserModel
          final userMap = json.decode(userJsonString);
          final user = UserModel.fromJson(userMap);
          emit(AuthAuthenticated(user));
        } catch (e) {
          // Jika terjadi error saat parsing, paksa logout
          await prefs.remove('token');
          await prefs.remove('user_data');
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    });
    
    // LOGIKA LOGIN
    // on<LoginRequested>((event, emit) async {
    //   emit(AuthLoading());
    //   try {
    //     final result = await authRepository.login(event.email, event.password, event.captchaToken);
        
    //     // Simpan Token JWT ke Local Storage Android/iOS
    //     final prefs = await SharedPreferences.getInstance();
    //     await prefs.setString('token', result['token']);
        
    //     emit(AuthAuthenticated(result['user']));
    //   } catch (e) {
    //     emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    //   }
    // });

    // LOGIKA LOGIN (PERBAIKAN)
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await authRepository.login(
            event.email, event.password, event.captchaToken);

        // Simpan Token JWT dan Data User ke Local Storage Android/iOS
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', result['token']);

        // 👇 TAMBAHKAN BARIS INI 👇
        await prefs.setString('user_data', result['user_json']);

        emit(AuthAuthenticated(result['user']));
      } catch (e) {
        emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // LOGIKA REGISTER
    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.register(event.firstName, event.lastName, event.email, event.password);
        emit(AuthActionSuccess('Registrasi berhasil! Silakan login.'));
      } catch (e) {
        emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // LOGIKA LUPA PASSWORD (KIRIM OTP)
    on<SendResetCodeRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.sendResetCode(event.email);
        emit(AuthActionSuccess('Kode OTP telah dikirim ke email.'));
      } catch (e) {
        emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // LOGIKA LUPA PASSWORD (VERIFIKASI OTP)
    on<VerifyResetCodeRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.verifyResetCode(event.email, event.code);
        emit(AuthActionSuccess('Kode berhasil diverifikasi.'));
      } catch (e) {
        emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // LOGIKA LUPA PASSWORD (RESET)
    on<ResetPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.resetPassword(event.email, event.code, event.password, event.confirmPassword);
        emit(AuthActionSuccess('Password berhasil diubah. Silakan login.'));
      } catch (e) {
        emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // LOGIKA LOGOUT
    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user_data'); // 👇 [BARU] Hapus data user juga
      emit(AuthUnauthenticated());
    });
  }
}