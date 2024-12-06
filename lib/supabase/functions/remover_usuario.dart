import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/functions/calcular_24hs.dart';
import 'package:taller_ceramica/supabase/functions/modificar_lugar_disponible.dart';
import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/widgets/enviar_wpp.dart';

class RemoverUsuario {
  final SupabaseClient supabaseClient;

  RemoverUsuario(this.supabaseClient);

  Future<void> removerUsuarioDeClase(int idClase, String user, bool parametro) async {

      final data = await supabaseClient.from('total').select().eq('id', idClase).single();

      final clase = ClaseModels.fromMap(data);

      // Agregar el nuevo mail si no está ya en la lista
      if (clase.mails.contains(user)) {
        clase.mails.remove(user);
         await supabaseClient.from('total').update(clase.toMap()).eq('id', idClase);
          if(Calcular24hs().esMayorA24Horas(clase.fecha, clase.hora)) {
            ModificarLugarDisponible().agregarlugarDisponible(idClase);
            EnviarWpp().sendWhatsAppMessage("$user ha cancelado la clase del dia ${clase.dia} ${clase.fecha} a las ${clase.hora}");
          }
          if(parametro){
            EnviarWpp().sendWhatsAppMessage("has removido a $user a la clase del dia ${clase.dia} ${clase.fecha} a las ${clase.hora}");

          }
    }
  }

  Future<void> removerUsuarioDeMuchasClase(ClaseModels clase, String user) async {
    
      final data = await ObtenerTotalInfo().obtenerInfo();


      for (final item in data){
        if(clase.hora == item.hora && clase.dia == item.dia){
          if(item.mails.contains(user)){
            item.mails.remove(user);
            await supabaseClient.from('total').update(item.toMap()).eq('id', item.id);
            ModificarLugarDisponible().agregarlugarDisponible(item.id);
          }
        }

      }
      EnviarWpp().sendWhatsAppMessage("Has removido a $user a 4 clases el dia ${clase.dia} a las ${clase.hora}");
  }
}
