class NoReceiptAvailableForDateException implements Exception {
  @override
  String toString() {
    return 'Nessuna ricevuta disponibile per la data selezionata';
  }
}
