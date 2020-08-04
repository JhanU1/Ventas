import 'package:admistrar/CrearProducto.dart';
import 'package:admistrar/Producto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'DBHelper.dart';
import 'Mostrador.dart';

class Eliminar extends StatefulWidget {
  DBProducto dbProducto;

  List<ProductoDB> list = [];
  List<Widget> listWidget;

  Eliminar() {
    dbProducto = DBProducto();
    dbProducto.getProductos().then((value) {
      list.addAll(value);
    });
  }

  @override
  EliminarState createState() => EliminarState();
}

class EliminarState extends State<Eliminar> {
  @override
  Widget build(BuildContext context) {
    void actualizarDB() {
      widget.dbProducto.getProductos().then((value) {
        widget.list = [];
        widget.list.addAll(value);
      });
    }

    void cargarListWidget() {
      actualizarDB();
      /*
      setState(() {
        widget.listWidget = [];
        widget.listWidget = List.generate(widget.list.length, (index) {
          Container container = Container(
            child: Column(
              children: List.generate(
                  widget.list[index].productos.length,
                  (i) => Container(
                        child: Column(
                          children: <Widget>[
                            Text("${widget.list[index].productos[i].nombre}")
                          ],
                        ),
                      )),
            ),
          );
          return Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            width: 250,
            child: Column(
              children: <Widget>[
                Text("${widget.list.toString()}"),
                Text("${widget.dbProducto}"),
                container,
                ListTile(
                    onLongPress: () {
                      /*
                      widget.dbProducto.eliminarNombre(widget.list[index].nombre);

                       */
                    },
                    title: Text("${widget.list[index].cliente.nombre}"),
                    leading: Container(
                      height: 70,
                      width: 70,
                      child: Text("${widget.list.length}"),
                    ),
                    subtitle: Column(children: <Widget>[
                      Text("${widget.list[index].toMap()}"),
                      Row(
                        children: <Widget>[
                          Text("${widget.list[index].valorTotal}"),
                          Text("${widget.list[index].ganancia}")
                        ],
                      )
                    ])),
              ],
            ),
          );
        });
      });
      */
    }

    return MaterialApp(
      home: Scaffold(
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: Text("Lista de ventanas"),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text("Crear Producto"),
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => CrearProducto()));
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
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Eliminar un producto"),
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Eliminar()));
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text("Eliminar"),
          actions: <Widget>[
            IconButton(
              onPressed: cargarListWidget,
              icon: Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: () {
                widget.dbProducto.eliminarImagenFile("null");
                widget.dbProducto.eliminarId(0);
                for (int i = 0; i < widget.list.length; i++) {
                  widget.list.elementAt(i).id = i;
                  widget.dbProducto.save(widget.list.elementAt(i));
                }
              },
              icon: Icon(Icons.ac_unit),
            )
          ],
        ),
        body: ListView(
          children: widget.listWidget != null
              ? widget.listWidget
              : <Widget>[Text("F")],
        ),
      ),
    );
  }
}
