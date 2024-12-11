import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class EnviarWpp {
  void sendWhatsAppMessage(String texto, String num) async {
    await dotenv.load(fileName: ".env");
    // Configura tus credenciales de Twilio
    var accountSid = dotenv.env['ACCOUNT_SID'] ?? '';
    var authToken = dotenv.env['AUTH_TOKEN'] ?? '';
    const fromWhatsAppNumber = 'whatsapp:+14155238886'; // Número de Twilio

    var url =
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json';

    // Datos del mensaje
    final messageData = {'From': fromWhatsAppNumber, 'To': num, 'Body': texto};

    // Codifica las credenciales en base64 para la autenticación básica
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}';

    // Realiza la solicitud POST
    await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: messageData,
    );
  }
}
