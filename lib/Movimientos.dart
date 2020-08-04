import 'package:admistrar/CrearProducto.dart';
import 'package:admistrar/DBHelper.dart';
import 'package:admistrar/Factura.dart';
import 'package:admistrar/Ventas.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'Mostrador.dart';

class MovimientosDB {
  int id;
  String nombre;
  String fecha;
  String descripcion;
  int valor;
  int ganancia;
  int gasto;

  MovimientosDB(
      {this.id,
      this.nombre,
      this.fecha,
      this.descripcion,
      this.gasto,
      this.ganancia,
      this.valor});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'nombre': nombre,
      'fecha': fecha,
      'descripcion': descripcion,
      'valor': valor,
      'gasto': gasto,
      'ganancia': ganancia,
    };
    return map;
  }

  MovimientosDB.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    nombre = map['nombre'];
    fecha = map['fecha'];
    descripcion = map['descripcion'];
    valor = map['valor'];
    gasto = map['gasto'];
    ganancia = map['ganancia'];
  }
}

class Movimientos extends StatefulWidget {
  MovimientosState createState() => MovimientosState();
  DBVentas dbVentas;
  DBMovimientos dbMovimientos;
  List<VentasDB> listaVentas;
  List<DataRow> listaRows;
  bool ordenarGanancia;
  bool ordenarValor;
  bool ordenarGasto;
  bool ordenarFecha;
  Icon icon;

  Movimientos() {
    dbVentas = DBVentas();
    dbMovimientos = DBMovimientos();
    listaVentas = [];
    listaRows = [];
  }
}

class MovimientosState extends State<Movimientos> {
  @override
  Widget build(BuildContext context) {
    Future<Widget> getVentas(
        DBVentas dbVentas, DBMovimientos dbMovimientos) async {
      var listaVentas = await dbVentas.getVentas();
      var listaMovimientos = await dbMovimientos.getMovimientos();
      listaVentas.forEach((element) {
        String productos = "";
        element.productos.forEach((element) {
          productos = productos + "," + element.nombre.toString();
        });

        listaMovimientos.add(MovimientosDB(
            id: element.id,
            ganancia: element.ganancia,
            nombre: "Venta",
            fecha: element.fecha.toString(),
            descripcion:
                "Cliente:${element.cliente.nombre},Productos:$productos",
            gasto: 0,
            valor: element.valorTotal));
      });

      ordenarPorGanancia() {
        if (widget.ordenarGanancia) {
          listaMovimientos.sort((a, b) {
            return a.ganancia.compareTo(b.ganancia) * -1;
          });
        } else {
          listaMovimientos.sort((a, b) {
            return a.ganancia.compareTo(b.ganancia);
          });
        }
      }

      ordenarPorGastos() {
        if (widget.ordenarGasto) {
          listaMovimientos.sort((a, b) {
            return a.gasto.compareTo(b.gasto) * -1;
          });
        } else {
          listaMovimientos.sort((a, b) {
            return a.gasto.compareTo(b.gasto);
          });
        }
      }

      ordenarPorValor() {
        if (widget.ordenarValor) {
          listaMovimientos.sort((a, b) {
            return a.valor.compareTo(b.valor) * -1;
          });
        } else {
          listaMovimientos.sort((a, b) {
            return a.valor.compareTo(b.valor);
          });
        }
      }

      ordenarporFecha() {
        if (widget.ordenarFecha) {
          listaMovimientos.sort((a, b) {
            return DateTime.parse(a.fecha).compareTo(DateTime.parse(b.fecha)) *
                -1;
          });
        } else {
          listaMovimientos.sort((a, b) {
            return DateTime.parse(a.fecha).compareTo(DateTime.parse(b.fecha));
          });
        }
      }

      if (widget.ordenarGanancia != null) {
        ordenarPorGanancia();
      } else {
        if (widget.ordenarGasto != null) {
          ordenarPorGastos();
        } else {
          if (widget.ordenarValor != null) {
            ordenarPorValor();
          } else {
            if (widget.ordenarFecha != null) {
              ordenarporFecha();
            }
          }
        }
      }

      double height = 1;
      BigInt totalV = BigInt.from(0);
      BigInt totalGa = BigInt.from(0);
      BigInt totalG = BigInt.from(0);
      widget.listaRows = List.generate(listaMovimientos.length, (index) {
        DateTime f = DateTime.parse(listaMovimientos[index].fecha);
        totalG = totalG + BigInt.from(listaMovimientos[index].gasto);
        totalGa = totalGa + BigInt.from(listaMovimientos[index].ganancia);
        totalV = totalV + BigInt.from(listaMovimientos[index].valor);
        double cont = 0;
        String getDescripcion(String descripcion, int tl) {
          cont++;
          if (descripcion.length > tl) {
            return descripcion.substring(0, tl) +
                "\n" +
                getDescripcion(
                    descripcion.substring(tl, descripcion.length), tl);
          } else {
            if (cont > height) {
              height = cont;
            }
            return descripcion;
          }
        }

        if (listaMovimientos[index].nombre == "Venta") {
          return DataRow(
              cells: <DataCell>[
                DataCell(Text("${f.day}/${f.month}/${f.year}")),
                DataCell(Text("${listaMovimientos[index].nombre}")),
                DataCell(Text(
                    getDescripcion(listaMovimientos[index].descripcion, 30))),
                DataCell(
                  Text("${listaMovimientos[index].valor}"),
                ),
                DataCell(Text("${listaMovimientos[index].ganancia}")),
                DataCell(Text("${listaMovimientos[index].gasto}")),
              ],
              onSelectChanged: (selecte) {
                if (selecte) {
                  VentasDB copia = listaVentas.firstWhere(
                      (element) => element.id == listaMovimientos[index].id);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Factura(
                                venta: copia,
                              )));
                }
              });
        }
        return DataRow(
            cells: <DataCell>[
              DataCell(Text("${f.day}/${f.month}/${f.year}")),
              DataCell(Text("${listaMovimientos[index].nombre}")),
              DataCell(Text(
                  getDescripcion(listaMovimientos[index].descripcion, 30))),
              DataCell(
                Text("${listaMovimientos[index].valor}"),
              ),
              DataCell(Text("${listaMovimientos[index].ganancia}")),
              DataCell(Text("${listaMovimientos[index].gasto}")),
            ],
            onSelectChanged: (selected) {
              if (selected) {}
            });
      });
      if (listaMovimientos.length >= 2) {
        DateTime f = DateTime.now();
        widget.listaRows.add(DataRow(
          cells: <DataCell>[
            DataCell(Text("${f.day}/${f.month}/${f.year}")),
            DataCell(Text("Total")),
            DataCell(Text("Total")),
            DataCell(
              Text("$totalV"),
            ),
            DataCell(Text("$totalGa")),
            DataCell(Text("$totalG")),
          ],
        ));
        widget.listaRows.add(DataRow(
          cells: <DataCell>[
            DataCell(Text("")),
            DataCell(Text("Ganancia Total")),
            DataCell(Text("Ganancia-Gasto")),
            DataCell(
              Text(" "),
            ),
            DataCell(Text("${totalGa - totalG}")),
            DataCell(Text(" ")),
          ],
        ));
      }
      DataTable table = DataTable(
        dataRowHeight: height == 1 ? height * 40 : height * 20,
        showCheckboxColumn: false,
        columns: <DataColumn>[
          DataColumn(
              label: widget.icon != null && widget.ordenarFecha != null
                  ? Row(
                      children: <Widget>[
                        widget.icon,
                        Text(
                          "Fecha",
                        )
                      ],
                    )
                  : Text(
                      "Fecha",
                    ),
              onSort: (a, b) {
                setState(() {
                  if (widget.ordenarFecha == null) {
                    widget.ordenarValor = null;
                    widget.ordenarFecha = false;
                    widget.ordenarGasto = null;
                    widget.ordenarGanancia = null;
                    widget.icon = Icon(Icons.arrow_downward);
                  } else {
                    widget.ordenarFecha = !widget.ordenarFecha;
                    widget.icon = widget.ordenarFecha
                        ? Icon(Icons.arrow_upward)
                        : Icon(Icons.arrow_downward);
                  }
                });
              }),
          DataColumn(label: Text("Nombre")),
          DataColumn(label: Text("Descripción")),
          DataColumn(
              label: widget.ordenarValor != null && widget.icon != null
                  ? Row(
                      children: <Widget>[widget.icon, Text("Valor")],
                    )
                  : Text("Valor"),
              numeric: true,
              onSort: (a, b) {
                setState(() {
                  if (widget.ordenarValor == null) {
                    widget.ordenarValor = false;
                    widget.ordenarFecha = null;
                    widget.ordenarGasto = null;
                    widget.ordenarGanancia = null;
                    widget.icon = Icon(Icons.arrow_downward);
                  } else {
                    widget.ordenarValor = !widget.ordenarValor;
                    widget.icon = widget.ordenarValor
                        ? Icon(Icons.arrow_upward)
                        : Icon(Icons.arrow_downward);
                  }
                });
              }),
          DataColumn(
              label: widget.icon != null && widget.ordenarGanancia != null
                  ? Row(
                      children: <Widget>[
                        widget.icon,
                        Text("Ganancia"),
                      ],
                    )
                  : Text("Ganancia"),
              numeric: true,
              onSort: (colum, ascen) {
                setState(() {
                  if (widget.ordenarGanancia == null) {
                    widget.ordenarValor = null;
                    widget.ordenarFecha = null;
                    widget.ordenarGasto = null;
                    widget.ordenarGanancia = false;
                    widget.icon = Icon(Icons.arrow_downward);
                  } else {
                    widget.ordenarGanancia = !widget.ordenarGanancia;
                    widget.icon = widget.ordenarGanancia
                        ? Icon(Icons.arrow_upward)
                        : Icon(Icons.arrow_downward);
                  }
                });
              }),
          DataColumn(
              label: widget.icon != null && widget.ordenarGasto != null
                  ? Row(
                      children: <Widget>[widget.icon, Text("Gasto")],
                    )
                  : Text("Gasto"),
              numeric: true,
              onSort: (columna, ascen) {
                setState(() {
                  if (widget.ordenarGasto == null) {
                    widget.ordenarGanancia = null;
                    widget.ordenarFecha = null;
                    widget.ordenarValor = null;
                    widget.ordenarGasto = false;
                    widget.icon = Icon(Icons.arrow_downward);
                  } else {
                    widget.ordenarGasto = !widget.ordenarGasto;
                    widget.icon = widget.ordenarGasto
                        ? Icon(Icons.arrow_upward)
                        : Icon(Icons.arrow_downward);
                  }
                });
              }),
        ],
        rows: widget.listaRows,
      );

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(child: table),
      );
    }

    List<String> buttons = ["Agregar Movimiento", "Actualizar"];

    cargarCrearMovimiento() {
      Navigator.push(context,
              MaterialPageRoute(builder: (context) => CrearMovimiento()))
          .then((value) {
        setState(() {});
      });
    }

    return Scaffold(
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
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Ventas()));
                },
              ),
              ListTile(
                title: Text("Movimientos"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text("Movimientos"),
          actions: <Widget>[
            PopupMenuButton(
                icon: Icon(Icons.more_vert),
                onSelected: (element) {
                  if (element == buttons[0]) {
                    cargarCrearMovimiento();
                  } else {
                    if (element == buttons[1]) {
                      setState(() {
                        widget.ordenarValor = null;
                        widget.ordenarGasto = null;
                        widget.ordenarFecha = null;
                        widget.ordenarGanancia = null;
                      });
                    }
                  }
                },
                itemBuilder: (BuildContext context) {
                  return buttons.map((String e) {
                    if (e == buttons[1]) {
                      return PopupMenuItem(
                        value: e,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.refresh,
                              color: Colors.blue,
                            ),
                            Text(e)
                          ],
                        ),
                      );
                    }
                    return PopupMenuItem(
                      value: e,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.done,
                            color: Colors.blue,
                          ),
                          Text(e),
                        ],
                      ),
                    );
                  }).toList();
                }),
          ],
        ),
        body: FutureBuilder(
          future: getVentas(widget.dbVentas, widget.dbMovimientos),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return snapshot.data;
            }
            return Center(child:CircularProgressIndicator());
          },
        ));
  }
}
