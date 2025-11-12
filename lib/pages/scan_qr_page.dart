import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gscankit/gscankit.dart';
import 'package:qr_doc/core/utils.dart';
import 'package:qr_doc/models/user_model.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  final controller = MobileScannerController(autoZoom: true, returnImage: true);
  UserModel? user = UserModel.getProfile();
  bool isDetected = false;

  @override
  Widget build(BuildContext context) {
    return GscanKit(
      controller: controller,
      appBar: (context, controller) => PreferredSize(
        preferredSize: Size(double.infinity, 80),
        child: Container(
          color: context.colorScheme.surface,
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "QR DOC",
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.colorScheme.primary,
                    ),
                  ),
                  Text(
                    "សួស្តី, ${user?.firstName}!",
                    style: context.textTheme.labelLarge,
                  ),
                ],
              ),
              Image.asset("assets/images/logo_cir.png", height: 60, width: 60),
            ],
          ),
        ),
      ),
      onDetect: (BarcodeCapture capture) {
        if (capture.barcodes.isNotEmpty && !isDetected) {
          isDetected = true;
          context.go(
            "/doc/detail",
            extra: {"code": capture.barcodes.first.displayValue ?? ""},
          );
        }
      },
      gscanOverlayConfig: GscanOverlayConfig(
        cornerLength: 40,
        borderRadius: 15,
        scannerLineAnimation: ScannerLineAnimation.none,
        scannerBorderPulseEffect: ScannerBorderPulseEffect.none,
        cornerRadius: 15,
      ),
    );
  }
}
