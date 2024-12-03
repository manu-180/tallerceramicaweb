class Calcular24hs {

  
  bool esMayorA24Horas(String fecha, String hora) {
  // Obtén el año actual
  final int anioActual = DateTime.now().year;

  // Divide la fecha (ejemplo: "05/05")
  final List<String> partesFecha = fecha.split('/');
  if (partesFecha.length != 2) {
    throw const FormatException("La fecha no está en el formato correcto (dd/MM)");
  }
  final int dia = int.parse(partesFecha[0]);
  final int mes = int.parse(partesFecha[1]);

  // Divide la hora (ejemplo: "16:30")
  final List<String> partesHora = hora.split(':');
  if (partesHora.length != 2) {
    throw const FormatException("La hora no está en el formato correcto (HH:mm)");
  }
  final int horas = int.parse(partesHora[0]);
  final int minutos = int.parse(partesHora[1]);

  // Crea un objeto DateTime para la fecha y hora de la clase
  final DateTime fechaClase = DateTime(anioActual, mes, dia, horas, minutos);

  // Obtén la fecha y hora actuales
  final DateTime fechaActual = DateTime.now();

  // Calcula la diferencia en horas entre las dos fechas
  final Duration diferencia = fechaClase.difference(fechaActual);

  // Si la diferencia es mayor a 24 horas, retorna true; de lo contrario, false
  return diferencia.inHours > 24;
}

}