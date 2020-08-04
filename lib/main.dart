import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_recognition/speech_recognition.dart';

import 'ResponseApi.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VoiceHome(),
    );
  }
}

class VoiceHome extends StatefulWidget {
  @override
  _VoiceHomeState createState() => _VoiceHomeState();
}

class _VoiceHomeState extends State<VoiceHome> {
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;

  String resultText = "";

  @override
  void initState() {
    super.initState();
    runSpeedReconizerService();
  }

  runSpeedReconizerService() async {
    var responsePermiso = await requestPermissionMicrofonoRequired();
    if (responsePermiso.isSuccess) {
      initSpeechRecognizer();
    }
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
      (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
      (String speech) => setState(() => resultText = speech),
    );

    _speechRecognition.setRecognitionCompleteHandler(
      () => setState(() => _isListening = false),
    );

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton(
                  child: Icon(Icons.cancel),
                  mini: true,
                  backgroundColor: resultText.length > 0
                      ? Colors.deepOrange
                      : Colors.deepOrangeAccent[100],
                  onPressed: () {
                    if (_isListening)
                      _speechRecognition.cancel().then(
                            (result) => setState(() {
                              _isListening = result;
                              resultText = "";
                            }),
                          );
                    else
                      setState(() {
                        resultText = "";
                      });
                  },
                ),
                FloatingActionButton(
                  child: Icon(Icons.mic),
                  onPressed: () {
                    if (_isAvailable && !_isListening)
                      _speechRecognition
                          .listen(locale: "es_ES")
                          .then((result) => print('$result'));
                  },
                  backgroundColor: _isListening ? Colors.pink[200] : Colors.red,
                ),
                FloatingActionButton(
                  child: Icon(Icons.stop),
                  mini: true,
                  backgroundColor:
                      _isListening ? Colors.deepPurple : Colors.deepPurple[100],
                  onPressed: () {
                    if (_isListening)
                      _speechRecognition.stop().then(
                            (result) => setState(() => _isListening = result),
                          );
                  },
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.cyanAccent[100],
                borderRadius: BorderRadius.circular(6.0),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              ),
              child: Text(
                resultText,
                style: TextStyle(fontSize: 24.0),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<ResponseApi> requestPermissionMicrofonoRequired() async {
    final status = await Permission.microphone.request();
    print("Estado de permiso: $status");
    switch (status) {
      case PermissionStatus.denied:
        print("Se nego  el permiso: $status");
        return requestPermissionMicrofonoRequired();
      case PermissionStatus.granted:
        final statusLoc = await Permission.location.request();
        return ResponseApi(
            isSuccess: true,
            result: null,
            message: "El permiso se ha habilitado");
      case PermissionStatus.permanentlyDenied:
        print("Se nego  el permiso permanentemente: $status");
        return ResponseApi(
            isSuccess: false,
            result: null,
            message: "El permiso de ubicacion fue permanentemente denegado");
      default:
        print("No acepto el permiso: $status");
        return requestPermissionMicrofonoRequired();
    }
  }
}
