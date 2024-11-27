import 'package:taller_ceramica/main.dart';

class ObtenerTotalInfo {

  Future<List> obtenerInfo() async {
    final data = await supabase.from('respaldo').select();
    return data;
  }

  Future<List<dynamic>> obtenermails() async {

    final data = await obtenerInfo(); 

    List<dynamic> ids = [];

    for (var i in data) {
      
      ids.add(i['mails']); // Agregar el ID de cada registro a la lista
    }
    return ids; // Retornar la lista de IDs
  }

}