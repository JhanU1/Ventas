import 'dart:io';

import 'package:admistrar/Mostrador.dart';
import 'package:admistrar/Ventas.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'DBHelper.dart';
import 'Movimientos.dart';
import 'Producto.dart';
import 'Utility.dart';

class CrearProducto extends StatefulWidget {
  int id;
  String nombre;
  String imagenFile;
  int precio_Compra;
  int precio_Venta;
  String title;

  CrearProducto(
      {this.nombre,
      this.imagenFile,
      this.precio_Compra,
      this.precio_Venta,
      this.id,
      this.title = "Crear Producto"});

  @override
  CrearProductoState createState() => CrearProductoState();
}

class CrearProductoState extends State<CrearProducto> {
  Column column;

  pickImageFromGallery() async {
    var imgFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 800, maxHeight: 800);
    String imgString = Utility.base64String(imgFile.readAsBytesSync());
    File(imgFile.path).delete();
    setState(() {
      widget.imagenFile = imgString;
    });
  }

  DBProducto dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DBProducto();
  }

  @override
  Widget build(BuildContext context) {
    void addProducto() async {
      if (widget.nombre != null &&
          widget.precio_Compra != null &&
          widget.precio_Venta != null &&
          widget.imagenFile != null) {
        ProductoDB productoDB = ProductoDB(
            nombre: widget.nombre,
            imagenFile: widget.imagenFile,
            precio_Venta: widget.precio_Venta,
            precio_Compra: widget.precio_Compra);
        dbHelper.save(productoDB);
      }
    }

    void editProducto() async {
      if (widget.nombre != null &&
          widget.precio_Compra != null &&
          widget.precio_Venta != null &&
          widget.imagenFile != null) {
        ProductoDB productoDB = ProductoDB(
            id: widget.id,
            precio_Compra: widget.precio_Compra,
            precio_Venta: widget.precio_Venta,
            imagenFile: widget.imagenFile,
            nombre: widget.nombre);
        await dbHelper.editarId(productoDB, widget.id);
      }
    }

    void actualizarProducto() async {
      editProducto();
      Navigator.pop(context);
    }

    void primeraCarga() {
      column = Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
            child: TextField(
              onChanged: (string) {
                widget.nombre = string;
              },
              textInputAction: TextInputAction.done,
              controller: TextEditingController(
                  text: widget.nombre != null ? widget.nombre : ""),
              maxLines: null,
              decoration: InputDecoration(
                labelText: "Nombre del Producto: ",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
            child: TextField(
              onChanged: (string) {
                widget.precio_Compra = int.parse(string);
              },
              controller: TextEditingController(
                  text: widget.precio_Compra != null
                      ? "${widget.precio_Compra}"
                      : ""),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                labelText: "Precio de Compra: ",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
            child: TextField(
              onChanged: (string) {
                widget.precio_Venta = int.parse(string);
              },
              textInputAction: TextInputAction.done,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
              controller: TextEditingController(
                  text: widget.precio_Venta != null
                      ? "${widget.precio_Venta}"
                      : ""),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Precio de Venta: ",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                pickImageFromGallery();
              });
            },
            child: Container(
              height: 400,
              alignment: Alignment.center,
              child: widget.imagenFile == null
                  ? Text(
                      "Cargar Imagen",
                      style: TextStyle(fontSize: 20),
                    )
                  : Utility.imageFromBase64String(widget.imagenFile),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  if (widget.title == "Crear Producto") {
                    addProducto();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CrearProducto()));
                  } else {
                    actualizarProducto();
                  }
                },
                child: widget.title == "Crear Producto"
                    ? Text(
                        "Guardar Producto",
                        style: TextStyle(fontSize: 20),
                      )
                    : Text("Guardar Cambios"),
              ),
            ],
          )
        ],
      );
    }

    primeraCarga();
    if (widget.title == "Crear Producto") {
      Scaffold scaffold = Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: Text("Lista de opciones"),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text("Crear Producto"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Lista de Productos"),
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Mostrador()));
                },
              ),
              ListTile(
                title: Text("Realizar una venta"),
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Ventas()));
                },
              ),
              ListTile(
                title: Text("Movimientos"),
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Movimientos()));
                },
              ),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  colors: [Colors.blue, Colors.white])),
          child: Container(
              margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              alignment: Alignment.center,
              child: ListView(
                children: <Widget>[column],
              )),
        ),
      );
      return scaffold;
    } else {
      Scaffold scaffold = Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  colors: [Colors.blue, Colors.white])),
          child: Container(
              margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              alignment: Alignment.center,
              child: ListView(
                children: <Widget>[column],
              )),
        ),
      );
      return scaffold;
    }
  }
}
