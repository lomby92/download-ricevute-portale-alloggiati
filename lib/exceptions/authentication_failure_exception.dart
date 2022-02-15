class AuthenticationFailureException implements Exception {
  String errorMessage;

  AuthenticationFailureException(this.errorMessage);

  @override
  String toString() {
    return 'Autenticazione fallita con errore: $errorMessage';
  }
}
