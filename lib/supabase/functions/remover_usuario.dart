import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';

class RemoverUsuario {
  final SupabaseClient supabaseClient;

  RemoverUsuario(this.supabaseClient);

  Future<void> removerUsuarioDeClase(int idClase, String user) async {

      final data = await supabaseClient.from('respaldo').select().eq('id', idClase).single();

      final clase = ClaseModels.fromMap(data);

      // Agregar el nuevo mail si no está ya en la lista
      if (clase.mails.contains(user)) {
        clase.mails.remove(user);

        // Actualizar la base de datos con el nuevo listado de mails
        await supabaseClient
            .from('respaldo')
            .update(clase.toMap())
            .eq('id', idClase);

    }
  }

  Future<void> removerUsuarioDeMuchasClase(String diaSeleccionado,String horaSeleccionada, String user) async {
    
      final data = await ObtenerTotalInfo().obtenerInfo();


      for (final item in data){
        if(horaSeleccionada == item.hora && diaSeleccionado == item.dia){
          if(item.mails.contains(user)){
            item.mails.remove(user);
            await supabaseClient
            .from('respaldo')
            .update(item.toMap())
            .eq('id', item.id);
          }
        }

      }
      // Agregar el nuevo mail si no está ya en la lista
      // if (clase.mails.contains(user)) {
      //   clase.mails.remove(user);

        // // Actualizar la base de datos con el nuevo listado de mails
        // await supabaseClient
        //     .from('respaldo')
        //     .update(clase.toMap())
        //     .eq('id', idClase);

    // }
  }
}
