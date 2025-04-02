import 'package:flutter/material.dart';

import '../../modules/info_signing/view/info_signing_page.dart';

class ConfirmSigningDialog extends StatefulWidget {
  final String company;
  final String position;
  final String time;

  const ConfirmSigningDialog({
    Key? key,
    required this.company,
    required this.position,
    required this.time,
  }) : super(key: key);

  @override
  State<ConfirmSigningDialog> createState() => _ConfirmSigningDialogState();
}

class _ConfirmSigningDialogState extends State<ConfirmSigningDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirmar Fichaje"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Empresa: ${widget.company}"),
          Text("Puesto: ${widget.position}"),
          Text("Hora: ${widget.time}"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Cierra el diálogo
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InfoSigningPage(
                  company: widget.company,
                  position: widget.position,
                  time: widget.time,
                ),
              ),
            );
          },
          child: const Text("Confirmar"),
        ),

      ],
    );
  }
}
