import 'package:flutter/material.dart';
import 'models/Usuario.dart';
import 'models/Materia.dart';
import 'models/SessaoMateria.dart';
import 'package:sinapse/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sinapse/models/Materia.dart';
import 'marcadores.dart'; // Importa a tela de marcadores

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StudyHomePage(),
    );
  }
}


  class StudyHomePage extends StatefulWidget {
  @override
  _StudyHomePage createState() => _StudyHomePage();
  }

  class _StudyHomePage extends State<StudyHomePage> {
    Materia? materia;
    SessaoMateria? sessaoMateria;

    @override
    void initState() {
      super.initState();
      init();
    }

    void init() async {
      Materia? lastMateria = await Materia.getMateriaLastSelected();
      setState(() {
        materia = lastMateria;
      });
    }

    // INCOMPLETOS
    // void startCounter(){
    //   DateTime now = DateTime.now();
    //   SessaoMateria sessao = SessaoMateria(startTime: now, idle: false, idUsuario: 1, idMateria: materia?.id);
    //
    //   setState(() {
    //     sessaoMateria = sessao;
    //   });
    // }
    //
    // void pauseCounter() async{
    //   DateTime now = DateTime.now();
    //
    //   sessaoMateria?.endTime = now;
    //   sessaoMateria?.quality = 4;
    //   await SessaoMateria.insertSessaoMateria(sessaoMateria!);
    //   setState(() {
    //     sessaoMateria = SessaoMateria(startTime: now, idle: true, idUsuario: 1, idMateria: materia?.id);
    //   });
    // }
    //
    // void stopCounter() async{
    //   DateTime now = DateTime.now();
    //
    //   sessaoMateria?.endTime = now;
    //   sessaoMateria?.quality = 4;
    //   await SessaoMateria.insertSessaoMateria(sessaoMateria!);
    // }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.green),
            onPressed: () {
              // Ação de voltar
            },
          ),
          title: Text('Title'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                // Ação de menu
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'COMEÇAR APRENDIZADO',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 20),
                // Container circular para o GIF
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/brain.gif', // Substitua pelo seu GIF ou imagem local
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Colors.blue, size: 12),
                      SizedBox(width: 10),
                      Text(
                        materia?.nome ?? 'Escolher Materia',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '00:00',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Ação de iniciar sinapse
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    backgroundColor: Colors.teal,
                  ),
                  child: Text(
                    'Começar Sinapse',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () async {
                    // Navega para a tela de marcadores
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MarkersPage()),
                    );

                    // print("Iniciando");
                    // await testCRUD();
                    // print("Acabou");

                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    side: BorderSide(color: Colors.teal, width: 2),
                  ),
                  child: Text(
                    'Sair',
                    style: TextStyle(fontSize: 18, color: Colors.teal),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

}

