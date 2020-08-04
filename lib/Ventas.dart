import 'package:admistrar/DBHelper.dart';
import 'package:admistrar/Mostrador.dart';
import 'package:admistrar/Movimientos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'CrearProducto.dart';
import 'Utility.dart';

class VentasDB {
  int id;
  Cliente cliente;
  List<ProductoVenta> productos;
  List<int> cuotas;
  int valorTotal;
  DateTime fecha;
  int ganancia;
  int domicilio;
  String tipo;

  VentasDB(
      {this.id,
      this.productos,
      this.cliente,
      this.fecha,
      this.valorTotal,
      this.ganancia,
      this.domicilio,
      this.cuotas,
      this.tipo});

  String productosToString() {
    String val = "";
    if (productos != null) {
      productos.forEach((element) {
        if (element != productos.last) {
          val = val + element.toString() + "/";
        } else {
          val = val + element.toString();
        }
      });
    }
    return val;
  }

  List<ProductoVenta> productosFromString(String sProductos) {
    List<ProductoVenta> productos = [];
    List<String> vec = sProductos.split("/");
    vec.forEach((element) {
      if (element != null) {
        if (element != "") {
          productos.add(ProductoVenta.fromString(element));
        }
      }
    });
    return productos.toList();
  }

  String cuotasToString() {
    String cuotasString = "";
    if (cuotas != null) {
      cuotas.forEach((element) {
        if (cuotas.last != element) {
          cuotasString = cuotasString + "${element.toString()}" + "/";
        } else {
          cuotasString = cuotasString + "${element.toString()}";
        }
      });
    }
    return cuotasString;
  }

  List<int> cuotasFromString(String scuotas) {
    List<int> cuotas = [];
    List<String> vect = scuotas.split("/");
    vect.forEach((element) {
      if (element != "") {
        cuotas.add(int.parse(element));
      }
    });
    return cuotas.toList();
  }

  Map<String, dynamic> toMap() {
    String f = fecha.toString();
    String ps = productosToString();
    String c = cliente.toString();
    String cu = cuotasToString();
    var map = <String, dynamic>{
      'id': id,
      'fecha': f,
      'cliente': c,
      'productos': ps,
      'valorTotal': valorTotal,
      'ganancia': ganancia,
      'domicilio': domicilio,
      'cuotas': cu,
      'tipo': tipo
    };
    return map;
  }

  VentasDB.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    String f = map['fecha'];
    fecha = DateTime.parse(f);
    String c = map['cliente'];
    cliente = Cliente.fromString(c);
    String ps = map['productos'];
    productos = productosFromString(ps);
    valorTotal = map['valorTotal'];
    ganancia = map['ganancia'];
    domicilio = map['domicilio'];
    String cu = map['cuotas'];
    cuotas = cuotasFromString(cu);
    tipo = map['tipo'];
  }
}

class Cliente {
  String nombre;
  String barrio;
  String direccion;

  Cliente({this.nombre = "", this.barrio = "", this.direccion = ""});

  @override
  String toString() {
    return "${this.nombre}/${this.barrio}/${this.direccion}";
  }

  Cliente.fromString(String cliente) {
    if (cliente.contains("/")) {
      List<String> c = cliente.split("/");
      nombre = c[0];
      barrio = c[1];
      direccion = c[2];
    }
  }
}

class ProductoVenta {
  int precio_Venta;
  int precio_Compra;
  int cantidad;
  String nombre;
  String imagenFile;

  ProductoVenta(
      {this.precio_Venta = 0,
      this.cantidad = 0,
      this.imagenFile,
      this.nombre,
      this.precio_Compra = 0});

  saldoTotal() {
    return precio_Venta * cantidad;
  }

  calcularGanancia() {
    return saldoTotal() - (cantidad * precio_Compra);
  }

  @override
  String toString() {
    return "${this.nombre}-${this.cantidad}-${this.precio_Venta}-${this.precio_Compra}";
  }

  ProductoVenta.fromString(String productoVenta) {
    if (productoVenta.contains("-")) {
      List<String> c = productoVenta.split("-");
      nombre = c[0];
      cantidad = int.parse(c[1]);
      precio_Venta = int.parse(c[2]);
      precio_Compra = int.parse(c[3]);
      imagenFile = null;
    }
  }
}

class Ventas extends StatefulWidget {
  DBProducto dbProducto;
  DBVentas dbVentas;
  List<ProductoVenta> productosVentas = [];
  List<int> cuotas = [];
  int total;
  int ganancia;
  String clienteNombre;
  String clienteBarrio;
  String clienteDireccion;
  int domicilio;
  DateTime fecha = DateTime.now();
  String title;
  String tipo;
  int cuotaInicial;
  int id;

  Ventas(
      {this.title = "Añadir Venta",
      this.cuotaInicial = 0,
      this.tipo = "Pago Inmediato",
      this.domicilio = 0,
      this.clienteDireccion,
      this.clienteBarrio,
      this.clienteNombre,
      this.ganancia = 0,
      this.productosVentas,
      this.cuotas,
      this.total = 0,
      this.id}) {
    dbProducto = DBProducto();
    dbVentas = DBVentas();
    if (this.productosVentas == null) {
      this.productosVentas = [];
    }
    if (this.cuotas == null) {
      this.cuotas = [];
    }
  }

  @override
  VentasState createState() => VentasState();
}

class VentasState extends State<Ventas> {
  @override
  Widget build(BuildContext context) {
    void calcularValorTotal() {
      int val = 0;
      widget.productosVentas.forEach((element) {
        val = val + element.saldoTotal();
      });
      val = val + widget.domicilio;
      widget.total = val;
    }

    void calcularGananciaTotal() {
      int val = 0;
      widget.productosVentas.forEach((element) {
        val = val + element.calcularGanancia();
      });
      widget.ganancia = val;
    }

    void guardarVenta() async {
      if (widget.clienteNombre != null &&
          widget.clienteDireccion != null &&
          widget.clienteBarrio != null &&
          widget.productosVentas != null &&
          widget.total != null &&
          widget.fecha != null &&
          widget.ganancia != null &&
          widget.domicilio != null &&
          widget.cuotas != null &&
          widget.tipo != null) {
        calcularGananciaTotal();
        calcularValorTotal();
        if (widget.tipo == "Credito") {
          widget.cuotas.add(widget.cuotaInicial);
        }
        VentasDB ventas = VentasDB(
            cliente: Cliente(
                nombre: widget.clienteNombre,
                barrio: widget.clienteBarrio,
                direccion: widget.clienteDireccion),
            productos: widget.productosVentas,
            valorTotal: widget.total,
            fecha: widget.fecha,
            ganancia: widget.ganancia,
            domicilio: widget.domicilio,
            cuotas: widget.cuotas,
            tipo: widget.tipo);
        widget.dbVentas.save(ventas);
      }
    }

    void editarVenta() async {
      if (widget.clienteNombre != null &&
          widget.clienteDireccion != null &&
          widget.clienteBarrio != null &&
          widget.productosVentas != null &&
          widget.total != null &&
          widget.fecha != null &&
          widget.ganancia != null &&
          widget.domicilio != null &&
          widget.cuotas != null &&
          widget.tipo != null) {
        calcularGananciaTotal();
        calcularValorTotal();
        if (widget.tipo == "Credito") {
          if (widget.cuotas.isNotEmpty) {
            widget.cuotas[0] = widget.cuotaInicial;
          } else {
            widget.cuotas.add(widget.cuotaInicial);
          }
        }
        widget.dbVentas.editarId(
            VentasDB(
                tipo: widget.tipo,
                cuotas: widget.cuotas,
                id: widget.id,
                ganancia: widget.ganancia,
                fecha: widget.fecha,
                domicilio: widget.domicilio,
                valorTotal: widget.total,
                productos: widget.productosVentas,
                cliente: Cliente(
                    nombre: widget.clienteNombre,
                    direccion: widget.clienteDireccion,
                    barrio: widget.clienteBarrio)),
            widget.id);
      }
    }

    //Seleccionar productos
    cargarListaDeSeleccion(BuildContext context) async {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Mostrador(
                    modo: "Seleccion",
                  )));
      if (result != null) {
        print(result.imagenFile);
        widget.productosVentas.add(ProductoVenta(
            cantidad: 1,
            precio_Venta: result.precio_Venta,
            precio_Compra: result.precio_Compra,
            imagenFile: result.imagenFile,
            nombre: result.nombre));
        calcularValorTotal();
        calcularGananciaTotal();
        setState(() {});
      }
    }

    //Container modo de venta
    List<String> tipo = ["Pago Inmediato", "Credito"];
    Row modo = Row(
      children: <Widget>[
        Text("Tipo: "),
        DropdownButton<String>(
            value: widget.tipo,
            onChanged: (value) {
              widget.tipo = value;
              setState(() {});
            },
            items: tipo.map<DropdownMenuItem<String>>((e) {
              return DropdownMenuItem(
                child: Text(e),
                value: e,
              );
            }).toList())
      ],
    );
    //Activar cuota
    Column widgetModo = Column(
      children: widget.tipo == tipo[0]
          ? <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.shopping_cart),
                  Text("Valor Total:"),
                  widget.total != null ? Text("${widget.total}") : Text("0"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.show_chart,
                    color: Colors.green,
                  ),
                  Text("Ganancia Total:"),
                  widget.ganancia != null
                      ? Text("${widget.ganancia}")
                      : Text("0")
                ],
              )
            ]
          : <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                child: TextField(
                  onEditingComplete: () {
                    calcularValorTotal();
                    calcularGananciaTotal();
                    FocusScope.of(context).unfocus();
                    setState(() {});
                  },
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly
                  ],
                  textInputAction: TextInputAction.done,
                  controller:
                      TextEditingController(text: "${widget.cuotaInicial}"),
                  onChanged: (string) {
                    widget.cuotaInicial = int.parse(string);
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: "Abono:",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: Colors.black, width: 1)),
                      focusColor: Colors.black,
                      hoverColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: Colors.black, width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.blue, width: 1)),
                      fillColor: Colors.black),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.shopping_cart),
                  Text("Valor Total:"),
                  widget.total != null ? Text("${widget.total}") : Text("0"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.show_chart,
                    color: Colors.green,
                  ),
                  Text("Ganancia Total:"),
                  widget.ganancia != null
                      ? Text("${widget.ganancia}")
                      : Text("0")
                ],
              )
            ],
    );
    //Lista de productos seleccionados

    ListView listView = ListView(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: Card(
            child: Column(
              children: <Widget>[
                Text(
                  "Informacion del Cliente",
                  style: TextStyle(fontSize: 20),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                  child: TextField(
                    onChanged: (string) {
                      widget.clienteNombre = string;
                    },
                    textInputAction: TextInputAction.done,
                    controller: TextEditingController(
                        text: widget.clienteNombre != null
                            ? "${widget.clienteNombre}"
                            : ""),
                    decoration: InputDecoration(
                      labelText: "Nombre:",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: Colors.black, width: 1)),
                      focusColor: Colors.black,
                      hoverColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: Colors.black, width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.blue, width: 1)),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                  child: TextField(
                    onChanged: (string) {
                      widget.clienteBarrio = string;
                    },
                    controller: TextEditingController(
                        text: widget.clienteBarrio != null
                            ? "${widget.clienteBarrio}"
                            : ""),
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: "Ubicacion(Ciudad/Municipio):",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: Colors.black, width: 1)),
                      focusColor: Colors.black,
                      hoverColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: Colors.black, width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.blue, width: 1)),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                  child: TextField(
                    onChanged: (string) {
                      widget.clienteDireccion = string;
                    },
                    textInputAction: TextInputAction.done,
                    controller: TextEditingController(
                        text: widget.clienteDireccion != null
                            ? "${widget.clienteDireccion}"
                            : ""),
                    decoration: InputDecoration(
                      labelText: "Direccion:",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: Colors.black, width: 1)),
                      focusColor: Colors.black,
                      hoverColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: Colors.black, width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.blue, width: 1)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: Card(
            child: Column(
              children: <Widget>[
                Text(
                  "Informacion de la Venta",
                  style: TextStyle(fontSize: 20),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[Text("Fecha:")],
                ),
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        showDatePicker(
                                context: context,
                                initialDate: widget.fecha,
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        cargarListaDeSeleccion(context);
                      },
                    )
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Productos:",
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.left,
                      ),
                    ]),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.black,
                        width: 1,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListView(
                    children: widget.productosVentas.isNotEmpty
                        ? ListTile.divideTiles(
                            color: Colors.black,
                            tiles: List.generate(widget.productosVentas.length,
                                (index) {
                              return ListTile(
                                onTap: () {},
                                leading: Container(
                                    width: 70,
                                    child: widget.productosVentas[index]
                                                .imagenFile !=
                                            null
                                        ? Utility.imageFromBase64String(widget
                                            .productosVentas[index].imagenFile)
                                        : Icon(Icons.image)),
                                title:
                                    Text(widget.productosVentas[index].nombre),
                                subtitle: Column(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 0),
                                      child: TextField(
                                        onEditingComplete: () {
                                          calcularValorTotal();
                                          calcularGananciaTotal();
                                          FocusScope.of(context).unfocus();
                                          setState(() {});
                                        },
                                        inputFormatters: <TextInputFormatter>[
                                          WhitelistingTextInputFormatter
                                              .digitsOnly
                                        ],
                                        textInputAction:
                                            TextInputAction.continueAction,
                                        controller: TextEditingController(
                                            text:
                                                "${widget.productosVentas[index].cantidad}"),
                                        onChanged: (string) {
                                          widget.productosVentas[index]
                                              .cantidad = int.parse(string);
                                        },
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: "Cantidad:",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: TextField(
                                        controller: TextEditingController(
                                            text:
                                                "${widget.productosVentas[index].precio_Venta}"),
                                        onChanged: (string) {
                                          widget.productosVentas[index]
                                              .precio_Venta = int.parse(string);
                                        },
                                        onEditingComplete: () {
                                          calcularValorTotal();
                                          calcularGananciaTotal();
                                          FocusScope.of(context).unfocus();
                                          setState(() {});
                                        },
                                        inputFormatters: <TextInputFormatter>[
                                          WhitelistingTextInputFormatter
                                              .digitsOnly
                                        ],
                                        textInputAction: TextInputAction.done,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: "Valor Unitario:",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })).toList()
                        : <Widget>[Text("No hay Productos seleccionados")],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                  child: TextField(
                    onChanged: (string) {
                      widget.domicilio = int.parse(string);
                    },
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    onEditingComplete: () {
                      calcularValorTotal();
                      calcularGananciaTotal();
                      FocusScope.of(context).unfocus();
                      setState(() {});
                    },
                    controller: TextEditingController(
                        text: widget.domicilio != null
                            ? "${widget.domicilio}"
                            : "0"),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: "Domicilio:",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                BorderSide(color: Colors.black, width: 1)),
                        focusColor: Colors.black,
                        hoverColor: Colors.black,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                BorderSide(color: Colors.black, width: 1)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                BorderSide(color: Colors.blue, width: 1)),
                        fillColor: Colors.black),
                  ),
                ),
                modo,
                widgetModo,
              ],
            ),
          ),
        ),
        RaisedButton(
          onPressed: () {
            setState(() {});
          },
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.refresh),
                Text("Actualizar Informacion")
              ]),
        ),
        RaisedButton(
          onPressed: () {
            setState(() {});
            if (widget.title == "Añadir Venta") {
              guardarVenta();
            } else {
              editarVenta();
            }
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Ventas()));
          },
          child: Text(widget.title == "Añadir Venta"
              ? "Guardar Venta"
              : "Actualizar Venta"),
        )
      ],
    );
    if (widget.title == "Añadir Venta") {
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
          title: Text("${widget.title}"),
        ),
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    colors: [Colors.blue, Colors.white])),
            child: Container(child: listView)),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("${widget.title}"),
        ),
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    colors: [Colors.blue, Colors.white])),
            child: Container(child: listView)),
      );
    }
  }
}
