class ProductoDB {
  int id;
  String nombre;
  int precio_Compra;
  int precio_Venta;
  String imagenFile;

  ProductoDB({this.id, this.nombre, this.precio_Compra, this.precio_Venta,
      this.imagenFile});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'nombre': nombre,
      'precio_Compra': precio_Compra,
      'precio_Venta': precio_Venta,
      'imagenFile': imagenFile,
    };
    return map;
  }

  ProductoDB.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    nombre = map['nombre'];
    precio_Compra = map['precio_Compra'];
    precio_Venta = map['precio_Venta'];
    imagenFile = map['imagenFile'];
  }
}
