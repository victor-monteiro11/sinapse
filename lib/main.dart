import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sinapse/database.dart';
import 'adicionar_marcadores.dart';
import 'chart.dart';
import 'models/Usuario.dart';
import 'models/Materia.dart';
import 'models/SessaoMateria.dart';
import 'package:sqflite/sqflite.dart';
import 'marcadores.dart';
import 'tela_login.dart';
import 'tela_registro.dart';
import 'user_manager.dart'; // Importar UserManager
import 'chart.dart';
import 'package:sinapse/services/local_notification_service.dart';

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
        '/marcadores': (context) => MarkersPage(),
        '/adicionar_marcadores': (context) => AddMarkerPage(),
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
  List<SessaoMateria> toBeAdded = [];

  late final LocalNotificationService _notificationService = LocalNotificationService();

  @override
  void initState() {
    super.initState();
    _initializeNotificationService();
    init();
  }

  Future<void> init() async {
    materias = await Materia.getMaterias(); // Carrega todas as matérias
    if (materias.isEmpty) {
      final result = await Navigator.pushNamed(context, '/adicionar_marcadores');
      var a = await Materia.getMaterias();
      setState(() {
        materias = a;
        materia = a[0];
      });

    }
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
    // await SessaoMateria.insertSessaoMateria(updatedSessaoMateria!);
    setState(() {
      toBeAdded.add(updatedSessaoMateria!);
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
    _showStartTimeNotification();
  }

  Future<void> pauseCounter() async {
    await closeSessaoMateria();
    await startSessaoMateria(true);
    _pauseTimer();
    setState(() {
      status = 'pausado';
    });
    _showPauseNotification();
  }

  Future<void> unPauseCounter() async {
    await closeSessaoMateria();
    await startSessaoMateria(false);
    _startTimer();
    setState(() {
      status = 'continuado';
    });
    _showUnPauseNotification();
  }

  Future<void> stopCounter() async {
    await closeSessaoMateria();
    _pauseTimer();
    _timer?.cancel();
    setState(() {
      status = 'parado';
    });
    _showStopNotification();
  }

  Future<void> _initializeNotificationService() async {
    await _notificationService.initialize();
  }

  void _showStartTimeNotification() {
    _notificationService.showNotification(
      id: 1,
      title: 'Cronômetro Iniciado',
      body: 'O cronômetro foi iniciado',
    );
  }
  void _showPauseNotification() {
     _notificationService.showNotification(
      id: 2,
      title: 'Cronômetro Pausado',
      body: 'O cronômetro foi pausado',
    );
  }
  void _showUnPauseNotification() {
    _notificationService.showNotification(
      id: 2,
      title: 'Cronômetro Reiniciado',
      body: 'O cronômetro foi reiniciado',
    );
  }

  void _showStopNotification() {
    final formattedTime = '${DateTime.now().hour}:${DateTime.now().minute}';
    _notificationService.showNotification(
      id: 3,
      title: 'Cronômetro Parado',
      body: 'O cronômetro foi parado às $formattedTime',
    );
  }

  void _showEndTimeNotification() {
    _notificationService.showNotification(
      id: 2,
      title: 'Horário de saída configurado',
      body: 'Horário de saída configurado para ',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            }
        ),
        title: Text('Sinapse'),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.teal,
                ),
                child: Center(
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Matérias'),
              onTap: () {
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
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('Chart'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PieChartPage()),
                );
              },
            ),
          ],
        ),
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
                  hint: Text('Selecionar Matéria'),
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
                          Icon(Icons.circle, color: materia.cor ?? Colors.grey, size: 12),
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
                    if(materia != null) {
                      await startCounter();
                    }
                  } else if (status == 'iniciado' || status == 'continuado') {
                    await pauseCounter();
                  } else if (status == 'pausado') {
                    await unPauseCounter();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  backgroundColor: status == '' || status == 'parado' || status == 'pausado' ? Colors.teal : Colors.redAccent,
                ),
                child: Text(
                  status == '' || status == 'parado' || status == 'pausado' ? '      Iniciar      ' : '      Pausar      ',
                  style: TextStyle(fontSize: 18, color: Colors.white),
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

                  if (toBeAdded.isNotEmpty) {

                    await showDialog(context: context,
                        builder: (context) {
                      return AlertDialog(
                        title: Text('Deseja salvar o progresso?'),
                        actions: [
                          TextButton(
                              child: Text('Cancelar'),
                              onPressed: () async {
                                //Caminho negar
                                print(toBeAdded);
                                // await SessaoMateria.insertSessoes(toBeAdded);
                                setState(() {
                                  toBeAdded = [];
                                });
                                print(toBeAdded);
                                print(await SessaoMateria.getSessoesMateria());
                                Navigator.pop(context);
                              }),
                          TextButton(
                              child: Text('Confirmar'),
                              onPressed: () async {
                                //Caminho aceitar
                                print(toBeAdded);
                                await SessaoMateria.insertSessoes(toBeAdded);
                                setState(() {
                                  toBeAdded = [];
                                });
                                print(toBeAdded);
                                print(await SessaoMateria.getSessoesMateria());
                                Navigator.popAndPushNamed(context, '/chart');
                              }),
                        ],
                      );
                      });
                    setState(() {
                      cronometro = DateTime(0, 0, 0, 0, 0, 0);
                      status = '';
                    });
                  }

                  //Caminho confirmar
                  // print(toBeAdded);
                  // await SessaoMateria.insertSessoes(toBeAdded);
                  // setState(() {
                  //   toBeAdded = [];
                  // });
                  // print(toBeAdded);
                  // print(await SessaoMateria.getSessoesMateria());

                  //Caminho negar
                  // print(toBeAdded);
                  // // await SessaoMateria.insertSessoes(toBeAdded);
                  // setState(() {
                  //   toBeAdded = [];
                  // });
                  // print(toBeAdded);
                  // print(await SessaoMateria.getSessoesMateria());

                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  side: BorderSide(color: Colors.teal, width: 2),
                ),
                child: Text(
                  'Concluir',
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
