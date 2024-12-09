# taller_ceramica

A new Flutter project.

## Getting Started

Para cambiar el nombre de la app :
""
dart run change_app_package_name:main com.manuelnavarro.tallerdeceramica
""
seleccionar el icono :
""
dart run flutter_launcher_icons 
""

andriod AAB :
""
flutter build appbundle
""

Vamos devuelta porque me marie.
Te pido que me mandes los ficheros completos pasados en limpio con las correcciones correspondientes. te digo donde me quede. tengo los ficheros asi :
"configuracion :
"// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/providers/auth_notifier.dart';
import 'package:taller_ceramica/providers/theme_provider.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';

class Configuracion extends ConsumerStatefulWidget {
  const Configuracion({super.key});

  @override
  _ConfiguracionState createState() => _ConfiguracionState();
}

class _ConfiguracionState extends ConsumerState<Configuracion> {
  User? user;

  @override
  void initState() {
    super.initState();
    // Establece el usuario actual cuando la pantalla se inicializa
    user = ref.read(authProvider); 

  
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final bool isDark = ref.watch(themeNotifyProvider).isDarkMode;
    final List<Color> colors = ref.watch(listTheColors);
    final int selectedColor = ref.watch(themeNotifyProvider).selectedColor;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: user == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'Para cambiar la configuración debes iniciar sesión!',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: color.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 150),
                ],
              ),
            )
          : ListView(
              children: [
                // ExpansionTile que envolverá el ListView.builder
                ExpansionTile(
                  title: const Text('Elige un color'),
                  children: [
                    ListView.builder(
                      shrinkWrap: true, // Evita problemas de scroll
                      physics: const NeverScrollableScrollPhysics(), // Desactiva el scroll dentro del ExpansionTile
                      itemCount: colors.length,
                      itemBuilder: (context, index) {
                        final color = colors[index];
                        return RadioListTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.palette_outlined,
                                color: color,
                                size: 35,
                              ),
                              const SizedBox(width: 15,),
                              Icon(
                                Icons.palette_outlined,
                                color: color,
                                size: 35,
                              ),
                              const SizedBox(width: 15,),
                              Icon(
                                Icons.palette_outlined,
                                color: color,
                                size: 35,
                              ),
                              const SizedBox(width: 15,),
                              
                            ],
                          ),
                          activeColor: color,
                          value: index,
                          groupValue: selectedColor,
                          onChanged: (value) {
                            ref.read(themeNotifyProvider.notifier).changeColor(index);
                           
                          },
                        );
                      },
                    ),
                    ListTile(
                      title: Text(isDark ? 'Modo claro' : 'Modo oscuro'),
                      onTap: () {
                        ref.read(themeNotifyProvider.notifier).toggleDarkMode();
                      },
                      leading: isDark
                          ? const Icon(Icons.light_mode_outlined)
                          : const Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
} "
"appTheme:

import 'package:flutter/material.dart';


const List<Color> listColors = [
  Color(0xFFE74C3C), 
  Color(0xFFF7D794), 
  Color(0xFF55E6C1), 
  Color(0xFF00CEC9), 
  Color(0xFFADD8E6), 
  Color(0xFFAF52DE), 
];


class AppTheme {
  final int selectedColor;
  final bool isDarkMode;

  AppTheme({this.selectedColor=0, this.isDarkMode=false});

  ThemeData getColor() => ThemeData(
    brightness: isDarkMode? Brightness.dark: Brightness.light,
    colorSchemeSeed: listColors[selectedColor],
    appBarTheme: const AppBarTheme(centerTitle: false)
  );

  AppTheme copyWidht({
    bool? isDarkMode, 
    int? selectedColor}
    ) => AppTheme( 
      isDarkMode: isDarkMode?? this.isDarkMode,
      selectedColor: selectedColor?? this.selectedColor
    );


}"
"themenotifwr:
"import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false); // false significa Modo Claro

  // Función para cambiar entre modo claro/oscuro
  void toggleTheme() {
    state = !state;
  }
}

// Definir el provider de estado
final themeNotifyProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
}); "
themeprovider:
"

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taller_ceramica/config/theme/app_theme.dart';



final listTheColors = Provider((ref) => listColors);

final themeNotifyProvider = StateNotifierProvider<ThemeNotify, AppTheme>((ref) => ThemeNotify());


class ThemeNotify extends StateNotifier<AppTheme>{

  ThemeNotify() : super(AppTheme());

  void toggleDarkMode () {
    state = state.copyWidht(isDarkMode: !state.isDarkMode);
  }

  void  changeColor(int index){
    state = state.copyWidht(selectedColor:index);
  }


} "
"StorageHelpers :
"import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class StorageHelper {
  static Future<SharedPreferences> getPreferences() async {
    return await SharedPreferences.getInstance();
  }

  static Future<void> clearCache() async {
    final prefs = await getPreferences();
    await prefs.clear();
  }

  // Guardar sesión
  static Future<void> saveSession(Session session) async {
    final prefs = await getPreferences();
    final sessionData = session.toJson();
    await prefs.setString('session', jsonEncode(sessionData));
  }

  // Obtener sesión
  static Future<Session?> getSession() async {
    final prefs = await getPreferences();
    final sessionString = prefs.getString('session');
    if (sessionString != null) {
      final sessionMap = jsonDecode(sessionString) as Map<String, dynamic>;
      return Session.fromJson(sessionMap);
    }
    return null;
  }

  // Eliminar sesión
  static Future<void> deleteSession() async {
    final prefs = await getPreferences();
    await prefs.remove('session');
  }
} "
"main:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taller_ceramica/config/router/app_router.dart';
import 'package:taller_ceramica/config/theme/app_theme.dart';
import 'package:taller_ceramica/providers/theme_provider.dart';
import 'package:taller_ceramica/utils/storage_helpers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Restaurar sesión de Supabase si existe
  try {
    final session = await StorageHelper.getSession();
    if (session != null) {
      // Si hay una sesión guardada, recuperarla
      await Supabase.instance.client.auth.recoverSession(session as String);
    }
  } catch (e) {
    debugPrint('Error al restaurar la sesión: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

final supabase = Supabase.instance.client;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppTheme themeNotify = ref.watch(themeNotifyProvider);

    return MaterialApp.router(
      title: "Taller de cerámica",
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: themeNotify.getColor(),
    );
  }
} " 