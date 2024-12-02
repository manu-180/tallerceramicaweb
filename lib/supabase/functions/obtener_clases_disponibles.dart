import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';

class ObtenerClasesDisponibles {

  
  Future<int> clasesDisponibles(String user) async {
    final data = await ObtenerTotalInfo().obtenerInfoUsuarios();

    for (final item in data) {
      if (item.fullname == user) {
        return item.clasesDisponibles;
      }
    }
    return 0;
  }
}