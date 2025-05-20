import 'package:taller_ceramica/main.dart';

class EliminarClase {
  Future<void> eliminarClase(int id) async {
    await supabase.from('Taller de cerámica Ricardo Rojas').delete().eq('id', id);
  }
}
