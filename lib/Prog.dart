import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'Utility.dart';

class Prog extends StatefulWidget {
  String text;
  String imagenFile;
  List<String> lista = [];
  Image file;

  @override
  ProgState createState() => ProgState();
}

class ProgState extends State<Prog> {
  GlobalKey _globalKey = new GlobalKey();

  pickImageFromGallery() async {
    var imgFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 100.0, maxWidth: 100.0);

    Image cambiada = Image.file(
      File(imgFile.path),
      width: 100,
      height: 100,
    );
    print(cambiada.height);
    print(cambiada.width);
    print(cambiada.hashCode);
    print(ResizeImage(cambiada.image, width: 400, height: 400));
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String temp = join(documentsDirectory.path, "temp");

    String imgString = Utility.base64String(imgFile.readAsBytesSync());
    setState(() {
      widget.file = cambiada;
      widget.imagenFile = imgString;
    });
  }

  Future<Uint8List> _capturePng() async {
    try {
      print('inside');
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      print(pngBytes);
      print(bs64);
      setState(() {});
      return pngBytes;
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    void guardarPantallazo() async {
      var directorio = await getExternalStorageDirectory();
      var c = await _capturePng();
      String file = join(directorio.path, "Pictures", "imagen.png");
      new File(file).writeAsBytesSync(c);
    }

    var screenSize = MediaQuery.of(context).size;
    // var width = screenSize.width;
    var height = screenSize.height;

    Container body = Container(
      child: ListView(
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              setState(() {});
            },
          ),
          widget.file != null
              ? widget.file
              : Container(
                  height: 0,
                  width: 0,
                ),
          widget.imagenFile != null
              ? Utility.imageFromBase64String(widget.imagenFile)
              : Container(
                  height: 0,
                  width: 0,
                ),
        ],
      ),
    );

    Scaffold scaffold = Scaffold(
        appBar: AppBar(
          title: Text("Prog"),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                pickImageFromGallery();
              },
              icon: Icon(Icons.details),
            )
          ],
        ),
        body: body);
    RepaintBoundary repaint = RepaintBoundary(key: _globalKey, child: scaffold);
    return MaterialApp(
      home: repaint,
    );
  }
}
