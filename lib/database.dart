import 'dart:async';

import '/models/Materia.dart';
import '/models/SessaoMateria.dart';
import '/models/Usuario.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';



Future<Database> getDataBase() async {
  final database = await openDatabase(join(await getDatabasesPath(),'sinapse.db'), onCreate: _onCreate, version: 1);
  database.execute('PRAGMA foreign_keys = ON');
  return database;
}

Future<void> _onCreate(Database db, int version) async {
  await db.execute('''
      CREATE TABLE Usuario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT
      )
    ''');

  await db.execute('''
      CREATE TABLE Materia (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        dataInsert TEXT NOT NULL,
        isLastSelected INTEGER NOT NULL DEFAULT 0
      )
    ''');

  await db.execute('''
      CREATE TABLE SessaoMateria (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        quality INTEGER,
        idle BOOLEAN,
        idUsuario INTEGER,
        idMateria INTEGER,
        FOREIGN KEY (idUsuario) REFERENCES Usuario(id) ON DELETE CASCADE,
        FOREIGN KEY (idMateria) REFERENCES Materia(id) ON DELETE CASCADE
      )
    ''');
}

Future<void> dropTables() async {
  final Database db = await getDataBase();
  await db.execute("DROP TABLE IF EXISTS SessaoMateria");
  await db.execute("DROP TABLE IF EXISTS Usuario");
  await db.execute("DROP TABLE IF EXISTS Materia");

}



Future<void> testCRUD () async {
  final Database db = await getDataBase();
  await dropTables();
  await _onCreate(db, 1);
  var usuario1 = Usuario(nome: 'Alice', email: 'alice@example.com');
  var usuario2 = Usuario(nome: 'Bob', email: 'bob@example.com');
  var usuario3 = Usuario(nome: 'Rodrigo', email: 'digas@example.com');
  await Usuario.insertUsuario(usuario1);
  await Usuario.insertUsuario(usuario2);
  await Usuario.insertUsuario(usuario3);

  var materia1 = Materia(nome: 'Mathematics', dataInsert: DateTime.parse('2024-09-01T10:00:00Z'));
  var materia2 = Materia(nome: 'Science', dataInsert: DateTime.parse('2024-09-01T11:00:00Z'), isLastSelected: true);
  var materia3 = Materia(nome: 'Portugues', dataInsert: DateTime.parse('2024-10-01T10:00:00Z'));
  var materia4 = Materia(nome: 'Direito', dataInsert: DateTime.parse('2023-09-01T11:00:00Z'));
  await Materia.insertMateria(materia1);
  await Materia.insertMateria(materia2);
  await Materia.insertMateria(materia3);
  await Materia.insertMateria(materia4);

  var sessao1 = SessaoMateria(
    startTime: DateTime.parse('2024-09-01T12:00:00Z'),
    endTime: DateTime.parse('2024-09-01T13:00:00Z'),
    quality: 5,
    idle: false,
    idUsuario: 1,
    idMateria: 2,
  );
  await SessaoMateria.insertSessaoMateria(sessao1);

  var sessao2 = SessaoMateria(
    startTime: DateTime.parse('2024-09-01T14:00:00Z'),
    endTime: DateTime.parse('2024-09-01T15:00:00Z'),
    quality: 4,
    idle: false,
    idUsuario: 2,
    idMateria: 2,
  );
  await SessaoMateria.insertSessaoMateria(sessao2);

  var sessao3 = SessaoMateria(
    startTime: DateTime.parse('2024-09-01T18:00:00Z'),
    endTime: DateTime.parse('2024-09-01T23:00:00Z'),
    quality: 1,
    idle: true,
    idUsuario: 3,
    idMateria: 3,
  );
  await SessaoMateria.insertSessaoMateria(sessao3);

  // Test CRUD operations
  print('Initial Usuarios: ${await Usuario.getUsuarios()}');
  print('Initial Materias: ${await Materia.getMaterias()}');
  print('Initial SessoesMateria: ${await SessaoMateria.getSessoesMateria()}');

  print('Usuario 1 pre update: ${(await Usuario.getUsuarioById(1))?.nome}');
  // Update a Usuario record
  usuario1 = Usuario(id: 1, nome: 'Alice Updated', email: 'alice_updated@example.com');
  await Usuario.updateUsuario(usuario1);
  print('Usuario 1 pos update: ${(await Usuario.getUsuarioById(1))?.nome}');


  print('Sessão 1 filha pre delecao pai: ${(await SessaoMateria.getSessaoMateriaById(1))}');

  // Delete a Usuario record and check cascading delete
  await Usuario.deleteUsuario(1);

  print('Sessão 1 filha pós delecao pai: ${(await SessaoMateria.getSessaoMateriaById(1))}');

  print('After Update & Delete:');
  print('Usuarios: ${await Usuario.getUsuarios()}');
  print('Materias: ${await Materia.getMaterias()}');
  print('SessoesMateria: ${await SessaoMateria.getSessoesMateria()}');
}










