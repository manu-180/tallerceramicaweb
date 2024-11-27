import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/models/clase_models.dart';

class AgregarUsuario {
  final SupabaseClient supabaseClient;

  AgregarUsuario(this.supabaseClient);

  Future<void> agregarUsuarioAClase(int idClase, String nuevoMail) async {
    try {
      // Obtener la clase por ID
      final data = await supabaseClient.from('respaldo').select().eq('id', idClase).single();

      final clase = ClaseModels.fromMap(data);

      // Agregar el nuevo mail si no está ya en la lista
      if (!clase.mails.contains(nuevoMail)) {
        clase.mails.add(nuevoMail);

        // Actualizar la base de datos con el nuevo listado de mails
        await supabaseClient
            .from('respaldo')
            .update(clase.toMap())
            .eq('id', idClase);

        print("Usuario agregado con éxito.");
      } else {
        print("El mail ya está registrado en esta clase.");
      }
        } catch (e) {
      print("Error: $e");
    }
  }
}
