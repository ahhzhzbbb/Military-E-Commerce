import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:military_e_commerce/features/reward/presentation/camera_screen.dart';
import 'package:military_e_commerce/features/reward/data/reward_controller.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  List<PlatformFile>? _selectedFiles = [];
  bool _isLoading = false;
  late final RewardController _rewardController;

  @override
  void initState() {
    super.initState();
    _rewardController = RewardController();
  }

  Future<void> _pickFiles() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      setState(() => _isLoading = true);
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.files;
        });
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles?.removeAt(index);
    });
  }

  Future<void> _openCamera() async {
    try {
      final messenger = ScaffoldMessenger.of(context);
      final cameras = await availableCameras();
      if (!mounted) return;
      
      if (cameras.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Không có camera khả dụng')),
        );
        return;
      }

      final File? capturedPhoto = await Navigator.push<File>(
        context,
        MaterialPageRoute(
          builder: (_) => CameraScreen(cameras: cameras),
        ),
      );

      if (capturedPhoto != null && mounted) {
        final platformFile = PlatformFile(
          name: 'captured_${DateTime.now().millisecondsSinceEpoch}.jpg',
          path: capturedPhoto.path,
          size: await capturedPhoto.length(),
        );

        setState(() {
          _selectedFiles?.add(platformFile);
        });

        messenger.showSnackBar(
          const SnackBar(content: Text('Ảnh đã được thêm vào danh sách')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét thưởng'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upload Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickFiles,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(
                _isLoading ? 'Đang tải...' : 'Chọn tệp để tải lên',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color.fromARGB(255, 159, 4, 4),
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _openCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Mở camera'),
            ),
            const SizedBox(height: 24),
            // File List Section
            if (_selectedFiles != null && _selectedFiles!.isNotEmpty) ...
            [
              Text(
                'Tệp đã chọn (${_selectedFiles!.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedFiles!.length,
                itemBuilder: (context, index) {
                  final file = _selectedFiles![index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: _getFileIcon(file.extension ?? ''),
                      title: Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        _formatFileSize(file.size),
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _removeFile(index),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Upload Confirmation Button
              ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await _rewardController.uploadFile(_selectedFiles!.first);
                    if (!mounted) return;
                    if (_rewardController.error != null) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Lỗi: ${_rewardController.error}')),
                      );
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Tải lên thành công!')),
                      );
                      setState(() => _selectedFiles = []);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Xác nhận tải lên'),
              ),
            ] else if (_selectedFiles != null && _selectedFiles!.isEmpty) ...
            [
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa chọn tệp',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getFileIcon(String extension) {
    final ext = extension.toLowerCase();
    final iconColor = Colors.blue;
    
    if (['jpg', 'jpeg', 'png'].contains(ext)) {
      return Icon(Icons.image, color: iconColor);
    } 
    return Icon(Icons.insert_drive_file, color: iconColor);
  }
}