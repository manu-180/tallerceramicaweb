import 'package:flutter/material.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/functions/generar_id.dart';
import 'package:taller_ceramica/supabase/functions/modificar_lugar_disponible.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';
import 'package:intl/intl.dart';

class GestionDeClasesScreen extends StatefulWidget {
  const GestionDeClasesScreen({super.key});

  @override
  State<GestionDeClasesScreen> createState() => _GestionDeClasesScreenState();
}

class _GestionDeClasesScreenState extends State<GestionDeClasesScreen> {
  List<String> fechasDisponibles = [];
  String? fechaSeleccionada;
  List<ClaseModels> clasesDisponibles = [];
  List<ClaseModels> clasesFiltradas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fechasDisponibles = generarFechasLunesAViernes();
    cargarDatos();
  }

  List<String> generarFechasLunesAViernes() {
    return [
      '02/12', '03/12', '04/12', '05/12', '06/12',
      '09/12', '10/12', '11/12', '12/12', '13/12',
      '16/12', '17/12', '18/12', '19/12', '20/12',
      '23/12', '24/12', '26/12', '27/12',
      '30/12', '31/12',
    ];
  }

  Future<void> cargarDatos() async {
    try {
      final datos = await ObtenerTotalInfo().obtenerInfo();

      final datosDiciembre = datos.where((clase) {
        final fecha = clase.fecha;
        return fecha.endsWith('/12');
      }).toList();

      setState(() {
        clasesDisponibles = datosDiciembre;
        clasesFiltradas = datosDiciembre;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error cargando datos: $e');
    }
  }

  void seleccionarFecha(String fecha) {
    setState(() {
      fechaSeleccionada = fecha;
      clasesFiltradas = clasesDisponibles.where((clase) {
        return clase.fecha == fechaSeleccionada;
      }).toList();
    });
  }

  String obtenerDia(String fecha) {
  final formato = DateFormat('dd/MM');
  final fechaParseada = formato.parse(fecha);
  final diaSemana = DateFormat('EEEE', 'es_ES').format(fechaParseada);

  final mapaDias = {
    'Monday': 'lunes',
    'Tuesday': 'martes',
    'Wednesday': 'miércoles',
    'Thursday': 'jueves',
    'Friday': 'viernes',
    'Saturday': 'sábado',
    'Sunday': 'domingo'
  };

  return mapaDias[diaSemana] ?? diaSemana;
}

  Future<void> mostrarDialogoAgregarClase() async {
    final newid = await GenerarId().generarIdClase();
    TextEditingController horaController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Agregar nueva clase"),
          content: TextField(
            controller: horaController,
            decoration: const InputDecoration(
              hintText: 'Ingrese la hora de la clase (HH:mm)',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final hora = horaController.text;
                if (hora.isNotEmpty && fechaSeleccionada != null) {
                  final horaFormatoValido = RegExp(r'^\d{2}:\d{2}$').hasMatch(hora);
                  if (!horaFormatoValido) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Formato de hora inválido. Use HH:mm.'),
                      ),
                    );
                    return;
                  }

                  final dia = obtenerDia(fechaSeleccionada!);
                  final List<Map<String, dynamic>> clasesAInsertar = [];

                  for (int i = 0; i < 5; i++) {
                    final fechaBase = DateFormat('dd/MM').parse(fechaSeleccionada!);
                    final fechaSemana = fechaBase.add(Duration(days: 7 * i));
                    final nuevaClase = {
                      'id': await GenerarId().generarIdClase(),
                      'semana': 'semana${i + 1}',
                      'dia': dia,
                      'fecha': DateFormat('dd/MM').format(fechaSemana),
                      'hora': hora,
                      'mails': [],
                      'lugares_disponibles': 5,
                    };
                    clasesAInsertar.add(nuevaClase);
                  }

                  try {
                    await supabase.from('clases').insert(clasesAInsertar);
                    setState(() {
                      clasesFiltradas.addAll(clasesAInsertar.map((clase) => ClaseModels(
                        id: clase['id'],
                        semana: clase['semana'],
                        dia: clase['dia'],
                        fecha: clase['fecha'],
                        hora: clase['hora'],
                        mails: clase['mails'],
                        lugaresDisponibles: clase['lugares_disponibles'],
                      )));
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Clases agregadas con éxito.'),
                      ),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    debugPrint('Error al insertar clases: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al agregar las clases.'),
                      ),
                    );
                  }
                }
              },
              child: const Text("Agregar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: fechaSeleccionada,
              hint: const Text('Selecciona una fecha'),
              onChanged: (value) {
                seleccionarFecha(value!);
              },
              items: fechasDisponibles.map((fecha) {
                return DropdownMenuItem(
                  value: fecha,
                  child: Text(fecha),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            if (isLoading) const CircularProgressIndicator(),
            if (!isLoading && fechaSeleccionada != null && clasesFiltradas.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: clasesFiltradas.length,
                  itemBuilder: (context, index) {
                    final clase = clasesFiltradas[index];
                    return Card(
                      child: ListTile(
                        title: Text('${clase.hora} - Lugares disponibles: ${clase.lugaresDisponibles}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                ModificarLugarDisponible().agregarLugarDisponible(clase.id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                ModificarLugarDisponible().removerLugarDisponible(clase.id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  clasesFiltradas.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (fechaSeleccionada != null) {
                  mostrarDialogoAgregarClase();
                }
              },
              child: const Text("Agregar nueva clase"),
            ),
          ],
        ),
      ),
    );
  }
}