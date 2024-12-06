import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/functions/modificar_lugar_disponible.dart';
import 'package:taller_ceramica/supabase/functions/obtener_clases_disponibles.dart';
import 'package:taller_ceramica/supabase/functions/modificar_credito.dart';
import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/widgets/twilio/enviar_wpp.dart';

class AgregarUsuario {
  final SupabaseClient supabaseClient;

  AgregarUsuario(this.supabaseClient);

  Future<void> agregarUsuarioAClase(int idClase, String user, bool parametro, ClaseModels claseModels) async {

      final usuarios = await ObtenerTotalInfo().obtenerInfoUsuarios();

      final data = await supabaseClient.from('total').select().eq('id', idClase).single();

      final clase = ClaseModels.fromMap(data);

      for (final usuario in usuarios) {
        if (usuario.fullname == user) {
          if (usuario.clasesDisponibles > 0 || parametro) {
            if (!clase.mails.contains(user)) {
              clase.mails.add(user);
              await supabaseClient.from('total').update(clase.toMap()).eq('id', idClase);
              EnviarWpp().sendWhatsAppMessage(
  'whatsapp:+5491134272488',
  '${user} se ha sumado a la clase del día ${claseModels.dia} ${claseModels.fecha} a las ${claseModels.hora}'
);
              ModificarLugarDisponible().removerlugarDisponible(idClase);
              if (!parametro) {
                ModificarCredito().removerCreditoUsuario(user);
              }
            }
          }
        }
      }
    }

Future<void> agregarUsuarioEnCuatroClases(
    String diaSeleccionado, String horaSeleccionada, String user) async {

  final data = await ObtenerTotalInfo().obtenerInfo();

  int count = 0;

  for (final item in data) {

    if (item.dia == diaSeleccionado && item.hora == horaSeleccionada) {
      count++;
      
    if (!item.mails.contains(user) && count < 5) {
      item.mails.add(user);
        await supabaseClient.from('total').update(item.toMap()).eq('id', item.id);
        ModificarLugarDisponible().removerlugarDisponible(item.id);
    }
    }
  }
  }
}

