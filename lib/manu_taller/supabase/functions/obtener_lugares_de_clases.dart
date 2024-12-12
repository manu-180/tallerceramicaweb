import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';

class ObtenerLugaresDeClases {
  Future<int?> lugaresDisponibles(int id) async {
    final data = await ObtenerTotalInfo().obtenerInfo();

    for (final item in data) {
      if (item.id == id) {
        return item.lugaresDisponibles;
      }
    }
    return 0;
  }
}
