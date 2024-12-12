class GenerarFechas {
  List<String> generarFechas(DateTime fechaInicio, DateTime fechaFin) {
    // Días hábiles permitidos: lunes a viernes
    List<int> diasHabiles = [
      1,
      2,
      3,
      4,
      5
    ]; // Lunes, Martes, Miércoles, Jueves, Viernes
    List<String> listaFechas = [];

    // Iterar desde la fecha inicial hasta la fecha final
    DateTime fechaActual = fechaInicio;
    while (fechaActual.isBefore(fechaFin) ||
        fechaActual.isAtSameMomentAs(fechaFin)) {
      if (diasHabiles.contains(fechaActual.weekday)) {
        listaFechas
            .add("${fechaActual.day}/${fechaActual.month}/${fechaActual.year}");
        // Repetir días martes, miércoles, jueves y viernes
        if (fechaActual.weekday >= 2 && fechaActual.weekday <= 5) {
          for (int i = 0; i < 2; i++) {
            listaFechas.add(
                "${fechaActual.day}/${fechaActual.month}/${fechaActual.year}");
          }
        }
      }
      // Avanzar al siguiente día
      fechaActual = fechaActual.add(Duration(days: 1));
    }

    return listaFechas;
  }

  void main() {
    // Llamar a la función con las fechas deseadas
    DateTime fechaInicio = DateTime(2024, 12, 2); // 2 de diciembre de 2024
    DateTime fechaFin = DateTime(2025, 1, 3); // 3 de enero de 2025
    List<String> resultado = generarFechas(fechaInicio, fechaFin);

    // Imprimir el resultado
    for (var fecha in resultado) {
      print(fecha);
    }
  }
}
