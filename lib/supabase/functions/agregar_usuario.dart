import 'package:supabase/supabase.dart';
import 'package:taller_ceramica/main.dart';

class AgregarUsuario {
  final SupabaseClient supabaseClient;

  AgregarUsuario(this.supabaseClient);

  Future<void> agregarUsuarioAClase(int idClase, String nuevoMail) async {
    try {
      // Obtener la clase actual para consultar el listado de mails existente
      
      final data = await supabase.from('respaldo').select();

      List<dynamic> mailsActuales = [];
      

      for (var i in data) {
        if (i['id'] == idClase) {
          mailsActuales = i['mails'];
        }
      }

      // Agregar el nuevo mail si no está ya en la lista
      if (!mailsActuales.contains(nuevoMail)) {
        mailsActuales.add(nuevoMail);

        // Actualizar la base de datos con el nuevo listado de mails
        final updateResponse = await supabaseClient
            .from('respaldo')
            .update({'mails': mailsActuales})
            .eq('id', idClase);

      } else {
        print("El mail ya está registrado en esta clase.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}
