import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';

class GestionHorariosScreen extends StatefulWidget {
  const GestionHorariosScreen({super.key});

  @override
  State<GestionHorariosScreen> createState() => _GestionHorariosScreenState();
}

class _GestionHorariosScreenState extends State<GestionHorariosScreen> {
  List<String> fechasDisponibles = [];
  String? fechaSeleccionada;
  List<ClaseModels> horariosDisponibles = [];
  List<ClaseModels> horariosFiltrados = [];
  bool isLoading = true;
  List<String> usuariosDisponibles = [];
  String usuarioSeleccionado = "";
  TextEditingController usuarioController = TextEditingController();
  List<String> usuariosDisponiblesOriginal = [];
  bool insertarX4 = false; // Variable para activar/desactivar insertar x4

  @override
  void initState() {
    super.initState();
    fechasDisponibles = generarFechasLunesAViernes();
    cargarDatos();
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
      final usuarios = await ObtenerTotalInfo().obtenerInfoUsuarios();

      final datosDiciembre = datos.where((clase) {
        final fecha = clase.fecha;
        return fecha.endsWith('/2024');
      }).toList();

      setState(() {
        horariosDisponibles = datosDiciembre;
        horariosFiltrados = datosDiciembre;
        usuariosDisponibles = usuarios.map((usuario) => usuario.fullname).toList();
        usuariosDisponiblesOriginal = List.from(usuariosDisponibles);
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
      horariosFiltrados = horariosDisponibles
          .where((clase) => clase.fecha == fechaSeleccionada)
          .toList();
      horariosFiltrados.sort((a, b) {
        final formatoFecha = DateFormat('dd/MM/yyyy');
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
    });
  }

  Future<void> mostrarDialogo(String tipoAccion, ClaseModels clase, ColorScheme color) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<String> usuariosFiltrados = List.from(usuariosDisponibles);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: Text(tipoAccion == "insertar"
                  ? "Seleccionar usuario para insertar"
                  : "Seleccionar usuario para remover"),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: usuarioController,
                      decoration: const InputDecoration(
                        hintText: 'Escribe el nombre del usuario',
                      ),
                      onChanged: (texto) {
                        setStateDialog(() {
                          usuariosFiltrados = usuariosDisponibles
                              .where((usuario) => usuario
                                  .toLowerCase()
                                  .contains(texto.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    usuariosFiltrados.isNotEmpty
                        ? Flexible(
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: usuariosFiltrados.length,
                                itemBuilder: (context, index) {
                                  final usuario = usuariosFiltrados[index];
                                  return ListTile(
                                    title: Text(usuario),
                                    onTap: () {
                                      setStateDialog(() {
                                        usuarioSeleccionado = usuario;
                                      });
                                    },
                                    selected: usuarioSeleccionado == usuario,
                                    selectedTileColor:
                                        color.secondary.withOpacity(0.2),
                                  );
                                },
                              ),
                            ),
                          )
                        : const Center(
                            child: Text("No se encontraron usuarios."),
                          ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tipoAccion == "insertar"
                            ? "Insertar x4"
                            : "Remover x4"),
                        Switch(
                          value: insertarX4,
                          onChanged: (value) {
                            setStateDialog(() {
                              insertarX4 = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (usuarioSeleccionado.isEmpty) return;

                            if (tipoAccion == "insertar") {
                              setState(() {
                                if (insertarX4) {
                                  AgregarUsuario(supabase)
                                      .agregarUsuarioEnCuatroClases(
                                          clase, usuarioSeleccionado);
                                  clase.mails.add(usuarioSeleccionado);
                                } else {
                                  AgregarUsuario(supabase)
                                      .agregarUsuarioAClase(clase.id,
                                          usuarioSeleccionado, true, clase);
                                  clase.mails.add(usuarioSeleccionado);
                                }
                              });
                            } else if (tipoAccion == "remover") {
                              setState(() {
                                if (insertarX4) {
                                  RemoverUsuario(supabase)
                                      .removerUsuarioDeMuchasClase(
                                          clase, usuarioSeleccionado);
                                  clase.mails.remove(usuarioSeleccionado);
                                } else {
                                  RemoverUsuario(supabase)
                                      .removerUsuarioDeClase(
                                          clase.id, usuarioSeleccionado, true);
                                  clase.mails.remove(usuarioSeleccionado);
                                }
                              });
                            }
                            Navigator.of(context).pop();
                          },
                          child: Text(tipoAccion == "insertar"
                              ? "Insertar"
                              : "Remover"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancelar"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
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
                  "En esta sesión podrás gestionar tus horarios. Ver quiénes asisten a tus clases y agregar o remover usuarios de las mismas",
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
            if (!isLoading && fechaSeleccionada != null)
              Expanded(
                child: horariosFiltrados.isNotEmpty
                    ? ListView.builder(
                        itemCount: horariosFiltrados.length,
                        itemBuilder: (context, index) {
                          final clase = horariosFiltrados[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: Text(
                                        '${clase.dia} - ${clase.hora}'),
                                    subtitle: Text(
                                        'Usuarios: ${clase.mails.join(", ")}'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            mostrarDialogo("insertar", clase,
                                                color);
                                          },
                                          child: const Text("Agregar Usuario"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            mostrarDialogo("remover", clase,
                                                color);
                                          },
                                          child: const Text("Remover Usuario"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text("No hay horarios disponibles para esta fecha."),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
