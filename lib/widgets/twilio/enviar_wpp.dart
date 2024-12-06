import 'dart:convert';
import 'package:http/http.dart' as http;

class EnviarWpp {

Future<void> sendWhatsAppMessage(String to, String message) async {
  const String accountSid = 'sid';
  const String authToken = 'token';
  const String from = 'whatsapp:+14155238886'; // Número del sandbox de Twilio

  final String url = 'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json';

  // Verificar que el número de destino está en formato E.164
  final Map<String, String> body = {
    'To': to, // Asegúrate de que 'to' esté en formato correcto (+549...)
    'From': from,
    'Body': message,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
       'Authorization': 'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      print('Mensaje enviado con éxito');
    } else {
      print('Error al enviar mensaje: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Error en la solicitud: $e');
  }
}

}