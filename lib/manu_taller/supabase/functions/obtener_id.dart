import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';

class ObtenerId {
  Future<int> obtenerID(String user) async {
    final data = await ObtenerTotalInfo().obtenerInfoUsuarios();

    for (final item in data) {
      if (item.fullname == user) {
        return item.id;
      }
    }
    return 0;
  }
}
