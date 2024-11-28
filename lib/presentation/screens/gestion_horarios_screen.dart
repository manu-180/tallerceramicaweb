import 'package:flutter/material.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';

class GestionHorariosScreen extends StatefulWidget {
  const GestionHorariosScreen({super.key});

  @override
  State<GestionHorariosScreen> createState() => _GestionHorariosScreenState();
}

class _GestionHorariosScreenState extends State<GestionHorariosScreen> {
  List<String> fechasDisponibles = [];
  String? fechaSeleccionada; // La fecha seleccionada por el usuario
  List<ClaseModels> horariosDisponibles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Crear una lista de fechas entre el 1/11 y el 30/11
    fechasDisponibles = List.generate(30, (index) {
      final day = (index + 1).toString().padLeft(2, '0');
      return '0${day}/11'; // Generar fecha en formato 'dd/11'
    });
    // Llamar a cargar los datos iniciales
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final datos = await ObtenerTotalInfo().obtenerInfo(); // Obtener los datos desde la base de datos
    final datosNoviembre = datos.where((clase) {
      final dia = clase.fecha.split('/')[0]; // Obtenemos solo el día
      return clase.fecha.contains('/11') && int.parse(dia) >= 1 && int.parse(dia) <= 30;
    }).toList(); // Filtrar solo las clases de noviembre

    setState(() {
      isLoading = false;
      horariosDisponibles = datosNoviembre;
    });
  }

  void seleccionarFecha(String fecha) {
    setState(() {
      fechaSeleccionada = fecha;
    });
    // Filtrar los horarios según la fecha seleccionada
    cargarHorarios();
  }

  void cargarHorarios() {
    if (fechaSeleccionada != null) {
      horariosDisponibles = horariosDisponibles.where((clase) {
        return clase.fecha == fechaSeleccionada;
      }).toList();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Horarios')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown para seleccionar la fecha
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
            const SizedBox(height: 20),
            // Si está cargando, mostrar indicador de carga
            if (isLoading) 
              const CircularProgressIndicator(),
            // Mostrar los horarios si no está cargando
            if (!isLoading && fechaSeleccionada != null)
              Expanded(
                child: ListView.builder(
                  itemCount: horariosDisponibles.length,
                  itemBuilder: (context, index) {
                    final clase = horariosDisponibles[index];
                    if (clase.fecha == fechaSeleccionada) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: ListTile(
                            title: Text('${clase.hora} - ${clase.dia} ${clase.fecha}'),
                            subtitle: Text('Usuarios: ${clase.mails.join(", ")}'),
                            trailing: Text('Lugar disponible: ${clase.lugarDisponible}'),
                          ),
                        ),
                      );
                    } else {
                      return Container(); // No mostrar nada si no es la fecha seleccionada
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
