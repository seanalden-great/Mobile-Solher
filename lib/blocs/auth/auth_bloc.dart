import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    
    // LOGIKA LOGIN
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await authRepository.login(event.email, event.password, event.captchaToken);
        
        // Simpan Token JWT ke Local Storage Android/iOS
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', result['token']);
        
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
      emit(AuthUnauthenticated());
    });
  }
}