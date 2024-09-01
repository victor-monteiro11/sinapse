import 'package:flutter/material.dart';
import 'adicionar_marcadores.dart'; // Importa a tela de adicionar marcadores

class MarkersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Title'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            MarkerItem(
              color: Colors.blue,
              subject: 'ESTRUTURA DE DADOS',
              time: '00:00',
            ),
            MarkerItem(
              color: Colors.orange,
              subject: 'DIREITO CONSTITUCIONAL',
              time: '00:00',
            ),
            MarkerItem(
              color: Colors.brown,
              subject: 'REDES DE COMPUTADORES',
              time: '00:00',
            ),
            MarkerItem(
              color: Colors.purple,
              subject: 'DIREITO PENAL',
              time: '00:00',
            ),
            MarkerItem(
              color: Colors.green,
              subject: 'DIREITO ADMINISTRATIVO',
              time: '00:00',
            ),
            MarkerItem(
              color: Colors.yellow,
              subject: 'PORTUGUÊS',
              time: '00:00',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar para a tela de adicionar marcador
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMarkerPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}

class MarkerItem extends StatelessWidget {
  final Color color;
  final String subject;
  final String time;

  const MarkerItem({
    required this.color,
    required this.subject,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              subject,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Ação para iniciar o tempo e ir para a tela de início
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'START',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          SizedBox(width: 10),
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
