import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/clase_models.dart'; // Asegúrate de tener esta ruta correcta.

class ObtenerTotalInfo {
  Future<List<ClaseModels>> obtenerInfo() async {
    final data = await supabase.from('respaldo').select();
    // Convertir la lista de mapas a una lista de instancias de ClaseModels.
    return List<ClaseModels>.from(data.map((map) => ClaseModels.fromMap(map)));
  }
}


// bueno bien tuvimos una mejora. por que cuando aprete el boton y me sume a la clase, si se cambio de habilitado a deshabilitado sin necesidad de volver para atras y volver a entrar a la pantalla de turnos. pero todavia no es el resultado que yo quiero. por que me gustaria que los botones de los horarios se mantengan abiertos. 
// Es decir que cuando aprete el boton de la clase, lo que paso fue que se salieron los botones de los horarios 