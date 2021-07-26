import 'dart:async';

import 'package:path/path.dart';
import 'package:splitter_app/recent_split_data.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseLocal {
  //id | split_type | note | date | pre_bill | tax | tip | total_bill | people_count | split_amount
  //id INTEGER PRIMARY KEY,
  static const String createLocalDatabase = "CREATE TABLE IF NOT EXISTS "
      "splitter("
      "id INTEGER PRIMARY KEY,"
      "split_type INTEGER, "
      "note TEXT, "
      "date TEXT, "
      "pre_bill REAL, "
      "tax INTEGER, "
      "tip INTEGER, "
      "total_bill REAL, "
      "people_count INTEGER, "
      "split_amount REAL)";

  static const String createParticipantTable = "CREATE TABLE IF NOT EXISTS "
      "participants("
      "participant_id INTEGER PRIMARY KEY, "
      "participant_name TEXT, "
      "participant_bill REAL, "
      "id INTEGER NOT NULL, "
      "FOREIGN KEY (id) REFERENCES splitter(id))";

  DatabaseLocal._();
  static final DatabaseLocal db = DatabaseLocal._();

  static Database _database;

  Future<Database> get database async {
    if(_database != null) return _database;
    else _database = await initDB();
    return _database;
  }

  void _onConfigure(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON");
  }

  void _onCreate(Database db, int version) async {
    await db.execute(createLocalDatabase);
    await db.execute(createParticipantTable);
  }

  Future<Database> initDB() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'splitter.db');
    //id | note | date | pre_bill | tax | tip | total_bill | people_count | split_amount
    return await openDatabase(path, version: 1, onConfigure: _onConfigure, onCreate: _onCreate);
  }
  
  Future<void> deleteDB() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS participants');
    await db.execute('DROP TABLE IF EXISTS splitter');
    await db.execute(createLocalDatabase);
    await db.execute(createParticipantTable);
  }

  Future<int> get nextId async {
    final db = await database;

    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM splitter");
    int id = table.first["id"];
    if(id == null) return 1;
    return id;
  }

  Future<int> get nextParticipantId async {
    final db = await database;

    var table = await db.rawQuery("SELECT MAX(participant_id)+1 as participant_id FROM participants");
    int id = table.first["participant_id"];
    if(id == null) return 1;
    return id;
  }

  Future<void> insertSplitData(dynamic recentSplitData, int type) async {
    final db = await database;

    int id = await nextId;
    int participantId = await nextId;

    if(type == 1){
      var data = recentSplitData.toMapSplit(id, type);
      await db.insert('splitter', data);
    }
    else if(type == 2){
      var data = recentSplitData.toMapSplit(id, type);
      db.insert('splitter', data);

      List<Map<String, dynamic>> participants = recentSplitData.toMapParticipants(id);
      participants.forEach((participantData) {
        db.rawInsert('INSERT INTO participants(participant_id, participant_name, participant_bill, id) '
            'VALUES(?, ?, ?, ?)', [participantId, participantData['participant_name'], participantData['participant_bill'], id]);
        participantId++;
      });
    }
    else {
      var data = recentSplitData.toMapSplit(id, type);
      await db.insert('splitter', data);

      String host = recentSplitData.host;
      db.rawInsert('INSERT INTO participants(participant_id, participant_name, participant_bill, id) '
          'VALUES(?, ?, ?, ?)', [participantId, host, null, id]);

    }
    print("Successfully insert data to local database");
  }

  Future<List<RecentSplitData>> getSplitterHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('splitter', orderBy: 'id DESC');
    return List.generate(maps.length, (index){
      return RecentSplitData.fromLocalDB(
          id: maps[index]['id'],
          type: maps[index]['split_type'],
          note: maps[index]['note'],
          date: maps[index]['date'],
          preBill: maps[index]['pre_bill'],
          taxPercentage: maps[index]['tax'].toDouble(),
          tipPercentage: maps[index]['tip'].toDouble(),
          totalBill: maps[index]['total_bill'],
          peopleCount: maps[index]['people_count'],
          splitAmount: maps[index]['split_amount']
      );
    });
  }

  Future<RecentSplitData> getSplitInfo(int index) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM splitter');
    return RecentSplitData.fromLocalDB(
        id: maps[index]['id'],
        type: maps[index]['split_type'],
        note: maps[index]['note'],
        date: maps[index]['date'],
        preBill: maps[index]['pre_bill'],
        taxPercentage: maps[index]['tax'].toDouble(),
        tipPercentage: maps[index]['tip'].toDouble(),
        totalBill: maps[index]['total_bill'],
        peopleCount: maps[index]['people_count'],
        splitAmount: maps[index]['split_amount']
    );
  }

  Future<List<Map<String, dynamic>>> getParticipants(int splitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM participants WHERE id = ${splitId+1}');
    return maps;
  }

  Future<String> getHost(int splitId) async {
    final db = await database;
    List<Map<String, dynamic>> host = await db.rawQuery('SELECT participant_name FROM participants WHERE id = ${splitId+1}');
    return host.first['participant_name'];
  }
}