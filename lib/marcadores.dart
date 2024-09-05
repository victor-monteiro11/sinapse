import 'package:flutter/material.dart';
import 'models/materia.dart'; // Importe o modelo de matéria
import 'adicionar_marcadores.dart'; // Importe a tela de adicionar marcadores


class MarkersPage extends StatefulWidget {
  @override
  _MarkersPageState createState() => _MarkersPageState();
}

class _MarkersPageState extends State<MarkersPage> {
  late Future<List<Materia>> _materias;
  late Materia _materia;

  @override
  void initState() {
    super.initState();
    _loadMaterias();
  }

  void _loadMaterias() {
    setState(() {
      _materias = Materia.getMaterias();
    });
  }

  void _deleteMateria(int id) async {
    await Materia.deleteMateria(id);
    _loadMaterias();
  }

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
        child: FutureBuilder<List<Materia>>(
          future: _materias,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar as matérias'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Nenhuma matéria adicionada ainda.'));
            }

            final materias = snapshot.data!;

            return ListView.builder(
              itemCount: materias.length,
              itemBuilder: (context, index) {
                final materia = materias[index];
                return MarkerItem(
                  color: Colors.blue, // Use a cor apropriada se disponível
                  subject: materia.nome,
                  onDelete: () => _deleteMateria(materia.id!),
                  onStart: () {

                    Navigator.of(context).pushNamed('/home');
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMarkerPage()),
          );
          if (result == true) {
            _loadMaterias();
          }
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
  final VoidCallback onDelete;
  final VoidCallback onStart;

  const MarkerItem({
    required this.color,
    required this.subject,
    required this.onDelete,
    required this.onStart,
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
            onPressed: onStart,
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
          TextButton(
            onPressed: onDelete,
            style: TextButton.styleFrom(
              backgroundColor: Colors.red[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'DEL',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
