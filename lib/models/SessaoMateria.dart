import 'dart:async';
import 'dart:core';

import 'package:sinapse/models/Materia.dart';
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

  //SPECIAL METHODS

  //Separa as SessõesMaterias em listas de mesma Materia
  static Future<Map<Materia, List<SessaoMateria>>> groupSessoesByMateria(List<SessaoMateria> sessoes, List<Materia?> materias) async {
    Map<Materia, List<SessaoMateria>> groupedByMateria = {};

    for (var sessao in sessoes) {
      if (sessao.idMateria != null) {
        // Find the corresponding Materia object
        Materia? materia = materias.firstWhere(
              (m) => m?.id == sessao.idMateria
        );

        if (materia != null) {
          if (!groupedByMateria.containsKey(materia)) {
            groupedByMateria[materia] = [];
          }
          groupedByMateria[materia]!.add(sessao);
        }
      }
    }

    // // Now, you have a map where each key is an idMateria and the value is a list of SessaoMateria objects with that idMateria
    // groupedByMateria.forEach((materia, sessoesList) {
    //   var nome = materia.nome;
    //   print('Materia: $nome');
    //   for (var sessao in sessoesList) {
    //     print('  Sessao id: ${sessao.id}');
    //   }
    // });

    return groupedByMateria;
  }


  //Retorna lista de Sessões do dia passado como parâmetro
  static Future<List<SessaoMateria>> getSessoesByDate(List<SessaoMateria> sessoes, DateTime date) async {
    return sessoes.where((sessao) {
      return sessao.startTime.year == date.year &&
          sessao.startTime.month == date.month &&
          sessao.startTime.day == date.day;
    }).toList();
  }

  //Retorna lista de Sessões do dia passado como parâmetro
  static Future<List<SessaoMateria>> getSessoesByIdle(List<SessaoMateria> sessoes, bool idle) async {
    return sessoes.where((sessao) => sessao.idle == idle).toList();
  }


  // Somar total de tempo de cada materia
  static Future<Map<Materia, Duration>> getSessoesSumTime(Map<Materia, List<SessaoMateria>> groupedSessoes) async {

    Map<Materia, Duration> totalTimeByMateria = {};

    groupedSessoes.forEach((materia, sessoes) {
      Duration totalDuration = Duration();

      for (var sessao in sessoes) {
        if (sessao.endTime != null) {
          totalDuration += sessao.endTime!.difference(sessao.startTime);
        }
      }

      totalTimeByMateria[materia] = totalDuration;
    });

    // totalTimeByMateria.forEach((materia, duration) {
    //   print('Materia: ${materia.nome}, Total Time: ${duration.inHours} hours, '
    //       '${duration.inMinutes.remainder(60)} minutes,'
    //       '${duration.inSeconds.remainder(60)} seconds');
    // });




    return totalTimeByMateria;
  }



}
