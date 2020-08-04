import 'dart:async';
import 'dart:io' as io;

import 'package:admistrar/Movimientos.dart';
import 'package:admistrar/Producto.dart';
import 'package:admistrar/Ventas.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProducto {
  // var
  static Database _db;

  //Columnas Tabla
  static const String ID = 'id';
  static const String NOMBRE = 'nombre';
  static const String PRECIO_COMPRA = 'precio_Compra';
  static const String PRECIO_VENTA = 'precio_Venta';
  static const String IMAGENFILE = 'imagenFile';

  // Tablas DB
  static const String TABLE = 'TableProductos';
  static const String DB_NAME = 'productos.db';

  Future<Database> get db async {
    if (null != _db) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY AUTOINCREMENT, $NOMBRE TEXT, $PRECIO_COMPRA INTEGER, $PRECIO_VENTA INTEGER, $IMAGENFILE TEXT)");
  }

  Future<void> eliminarId(int id) async {
    var dbClient = await db;
    await dbClient.delete("$TABLE", where: "id = ?", whereArgs: [id]);
  }

  Future<void> editarId(ProductoDB productoDB, int id) async {
    var dbClient = await db;
    await dbClient
        .update("$TABLE", productoDB.toMap(), where: "id = ?", whereArgs: [id]);
  }

  Future<void> eliminarNombre(String nombre) async {
    var dbClient = await db;
    await dbClient.delete("$TABLE", where: "nombre = ?", whereArgs: [nombre]);
  }

  Future<void> editarNombre(ProductoDB productoDB, String nombre) async {
    var dbClient = await db;
    await dbClient.update("$TABLE", productoDB.toMap(),
        where: "nombre = ?", whereArgs: [nombre]);
  }

  Future<void> eliminarImagenFile(String imagenFile) async {
    var dbClient = await db;
    await dbClient
        .delete("$TABLE", where: "imagenFile = ?", whereArgs: [imagenFile]);
  }

  Future<ProductoDB> save(ProductoDB employee) async {
    var dbClient = await db;
    employee.id = await dbClient.insert(TABLE, employee.toMap());
    return employee;
  }

  Future<List<ProductoDB>> getProductos() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE,
        columns: [ID, NOMBRE, PRECIO_COMPRA, PRECIO_VENTA, IMAGENFILE]);
    List<ProductoDB> employees = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        employees.add(ProductoDB.fromMap(maps[i]));
      }
    }
    return employees;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}

class DBVentas {
  // Var
  static Database _db;

  //Columnas Tabla
  static const String ID = 'id';
  static const String FECHA = 'fecha';
  static const String PRODUCTOS = 'productos';
  static const String CLIENTE = 'cliente';
  static const String VALORTOTAL = 'valorTotal';
  static const String GANANCIA = 'ganancia';
  static const String DOMICILIO = 'domicilio';
  static const String CUOTAS = 'cuotas';
  static const String TIPO = 'tipo';

  //Tabla DB
  static const String TABLE = 'TableVentas';
  static const String DB_NAME = 'ventas.db';

  Future<Database> get db async {
    if (null != _db) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<void> editarId(VentasDB ventasDB, int id) async {
    var dbClient = await db;
    await dbClient
        .update("$TABLE", ventasDB.toMap(), where: "id = ?", whereArgs: [id]);
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY AUTOINCREMENT, $FECHA TEXT, $CLIENTE TEXT, $PRODUCTOS TEXT, $VALORTOTAL INTEGER, $GANANCIA INTEGER, $DOMICILIO INTEGER, $CUOTAS TEXT, $TIPO TEXT)");
  }

  Future<VentasDB> save(VentasDB employee) async {
    var dbClient = await db;
    employee.id = await dbClient.insert(TABLE, employee.toMap());
    return employee;
  }

  Future<List<VentasDB>> getVentas() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE, columns: [
      ID,
      FECHA,
      CLIENTE,
      PRODUCTOS,
      VALORTOTAL,
      GANANCIA,
      DOMICILIO,
      CUOTAS,
      TIPO
    ]);
    List<VentasDB> employees = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        employees.add(VentasDB.fromMap(maps[i]));
      }
    }
    return employees;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}

class DBMovimientos {
  // Var
  static Database _db;

  //Columnas Tabla
  static const String ID = 'id';
  static const String FECHA = 'fecha';
  static const String NOMBRE = 'nombre';
  static const String DESCRIPCION = 'descripcion';
  static const String VALOR = 'valor';
  static const String GASTO = 'gasto';
  static const String GANANCIA = 'ganancia';

  //Tabla DB
  static const String TABLE = 'TableMovimientos';
  static const String DB_NAME = 'movimientos.db';

  Future<Database> get db async {
    if (null != _db) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY AUTOINCREMENT, $FECHA TEXT, $NOMBRE TEXT, $DESCRIPCION TEXT, $VALOR INTEGER, $GASTO INTEGER, $GANANCIA INTEGER)");
  }

  Future<MovimientosDB> save(MovimientosDB employee) async {
    var dbClient = await db;
    employee.id = await dbClient.insert(TABLE, employee.toMap());
    return employee;
  }

  Future<List<MovimientosDB>> getMovimientos() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE,
        columns: [ID, FECHA, NOMBRE, DESCRIPCION, VALOR, GASTO, GANANCIA]);
    List<MovimientosDB> employees = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        employees.add(MovimientosDB.fromMap(maps[i]));
      }
    }
    return employees;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
