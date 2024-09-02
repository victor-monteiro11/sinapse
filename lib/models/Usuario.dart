import 'package:sqflite/sqflite.dart';

import '../database.dart';

class Usuario {
  int ?id;
  String nome;
  String email;

  Usuario({this.id, required this.nome, required this.email});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
    );
  }

  //USUARIO CRUD
  static Future<void> insertUsuario(Usuario usuario) async {
    final Database db = await getDataBase();
    await db.rawInsert(
      'INSERT INTO Usuario (nome, email) VALUES (?, ?)',
      [
        usuario.nome,
        usuario.email,
      ],
    );

  }

  static Future<Usuario?> getUsuarioById(int id) async {
    final Database db = await getDataBase();
    final List<Map<String, dynamic>> maps = await db.query(
      'Usuario',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    } else {
      return null; // No record found
    }
  }

  static Future<List<Usuario>> getUsuarios() async {
    final Database db = await getDataBase();
    final List<Map<String, dynamic>> maps = await db.query('Usuario');

    return List.generate(maps.length, (i) {
      return Usuario.fromMap(maps[i]);
    });
  }

  static Future<void> updateUsuario(Usuario usuario) async {
    final db = await getDataBase();

    await db.rawUpdate(
      'UPDATE Usuario SET nome = ?, email = ? WHERE id = ?',
      [
        usuario.nome,
        usuario.email,
        usuario.id,
      ],
    );
  }

  static Future<void> deleteUsuario(int id) async {
    final db = await getDataBase();

    await db.delete(
      'Usuario',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


}
