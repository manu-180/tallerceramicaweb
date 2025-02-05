import 'package:taller_ceramica/main.dart';

class EliminarClase {
  Future<void> eliminarClase(int id) async {
    await supabase.from('ceramica Ricardo Rojas').delete().eq('id', id);
  }
}
