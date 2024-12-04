import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';

class ModificarAlertTrigger {

  Future<bool> agregarAlertTrigger(String user) async {

    final data = await ObtenerTotalInfo().obtenerInfoUsuarios();

    for (final usuario in data){
      // ignore: unrelated_type_equality_checks
      if (usuario.fullname == user) {
        await supabase.from('usuarios').update({ 'trigger_alert': 1 }).eq('id', usuario.id);
      }
    }
    return true;
  
  }

  Future<bool> resetearAlertTrigger(String user) async {

    final data = await ObtenerTotalInfo().obtenerInfoUsuarios();


    for (final item in data) {
      if (item.fullname == user) {
        await supabase.from('usuarios').update({ 'trigger_alert': 0 }).eq('id', item.id);
      }
    }
    return true;
  
  }
}
