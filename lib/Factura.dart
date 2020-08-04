import 'dart:io';

import 'package:admistrar/DBHelper.dart';
import 'package:admistrar/Movimientos.dart';
import 'package:admistrar/Ventas.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as pv;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as widgets;

class Factura extends StatefulWidget {
  VentasDB venta;

  Factura({this.venta});

  FacturaState createState() => FacturaState();
}

class FacturaState extends State<Factura> {
  @override
  Widget build(BuildContext context) {
    List<widgets.TableRow> listaRowPDF = [];
    var pdf;
    generarPDF() {
      pdf = widgets.Document();
      pdf.addPage(widgets.Page(
          pageFormat: PdfPageFormat.a4,
          build: (widgets.Context context) {
            return widgets.ListView(children: <widgets.Widget>[
              widgets.Column(children: [
                widgets.Row(
                    mainAxisAlignment: widgets.MainAxisAlignment.start,
                    children: <widgets.Widget>[
                      widgets.Container(
                        margin: widgets.EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0),
                        child: widgets.Text(
                          "N.Factura: ${widget.venta.id} ",
                          style: widgets.TextStyle(fontSize: 15),
                        ),
                      ),
                    ]),
                widgets.Row(
                    mainAxisAlignment: widgets.MainAxisAlignment.start,
                    children: <widgets.Widget>[
                      widgets.Container(
                        margin: widgets.EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0),
                        child: widgets.Text(
                          "Nombre: ${widget.venta.cliente.nombre}",
                          style: widgets.TextStyle(fontSize: 15),
                        ),
                      ),
                    ]),
                widgets.Row(
                    mainAxisAlignment: widgets.MainAxisAlignment.start,
                    children: <widgets.Widget>[
                      widgets.Container(
                        margin: widgets.EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0),
                        child: widgets.Text(
                          "Ubicacion: ${widget.venta.cliente.barrio}",
                          style: widgets.TextStyle(fontSize: 15),
                        ),
                      ),
                    ]),
                widgets.Row(
                    mainAxisAlignment: widgets.MainAxisAlignment.start,
                    children: <widgets.Widget>[
                      widgets.Container(
                        margin: widgets.EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0),
                        child: widgets.Text(
                          "Direccion: ${widget.venta.cliente.direccion}",
                          style: widgets.TextStyle(fontSize: 15),
                        ),
                      ),
                    ]),
                widgets.Row(
                    mainAxisAlignment: widgets.MainAxisAlignment.start,
                    children: <widgets.Widget>[
                      widgets.Container(
                        margin: widgets.EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0),
                        child: widgets.Text(
                          "Fecha: ${widget.venta.fecha.day}/${widget.venta.fecha.month}/${widget.venta.fecha.year}",
                          style: widgets.TextStyle(fontSize: 15),
                        ),
                      ),
                    ]),
                widgets.Row(
                    mainAxisAlignment: widgets.MainAxisAlignment.start,
                    children: <widgets.Widget>[
                      widgets.Container(
                        margin: widgets.EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0),
                        child: widgets.Text(
                          "Productos:",
                          style: widgets.TextStyle(fontSize: 15),
                        ),
                      ),
                    ]),
              ]),
              widgets.Center(
                  child: widgets.Table(children: listaRowPDF.toList()))
            ]); // Center
          }));
    }

    guardarPDF() async {
      generarPDF();
      var directorio = await pv.getExternalStorageDirectory();

      String file = join(directorio.path, "factura.pdf");
      File f = File(file);
      if (f.existsSync()) {
        f.delete();
      }
      new File(file).writeAsBytesSync(pdf.save());
    }

    double height = 0;
    BigInt vuVT = BigInt.from(0);
    BigInt vuCT = BigInt.from(0);
    BigInt vTV = BigInt.from(0);
    BigInt vTC = BigInt.from(0);
    BigInt vGa = BigInt.from(0);
    BigInt sr = BigInt.from(0);
    List<DataRow> listRow =
        List.generate(widget.venta.productos.length, (index) {
      double cont = 0;
      //Valor Compra Total
      int tg = widget.venta.productos[index].cantidad *
          widget.venta.productos[index].precio_Compra;
      //Valor venta Total
      int salT = widget.venta.productos[index].saldoTotal();
      // Ganancia Unitaria
      int resta = widget.venta.productos[index].precio_Venta -
          widget.venta.productos[index].precio_Compra;
      // Ganancia de toda la venta
      int resta1 = salT - tg;

      vuVT = vuVT + BigInt.from(widget.venta.productos[index].precio_Venta);
      vuCT = vuCT + BigInt.from(widget.venta.productos[index].precio_Compra);
      sr = sr + BigInt.from(resta);
      vTV = vTV + BigInt.from(widget.venta.productos[index].saldoTotal());
      vTC = vTC + BigInt.from(tg);
      vGa = vGa + BigInt.from(resta1);
      String getnombre(String nombre, int tl) {
        cont++;
        if (nombre.length > tl) {
          return nombre.substring(0, tl) +
              "\n" +
              getnombre(nombre.substring(tl, nombre.length), tl);
        } else {
          if (cont > height) {
            height = cont;
          }
          return nombre;
        }
      }

      if (index == 0) {
        listaRowPDF.add(widgets.TableRow(children: <widgets.Text>[
          widgets.Text("Cant", style: widgets.TextStyle(fontSize: 15)),
          widgets.Text("Descripcion", style: widgets.TextStyle(fontSize: 15)),
          widgets.Text("Valor U", style: widgets.TextStyle(fontSize: 15)),
          widgets.Text("Valor Total", style: widgets.TextStyle(fontSize: 15)),
        ]));
      }

      listaRowPDF.add(widgets.TableRow(children: <widgets.Text>[
        widgets.Text("${widget.venta.productos[index].cantidad}"),
        widgets.Text("${getnombre(widget.venta.productos[index].nombre, 40)}"),
        widgets.Text("${widget.venta.productos[index].precio_Venta}"),
        widgets.Text("${widget.venta.productos[index].saldoTotal()}")
      ]));

      return DataRow(cells: <DataCell>[
        DataCell(Text("${widget.venta.productos[index].cantidad}")),
        DataCell(
            Text("${getnombre(widget.venta.productos[index].nombre, 15)}")),
        DataCell(Text("${widget.venta.productos[index].precio_Venta}")),
        DataCell(Text("${widget.venta.productos[index].precio_Compra}")),
        DataCell(Text("$resta")),
        DataCell(Text("$salT")),
        DataCell(Text("$tg")),
        DataCell(Text("$resta1")),
      ]);
    });

    listRow.add(DataRow(cells: <DataCell>[
      DataCell(Text(" ")),
      DataCell(Text("Total")),
      DataCell(Text("$vuVT")),
      DataCell(Text("$vuCT")),
      DataCell(Text("$sr")),
      DataCell(Text("$vTV")),
      DataCell(Text("$vTC")),
      DataCell(Text("$vGa")),
    ]));

    listaRowPDF.add(widgets.TableRow(children: <widgets.Widget>[
      widgets.Text("${widget.venta.domicilio != 0 ? 1 : 0}"),
      widgets.Text("Domicilio"),
      widgets.Text(" "),
      widgets.Text("${widget.venta.domicilio}")
    ]));
    listaRowPDF.add(widgets.TableRow(children: <widgets.Widget>[
      widgets.Text(" "),
      widgets.Text("Total", style: widgets.TextStyle(fontSize: 15)),
      widgets.Text(" "),
      widgets.Text("${widget.venta.valorTotal}",
          style: widgets.TextStyle(fontSize: 15))
    ]));
    DataTable cuotas;
    if (widget.venta.cuotas.length > 0) {
      BigInt totalp = BigInt.zero;
      List<DataRow> listaRowCuotas =
          List.generate(widget.venta.cuotas.length, (index) {
        totalp = totalp + BigInt.from(widget.venta.cuotas[index]);
        return DataRow(cells: <DataCell>[
          DataCell(Text("${index + 1}")),
          DataCell(Text("${widget.venta.cuotas[index]}"), onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Cuota(
                          ventaDB: widget.venta,
                          index: index,
                        ))).then((value) {
              setState(() {});
            });
          })
        ]);
      });
      listaRowCuotas.add(DataRow(cells: <DataCell>[
        DataCell(Text("Total Pagos Realizados")),
        DataCell(Text("$totalp"))
      ]));
      BigInt falta = BigInt.from(widget.venta.valorTotal) -
          totalp -
          BigInt.from(widget.venta.domicilio);
      if (falta <= BigInt.from(0)) {
        widget.venta.tipo = "Finalizado";
      } else {
        if (widget.venta.tipo != "Credito") {
          widget.venta.tipo = "Credito";
        }
      }
      listaRowCuotas.add(DataRow(cells: <DataCell>[
        DataCell(Text("Valor por pagar")),
        DataCell(Text("$falta"))
      ]));
      cuotas = DataTable(
        columns: <DataColumn>[
          DataColumn(
              label: Text(
            "Num Pago",
            style: TextStyle(fontSize: 15),
          )),
          DataColumn(label: Text("Valor", style: TextStyle(fontSize: 15)))
        ],
        rows: listaRowCuotas,
      );
    }
    Container listView;
    if (cuotas == null) {
      listView = Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: ListView(children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Text(
                "N.Factura: ${widget.venta.id} ",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Text(
                "Nombre: ${widget.venta.cliente.nombre}",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Text(
                "Barrio: ${widget.venta.cliente.barrio}",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Text(
                "Direccion: ${widget.venta.cliente.direccion}",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Text(
                "Fecha: ${widget.venta.fecha.day}/${widget.venta.fecha.month}/${this.widget.venta.fecha.year}",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Text(
                "Productos:",
                style: TextStyle(fontSize: 15),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                dataRowHeight: height * 20,
                columnSpacing: 10,
                rows: listRow,
                columns: <DataColumn>[
                  DataColumn(
                      label: Text(
                    "Cant",
                    style: TextStyle(fontSize: 15),
                  )),
                  DataColumn(
                      label: Text(
                    "Descripción",
                    style: TextStyle(fontSize: 15),
                  )),
                  DataColumn(
                      label: Text(
                    "V.U venta",
                    style: TextStyle(fontSize: 15),
                  )),
                  DataColumn(
                      label: Text(
                    "V.U Compra",
                    style: TextStyle(fontSize: 15),
                  )),
                  DataColumn(
                      label: Text(
                    "Ganancia U",
                    style: TextStyle(fontSize: 15),
                  )),
                  DataColumn(
                      label: Text(
                    "V.T venta",
                    style: TextStyle(fontSize: 15),
                  )),
                  DataColumn(
                      label: Text(
                    "V.T Compra",
                    style: TextStyle(fontSize: 15),
                  )),
                  DataColumn(
                      label: Text(
                    "Ganancia T",
                    style: TextStyle(fontSize: 15),
                  )),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Row(
                children: <Widget>[
                  Icon(Icons.home),
                  Text(
                    "Costo Domicilio: ${widget.venta.domicilio}",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Row(children: <Widget>[
                Icon(Icons.shopping_cart),
                Text(
                  "Valor Total: ${widget.venta.valorTotal}",
                  style: TextStyle(fontSize: 15),
                )
              ]),
            ),
          ]));
    } else {
      listView = Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: ListView(children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Text(
                "N.Factura: ${widget.venta.id} ",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Text(
                "Nombre: ${widget.venta.cliente.nombre}",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Text(
                "Barrio: ${widget.venta.cliente.barrio}",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Text(
                "Direccion: ${widget.venta.cliente.direccion}",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Text(
                "Fecha: ${widget.venta.fecha.day}/${widget.venta.fecha.month}/${this.widget.venta.fecha.year}",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Row(
                children: <Widget>[
                  widget.venta.tipo == "Credito"
                      ? Icon(
                          Icons.monetization_on,
                          color: Colors.red,
                        )
                      : Icon(
                          Icons.monetization_on,
                          color: Colors.green,
                        ),
                  Text(
                    "Estado: ${widget.venta.tipo}",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Text(
                "Productos:",
                style: TextStyle(fontSize: 15),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                dataRowHeight: height * 20,
                columnSpacing: 10,
                rows: listRow,
                columns: <DataColumn>[
                  DataColumn(
                      label: Text(
                    "Cant",
                    style: TextStyle(fontSize: 15),
                  )),
                  DataColumn(
                      label: Text(
                    "Descripción",
                    style: TextStyle(fontSize: 15),
                  )),
                  DataColumn(
                      label: Text(
                    "V.U venta",
                    style: TextStyle(fontSize: 15),
                  )),
                  DataColumn(
                      label: Text(
                    "V.U Compra",
                    style: TextStyle(fontSize: 15),
                  )),
                  DataColumn(
                      label: Text(
                    "Ganancia U",
                    style: TextStyle(fontSize: 15),
                  )),
                  DataColumn(
                      label: Text(
                    "V.T venta",
                    style: TextStyle(fontSize: 15),
                  )),
                  DataColumn(
                      label: Text(
                    "V.T Compra",
                    style: TextStyle(fontSize: 15),
                  )),
                  DataColumn(
                      label: Text(
                    "Ganancia T",
                    style: TextStyle(fontSize: 15),
                  )),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text("Añadir Abono "),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Cuota(
                                  ventaDB: widget.venta,
                                ))).then((value) {
                      setState(() {});
                    });
                  },
                )
              ],
            ),
            cuotas,
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Row(
                children: <Widget>[
                  Icon(Icons.home),
                  Text(
                    "Costo Domicilio: ${widget.venta.domicilio}",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Row(children: <Widget>[
                Icon(Icons.shopping_cart),
                Text(
                  "Valor Total: ${widget.venta.valorTotal}",
                  style: TextStyle(fontSize: 15),
                )
              ]),
            ),
          ]));
    }
    List<String> buttons = ["PDF-Voucher", "Modificar"];
    return Scaffold(
      appBar: AppBar(
        title: Text("Factura"),
        actions: <Widget>[
          PopupMenuButton(
              icon: Icon(Icons.more_vert),
              onSelected: (element) {
                if (element == buttons[0]) {
                  guardarPDF();
                  Navigator.pop(context);
                } else {
                  if (widget.venta.cuotas.isNotEmpty) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Ventas(
                                  id: widget.venta.id,
                                  title: "Editar venta",
                                  clienteBarrio: widget.venta.cliente.barrio,
                                  clienteDireccion:
                                      widget.venta.cliente.direccion,
                                  clienteNombre: widget.venta.cliente.nombre,
                                  cuotaInicial:
                                      widget.venta.cuotas.elementAt(0),
                                  domicilio: widget.venta.domicilio,
                                  ganancia: widget.venta.ganancia,
                                  productosVentas: widget.venta.productos,
                                  tipo: widget.venta.tipo,
                                  total: widget.venta.valorTotal,
                                  cuotas: widget.venta.cuotas,
                                ))).then((value) {
                      setState(() {});
                    });
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Ventas(
                                  id: widget.venta.id,
                                  title: "Editar venta",
                                  clienteBarrio: widget.venta.cliente.barrio,
                                  clienteDireccion:
                                      widget.venta.cliente.direccion,
                                  clienteNombre: widget.venta.cliente.nombre,
                                  cuotaInicial: 0,
                                  domicilio: widget.venta.domicilio,
                                  ganancia: widget.venta.ganancia,
                                  productosVentas: widget.venta.productos,
                                  tipo: widget.venta.tipo,
                                  total: widget.venta.valorTotal,
                                  cuotas: widget.venta.cuotas,
                                ))).then((value) {
                      setState(() {});
                    });
                  }
                }
              },
              itemBuilder: (BuildContext context) {
                return buttons.map((String e) {
                  if (e == buttons[0]) {
                    return PopupMenuItem(
                      value: e,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.picture_as_pdf,
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
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        Text(e)
                      ],
                    ),
                  );
                }).toList();
              }),
        ],
      ),
      body: listView,
    );
  }
}

class CrearMovimiento extends StatefulWidget {
  DBMovimientos dbMovimientos;
  String nombre;
  String descripcion;
  DateTime fecha;
  int valor;
  bool gasto;

  CrearMovimiento(
      {this.valor, this.nombre, this.gasto, this.descripcion, this.fecha}) {
    dbMovimientos = DBMovimientos();
    fecha = DateTime.now();
    gasto = true;
    valor = 0;
  }

  CrearMovimientoState createState() => CrearMovimientoState();
}

class CrearMovimientoState extends State<CrearMovimiento> {
  @override
  Widget build(BuildContext context) {
    guardarMovimiento() async {
      if (widget.gasto != null &&
          widget.descripcion != null &&
          widget.nombre != null &&
          widget.fecha != null &&
          widget.valor != null) {
        if (widget.gasto) {
          widget.dbMovimientos.save(MovimientosDB(
            valor: widget.valor,
            descripcion: widget.descripcion,
            fecha: widget.fecha.toString(),
            nombre: widget.nombre,
            ganancia: 0,
            gasto: widget.valor,
          ));
        } else {
          widget.dbMovimientos.save(MovimientosDB(
            valor: widget.valor,
            descripcion: widget.descripcion,
            fecha: widget.fecha.toString(),
            nombre: widget.nombre,
            ganancia: widget.valor,
            gasto: 0,
          ));
        }
      }
    }

    List<String> representa = ["un gasto", "una ganancia"];
    Container listView = Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              child: TextField(
                onChanged: (string) {
                  widget.nombre = string;
                },
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    labelText: "Nombre:",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black, width: 1)),
                    focusColor: Colors.black,
                    hoverColor: Colors.black,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black, width: 1)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blue, width: 1)),
                    fillColor: Colors.black),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              child: TextField(
                onChanged: (string) {
                  widget.descripcion = string;
                },
                textInputAction: TextInputAction.done,
                maxLines: null,
                decoration: InputDecoration(
                    labelText: "Descripcion:",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black, width: 1)),
                    focusColor: Colors.black,
                    hoverColor: Colors.black,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black, width: 1)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blue, width: 1)),
                    fillColor: Colors.black),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              child: TextField(
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
                onChanged: (string) {
                  widget.valor = int.parse(string);
                },
                controller: TextEditingController(text: "${widget.valor}"),
                textInputAction: TextInputAction.continueAction,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Valor:",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black, width: 1)),
                    focusColor: Colors.black,
                    hoverColor: Colors.black,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black, width: 1)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blue, width: 1)),
                    fillColor: Colors.black),
              ),
            ),
            Row(
              children: <Widget>[
                Text("Representa "),
                DropdownButton<String>(
                    value: widget.gasto ? representa[0] : representa[1],
                    onChanged: (value) {
                      if (value == representa[0]) {
                        widget.gasto = true;
                      } else {
                        widget.gasto = false;
                      }
                      setState(() {});
                    },
                    icon: widget.gasto
                        ? Icon(
                            Icons.call_received,
                            color: Colors.red,
                          )
                        : Icon(
                            Icons.call_made,
                            color: Colors.green,
                          ),
                    items: representa.map<DropdownMenuItem<String>>((e) {
                      return DropdownMenuItem(
                        child: Text(e),
                        value: e,
                      );
                    }).toList())
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                    child: Text(
                      "Fecha:",
                      style: TextStyle(fontSize: 20),
                    ))
              ],
            ),
            Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(DateTime.now().year),
                            lastDate: DateTime.now())
                        .then((value) {
                      if (value != null) {
                        widget.fecha = value;
                      }
                      setState(() {});
                    });
                  },
                  child: Text(
                    "${widget.fecha.day}-${widget.fecha.month}-${widget.fecha.year}",
                    style: TextStyle(fontSize: 30),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    setState(() {});
                    guardarMovimiento();
                    Navigator.pop(context);
                  },
                  child: Text("Guardar Movimiento"),
                )
              ],
            ),
          ],
        ));
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar Movimiento"),
      ),
      body: listView,
    );
  }
}

class Cuota extends StatelessWidget {
  VentasDB ventaDB;
  int valor = 0;
  int index;
  DBVentas dbVentas;

  Cuota({this.ventaDB, this.index}) {
    dbVentas = DBVentas();
    if (index != null) {
      valor = ventaDB.cuotas[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: index != null ? Text("Editar Cuota") : Text("Agregar Cuota"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("Referencia Venta: ${ventaDB.id}"),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              child: TextField(
                onChanged: (string) {
                  valor = int.parse(string);
                },
                textInputAction: TextInputAction.done,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
                controller: TextEditingController(text: "${valor}"),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Valor Abono: ",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            RaisedButton(
              onPressed: () {
                if (valor != null) {
                  if (index != null) {
                    ventaDB.cuotas[index] = valor;
                  } else {
                    ventaDB.cuotas.add(valor);
                  }

                  dbVentas.editarId(ventaDB, ventaDB.id);
                }
                Navigator.pop(context);
              },
              child:
                  index != null ? Text("Editar Cuota") : Text("Agregar Abono"),
            )
          ],
        ),
      ),
    );
  }
}
