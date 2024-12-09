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
}
