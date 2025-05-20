import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';

class UpdateUser {
  final SupabaseClient supabaseClient;

  UpdateUser(this.supabaseClient);

  Future<void> updateUser(String user, String updateUser) async {
    final clases = await ObtenerTotalInfo().obtenerInfo();

    for (final clase in clases) {
      if (clase.mails.contains(user)) {
        final listUsers = clase.mails;
        listUsers.remove(user);
        listUsers.add(updateUser);
        await supabaseClient
            .from('Taller de cerámica Ricardo Rojas')
            .update({'mails': listUsers}).eq('id', clase.id);
      }
    }
  }

  Future<void> updateTableUser(String userUid, String updateUser) async {
    final users = await ObtenerTotalInfo().obtenerInfoUsuarios();

    for (final user in users) {
      if (user.userUid == userUid) {
        final newName = updateUser;
        await supabaseClient
            .from('usuarios')
            .update({'fullname': newName}).eq('id', user.id);
      }
    }
  }
}
