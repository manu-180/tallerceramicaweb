import 'dart:convert';
import 'package:http/http.dart' as http;


class EnviarWpp {

 

void sendWhatsAppMessage(String texto, String num) async {
  // Configura tus credenciales de Twilio
  const accountSid = 'AC3dc31aa60bcd46645dd763faef054683';
  const authToken = 'df49799dbca2eb2cfe1b1467035f148b';
  const fromWhatsAppNumber = 'whatsapp:+14155238886'; // Número de Twilio
  
  const url = 'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json';

  // Datos del mensaje
  final messageData = {
    'From': fromWhatsAppNumber,
    'To': num,
    'Body': texto
  };

  // Codifica las credenciales en base64 para la autenticación básica
  final String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken'));

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