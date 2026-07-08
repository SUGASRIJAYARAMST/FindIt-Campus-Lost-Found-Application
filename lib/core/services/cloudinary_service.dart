import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'dikwkqqet';
  static const String _uploadPreset = 'findit';

  bool get isConfigured =>
      _cloudName != 'YOUR_CLOUD_NAME' && _uploadPreset != 'YOUR_UPLOAD_PRESET';

  Future<String> uploadImage({
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    if (!isConfigured) {
      throw Exception('Cloudinary is not configured. Please set your cloud name and upload preset in cloudinary_service.dart');
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['secure_url'] as String;
    }

    debugPrint('Cloudinary upload error: $body');
    throw Exception('Upload failed (${response.statusCode})');
  }
}
