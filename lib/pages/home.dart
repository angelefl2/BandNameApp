import 'dart:io';

import 'package:band_names_app/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bandas = [
    Band(id: '1', name: "Metallica", votes: 5),
    Band(id: '2', name: "PowerWolf", votes: 6),
    Band(id: '3', name: "Bon Jovi", votes: 3),
    Band(id: '4', name: "Dire Strair", votes: 7),
    Band(id: '5', name: "Koorpiklani", votes: 8),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Center(
              child: Text("BandNames", style: TextStyle(color: Colors.black87))),
          backgroundColor: Colors.white,
          elevation: 1),
      body: ListView.builder(
          itemCount: bandas.length, itemBuilder: (_, int i) => _bandTile(bandas[i])),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add), elevation: 1, onPressed: () => addNewBand()),
    );
  }

  Dismissible _bandTile(Band banda) {
    return Dismissible(
      key: Key(banda.id),
      background: Container(
        padding: const EdgeInsets.only(left: 10.0),
          color: Colors.red,
          child: const Align(
            child: Text(
              "Eliminar",
              style: TextStyle(color: Colors.white),
            ),
            alignment: Alignment.centerLeft,
          )),
      direction: DismissDirection.startToEnd,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(banda.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(banda.name),
        trailing: Text(
          '${banda.votes}',
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () {
          print(banda.name);
        },
      ),
      onDismissed: (direction) {
        print(direction);
      },
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Introduce nombre de la banda'),
            content: TextField(controller: textController),
            actions: <Widget>[
              MaterialButton(
                  child: const Text('ADD'),
                  elevation: 1,
                  textColor: Colors.blue,
                  onPressed: () => addbandToList(textController.text))
            ],
          );
        },
      );
    } else {
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: const Text("Nombre de la banda"),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text("DISMISS"),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text("ADD"),
                  onPressed: () => addbandToList(textController.text),
                ),
              ],
            );
          });
    }
  }

  addbandToList(String nombre) {
    if (nombre.length > 1) {
      // Agregamos al backend
      bandas.add(Band(id: '1', name: nombre, votes: 3));
      setState(() {});
    }

    Navigator.pop(context);
  }
}
