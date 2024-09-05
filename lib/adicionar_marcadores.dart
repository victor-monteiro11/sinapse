import 'package:flutter/material.dart';
import 'models/materia.dart';

class AddMarkerPage extends StatefulWidget {
  @override
  _AddMarkerPageState createState() => _AddMarkerPageState();
}

class _AddMarkerPageState extends State<AddMarkerPage> {
  final TextEditingController _nomeController = TextEditingController();

  Future<void> _addMateria() async {
    if (_nomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('O nome da matéria é obrigatório')),
      );
      return;
    }

    final novaMateria = Materia(
      nome: _nomeController.text,
      dataInsert: DateTime.now(),
      isLastSelected: false,
    );

    await Materia.insertMateria(novaMateria);
    Navigator.pop(context, true); // Retorna à tela anterior e sinaliza para recarregar a lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: Text('Adicionar Matéria '),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome da Matéria',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addMateria,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text(
                'Adicionar',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
