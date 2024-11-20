import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensoresScreen extends StatefulWidget {
  @override
  _SensoresScreenState createState() => _SensoresScreenState();
}

class _SensoresScreenState extends State<SensoresScreen> {
  // Variables para almacenar los datos de los sensores
  String _accelerometer = "Acelerómetro: esperando datos...";
  String _gyroscope = "Giroscopio: esperando datos...";
  String _magnetometer = "Magnetómetro: esperando datos...";

  @override
  void initState() {
    super.initState();

    // Escucha los datos del acelerómetro
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometer = 'Acelerómetro: \nX: ${event.x}, Y: ${event.y}, Z: ${event.z}';
      });
    });

    // Escucha los datos del giroscopio
    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscope = 'Giroscopio: \nX: ${event.x}, Y: ${event.y}, Z: ${event.z}';
      });
    });

    // Escucha los datos del magnetómetro
    magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        _magnetometer = 'Magnetómetro: \nX: ${event.x}, Y: ${event.y}, Z: ${event.z}';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensores del dispositivo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_accelerometer, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text(_gyroscope, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text(_magnetometer, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
