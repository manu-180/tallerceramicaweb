class ClaseModels {
  final int id;
  final String semana;
  final String dia;
  final String fecha;
  final String hora;
  final List<String> mails;
  final int? lugarDisponible;
  final bool? isFull;

  ClaseModels({
    required this.id,
    required this.semana,
    required this.dia,
    required this.fecha,
    required this.hora,
    required this.mails,
    required this.lugarDisponible,
    this.isFull = false,
  });

  // Método para convertir un Map (desde Supabase) a una instancia de Clase
  factory ClaseModels.fromMap(Map<String, dynamic> map) {
    return ClaseModels(
      id: map['id'] as int,
      semana: map['semana'] as String,
      dia: map['dia'] as String,
      fecha: map['fecha'] as String,
      hora: map['hora'] as String,
      lugarDisponible: map['lugarDisponible'] != null ? map['lugarDisponible'] as int : null,
      mails: List<String>.from(map['mails'] ?? []),
    );
  }

  ClaseModels copyWith({
    int? id,
    String? dia,
    String? semana,
    String? fecha,
    String? hora,
    List<String>? mails,
    int? lugarDisponible, 
    bool? isFull,
  }) {
    return ClaseModels(
      id: id ?? this.id,
      dia: dia ?? this.dia,
      semana: semana ?? this.semana,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      mails: mails ?? this.mails,
      lugarDisponible: lugarDisponible ?? this.lugarDisponible,
      isFull: isFull ?? this.isFull,
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
