import 'package:flutter/material.dart';
import 'models/materia.dart';
import 'models/Cores.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddMarkerPage extends StatefulWidget {
  @override
  _AddMarkerPageState createState() => _AddMarkerPageState();
}

class _AddMarkerPageState extends State<AddMarkerPage> {
  final TextEditingController _nomeController = TextEditingController();
  Color color = Colors.red;

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
      cor: color,
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
        title: Text('Adicionar Matéria'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                  width: 100,
                  height: 30,
                ),
                const SizedBox(width: 10),


                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15)
                  ),
                  child: Text(
                    '   Adicionar Cor   ',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () => pickColor(context),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addMateria,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text(
                '           Adicionar Matéria              ',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildColorPicker() => BlockPicker(
    pickerColor: color,
    availableColors: [
      Colors.green,
      Colors.black,
      Colors.blue,
      Colors.deepOrangeAccent,
      Colors.deepPurpleAccent,
      Colors.indigo,
      Colors.pink,
      Colors.yellowAccent,
      Colors.lightGreenAccent,
      Colors.black26,
      Colors.teal,
      Colors.brown,
    ],
    onColorChanged: (color) => setState(() => this.color = color),
  );

  void pickColor(BuildContext context) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Selecione sua cor'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildColorPicker(),
          TextButton(
            child: Text(
              'SELECIONAR',
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ),
  );
}
