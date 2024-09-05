import 'dart:ui';
import 'dart:math' as math;
import 'package:sqflite/sqflite.dart';


import '../database.dart';
import 'Cores.dart';

class Materia {
  int ?id;
  String nome;
  DateTime dataInsert;
  bool isLastSelected;
  Color ?cor;



  Materia({this.id, required this.nome, required this.dataInsert, this.isLastSelected = false, this.cor});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'dataInsert': dataInsert.toIso8601String(),
      'isLastSelected': isLastSelected ? 1 : 0,
      'cor': cor != null ? Cores.getHexFromColor(cor!) : null,
    };
  }

  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      id: map['id'],
      nome: map['nome'],
      dataInsert: DateTime.parse(map['dataInsert']),
      isLastSelected: map['isLastSelected'] == 1,
      cor: map['cor'] != null ? Cores.getColorFromHex(map['cor']) : Cores.getRandomColor(),
    );
  }

  //MATERIA CRUD
  static Future<void> insertMateria(Materia materia) async {
    final Database db = await getDataBase();
    await db.rawInsert(
      'INSERT INTO Materia (nome, dataInsert, isLastSelected, cor) VALUES (?, ?, ?, ?)',
      [
        materia.nome,
        materia.dataInsert.toIso8601String(),
        materia.isLastSelected ? 1 : 0,
        materia.cor != null ? Cores.getHexFromColor(materia.cor!) : null,
      ],
    );
  }

  static Future<Materia?> getMateriaById(int id) async {
    final Database db = await getDataBase();
    final List<Map<String, dynamic>> maps = await db.query(
      'Materia',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Materia.fromMap(maps.first);
    } else {
      return null; // No record found
    }
  }

  static Future<List<Materia>> getMaterias() async {
    final Database db = await getDataBase();
    final List<Map<String, dynamic>> maps = await db.query('Materia');

    return List.generate(maps.length, (i) {
      return Materia.fromMap(maps[i]);
    });
  }

  static Future<void> updateMateria(Materia materia) async {
    final db = await getDataBase();

    await db.rawUpdate(
      'UPDATE Materia SET nome = ?, dataInsert = ?, isLastSelected = ?, cor = ? WHERE id = ?',
      [
        materia.nome,
        materia.dataInsert.toIso8601String(),
        materia.isLastSelected ? 1 : 0,
        materia.cor != null ? Cores.getHexFromColor(materia.cor!) : null,
        materia.id,
      ],
    );
  }

  static Future<void> deleteMateria(int id) async {
    final db = await getDataBase();

    await db.delete(
      'Materia',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //SPECIAL METHODS
  static Future<Materia?> getMateriaLastSelected() async {
    final Database db = await getDataBase();
    final List<Map<String, dynamic>> maps = await db.query(
      'Materia',
      where: 'isLastSelected = ?',
      whereArgs: [1], // 1 represents true in SQLite
    );

    if (maps.isNotEmpty) {
      return Materia.fromMap(maps.first);
    } else {
      return null; // No record found
    }
  }

  // Function to set a Materia as the last selected
  static Future<void> setMateriaLastSelected(int id) async {
    final Database db = await getDataBase();
    // 1. Set isLastSelected = 0 for all Materias
    await db.update(
      'Materia',
      {'isLastSelected': 0},
      where: 'isLastSelected = 1',
    );

    // 2. Set isLastSelected = 1 for the selected Materia
    await db.update(
      'Materia',
      {'isLastSelected': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
