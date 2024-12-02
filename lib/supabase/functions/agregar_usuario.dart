import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/functions/Obtener_id.dart';
import 'package:taller_ceramica/supabase/functions/obtener_clases_disponibles.dart';
import 'package:taller_ceramica/supabase/functions/modificar_credito.dart';
import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';

class AgregarUsuario {
  final SupabaseClient supabaseClient;

  AgregarUsuario(this.supabaseClient);

  Future<void> agregarUsuarioAClase(int idClase, String nuevoMail) async {

      final data = await supabaseClient.from('respaldo').select().eq('id', idClase).single();

      final clase = ClaseModels.fromMap(data);

      if ( await ObtenerClasesDisponibles().clasesDisponibles(nuevoMail) > 0){

        if (!clase.mails.contains(nuevoMail)) {
        clase.mails.add(nuevoMail);
        await supabaseClient.from('respaldo').update(clase.toMap()).eq('id', idClase);
        ModificarCredito().removerCreditoUsuario( await ObtenerId().obtenerID(nuevoMail));
      }
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
        if ( await ObtenerClasesDisponibles().clasesDisponibles(nuevoMail) > 0){
          ModificarCredito().removerCreditoUsuario( await ObtenerId().obtenerID(nuevoMail));
          await supabaseClient
            .from('respaldo')
            .update(item.toMap())
            .eq('id', item.id);
        }        
      }
    }
  }
  }
}

