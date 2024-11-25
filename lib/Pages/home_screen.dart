import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  // Método para abrir el enlace del repositorio
  void _launchURL() async {
    const url = 'https://github.com/AlejandroLuna02/ChatBot_ConVoz.git';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir el enlace $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1E), // Fondo oscuro
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Inicio',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo de la universidad
              Center(
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/logo.jpg'),
                  radius: 50,
                ),
              ),
              SizedBox(height: 16),

              // Información de la aplicación
              Center(
                child: Column(
                  children: [
                    Text(
                      'ChatBot',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Carrera: Ingeniería en Software',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Materia: Programación Móvil II',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Grupo: A',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Nombre: Guillen Luna Jesus Alejandro',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Matrícula: 221198',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8,),
                    Text(
                      'Recuperacion A1',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Enlace al repositorio
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.link),
                  label: Text('Ver Repositorio'),
                  onPressed: _launchURL,
                ),
              ),
              SizedBox(height: 24),

              // Accesos principales
              Text(
                'Accesos',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  quickAccessTile(
                    icon: Icons.chat,
                    label: 'Chatbot',
                    onTap: () {
                      Navigator.pushNamed(context, '/chat');
                    },
                  ),
                  quickAccessTile(
                    icon: Icons.gps_fixed,
                    label: 'GPS',
                    onTap: () {
                      Navigator.pushNamed(context, '/gps');
                    },
                  ),
                  quickAccessTile(
                    icon: Icons.qr_code_scanner,
                    label: 'QR Scanner',
                    onTap: () {
                      Navigator.pushNamed(context, '/qr');
                    },
                  ),
                  quickAccessTile(
                    icon: Icons.mic,
                    label: 'Micrófono',
                    onTap: () {
                      Navigator.pushNamed(context, '/micro');
                    },
                  ),
                  quickAccessTile(
                    icon: Icons.sensors,
                    label: 'Sensores',
                    onTap: () {
                      Navigator.pushNamed(context, '/sensores');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para las opciones de acceso rápido
  Widget quickAccessTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.yellow, size: 32),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
