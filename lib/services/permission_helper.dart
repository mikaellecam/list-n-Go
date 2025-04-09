import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  Future<bool> requestCameraPermission(BuildContext context) async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Accès à la caméra requis'),
              content: const Text(
                'Cette fonctionnalité nécessite l\'accès à la caméra. Veuillez activer la permission dans les paramètres de l\'application.',
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(context),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromRGBO(247, 147, 76, 1.0),
                  ),
                  child: const Text('Ouvrir les paramètres'),
                ),
              ],
            ),
      );
      return false;
    }

    return status.isGranted;
  }
}
