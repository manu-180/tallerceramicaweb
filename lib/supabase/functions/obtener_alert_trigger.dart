import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';

class ObtenerAlertTrigger {
  Future<int> alertTrigger(String user) async {
    final data = await ObtenerTotalInfo().obtenerInfoUsuarios();

    for (final item in data) {
      if (item.fullname == user) {
        return item.alertTrigger;
      }
    }
    return 0;
  }
}
