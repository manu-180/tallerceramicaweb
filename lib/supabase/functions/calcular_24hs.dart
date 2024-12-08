class Calcular24hs {

  
  bool esMayorA24Horas(String fecha, String hora) {
  final int anioActual = DateTime.now().year;

  final List<String> partesFecha = fecha.split('/');
  if (partesFecha.length != 2) {
    throw const FormatException("La fecha no está en el formato correcto (dd/MM)");
  }
  final int dia = int.parse(partesFecha[0]);
  final int mes = int.parse(partesFecha[1]);

  final List<String> partesHora = hora.split(':');
  if (partesHora.length != 2) {
    throw const FormatException("La hora no está en el formato correcto (HH:mm)");
  }
  final int horas = int.parse(partesHora[0]);
  final int minutos = int.parse(partesHora[1]);

  final DateTime fechaClase = DateTime(anioActual, mes, dia, horas, minutos);

  final DateTime fechaActual = DateTime.now();

  final Duration diferencia = fechaClase.difference(fechaActual);

  return diferencia.inHours > 24;
}
bool esMenorA0Horas(String fecha, String hora) {
  final int anioActual = DateTime.now().year;

  final List<String> partesFecha = fecha.split('/');
  
  if (partesFecha.length != 2) {
    throw const FormatException("La fecha no está en el formato correcto (dd/MM)");
  }
  final int dia = int.parse(partesFecha[0]);
  final int mes = int.parse(partesFecha[1]);

  final List<String> partesHora = hora.split(':');
  if (partesHora.length != 2) {
    throw const FormatException("La hora no está en el formato correcto (HH:mm)");
  }
  final int horas = int.parse(partesHora[0]);
  final int minutos = int.parse(partesHora[1]);

  final DateTime fechaClase = DateTime(anioActual, mes, dia, horas, minutos);

  final DateTime fechaActual = DateTime.now();

  final Duration diferencia = fechaClase.difference(fechaActual);

  return diferencia.isNegative; // Devuelve true si ya pasó la fecha.
}



}