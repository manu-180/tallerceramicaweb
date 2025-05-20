import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/ivanna_taller/models/clase_models.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/calcular_24hs.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/modificar_lugar_disponible.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/ivanna_taller/utils/utils_barril.dart';

class RemoverUsuario {
  final SupabaseClient supabaseClient;

  RemoverUsuario(this.supabaseClient);

  Future<void> removerUsuarioDeClase(
      int idClase, String user, bool parametro) async {
    final data = await ObtenerTotalInfo().obtenerInfo();

    for (final item in data) {
      if (item.id == idClase) {
        final listUsers = item.mails;
        if (listUsers.contains(user)) {
          listUsers.remove(user);
          await supabaseClient
              .from('Taller de cerámica Ricardo Rojas')
              .update({'mails': listUsers}).eq('id', idClase);
          ModificarLugarDisponible().agregarLugarDisponible(idClase);
          if (!parametro) {
        EnviarWpp().sendWhatsAppMessage(
          "HXc3a9c584ef95fdb872121c9cb8a09fd1",
          'whatsapp:+5491132820164',
            Calcular24hs().esMayorA24Horas(item.fecha, item.hora)
                ? [user, item.dia, item.fecha, item.hora, "Se genero un credito para recuperar la clase"]
                : [user, item.dia, item.fecha, item.hora, "Cancelo con menos de 24 horas de anticipacion, no podra recuperar la clase"],
            );
        EnviarWpp().sendWhatsAppMessage(
          "HXc3a9c584ef95fdb872121c9cb8a09fd1",
          'whatsapp:+5491134272488',
            Calcular24hs().esMayorA24Horas(item.fecha, item.hora)
                ? [user, item.dia, item.fecha, item.hora, "Se genero un credito para recuperar la clase"]
                : [user, item.dia, item.fecha, item.hora, "Cancelo con menos de 24 horas de anticipacion, no podra recuperar la clase"],
            );

          }
          if (parametro) {
            EnviarWpp().sendWhatsAppMessage(
          "HXc0f22718dded5d710b659d89b4117bb1",
          'whatsapp:+5491132820164',
          [user, item.dia, item.fecha, item.hora, ""]
            );
        EnviarWpp().sendWhatsAppMessage(
          "HXc0f22718dded5d710b659d89b4117bb1",
          'whatsapp:+5491134272488',
          [user, item.dia, item.fecha, item.hora, ""]
            );
          }
        }
      }
    }
  }

  Future<void> removerUsuarioDeMuchasClase(
      ClaseModels clase, String user) async {
    final data = await ObtenerTotalInfo().obtenerInfo();

    for (final item in data) {
      if (clase.hora == item.hora && clase.dia == item.dia) {
        if (item.mails.contains(user)) {
          item.mails.remove(user);
          await supabaseClient
              .from('Taller de cerámica Ricardo Rojas')
              .update(item.toMap())
              .eq('id', item.id);
          ModificarLugarDisponible().agregarLugarDisponible(item.id);
        }
      }
    }
    EnviarWpp().sendWhatsAppMessage(
      "HX5a0f97cd3b0363325e3b1cc6c4d6a372",
      'whatsapp:+5491132820164',
      [user,clase.dia,"","",""],
    );
    EnviarWpp().sendWhatsAppMessage(
      "HX5a0f97cd3b0363325e3b1cc6c4d6a372",
      'whatsapp:+5491134272488',
      [user,clase.dia,"","",""],
    );
  }
}
