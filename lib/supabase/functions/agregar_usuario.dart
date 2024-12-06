import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/functions/modificar_lugar_disponible.dart';
import 'package:taller_ceramica/supabase/functions/modificar_credito.dart';
import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/widgets/enviar_wpp.dart';

class AgregarUsuario {
  final SupabaseClient supabaseClient;

  AgregarUsuario(this.supabaseClient);

  Future<void> agregarUsuarioAClase(int idClase, String user, bool parametro, ClaseModels claseModels) async {

      final usuarios = await ObtenerTotalInfo().obtenerInfoUsuarios();

      final data = await supabaseClient.from('respaldo').select().eq('id', idClase).single();

      final clase = ClaseModels.fromMap(data);

      for (final usuario in usuarios) {
        if (usuario.fullname == user) {
          if (usuario.clasesDisponibles > 0 || parametro) {
            if (!clase.mails.contains(user)) {
              clase.mails.add(user);
              await supabaseClient.from('respaldo').update(clase.toMap()).eq('id', idClase);
              ModificarLugarDisponible().removerLugarDisponible(idClase);
              EnviarWpp().sendWhatsAppMessage("has insertado a $user a la clase del dia ${clase.dia} ${clase.fecha} a las ${clase.hora}");
              if (!parametro) {
              ModificarCredito().removerCreditoUsuario(user);
              EnviarWpp().sendWhatsAppMessage("$user se ha inscripto a la clase del dia ${clase.dia} ${clase.fecha} a las ${clase.hora}");
              }
            }
          }
        }
      }
    }

Future<void> agregarUsuarioEnCuatroClases(
    ClaseModels clase, String user) async {

  final data = await ObtenerTotalInfo().obtenerInfo();

  int count = 0;

  for (final item in data) {

    if (item.dia == clase.dia && item.hora == clase.hora) {
      count++;
      
    if (!item.mails.contains(user) && count < 5) {
      item.mails.add(user);
        await supabaseClient.from('respaldo').update(item.toMap()).eq('id', item.id);
        ModificarLugarDisponible().removerLugarDisponible(item.id);
    }
    }
  }
  EnviarWpp().sendWhatsAppMessage("Has insertado a $user a 4 clases el dia ${clase.dia} a las ${clase.hora}");
  }
}

