import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { online, offline, connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;

  final IO.Socket _socket = IO.io('http://10.0.2.2:3000', {
      'transports': ['websocket'],
      'autoConnect': true
    });

  get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;

  SocketService() {
    _initConfig();
  }

  _initConfig() {

    // Dart client
    socket.on('connect', (_) {
      print('Conectado al Servidor');
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    socket.on('disconnect', (data) {
      print('disconnected');
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

     socket.on('nuevo-mensaje', (payload) {
      print("Nuevo mensaje: ${payload}");
      notifyListeners();
    });


    
  }
}
