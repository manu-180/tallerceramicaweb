import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';

class CambiarTema {

  
  Future<void> cambiarTema(String user, int color) async {
    final data = await ObtenerTotalInfo().obtenerInfoUsuarios();

    for (final item in data) {
      if (item.fullname == user) {
        await supabase.from('usuarios').update({ 'tema': color }).eq('id', item.id);
      }
    }
  }

  Future<int> obtenerColor (String user) async {
    final data = await ObtenerTotalInfo().obtenerInfoUsuarios();

    for (final item in data) {
      if (item.fullname == user) {
        return item.tema;
      }
    }
    return 0;
  }
}