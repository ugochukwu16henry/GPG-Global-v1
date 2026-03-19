import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../services/storage_service.dart';

// ---------------------------------------------------------------------------
// FileUploadButton
//
// A reusable button that lets users pick and upload files to a Supabase
// Storage bucket via the GPG backend signed-URL mechanism. No Supabase keys
// are needed on the client — the backend issues a short-lived upload URL.
//
// Usage example (avatar update):
//
//   FileUploadButton(
//     storageService: storageService,
//     bucket: StorageBucket.avatars,
//     label: 'Update Profile Photo',
//     icon: Icons.camera_alt,
//     allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
//     onUploaded: (result) => ref.read(...).setAvatar(result.publicOrSignedUrl),
//   )
// ---------------------------------------------------------------------------

enum _PickMode { image, document }

class FileUploadButton extends StatefulWidget {
  const FileUploadButton({
    super.key,
    required this.storageService,
    required this.bucket,
    this.label = 'Upload File',
    this.icon = Icons.upload_file,
    this.allowedExtensions,
    this.onUploaded,
    this.onError,
    this.buttonStyle,
    this.compact = false,
  });

  final StorageService storageService;
  final StorageBucket bucket;
  final String label;
  final IconData icon;

  /// Restrict file types, e.g. ['jpg', 'png', 'pdf']. Null = all allowed.
  final List<String>? allowedExtensions;

  final void Function(StorageUploadResult result)? onUploaded;
  final void Function(String error)? onError;
  final ButtonStyle? buttonStyle;

  /// When true, renders as a compact icon-only button.
  final bool compact;

  @override
  State<FileUploadButton> createState() => _FileUploadButtonState();
}

class _FileUploadButtonState extends State<FileUploadButton> {
  bool _uploading = false;

  _PickMode get _pickMode {
    if (widget.bucket == StorageBucket.avatars) return _PickMode.image;
    return _PickMode.document;
  }

  Future<void> _pick() async {
    if (_uploading) return;

    try {
      String? fileName;
      Uint8List? bytes;
      String mimeType = 'application/octet-stream';

      if (_pickMode == _PickMode.image) {
        // Show choice: camera or gallery
        final source = await _showImageSourceDialog();
        if (source == null) return;

        final picker = ImagePicker();
        final picked = await picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 88,
        );
        if (picked == null) return;

        bytes = await picked.readAsBytes();
        fileName = picked.name;
        mimeType = lookupMimeType(fileName) ?? 'image/jpeg';
      } else {
        // Document / video via file_picker
        final defaultMediaExtensions = <String>[
          'jpg',
          'jpeg',
          'png',
          'webp',
          'mp4',
          'mov',
          'm4v',
          'webm',
        ];
        final extensions = widget.allowedExtensions ??
            (widget.bucket == StorageBucket.media
                ? defaultMediaExtensions
                : null);
        final result = await FilePicker.platform.pickFiles(
          type: extensions != null ? FileType.custom : FileType.any,
          allowedExtensions: extensions,
          withData: true,
        );
        if (result == null || result.files.isEmpty) return;

        final file = result.files.first;
        bytes = file.bytes;
        fileName = file.name;
        mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

        if (bytes == null) return; // web may have null path but data present
      }

      setState(() {
        _uploading = true;
      });

      final uploadResult = await widget.storageService.uploadFile(
        bucket: widget.bucket,
        fileName: fileName,
        bytes: bytes,
        mimeType: mimeType,
      );

      widget.onUploaded?.call(uploadResult);
    } catch (e) {
      widget.onError?.call(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_uploading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (widget.compact) {
      return IconButton(
        icon: Icon(widget.icon),
        tooltip: widget.label,
        onPressed: _pick,
      );
    }

    return ElevatedButton.icon(
      style: widget.buttonStyle,
      onPressed: _pick,
      icon: Icon(widget.icon, size: 18),
      label: Text(widget.label),
    );
  }
}

// ---------------------------------------------------------------------------
// AvatarUploadCircle
//
// Specialised avatar upload widget: shows current avatar (or initials
// fallback), with a camera-overlay tap target.
// ---------------------------------------------------------------------------

class AvatarUploadCircle extends StatelessWidget {
  const AvatarUploadCircle({
    super.key,
    required this.storageService,
    required this.displayName,
    this.currentAvatarUrl,
    this.radius = 44,
    this.onUploaded,
  });

  final StorageService storageService;
  final String displayName;
  final String? currentAvatarUrl;
  final double radius;
  final void Function(StorageUploadResult)? onUploaded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = displayName.isNotEmpty
        ? displayName
            .trim()
            .split(' ')
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase()
        : '?';

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage:
              currentAvatarUrl != null ? NetworkImage(currentAvatarUrl!) : null,
          child: currentAvatarUrl == null
              ? Text(initials,
                  style: TextStyle(
                      fontSize: radius * 0.45,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer))
              : null,
        ),
        FileUploadButton(
          storageService: storageService,
          bucket: StorageBucket.avatars,
          label: 'Update Photo',
          icon: Icons.camera_alt,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
          compact: true,
          onUploaded: onUploaded,
          buttonStyle: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(6),
            minimumSize: const Size(32, 32),
          ),
        ),
      ],
    );
  }
}
