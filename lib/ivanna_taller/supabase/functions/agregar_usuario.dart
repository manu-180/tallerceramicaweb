import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/ivanna_taller/models/clase_models.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/modificar_lugar_disponible.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/modificar_credito.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/ivanna_taller/utils/enviar_wpp.dart';

class AgregarUsuario {
  final SupabaseClient supabaseClient;

  AgregarUsuario(this.supabaseClient);

  Future<void> agregarUsuarioAClase(
      int idClase, String user, bool parametro, ClaseModels claseModels) async {
    final usuarios = await ObtenerTotalInfo().obtenerInfoUsuarios();

    final data =
        await supabaseClient.from('Taller de cerámica Ricardo Rojas').select().eq('id', idClase).single();

    final clase = ClaseModels.fromMap(data);

    for (final usuario in usuarios) {
      if (usuario.fullname == user) {
        if (usuario.clasesDisponibles > 0 || parametro) {
          if (!clase.mails.contains(user)) {
            clase.mails.add(user);
            await supabaseClient
                .from('Taller de cerámica Ricardo Rojas')
                .update(clase.toMap())
                .eq('id', idClase);
            ModificarLugarDisponible().removerLugarDisponible(idClase);
            if (parametro) {
              EnviarWpp().sendWhatsAppMessage(
  "HX6dad986ed219654d62aed35763d10ccb",
  'whatsapp:+5491134272488',
  [user, clase.dia, clase.fecha, clase.hora, ""] 
);
EnviarWpp().sendWhatsAppMessage(
  "HX6dad986ed219654d62aed35763d10ccb",
  'whatsapp:+5491132820164',
  [user, clase.dia, clase.fecha, clase.hora, ""] 
);
            }
            if (!parametro) {
              ModificarCredito().removerCreditoUsuario(user);
              EnviarWpp().sendWhatsAppMessage(
  "HXb7f90c40c60e781a4c4be85825808e79",
  'whatsapp:+5491132820164',
  [user, clase.dia, clase.fecha, clase.hora, ""] 
);
EnviarWpp().sendWhatsAppMessage(
  "HXb7f90c40c60e781a4c4be85825808e79",
  'whatsapp:+5491134272488',
  [user, clase.dia, clase.fecha, clase.hora, ""] 
);
            }
          }
        }
      }
    }
  }

  Future<void> agregarUsuarioEnCuatroClases(
      ClaseModels clase, String user) async {
    final data = await ObtenerTotalInfo().obtenerInfo();
    final Map<String, int> diaToNumero = {
      'lunes': 1,
      'martes': 2,
      'miercoles': 3,
      'jueves': 4,
      'viernes': 5,
      'sabado': 6,
      'domingo': 7,
    };

    data.sort((a, b) => diaToNumero[a.dia]!.compareTo(diaToNumero[b.dia]!));

    int count = 0;

    for (final item in data) {
      if (item.dia == clase.dia && item.hora == clase.hora) {
        if (!item.mails.contains(user) && count < 4) {
          item.mails.add(user);
          await supabaseClient
              .from('Taller de cerámica Ricardo Rojas')
              .update(item.toMap())
              .eq('id', item.id);
          ModificarLugarDisponible().removerLugarDisponible(item.id);
          count++;
        }
      }
    }

    // Enviar el mensaje al usuario solo después de que se haya agregado a las 4 clases
    if (count == 4) {
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
}
