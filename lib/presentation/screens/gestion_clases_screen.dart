// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/functions/generar_id.dart';
import 'package:taller_ceramica/supabase/functions/modificar_lugar_disponible.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/utils/encontrar_semana.dart';
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

  void ordenarClasesPorFechaYHora() {
  clasesFiltradas.sort((a, b) {
    final formatoFecha = DateFormat('dd/MM');
    final fechaA = formatoFecha.parse(a.fecha);
    final fechaB = formatoFecha.parse(b.fecha);

    if (fechaA == fechaB) {
      
      final formatoHora = DateFormat('HH:mm');
      final horaA = formatoHora.parse(a.hora);
      final horaB = formatoHora.parse(b.hora);
      return horaA.compareTo(horaB);
    }
    return fechaA.compareTo(fechaB);
  });
}


   List<String> generarFechasLunesAViernes() {
    final DateFormat formato = DateFormat('dd/MM/yyyy');
    final List<String> fechas = [];
    final DateTime inicio = DateTime(2024, 12, 2);
    final DateTime fin = DateTime(2024, 12, 31);

    for (DateTime fecha = inicio;
        fecha.isBefore(fin) || fecha.isAtSameMomentAs(fin);
        fecha = fecha.add(const Duration(days: 1))) {
      if (fecha.weekday >= DateTime.monday && fecha.weekday <= DateTime.friday) {
        fechas.add(formato.format(fecha));
      }
    }

    return fechas;
  }

  Future<void> cargarDatos() async {
    try {
      final datos = await ObtenerTotalInfo().obtenerInfo();


      setState(() {
        clasesDisponibles = datos;
        clasesFiltradas = List.from(datos); // Copia de datos para filtrar
        ordenarClasesPorFechaYHora(); // Ordenar antes de mostrar
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

  Future<void> agregarLugar(int id) async {
    setState(() {
      final index = clasesFiltradas.indexWhere((clase) => clase.id == id);
      if (index != -1) {
        clasesFiltradas[index].lugaresDisponibles++;
      }
    });
  }

  Future<void> quitarLugar(int id) async {
    setState(() {
      final index = clasesFiltradas.indexWhere((clase) => clase.id == id);
      if (index != -1 && clasesFiltradas[index].lugaresDisponibles > 0) {
        clasesFiltradas[index].lugaresDisponibles--;
      }
    });
  }
  // Función para mostrar el diálogo de confirmación
  Future<bool?> mostrarDialogoConfirmacion(BuildContext context, String mensaje) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmación"),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // "No"
              },
              child: const Text("No"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true); // "Sí"
              },
              child: const Text("Sí"),
            ),
          ],
        );
      },
    );
  }

String obtenerDia(DateTime fecha) {
  // Utiliza el parámetro 'fecha' de tipo DateTime correctamente
  switch (fecha.weekday) {
    case DateTime.monday: return 'lunes';
    case DateTime.tuesday: return 'martes';
    case DateTime.wednesday: return 'miercoles';
    case DateTime.thursday: return 'jueves';
    case DateTime.friday: return 'viernes';
    case DateTime.saturday: return 'sabado';
    case DateTime.sunday: return 'domingo';
    default: return 'Desconocido'; // En caso de que falle la conversión
  }
}

Future<void> mostrarDialogoAgregarClase() async {
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
                final hora = horaController.text;
                  final horaFormatoValido = RegExp(r'^\d{2}:\d{2}$').hasMatch(hora);

                  if (!horaFormatoValido) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Formato de hora inválido. Asegúrate de usar HH:mm (por ejemplo, 14:30).'),
                      ),
                    );
                    return;
                  }
                // Convertir la fecha seleccionada de String a DateTime
                DateTime fechaBase;
                try {
                  fechaBase = DateFormat('dd/MM/yyyy').parse(fechaSeleccionada!);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Formato de fecha inválido. Use dd/MM/yyyy.'),
                    ),
                  );
                  return;
                }

                // Aquí, 'obtenerDia' ahora recibe un DateTime y funciona correctamente
                final dia = obtenerDia(fechaBase);

                final List<Map<String, dynamic>> clasesAInsertar = [];
              
                for (int i = 0; i < 5; i++) {
                  final fechaSemana = fechaBase.add(Duration(days: 7 * i)); // Calcular la fecha de cada semana
                  final nuevaClase = {
                    'id': await GenerarId().generarIdClase(),
                    'semana': EncontrarSemana().obtenerSemana(fechaSeleccionada!),
                    'dia': dia,
                    'fecha': DateFormat('dd/MM/yyyy').format(fechaSemana), // Asegurarse de que la fecha esté en formato String
                    'hora': hora,
                    'mails': [],
                    'lugar_disponible': 5,
                  };
                  clasesAInsertar.add(nuevaClase);
                }
                for (int i = 0; i < 5; i++) {
                  final fechaSemana = fechaBase.add(Duration(days: 7 * i));
                try {
                  await supabase.from('respaldo').insert({
                        'id': await GenerarId().generarIdClase(),
                        'semana': EncontrarSemana().obtenerSemana(fechaSeleccionada!),
                        'dia': dia,
                        'fecha': DateFormat('dd/MM/yyyy').format(fechaSemana),
                        'hora': hora,
                        'mails': [],
                        'lugar_disponible': 5
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
              }}
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
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.primary.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "En esta sesión podrás gestionar tus clases. Ver cuantos lugares disponibles tienen, agregar o quitar lugares, eliminar clases y crear clases nuevas.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
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
                              onPressed: () async {
                                // Muestra un diálogo de confirmación antes de agregar el crédito
                                bool? respuesta = await mostrarDialogoConfirmacion(
                                  context,
                                  "¿Quieres agregar un crédito a esta clase?"
                                );
                                
                                if (respuesta == true) {
                                  agregarLugar(clase.id);
                                  ModificarLugarDisponible().agregarLugarDisponible(clase.id);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () async {
                                // Muestra un diálogo de confirmación antes de remover el crédito
                                bool? respuesta = await mostrarDialogoConfirmacion(
                                  context,
                                  "¿Quieres remover un crédito a esta clase?"
                                );

                                if (respuesta == true && clase.lugaresDisponibles > 0) {
                                  quitarLugar(clase.id);
                                  ModificarLugarDisponible().removerLugarDisponible(clase.id);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                // Muestra un diálogo de confirmación antes de eliminar la clase
                                bool? respuesta = await mostrarDialogoConfirmacion(
                                  context,
                                  "¿Estás seguro/a que quieres eliminar esta clase?"
                                );

                                if (respuesta == true) {
                                  setState(() {
                                    clasesFiltradas.removeAt(index);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                                          );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 200,
        child: FloatingActionButton(
          backgroundColor: color.secondaryContainer,
          onPressed: () {
            if (fechaSeleccionada == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, selecciona una fecha antes de agregar clases.'),
                ),
              );
              return;
            }
            mostrarDialogoAgregarClase();
          },
          child: const Text("Crear una clase nueva"),
        ),
      ),
    );
  }
}

