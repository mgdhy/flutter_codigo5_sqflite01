import 'dart:io';
import 'package:flutter_codigo5_sqflite/models/book_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBAdmin {
  Database? myDatabase;
  static final DBAdmin db = DBAdmin._();
  DBAdmin._();

  Future<Database?> getCheckDatabase() async {
    if (myDatabase != null) return myDatabase;
    myDatabase = await initDB(); //Creación de la base de datos
    return myDatabase;
  }

  Future<Database> initDB() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "BookDB.db");
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int v) async {
        await db.execute(
            "CREATE TABLE BOOK(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, author TEXT, description TEXT, image TEXT)");
      },
    );
  }

  // READ - Realizar consultas a la tabla

  Future<List<Map<String, dynamic>>> getBooksRaw() async {
    final Database? db = await getCheckDatabase();
    List<Map<String, dynamic>> res = await db!.rawQuery("SELECT * FROM BOOK");
    return res;
  }

  Future<List<BookModel>> getBooks() async {
    List<BookModel> books = [];
    final Database? db = await getCheckDatabase();
    List res = await db!.query("BOOK", orderBy: "id DESC");
    //res = res.reversed.toList();
    books = res
        .map<BookModel>((matasquita) => BookModel.fromJson(matasquita))
        .toList();
    return books;
  }

  // CREATE - Insertar data en la tabla

  Future<int> insertBookRaw(BookModel model) async {
    final Database? db = await getCheckDatabase();
    int res = await db!.rawInsert(
        "INSERT INTO BOOK(title, author, description, image) VALUES('${model.title}', '${model.author}', '${model.description}', '${model.image}')");
    return res;
  }

  Future<int> insertBook(BookModel model) async {
    final Database? db = await getCheckDatabase();
    int res = await db!.insert("BOOK", model.toJson());
    return res;
  }

  //UPDATE ... SET ....
  Future<int> updateBookRaw(BookModel model) async {
    final Database? db = await getCheckDatabase();
    int res = await db!.rawUpdate(
        "UPDATE BOOK SET title = '${model.title}', author = '${model.author}', description = '${model.description}', image = '${model.image}' WHERE id = ${model.id} ");
    return res;
  }

  Future<int> updateBook(BookModel model) async {
    final Database? db = await getCheckDatabase();
    int res =
        await db!.update("BOOK", model.toJson(), where: "id = ${model.id}");
    return res;
  }

  Future<int> deleteBookRaw(int idBook) async {
    final Database? db = await getCheckDatabase();
    int res = await db!.rawDelete("DELETE FROM BOOK WHERE id = $idBook");
    return res;
  }

  Future<int> deleteBook(int idBook) async {
    final Database? db = await getCheckDatabase();
    int res = await db!.delete("BOOK", where: "id = $idBook");
    return res;
  }
}
