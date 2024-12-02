import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';

class CambiarColor {

  Future<void> cambiarColor(String userUid, int color) async {
    final data =  ObtenerTotalInfo().obtenerInfoUsuarios();

    for (final item in await data)  {
      if (item.userUid == userUid) {
        await supabase.from('usuarios').update({ 'theme': color }).eq('id', item.id);
      }
    }
  }
  Future<int> obtenerColor(String userUid) async {
    final data =  ObtenerTotalInfo().obtenerInfoUsuarios();

    for (final item in await data)  {
      if (item.userUid == userUid) {
        return item.theme;
      }
    }
    return 0;
  }

  
}