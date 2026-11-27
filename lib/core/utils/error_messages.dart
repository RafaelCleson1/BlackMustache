import 'package:supabase_flutter/supabase_flutter.dart';

String describeError(Object error) {
  final raw = error.toString();

  if (raw.contains('23505') || raw.contains('duplicate key')) {
    return 'Este horário acabou de ser reservado. Escolha outro horário.';
  }
  if (raw.contains('P0001') || raw.contains('Horário indisponível')) {
    return 'Este horário não está mais disponível para este profissional.';
  }
  if (raw.contains('SocketException') ||
      raw.contains('ClientException') ||
      raw.contains('Failed host lookup') ||
      raw.contains('XMLHttpRequest')) {
    return 'Não foi possível conectar. Verifique sua internet e tente novamente.';
  }
  if (raw.contains('PGRST')) {
    return 'Não foi possível falar com o servidor. Tente novamente em instantes.';
  }
  if (raw.toLowerCase().contains('autentic')) {
    return 'Entre na sua conta para continuar.';
  }
  return 'Algo deu errado. Tente novamente.';
}

String describeAuthError(Object error) {
  final code = error is AuthException ? error.code ?? '' : '';
  final message = error is AuthException ? error.message : error.toString();
  final text = '$code $message'.toLowerCase();

  if (text.contains('invalid_credentials') ||
      text.contains('invalid_login_credentials') ||
      text.contains('invalid password') ||
      text.contains('wrong password')) {
    return 'E-mail ou senha incorretos.';
  }
  if (text.contains('user_not_found') ||
      text.contains('unable to validate user') ||
      text.contains('não encontramos o usuário')) {
    return 'Não encontramos uma conta com este e-mail.';
  }
  if (text.contains('email_not_confirmed') ||
      text.contains('confirm your email')) {
    return 'Confirme seu e-mail antes de entrar. Verifique sua caixa de entrada.';
  }
  if (text.contains('too_many_requests') || text.contains('rate limit')) {
    return 'Muitas tentativas. Aguarde alguns instantes e tente novamente.';
  }
  if (text.contains('email_address_invalid')) {
    return 'Este e-mail já está cadastrado ou é inválido. Entre ou use outro e-mail.';
  }
  if (text.contains('email_exists') ||
      text.contains('user_already_exists') ||
      text.contains('already registered') ||
      text.contains('already exists')) {
    return 'Este e-mail já está cadastrado. Entre ou use outro e-mail.';
  }
  if (text.contains('signup_disabled') || text.contains('signups disabled')) {
    return 'Cadastro não habilitado. Contate a barbearia.';
  }
  if (text.contains('weak_password') ||
      text.contains('password should be at least')) {
    return 'Senha muito fraca. Use ao menos 6 caracteres.';
  }
  if (text.contains('socketexception') ||
      text.contains('clientexception') ||
      text.contains('failed host lookup') ||
      text.contains('network')) {
    return 'Não foi possível conectar. Verifique sua internet e tente novamente.';
  }
  return describeError(error);
}
