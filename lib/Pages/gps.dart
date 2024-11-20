import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class GpsScreen extends StatefulWidget {
  @override
  _GpsScreenState createState() => _GpsScreenState();
}

class _GpsScreenState extends State<GpsScreen> {
  String? _locationMessage = '';
  bool _isLoading = false;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Solicita permisos para acceder a la ubicación
      bool serviceEnabled;
      LocationPermission permission;

      // Verifica si los servicios de ubicación están habilitados
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationMessage = 'Los servicios de ubicación están desactivados.';
          _isLoading = false;
        });
        return;
      }

      // Solicita permisos de ubicación
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationMessage = 'Los permisos de ubicación han sido denegados';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage =
              'Los permisos de ubicación han sido denegados permanentemente';
          _isLoading = false;
        });
        return;
      }

      // Obtiene la ubicación actual con precisión media
      Position position = await Geolocator.getCurrentPosition( //aqui se obtiene las coordenadas
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10)); // Límite de tiempo de 10 segundos

      setState(() {
        _locationMessage =
            "Latitud: ${position.latitude}, Longitud: ${position.longitude}";
        _isLoading = false;
      });

      // Genera un enlace para Google Maps
      final googleMapsUrl =
          "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
      _openLink(googleMapsUrl); // Llama a la función para abrir el enlace

    } catch (e) {
      setState(() {
        _locationMessage = 'Error obteniendo la ubicación: $e';
        _isLoading = false;
      });
    }
  }

  // Función para abrir la URL
  void _openLink(String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        throw 'No se pudo abrir el enlace $url';
      }
    } catch (e) {
      print('No se pudo abrir el enlace: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubicación GPS'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLoading
                ? CircularProgressIndicator() // Indicador de carga mientras se obtiene la ubicación
                : Text(
                    _locationMessage ?? '',
                    textAlign: TextAlign.center,
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: Text('Obtener Ubicación Actual'),
            ),
          ],
        ),
      ),
    );
  }
}