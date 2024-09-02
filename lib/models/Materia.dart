import 'package:sqflite/sqflite.dart';

import '../database.dart';

class Materia {
  int ?id;
  String nome;
  DateTime dataInsert;
  bool isLastSelected;

  Materia({this.id, required this.nome, required this.dataInsert, this.isLastSelected = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'dataInsert': dataInsert.toIso8601String(),
      'isLastSelected': isLastSelected ? 1 : 0,
    };
  }

  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      id: map['id'],
      nome: map['nome'],
      dataInsert: DateTime.parse(map['dataInsert']),
      isLastSelected: map['isLastSelected'] == 1,
    );
  }

  //MATERIA CRUD
  static Future<void> insertMateria(Materia materia) async {
    final Database db = await getDataBase();
    await db.rawInsert(
      'INSERT INTO Materia (nome, dataInsert, isLastSelected) VALUES (?, ?, ?)',
      [materia.nome, materia.dataInsert.toIso8601String(), materia.isLastSelected ? 1 : 0],
    );
  }

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
      'UPDATE Materia SET nome = ?, dataInsert = ?, isLastSelected = ? WHERE id = ?',
      [
        materia.nome,
        materia.dataInsert.toIso8601String(),
        materia.isLastSelected ? 1 : 0,
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
}
