import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';

class ModificarLugarDisponible {

  Future<bool> agregarlugarDisponible(int id) async {

    final data = await ObtenerTotalInfo().obtenerInfo();

    for (final clase in data){
      if (clase.id == id) {
        var lugarDisponibleActualmente = clase.lugarDisponible;
        lugarDisponibleActualmente += 1;
        await supabase.from('total').update({ 'lugar_disponible': lugarDisponibleActualmente }).eq('id', clase.id);
      }
    }
    
    return true;
  }


  Future<bool> removerlugarDisponible(int id) async {

    final data = await ObtenerTotalInfo().obtenerInfo();

    for (final clase in data){
      if (clase.id == id) {
        var lugarDisponibleActualmente = clase.lugarDisponible;
        lugarDisponibleActualmente -= 1;
        await supabase.from('total').update({ 'lugar_disponible': lugarDisponibleActualmente }).eq('id', clase.id);
        
      }
    }
    
    return true;
  }
}