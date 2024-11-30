import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/usuario_models.dart';

class ModificarCredito {

  Future<bool> agregarCreditoUsuario(int userId) async {

    final data = await supabase.from('usuarios').select().eq('id', userId).single();

    final usuario = UsuarioModels.fromMap(data);

  
    if (usuario.id == userId) {

      var creditosActualmente = usuario.clasesDisponibles;
      creditosActualmente += 1;

      await supabase.from('usuarios').update({ 'clases_disponibles': creditosActualmente }).eq('id', userId);
    }
    return true;
  
  }

  Future<bool> removerCreditoUsuario(int userId) async {

    final data = await supabase.from('usuarios').select().eq('id', userId).single();

    final usuario = UsuarioModels.fromMap(data);

  
    if (usuario.id == userId) {

      var creditosActualmente = usuario.clasesDisponibles;
      creditosActualmente -= 1;
      if (usuario.clasesDisponibles > 0) {
        await supabase.from('usuarios').update({ 'clases_disponibles': creditosActualmente }).eq('id', userId);
      }
      
    }
    return true;
  }

}
