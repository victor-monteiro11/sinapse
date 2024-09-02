import 'dart:async';

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
    DateTime? cronometro = DateTime(0,0,0,0,0,0);
    Timer? _timer;
    int numero = 1;

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

    void _startTimer() {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          cronometro = cronometro?.add(Duration(seconds: 1));
        });
      });
    }

    void _pauseTimer() {
      setState(() {
        _timer?.cancel(); // Cancel the timer to pause it
      });
    }

    Future<void> startSessaoMateria(bool idle)async {
      DateTime now = DateTime.now();
      SessaoMateria sessao = SessaoMateria(startTime: now, idle: idle, idUsuario: 2, idMateria: materia?.id);

      setState(() {
        sessaoMateria = sessao;
      });
    }

    Future<void> closeSessaoMateria() async{
      DateTime now = DateTime.now();

      SessaoMateria? updatedSessaoMateria = sessaoMateria;
      updatedSessaoMateria?.endTime = now;
      //a definir depois
      updatedSessaoMateria?.quality = 4;
      await SessaoMateria.insertSessaoMateria(updatedSessaoMateria!);
      setState(() {
        sessaoMateria = updatedSessaoMateria;
      });
    }

    // INCOMPLETOS
    Future<void> startCounter()async {
      await startSessaoMateria(false);
      _startTimer();
    }

    Future<void> pauseCounter() async{
      await closeSessaoMateria();
      await startSessaoMateria(true);
      _pauseTimer();
    }

    Future<void> unPauseCounter() async{
      await closeSessaoMateria();
      await startSessaoMateria(false);
      _startTimer();
    }

    Future<void> stopCounter() async{
      await closeSessaoMateria();
      _pauseTimer();
    }

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
                  '${cronometro!.minute.toString().padLeft(2, '0')}:${cronometro!.second.toString().padLeft(2, '0')}',
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
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => MarkersPage()),
                    // );

                    switch (numero) {
                      case 1:
                        await startCounter();
                        print(await (SessaoMateria.getSessoesMateria()));
                        print(sessaoMateria?.startTime);
                        print(sessaoMateria?.endTime);
                        print(sessaoMateria?.idle);
                        break;
                      case 2:
                        await pauseCounter();
                        SessaoMateria? lastAdded = await SessaoMateria.getSessaoMateriaById(numero+2);
                        print(lastAdded?.startTime);
                        print(lastAdded?.endTime);
                        print(lastAdded?.idle);
                        break;
                      case 3:
                        await unPauseCounter();
                        SessaoMateria? lastAdded = await SessaoMateria.getSessaoMateriaById(numero+2);
                        print(lastAdded?.startTime);
                        print(lastAdded?.endTime);
                        print(lastAdded?.idle);
                        break;
                      case 4:
                        await stopCounter();
                        SessaoMateria? lastAdded = await SessaoMateria.getSessaoMateriaById(numero+2);
                        print(lastAdded?.startTime);
                        print(lastAdded?.endTime);
                        print(lastAdded?.idle);
                        break;
                    }
                    setState(() {
                      numero+=1;
                    });

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

