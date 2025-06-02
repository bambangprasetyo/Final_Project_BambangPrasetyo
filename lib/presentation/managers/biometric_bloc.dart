import 'package:bloc/bloc.dart';
import 'package:h8_fli_biometric_starter/domain/usecases/biometric_usecase.dart';
import 'package:meta/meta.dart';

part 'biometric_event.dart';
part 'biometric_state.dart';

class BiometricBloc extends Bloc<BiometricEvent, BiometricState> {
  // TODO: 1. Add usecases as the dependencies.
  final BiometricCheckAvailabilityUseCase checkAvailabilityUseCase;
  final BiometricAuthenticateUseCase authenticateUseCase;
  BiometricBloc({
    required this.checkAvailabilityUseCase,
    required this.authenticateUseCase,
  }) : super(BiometricInitial()) {
    // TODO: 2. Complete the events implementation.
    on<BiometricCheckAvailability>((event, emit) async {
      try {
        emit(BiometricAuthInProgress());
        final isAvailable = await checkAvailabilityUseCase.execute();
        if (isAvailable) {
          add(BiometricAuthenticate());
        }
      } catch (e) {
        emit(BiometricAuthInFail(message: e.toString()));
      }
    });

    on<BiometricAuthenticate>((event, emit) async {
      try {
        emit(BiometricAuthInProgress());
        final isAuthenticated = await authenticateUseCase.execute(
          password: event.password,
        );

        if (isAuthenticated) {
          emit(BiometricAuthInSuccess());
        } else {
          throw Exception('Authh Failed');
        }
      } catch (e) {
        emit(BiometricAuthInFail(message: e.toString()));
      }
    });
  }
}
