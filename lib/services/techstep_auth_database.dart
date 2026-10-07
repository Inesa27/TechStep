import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class TechStepAuthDatabase {
  TechStepAuthDatabase._();

  static final TechStepAuthDatabase instance =
      TechStepAuthDatabase._();

  static const _databaseName = 'techstep_auth.db';
  static const _databaseVersion = 1;
  static const _webUsersKey = 'techstep_auth_users_v1';

  Database? _database;
  final SharedPreferencesAsync _webPreferences =
      SharedPreferencesAsync();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Native SQLite is not used on Flutter Web.',
      );
    }

    if (_database != null) {
      return _database!;
    }

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            nis TEXT NOT NULL UNIQUE,
            class_name TEXT NOT NULL,
            password TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  Future<List<Map<String, dynamic>>> _getWebUsers() async {
    final raw = await _webPreferences.getString(_webUsersKey);

    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        return <Map<String, dynamic>>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> _saveWebUsers(
    List<Map<String, dynamic>> users,
  ) async {
    await _webPreferences.setString(
      _webUsersKey,
      jsonEncode(users),
    );
  }

  Future<bool> registerUser({
    required String name,
    required String nis,
    required String className,
    required String password,
  }) async {
    final normalizedNis = nis.trim().toLowerCase();

    if (kIsWeb) {
      final users = await _getWebUsers();

      final alreadyExists = users.any(
        (user) => user['nis'].toString() == normalizedNis,
      );

      if (alreadyExists) {
        return false;
      }

      final nextId = users.isEmpty
          ? 1
          : users
                  .map(
                    (user) =>
                        int.tryParse(user['id'].toString()) ?? 0,
                  )
                  .fold<int>(
                    0,
                    (max, id) => id > max ? id : max,
                  ) +
              1;

      users.add({
        'id': nextId,
        'name': name.trim(),
        'nis': normalizedNis,
        'class_name': className.trim(),
        'password': password,
        'created_at': DateTime.now().toIso8601String(),
      });

      await _saveWebUsers(users);
      return true;
    }

    final db = await database;

    try {
      await db.insert(
        'users',
        {
          'name': name.trim(),
          'nis': normalizedNis,
          'class_name': className.trim(),
          'password': password,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      return true;
    } on DatabaseException {
      return false;
    }
  }

  Future<bool> loginUser({
    required String nis,
    required String password,
  }) async {
    final normalizedNis = nis.trim().toLowerCase();

    if (kIsWeb) {
      final users = await _getWebUsers();

      return users.any(
        (user) =>
            user['nis'].toString() == normalizedNis &&
            user['password'].toString() == password,
      );
    }

    final db = await database;

    final result = await db.query(
      'users',
      columns: ['id'],
      where: 'nis = ? AND password = ?',
      whereArgs: [normalizedNis, password],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUserByNis(
    String nis,
  ) async {
    final normalizedNis = nis.trim().toLowerCase();

    if (kIsWeb) {
      final users = await _getWebUsers();

      for (final user in users) {
        if (user['nis'].toString() == normalizedNis) {
          return user;
        }
      }

      return null;
    }

    final db = await database;

    final result = await db.query(
      'users',
      where: 'nis = ?',
      whereArgs: [normalizedNis],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
