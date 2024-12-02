import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/config/router/app_router.dart';
import 'package:taller_ceramica/config/theme/app_theme.dart';
import 'package:taller_ceramica/providers/theme_provider.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://gcjyhrlcftbkeaiqlzlm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdjanlocmxjZnRia2VhaXFsemxtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTU3MjQ3NzAsImV4cCI6MjAzMTMwMDc3MH0.MFsm9DJ9XnVnsTUK-N2SsCBf8wnhW03mGp5d2Z2Jf9Q',
  );

  // Inicia la aplicación
  runApp(const ProviderScope(
      child: MyApp())
  );
}

// Get a reference your Supabase client
final supabase = Supabase.instance.client;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context, ref) {


    final AppTheme themeNotify = ref.watch(themeNotifyProvider);

    return MaterialApp.router(
      title: "Taller de ceramica",
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: themeNotify.getColor(),
    );
  }

}

