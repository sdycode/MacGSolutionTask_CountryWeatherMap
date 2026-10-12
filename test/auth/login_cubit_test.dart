import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:country_weather_app/core/error/failure.dart';
import 'package:country_weather_app/core/error/result.dart';
import 'package:country_weather_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:country_weather_app/features/auth/presentation/cubit/auth_form_state.dart';
import 'package:country_weather_app/features/auth/presentation/cubit/login_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository auth;

  setUp(() => auth = _MockAuthRepository());

  blocTest<LoginCubit, AuthFormState>(
    'wrong password shows the incorrect email or password message',
    build: () {
      when(() => auth.signIn(any(), any())).thenAnswer(
        (_) async => const Err(
          AuthFailure(
            'Incorrect email or password.',
            code: 'invalid-credential',
          ),
        ),
      );
      return LoginCubit(auth);
    },
    act: (cubit) => cubit.signIn(' a@b.com ', 'wrong'),
    expect: () => [
      const AuthFormState(status: FormStatus.loading),
      const AuthFormState(
        status: FormStatus.failure,
        message: 'Incorrect email or password.',
      ),
    ],
    verify: (_) => verify(() => auth.signIn('a@b.com', 'wrong')).called(1),
  );

  blocTest<LoginCubit, AuthFormState>(
    'successful sign in',
    build: () {
      when(
        () => auth.signIn(any(), any()),
      ).thenAnswer((_) async => const Success(null));
      return LoginCubit(auth);
    },
    act: (cubit) => cubit.signIn('a@b.com', 'Password1'),
    expect: () => [
      const AuthFormState(status: FormStatus.loading),
      const AuthFormState(status: FormStatus.success),
    ],
  );
}
