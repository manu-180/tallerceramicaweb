class ClaseModels {
  final int id;
  final String semana;
  final String dia;
  final String fecha;
  final String hora;
  final List<String> mails;

  ClaseModels({
    required this.id,
    required this.semana,
    required this.dia,
    required this.fecha,
    required this.hora,
    required this.mails,
  });

  // Método para convertir un Map (desde Supabase) a una instancia de Clase
  factory ClaseModels.fromMap(Map<String, dynamic> map) {
    return ClaseModels(
      id: map['id'] as int,
      semana: map['semana'] as String,
      dia: map['dia'] as String,
      fecha: map['fecha'] as String,
      hora: map['hora'] as String,
      mails: List<String>.from(map['mails'] ?? []),
    );
  }

  // Método para convertir una instancia de Clase a un Map (para actualizar datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'semana': semana,
      'dia': dia,
      'fecha': fecha,
      'hora': hora,
      'mails': mails,
    };
  }
}
