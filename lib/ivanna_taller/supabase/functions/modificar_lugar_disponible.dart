import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/main.dart';

class ModificarLugarDisponible {
  Future<bool> agregarLugarDisponible(int id) async {
    final data = await ObtenerTotalInfo().obtenerInfo();

    for (final clase in data) {
      if (clase.id == id) {
        var lugarDisponibleActualmente = clase.lugaresDisponibles;
        lugarDisponibleActualmente += 1;
        await supabase
            .from('ceramica Ricardo Rojas')
            .update({'lugar_disponible': lugarDisponibleActualmente}).eq(
                'id', clase.id);
      }
    }

    return true;
  }

  Future<bool> removerLugarDisponible(int id) async {
    final data = await ObtenerTotalInfo().obtenerInfo();

    for (final clase in data) {
      if (clase.id == id) {
        var lugarDisponibleActualmente = clase.lugaresDisponibles;
        lugarDisponibleActualmente -= 1;
        await supabase
            .from('ceramica Ricardo Rojas')
            .update({'lugar_disponible': lugarDisponibleActualmente}).eq(
                'id', clase.id);
      }
    }

    return true;
  }
}
