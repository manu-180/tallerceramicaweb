import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';

class AgregarUsuario {
  final SupabaseClient supabaseClient;

  AgregarUsuario(this.supabaseClient);

  Future<void> agregarUsuarioAClase(int idClase, String nuevoMail) async {

      final data = await supabaseClient.from('respaldo').select().eq('id', idClase).single();

      final clase = ClaseModels.fromMap(data);

      if (!clase.mails.contains(nuevoMail)) {
        clase.mails.add(nuevoMail);

        // Actualizar la base de datos con el nuevo listado de mails
        await supabaseClient
            .from('respaldo')
            .update(clase.toMap())
            .eq('id', idClase);
      }
    }

Future<void> agregarUsuarioEnCuatroClases(
    String diaSeleccionado, String horaSeleccionada, String nuevoMail) async {

  final data = await ObtenerTotalInfo().obtenerInfo();

  int count = 0;

  for (final item in data) {

    if (item.dia == diaSeleccionado && item.hora == horaSeleccionada) {
      count++;
      
     if (!item.mails.contains(nuevoMail) && count < 5) {
        item.mails.add(nuevoMail);

        // Actualizar la base de datos con el nuevo listado de mails
        await supabaseClient
            .from('respaldo')
            .update(item.toMap())
            .eq('id', item.id);
      }
    }
  }
  }
}

