import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/functions/Obtener_id.dart';
import 'package:taller_ceramica/supabase/functions/calcular_24hs.dart';
import 'package:taller_ceramica/supabase/functions/modificar_credito.dart';
import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';

class RemoverUsuario {
  final SupabaseClient supabaseClient;

  RemoverUsuario(this.supabaseClient);

  Future<void> removerUsuarioDeClase(int idClase, String user) async {

      final data = await supabaseClient.from('total').select().eq('id', idClase).single();

      final clase = ClaseModels.fromMap(data);

      // Agregar el nuevo mail si no está ya en la lista
      if (clase.mails.contains(user)) {
        clase.mails.remove(user);
         await supabaseClient.from('total').update(clase.toMap()).eq('id', idClase);
          if(Calcular24hs().esMayorA24Horas(clase.fecha, clase.hora)) {
            ModificarCredito().agregarCreditoUsuario( await ObtenerId().obtenerID(user)); 
          }
    }
  }

  Future<void> removerUsuarioDeMuchasClase(String diaSeleccionado,String horaSeleccionada, String user) async {
    
      final data = await ObtenerTotalInfo().obtenerInfo();


      for (final item in data){
        if(horaSeleccionada == item.hora && diaSeleccionado == item.dia){
          if(item.mails.contains(user)){
            item.mails.remove(user);
            await supabaseClient.from('total').update(item.toMap()).eq('id', item.id);
          }
        }

      }
  }
}
