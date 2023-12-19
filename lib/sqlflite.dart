import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  Database? mydatabase;

  Future<Database?> checkdata() async {
    if (mydatabase == null) {
      mydatabase = await creating();
      return mydatabase;
    } else {
      return mydatabase;
    }
  }

  int Version = 1;
  creating() async {
    String databasepath = await getDatabasesPath();
    String mypath = join(databasepath, 'new2.db');
    Database mydb =
    await openDatabase(mypath, version: Version, onCreate: (db, version) {
      db.execute('''CREATE TABLE IF NOT EXISTS 'USERS'(
      'ID' TEXT NOT NULL,
      'firstname' TEXT NOT NULL,
      'lastname' TEXT NOT NULL,
      'email' TEXT NOT NULL) ''');
    });
    return mydb;
  }

  isExist() async {
    String databasepath = await getDatabasesPath();
    String mypath = join(databasepath, 'new2.db');
    await databaseExists(mypath) ? print("it exists") : print("not exist");
  }

  reseting() async {
    String databasepath = await getDatabasesPath();
    String mypath = join(databasepath, 'new2.db');
    await deleteDatabase(mypath);
  }

  read(sql) async {
    Database? somevar = await checkdata();
    var myesponse = somevar!.rawQuery(sql);
    return myesponse;
  }

  write(sql) async {
    Database? somevar = await checkdata();
    var myesponse = somevar!.rawInsert(sql);
    return myesponse;
  }

  update(sql) async {
    Database? somevar = await checkdata();
    var myesponse = somevar!.rawUpdate(sql);
    return myesponse;
  }

  delete(sql) async {
    Database? somevar = await checkdata();
    var myesponse = somevar!.rawDelete(sql);
    return myesponse;
  }
}
