import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/usuario_models.dart';
import 'package:taller_ceramica/supabase/functions/modificar_alert_trigger.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';

class ModificarCredito {

  Future<bool> agregarCreditoUsuario(int userId) async {

    final data = await supabase.from('usuarios').select().eq('id', userId).single();

    final usuario = UsuarioModels.fromMap(data);

  
    if (usuario.id == userId) {

      var creditosActualmente = usuario.clasesDisponibles;
      creditosActualmente += 1;

      await supabase.from('usuarios').update({ 'clases_disponibles': creditosActualmente }).eq('id', userId);
      ModificarAlertTrigger().resetearAlertTrigger(usuario.fullname);
    }
    return true;
  
  }

  Future<bool> removerCreditoUsuario(String user) async {

    final data = await ObtenerTotalInfo().obtenerInfoUsuarios();

    for (final usuario in data){
      if (usuario.fullname == user) {
        var creditosActualmente = usuario.clasesDisponibles;
        creditosActualmente -= 1;
        if (usuario.clasesDisponibles > 0) {
          await supabase.from('usuarios').update({ 'clases_disponibles': creditosActualmente }).eq('id', usuario.id);
          ModificarAlertTrigger().resetearAlertTrigger(usuario.fullname);
        }
      }
    }
    
    return true;
  }

}
