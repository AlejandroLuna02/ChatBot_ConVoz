import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class MicroScreen extends StatefulWidget {
  @override
  _MicroScreenState createState() => _MicroScreenState();
}

class _MicroScreenState extends State<MicroScreen> {
  late stt.SpeechToText _speech; 
  late FlutterTts _flutterTts; // Flutter Text-to-Speech
  bool _isListening = false;
  String _speechText = ''; //se capturan y guardan en esta variable
  String _selectedLanguage = "en-US";

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTts(); // Inicializar TTS se inicia la funcion 
  }

  // Inicializar la función de Speech-to-Text
  Future<void> _initializeSpeech() async {
    _speech = stt.SpeechToText(); //aqui se inicia el hablar para que se escriba
    await _requestMicrophonePermission();
  }

  // Inicializar la función de Text-to-Speech
  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts(); //aqui texto a voz se inicia
    await _flutterTts.setLanguage(_selectedLanguage);
  }

  // Pedir permisos de micrófono
  Future<void> _requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  // Iniciar la grabación de voz
  Future<void> _startListening() async { //lo de la voz inicia en este arreglo
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done') {
            _stopListening();
          }
        },
        onError: (val) => print('Error: $val'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen( // aqui se inicia la conversion de voz a texto
          onResult: (val) {
            setState(() {
              _speechText = val.recognizedWords;
            });
          },
          localeId: _selectedLanguage,
        );
      }
    } else {
      print("Permisos de micrófono denegados");
    }
  }

  // Detener la grabación de voz
  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  // Cambiar el idioma para la voz
  void _changeLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
    _flutterTts.setLanguage(languageCode);
  }

  // Reproducir el texto como audio usando Text-to-Speech
  Future<void> _speak() async { // _speak se encarga de convertir el texto a _speechText
    if (_speechText.isNotEmpty) {
      await _flutterTts.speak(_speechText); //aqui se convierte de texto a voz
    } else {
      await _flutterTts.speak('No hay texto para reproducir.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grabar y Reproducir Texto'),
        backgroundColor: Colors.yellow[600],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _speechText.isEmpty
                      ? 'Presiona el micrófono para empezar a grabar...'
                      : _speechText,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic_off : Icons.mic,
                    color: Colors.yellow[600],
                    size: 36.0,
                  ),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
                IconButton(
                  icon: Icon(
                    Icons.volume_up,
                    color: Colors.yellow[600],
                    size: 36.0,
                  ),
                  onPressed: _speak,  // Reproduce el texto al presionar el botón
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
