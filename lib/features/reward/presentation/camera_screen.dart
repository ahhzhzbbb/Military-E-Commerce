import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({required this.cameras, super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();

    if (widget.cameras.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có camera khả dụng')),
        );
      }
      return;
    }

    controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.medium,
    );

    controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _capturePhoto() async {
    if (_isTakingPicture || !controller.value.isInitialized) return;

    try {
      setState(() => _isTakingPicture = true);

      final XFile picture = await controller.takePicture();
      final file = File(picture.path);

      if (mounted) {
        Navigator.pop(context, file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi chụp ảnh: $e')),
        );
      }
      setState(() => _isTakingPicture = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          CameraPreview(controller),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton(
                onPressed: _isTakingPicture ? null : _capturePhoto,
                backgroundColor: Colors.red,
                child: _isTakingPicture
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.camera, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}