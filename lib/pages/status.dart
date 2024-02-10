import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_names_app/services/socket_service.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Column(
          children: [Text("Serverstatus: ${socketService.serverStatus} ")],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}
