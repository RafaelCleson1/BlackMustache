import 'package:black_mustache/core/utils/error_messages.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('describeAuthError', () {
    test('traduz credenciais inválidas', () {
      expect(
        describeAuthError(
          const AuthException(
            'Invalid login credentials',
            code: 'invalid_credentials',
          ),
        ),
        'E-mail ou senha incorretos.',
      );
    });

    test('traduz usuário não encontrado', () {
      expect(
        describeAuthError(
          const AuthException('User not found', code: 'user_not_found'),
        ),
        'Não encontramos uma conta com este e-mail.',
      );
    });

    test('traduz e-mail não confirmado', () {
      expect(
        describeAuthError(
          const AuthException(
            'Email not confirmed',
            code: 'email_not_confirmed',
          ),
        ),
        contains('Confirme seu e-mail'),
      );
    });

    test('traduz e-mail já cadastrado no cadastro', () {
      expect(
        describeAuthError(
          const AuthException('User already registered', code: 'email_exists'),
        ),
        'Este e-mail já está cadastrado. Entre ou use outro e-mail.',
      );
    });

    test('traduz e-mail duplicado ou inválido no cadastro', () {
      expect(
        describeAuthError(
          const AuthException(
            'Email address "admin@email.com" is invalid',
            code: 'email_address_invalid',
          ),
        ),
        'Este e-mail já está cadastrado ou é inválido. Entre ou use outro e-mail.',
      );
    });

    test('traduz senha fraca no cadastro', () {
      expect(
        describeAuthError(
          const AuthException(
            'Password should be at least 6 characters',
            code: 'weak_password',
          ),
        ),
        'Senha muito fraca. Use ao menos 6 caracteres.',
      );
    });

    test('mantém fallback para erros desconhecidos', () {
      expect(
        describeAuthError(Exception('erro inesperado')),
        contains('Algo deu errado'),
      );
    });
  });
}
