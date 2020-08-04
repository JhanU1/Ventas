import 'package:admistrar/CrearProducto.dart';
import 'package:admistrar/DBHelper.dart';
import 'package:admistrar/Producto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Movimientos.dart';
import 'Utility.dart';
import 'Ventas.dart';

class Mostrador extends StatefulWidget {
  DBProducto dbHelper;
  List<Widget> listWidget = [];
  String buscando;

  /*
    -Mostrar
    -Seleccion
   */
  String modo;

  Mostrador({
    this.modo = "Mostrar",
  }) {
    dbHelper = DBProducto();
  }

  @override
  MostradorState createState() => MostradorState();
}

class MostradorState extends State<Mostrador> {
  DBProducto dbHelper;

  @override
  void initState() {
    dbHelper = DBProducto();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void cargarCrearProducto(
        {String nombre,
        int precio_Compra,
        int precio_Venta,
        String imagenFile,
        int id}) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CrearProducto(
              id: id,
              title: "Editar Producto",
              imagenFile: imagenFile,
              precio_Venta: precio_Venta,
              precio_Compra: precio_Compra,
              nombre: nombre,
            ),
          )).then((value) {
        setState(() {});
      });
    }

    Card Producto(
        {String nombre,
        int precio_Compra,
        int precio_Venta,
        String imagenFile,
        int id}) {
      List<String> buttons = <String>["Eliminar", "Modificar"];
      return Card(
          shadowColor: Colors.black,
          borderOnForeground: true,
          elevation: 20.0,
          margin: EdgeInsets.symmetric(vertical: 30, horizontal: 0),
          child: Column(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(id != null ? "$id" : "No tiene"),
                PopupMenuButton(
                    icon: Icon(Icons.more_vert),
                    onSelected: (element) {
                      if (element == buttons[0]) {
                        dbHelper.eliminarId(id);
                        setState(() {});
                      } else {
                        if (element == buttons[1]) {
                          cargarCrearProducto(
                              nombre: nombre,
                              id: id,
                              imagenFile: imagenFile,
                              precio_Compra: precio_Compra,
                              precio_Venta: precio_Venta);
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return buttons.map((String e) {
                        return PopupMenuItem(
                          value: e,
                          child: Text(e),
                        );
                      }).toList();
                    })
              ],
            ),
            Text(
              nombre,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30),
            ),
            Container(
              child: imagenFile != null
                  ? Utility.imageFromBase64String(imagenFile)
                  : Icon(Icons.broken_image),
              height: 400,
            ),
            Text(
              "Precio de Compra:\$ ${precio_Compra}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            Text(
              "Precio de Venta: \$ $precio_Venta",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            Text(
              "Ganancia: \$ ${precio_Venta - precio_Compra}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ]));
    }

    TextField textField = TextField(
      autofocus: false,
      onChanged: (string) {
        widget.buscando = string;
      },
      onEditingComplete: () {
        setState(() {});
      },
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: "Buscar",
      ),
    );

    Future<Widget> getProductos() async {
      final list = await widget.dbHelper.getProductos();
      if (widget.buscando != null) {
        List<ProductoDB> newlist = [];
        if (widget.buscando != null) {
          if (widget.buscando != "") {
            if (list.isNotEmpty) {
              list.forEach((element) {
                if (element.nombre.contains(widget.buscando)) {
                  newlist.add(element);
                }
              });
              widget.listWidget = [];
              if (widget.modo == "Mostrar") {
                widget.listWidget = List.generate(newlist.length, (index) {
                  return Producto(
                    id: newlist[index].id,
                    nombre: newlist[index].nombre,
                    precio_Compra: newlist[index].precio_Compra,
                    precio_Venta: newlist[index].precio_Venta,
                    imagenFile: newlist[index].imagenFile,
                  );
                });
              } else {
                widget.listWidget = List.generate(newlist.length, (index) {
                  return ListTile(
                    onTap: () {
                      Navigator.pop(context, newlist[index]);
                    },
                    leading: Container(
                        height: 200,
                        width: 120,
                        child: newlist[index].imagenFile != null
                            ? Utility.imageFromBase64String(
                                newlist[index].imagenFile)
                            : Icon(Icons.broken_image)),
                    title: Text(newlist[index].nombre),
                    subtitle: Row(
                      children: <Widget>[
                        Text(
                            "P.V: ${newlist[index].precio_Venta},P.C:${newlist[index].precio_Compra}")
                      ],
                    ),
                  );
                });
              }
              return ListView(
                children: widget.listWidget,
              );
            }
          }
        }
      }
      widget.listWidget = [];
      if (widget.modo == "Mostrar") {
        widget.listWidget = List.generate(list.length, (index) {
          return Producto(
            id: list[index].id,
            nombre: list[index].nombre,
            precio_Compra: list[index].precio_Compra,
            precio_Venta: list[index].precio_Venta,
            imagenFile: list[index].imagenFile,
          );
        });
      } else {
        widget.listWidget = List.generate(list.length, (index) {
          return ListTile(
            onTap: () {
              Navigator.pop(context, list[index]);
            },
            leading: Container(
                height: 200,
                width: 120,
                child: list[index].imagenFile != null
                    ? Utility.imageFromBase64String(list[index].imagenFile)
                    : Icon(Icons.broken_image)),
            title: Text(list[index].nombre),
            subtitle: Row(
              children: <Widget>[
                Text(
                    "P.V: ${list[index].precio_Venta},   P.C:${list[index].precio_Compra}")
              ],
            ),
          );
        });
      }
      return ListView(
        children: widget.listWidget,
      );
    }

    //Tomar Tamaño dela pantalla
    // var screenSize = MediaQuery.of(context).size;
    //var width = screenSize.width;
    if (widget.modo == "Mostrar") {
      return Scaffold(
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
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => CrearProducto()));
                },
              ),
              ListTile(
                title: Text("Lista de Productos"),
                onTap: () {
                  Navigator.pop(context);
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
        appBar: AppBar(
          title: textField,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {});
              },
            )
          ],
        ),
        body: FutureBuilder(
          future: getProductos(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return snapshot.data;
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: textField,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {});
              },
            )
          ],
        ),
        body: FutureBuilder(
          future: getProductos(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return snapshot.data;
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );
    }
  }
}

class PageMostrador extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Mostrador(),
    );
  }
}
