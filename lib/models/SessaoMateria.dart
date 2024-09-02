import 'package:sqflite/sqflite.dart';

import '../database.dart';

class SessaoMateria {
  int? id;
  DateTime startTime;
  DateTime? endTime;
  int? quality;  // Nullable because it might not be provided
  bool idle;
  int? idUsuario;  // Nullable because it might not be provided
  int? idMateria;  // Nullable because it might not be provided

  SessaoMateria({
    this.id,
    required this.startTime,
    this.endTime,
    this.quality,
    required this.idle,
    this.idUsuario,
    this.idMateria,
  });

  // Convert a SessaoMateria into a Map. The keys must correspond to the column names in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'quality': quality,
      'idle': idle ? 1 : 0,  // Store as integer for boolean
      'idUsuario': idUsuario,
      'idMateria': idMateria,
    };
  }

  // Convert a Map into a SessaoMateria. The map must contain the column names and values from the database.
  factory SessaoMateria.fromMap(Map<String, dynamic> map) {
    return SessaoMateria(
      id: map['id'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      quality: map['quality'],
      idle: map['idle'] == 1,  // Convert integer to boolean
      idUsuario: map['idUsuario'],
      idMateria: map['idMateria'],
    );
  }

  //SESSOESMATERIA CRUD
  static Future<void> insertSessaoMateria(SessaoMateria sessaoMateria) async {
    final Database db = await getDataBase();
    await db.rawInsert(
      'INSERT INTO SessaoMateria (startTime, endTime, quality, idle, idUsuario, idMateria) VALUES (?, ?, ?, ?, ?, ?)',
      [
        sessaoMateria.startTime.toIso8601String(),
        sessaoMateria.endTime?.toIso8601String(),
        sessaoMateria.quality,
        sessaoMateria.idle ? 1 : 0,
        sessaoMateria.idUsuario,
        sessaoMateria.idMateria
      ],
    );
  }

  static Future<SessaoMateria?> getSessaoMateriaById(int id) async {
    final Database db = await getDataBase();
    final List<Map<String, dynamic>> maps = await db.query(
      'SessaoMateria',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return SessaoMateria.fromMap(maps.first);
    } else {
      return null; // No record found
    }
  }

  static Future<List<SessaoMateria>> getSessoesMateria() async {
    final Database db = await getDataBase();
    final List<Map<String, dynamic>> maps = await db.query('SessaoMateria');

    return List.generate(maps.length, (i) {
      return SessaoMateria.fromMap(maps[i]);
    });
  }


  static Future<void> updateSessaoMateria(SessaoMateria sessaoMateria) async {
    final db = await getDataBase();

    await db.rawUpdate(
      'UPDATE SessaoMateria SET startTime = ?, endTime = ?, quality = ?, idle = ?, idUsuario = ?, idMateria = ? WHERE id = ?',
      [
        sessaoMateria.startTime.toIso8601String(),
        sessaoMateria.endTime?.toIso8601String(),
        sessaoMateria.quality,
        sessaoMateria.idle ? 1 : 0,
        sessaoMateria.idUsuario,
        sessaoMateria.idMateria,
        sessaoMateria.id,
      ],
    );
  }

  static Future<void> deleteSessaoMateria(int id) async {
    final db = await getDataBase();

    await db.delete(
      'SessaoMateria',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
