import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import 'package:band_names_app/models/band.dart';
import 'package:band_names_app/services/socket_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bandas = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    // Cogemos la lista de bandas del backend y la mapeamos a una lista de dart.
    bandas = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "BandNames",
            style: TextStyle(color: Colors.black87),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
              margin: const EdgeInsets.only(right: 10),
              child: socketService.serverStatus == ServerStatus.online
                  ? const Icon(Icons.check_circle, color: Colors.blue)
                  : const Icon(Icons.offline_bolt, color: Colors.red))
        ],
      ),
      body: Column(
        children: [
          bandas.isNotEmpty ? _showGraph() : Container(),
          Expanded(
            child: ListView.builder(
                itemCount: bandas.length,
                itemBuilder: (_, int i) => _bandTile(bandas[i])),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add), elevation: 1, onPressed: () => addNewBand()),
    );
  }

  Dismissible _bandTile(Band banda) {
    final socketService = Provider.of<SocketService>(context, listen: false);

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
            onTap: () => socketService.socket.emit('vote-band', {'id': banda.id})),
        onDismissed: (_) => socketService.emit('delete-band', {'id': banda.id}));
  }

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text('Introduce nombre de la banda'),
                content: TextField(controller: textController),
                actions: <Widget>[
                  MaterialButton(
                      child: const Text('ADD'),
                      elevation: 1,
                      textColor: Colors.blue,
                      onPressed: () => addbandToList(textController.text))
                ],
              ));
    } else {
      showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
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
              ));
    }
  }

  addbandToList(String nombre) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    if (nombre.length > 1) {
      // Agregamos al backend
      socketService.emit('add-band', {"name": nombre});
    }

    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = {};
    bandas.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    List<Color> colorList = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.brown
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 20),
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        centerText: "Bandas",
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: true,
          showChartValuesOutside: false,
        ),
      ),
    );
  }
}
