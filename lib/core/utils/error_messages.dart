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
  return 'Algo deu errado. Tente novamente.';
}
