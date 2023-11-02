import 'package:sqflite/sqflite.dart';

late Database db;

Future<void> initializedDatabase() async {
  db = await openDatabase('cameraApplication.db', version: 1,
      onCreate: (db, version) async {
    await db.execute(
        'CREATE TABLE camera(id INTEGER PRIMARY KEY AUTOINCREMENT,imagesrc TEXT)');
  });
}
Future<void> addImageToDB(String imagesrc)async{
  await db.rawInsert('INSERT INTO camera(imagesrc)VALUES(?)',[imagesrc]);
}
Future<List<Map<String,dynamic>>>getImagesFromDB()async{
   final value =await db.rawQuery('SELECT * FROM camera');
   return value;
 }
 Future<void>deleteImageFromDB(int id)async{
  await db.rawDelete('DELETE FROM camera WHERE id =?',[id]);
 }
 