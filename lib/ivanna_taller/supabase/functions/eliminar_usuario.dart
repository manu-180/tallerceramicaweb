import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/main.dart';

class EliminarUsuario {
  Future<void> eliminarDeBaseDatos(int userId) async {
    final dataClases = await ObtenerTotalInfo().obtenerInfo();
    final dataUsuarios = await ObtenerTotalInfo().obtenerInfoUsuarios();

    var user = "";

    await supabase.from('usuarios').delete().eq('id', userId);

    for (var usuario in dataUsuarios) {
      if (usuario.id == userId) {
        user = usuario.fullname;
      }
    }
    for (var clase in dataClases) {
      if (clase.mails.contains(user)) {
        var alumnos = clase.mails;
        alumnos.remove(user);
        await supabase
            .from('ceramica Ricardo Rojas')
            .update({'mails': alumnos}).eq('id', clase.id);
      }
    }
  }
}
