from flask import Flask, request, jsonify
from twilio.rest import Client

app = Flask(__name__)

# Tu SID y token de autenticación de Twilio
account_sid = 'sid'
auth_token = 'token'
client = Client(account_sid, auth_token)

@app.route('/send_whatsapp', methods=['POST'])
def send_whatsapp():
    data = request.json
    text = data.get('text')  # El mensaje a enviar
    num = data.get('num')  # El número de destino

    # Número de Twilio
    from_whatsapp_number = 'whatsapp:+14155238886'
    to_whatsapp_number = f'whatsapp:{num}'
    
    try:
        # Enviar mensaje de WhatsApp
        message = client.messages.create(
            body=text,
            from_=from_whatsapp_number,
            to=to_whatsapp_number
        )
        return jsonify({"status": "success", "message": "Mensaje enviado correctamente"})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)

