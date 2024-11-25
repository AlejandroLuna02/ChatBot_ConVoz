import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

const String apiKey = "AIzaSyCSODG2Bohy9_tSYKXAtrL6s3KEEk-smeI";

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  bool _isListening = false;
  bool _isConnected = true;
  String _speechText = '';
  String _selectedLanguage = "en-US";
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  Timer? _connectionChecker;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _startConnectionCheck();
  }

  @override
  void dispose() {
    _connectionChecker?.cancel();
    super.dispose();
  }

  Future<void> _initializeService() async {
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    _chatSession = _model.startChat();

    await _requestMicrophonePermission();
    await _checkInternetConnection();
    await _loadMessages();
  }

  void _startConnectionCheck() {
    _connectionChecker = Timer.periodic(Duration(seconds: 5), (_) async {
      await _checkInternetConnection();
    });
  }

  Future<void> _requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> _checkInternetConnection() async {
    try {
      final response = await http.get(Uri.parse('https://google.com'));
      if (response.statusCode == 200) {
        if (!_isConnected) {
          setState(() {
            _isConnected = true;
          });
        }
      } else {
        if (_isConnected) {
          setState(() {
            _isConnected = false;
          });
        }
      }
    } catch (e) {
      if (_isConnected) {
        setState(() {
          _isConnected = false;
        });
      }
    }
  }

  Future<void> _clearChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chatMessages');
    setState(() {
      _messages.clear();
    });
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedMessages = prefs.getStringList('chatMessages');

    if (savedMessages != null) {
      setState(() {
        _messages.clear();
        _messages.addAll(savedMessages.map((msg) {
          bool isUser = msg.startsWith('user:');
          String text = msg.replaceFirst(isUser ? 'user:' : 'bot:', '');
          return ChatMessage(text: text, isUser: isUser);
        }).toList());
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty && _isConnected) {
      setState(() {
        _messages.add(ChatMessage(text: _controller.text, isUser: true));
      });

      String userMessage = _controller.text;
      _controller.clear();

      setState(() {
        _messages.add(ChatMessage(text: "Analizando...", isUser: false));
      });

      try {
        final response = await _chatSession.sendMessage(Content.text(userMessage));
        String botResponse = response.text ?? "No se recibió respuesta";

        botResponse = botResponse.replaceAll('*', '');

        setState(() {
          _messages.removeLast();
          _messages.add(ChatMessage(text: botResponse, isUser: false));
        });

        await _saveMessages();
        await _speak(botResponse);
      } catch (e) {
        setState(() {
          _messages.removeLast();
          _messages.add(ChatMessage(text: "Error: $e", isUser: false));
        });
      }
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.speak(text);
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> messagesToSave = _messages
        .take(40)
        .map((msg) => "${msg.isUser ? 'user:' : 'bot:'}${msg.text}")
        .toList();
    await prefs.setStringList('chatMessages', messagesToSave);
  }

  void _processQRCode(String qrCodeContent) {
    if (qrCodeContent == "BORRAR CONVERSACION") {
      _clearChat();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Conversación borrada exitosamente.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("El código QR no es válido.")),
      );
    }
  }

  Future<void> _scanQRCode() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodeScannerScreen(onQRCodeScanned: _processQRCode),
      ),
    );
  }

  Future<void> _startListening() async {
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
        _speech.listen(
          onResult: (val) {
            setState(() {
              _speechText = val.recognizedWords;
              _controller.text = _speechText;
            });
          },
          localeId: _selectedLanguage,
        );
      }
    } else {
      print("Permisos de micrófono denegados");
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.yellow,
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: _scanQRCode,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Align(
                    alignment: _messages[index].isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: _messages[index].isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!_messages[index].isUser)
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/images/bot.jpeg'),
                          ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _messages[index].isUser
                                  ? Colors.yellow[600]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomLeft: _messages[index].isUser
                                    ? Radius.circular(16)
                                    : Radius.circular(0),
                                bottomRight: _messages[index].isUser
                                    ? Radius.circular(0)
                                    : Radius.circular(16),
                              ),
                            ),
                            child: Text(
                              _messages[index].text,
                              style: TextStyle(
                                color: _messages[index].isUser
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        if (_messages[index].isUser)
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/images/profile.png'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic, color: Colors.yellow[600]),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: _isConnected ? Colors.yellow[600] : Colors.grey,
                  ),
                  onPressed: _isConnected ? _sendMessage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class QRCodeScannerScreen extends StatelessWidget {
  final void Function(String) onQRCodeScanned;

  QRCodeScannerScreen({required this.onQRCodeScanned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Escanear QR"),
      ),
      body: MobileScanner(
        onDetect: (barcodeCapture) {
          final barcode = barcodeCapture.barcodes.first;
          if (barcode.rawValue != null) {
            Navigator.pop(context);
            onQRCodeScanned(barcode.rawValue!);
          }
        },
      ),
    );
  }
}
