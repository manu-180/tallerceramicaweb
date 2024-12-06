class ClaseModels {
  final int id;
  final String semana; // Semana de la clase
  final String dia; // Día de la semana
  final String fecha; // Fecha específica (formato: dd/mm)
  final String hora; // Hora de la clase
  final List<String> mails; // Lista de correos electrónicos de los alumnos inscritos
  int lugaresDisponibles = 0; // Lugares disponibles en la clase
  bool isFull; // Indica si la clase está llena

  // Constructor actualizado
  ClaseModels({
    required this.id,
    required this.semana,
    required this.dia,
    required this.fecha,
    required this.hora,
    required this.mails,
    required this.lugaresDisponibles,
    this.isFull = false,
  });

  // Método para actualizar el estado de la clase
  void actualizarLugaresDisponibles(int nuevosLugares) {
    lugaresDisponibles = nuevosLugares;
    isFull = nuevosLugares == 0; // La clase está llena si no hay lugares
  }

  // Método para crear una instancia desde un Map (útil para bases de datos)
  factory ClaseModels.fromMap(Map<String, dynamic> map) {
    return ClaseModels(
      id: map['id'],
      semana: map['semana'],
      dia: map['dia'],
      fecha: map['fecha'],
      hora: map['hora'],
      mails: List<String>.from(map['mails'] ?? []),
      lugaresDisponibles: map['lugar_disponible'],
      isFull: map['lugaresDisponibles'] == 0,
    );
  }

  // Método para convertir una instancia a Map (útil para bases de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'semana': semana,
      'dia': dia,
      'fecha': fecha,
      'hora': hora,
      'mails': mails,
      'lugaresDisponibles': lugaresDisponibles,
      'isFull': isFull,
    };
  }
}
