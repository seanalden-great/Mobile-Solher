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

    on<CheckLoginStatusEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJsonString = prefs.getString('user_data');

      if (token != null && userJsonString != null) {
        try {
          final userMap = json.decode(userJsonString);
          final user = UserModel.fromJson(userMap);
          emit(AuthAuthenticated(user));
        } catch (e) {
          await prefs.remove('token');
          await prefs.remove('user_data');
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    });
    
    // LOGIKA LOGIN (PERBAIKAN)
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await authRepository.login(
            event.email, event.password, event.appSecret); // 👈 Gunakan appSecret

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', result['token']);
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
      await prefs.remove('user_data');
      emit(AuthUnauthenticated());
    });

    // LOGIKA UPDATE PROFIL
    on<UpdateProfileRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await authRepository.updateProfileInfo(
            event.firstName, event.lastName, event.email, event.phone);
        emit(AuthActionSuccess(
            result['message'] ?? 'Profil berhasil diperbarui.'));
        emit(AuthAuthenticated(result['user']));
      } catch (e) {
        emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // LOGIKA UPDATE FOTO PROFIL
    on<UpdateProfileImageRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await authRepository.updateProfileImage(event.filePath);
        emit(AuthActionSuccess(
            result['message'] ?? 'Foto profil berhasil diperbarui.'));
        emit(AuthAuthenticated(result['user']));
      } catch (e) {
        emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // LOGIKA TANGKAPAN GOOGLE LOGIN
    on<GoogleAuthSuccessEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', event.token);
        await prefs.setString('user_data', event.userJsonString);

        final userMap = json.decode(event.userJsonString);
        final user = UserModel.fromJson(userMap);

        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError('Gagal memproses data Google.'));
      }
    });
  }
}