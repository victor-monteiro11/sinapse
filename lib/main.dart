import 'dart:async';
import 'package:flutter/material.dart';
import 'chart.dart';
import 'models/Usuario.dart';
import 'models/Materia.dart';
import 'models/SessaoMateria.dart';
import 'package:sqflite/sqflite.dart';
import 'marcadores.dart';
import 'tela_login.dart';
import 'tela_registro.dart';
import 'user_manager.dart'; // Importar UserManager

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sinapse',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => StudyHomePage(),
        '/chart': (context) => PieChartPage(),
      },
    );
  }
}

class StudyHomePage extends StatefulWidget {
  final Materia? materia;

  const StudyHomePage({Key? key, this.materia}) : super(key: key);

  @override
  _StudyHomePageState createState() => _StudyHomePageState();
}

class _StudyHomePageState extends State<StudyHomePage> {
  Materia? materia;

  SessaoMateria? sessaoMateria;
  DateTime? cronometro = DateTime(0, 0, 0, 0, 0, 0);
  Timer? _timer;
  String status = '';
  List<Materia> materias = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    materias = await Materia.getMaterias(); // Carrega todas as matérias
    if (widget.materia != null) {
      setState(() {
        materia = widget.materia;
      });
      await startCounter(); // Inicia automaticamente o cronômetro
    } else {
      Materia? lastMateria = await Materia.getMateriaLastSelected();
      setState(() {
        materia = lastMateria;
      });
    }
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
      _timer?.cancel();
    });
  }

  Future<void> startSessaoMateria(bool idle) async {
    DateTime now = DateTime.now();
    SessaoMateria sessao = SessaoMateria(
      startTime: now,
      idle: idle,
      idUsuario: UserManager.userId, // Use o ID do usuário do UserManager
      idMateria: materia?.id,
    );

    setState(() {
      sessaoMateria = sessao;
    });
  }

  Future<void> closeSessaoMateria() async {
    DateTime now = DateTime.now();

    SessaoMateria? updatedSessaoMateria = sessaoMateria;
    updatedSessaoMateria?.endTime = now;
    updatedSessaoMateria?.quality = 4;
    await SessaoMateria.insertSessaoMateria(updatedSessaoMateria!);
    setState(() {
      sessaoMateria = updatedSessaoMateria;
    });
  }

  Future<void> startCounter() async {
    await startSessaoMateria(false);
    setState(() {
      status = 'iniciado';
      cronometro = DateTime(0, 0, 0, 0, 0, 0);
    });
    _startTimer();
  }

  Future<void> pauseCounter() async {
    await closeSessaoMateria();
    await startSessaoMateria(true);
    _pauseTimer();
    setState(() {
      status = 'pausado';
    });
  }

  Future<void> unPauseCounter() async {
    await closeSessaoMateria();
    await startSessaoMateria(false);
    _startTimer();
    setState(() {
      status = 'continuado';
    });
  }

  Future<void> stopCounter() async {
    await closeSessaoMateria();
    _pauseTimer();
    _timer?.cancel();
    setState(() {
      status = 'parado';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => LoginPage()),
              // );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PieChartPage()),
              );
            }
        ),
        title: Text('Title'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MarkersPage()),
              ).then((selectedMateria) async {
                // Recarregar as matérias ao retornar
                materias = await Materia.getMaterias();
                setState(() {
                  materia = selectedMateria;
                });
                if (selectedMateria != null) {
                  startCounter();
                }
              });
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
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    status == 'iniciado' || status == 'continuado'
                        ? 'lib/assets/brain.gif'
                        : 'lib/assets/brain_statico.png',
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
                child: DropdownButton<int>(
                  value: materia?.id,
                  hint: Text('Escolher Matéria'),
                  onChanged: (int? idMateria) async {
                    Materia? selectedMateria = await Materia.getMateriaById(idMateria!);
                    setState(() {
                      materia = selectedMateria;
                    });
                  },
                  items: materias.map((Materia materia) {
                    return DropdownMenuItem<int>(
                      value: materia.id,
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: Colors.blue, size: 12),
                          SizedBox(width: 10),
                          Text(
                            materia.nome,
                            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                '${cronometro!.minute.toString().padLeft(2, '0')}:${cronometro!.second.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: status != 'parado' ? Colors.grey[700] : Colors.red,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (status == '' || status == 'parado') {
                    await startCounter();
                  } else if (status == 'iniciado' || status == 'continuado') {
                    await pauseCounter();
                  } else if (status == 'pausado') {
                    await unPauseCounter();
                  }
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
                  if (status == 'continuado' ||
                      status == 'iniciado' ||
                      status == 'pausado') {
                    await stopCounter();
                  }
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
