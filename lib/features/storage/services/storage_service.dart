import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// StorageBucket mirrors the GraphQL enum on the backend
// ---------------------------------------------------------------------------
enum StorageBucket { avatars, media, documents }

extension StorageBucketName on StorageBucket {
  String get value => name; // 'avatars' | 'media' | 'documents'
}

// ---------------------------------------------------------------------------
// Result types
// ---------------------------------------------------------------------------
class UploadUrlResult {
  const UploadUrlResult({
    required this.signedUrl,
    required this.token,
    required this.path,
  });

  final String signedUrl;
  final String token;
  final String path;
}

class StorageUploadResult {
  const StorageUploadResult(
      {required this.path, required this.publicOrSignedUrl});
  final String path;
  final String publicOrSignedUrl;
}

// ---------------------------------------------------------------------------
// StorageService
// Calls the GPG backend to get signed upload/download URLs, then interacts
// directly with Supabase Storage using those URLs — no Supabase keys on client.
// ---------------------------------------------------------------------------
class StorageService {
  StorageService(
      {required this.backendUrl,
      required this.authToken,
      required this.userId});

  final String backendUrl;
  final String authToken; // JWT / session token for x-auth-token header
  final String userId;

  // ---- GraphQL helper ----

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-auth-token': authToken,
        'x-user-id': userId,
      };

  Future<Map<String, dynamic>> _gql(String body) async {
    final res = await http.post(
      Uri.parse('$backendUrl/graphql'),
      headers: _headers,
      body: body,
    );
    if (res.statusCode != 200) {
      throw Exception(
          'GraphQL request failed (${res.statusCode}): ${res.body}');
    }
    final json = _jsonDecode(res.body);
    final errors = json['errors'];
    if (errors != null) {
      throw Exception('GraphQL error: ${(errors as List).first['message']}');
    }
    return json['data'] as Map<String, dynamic>;
  }

  // ---- Upload ----

  /// Request a signed upload URL from the backend, then PUT bytes directly to
  /// Supabase Storage. Returns the stored [path] and a download URL.
  Future<StorageUploadResult> uploadFile({
    required StorageBucket bucket,
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    // 1. Get signed upload URL from backend
    final data = await _gql('''
{
  "query": "mutation RequestUpload(\$userId: ID!, \$bucket: StorageBucket!, \$fileName: String!) { requestUploadUrl(userId: \$userId, bucket: \$bucket, fileName: \$fileName) { signedUrl token path } }",
  "variables": { "userId": "$userId", "bucket": "${bucket.value}", "fileName": "$fileName" }
}''');

    final uploadData = data['requestUploadUrl'] as Map<String, dynamic>;
    final signedUrl = uploadData['signedUrl'] as String;
    final path = uploadData['path'] as String;

    // 2. PUT the file bytes directly to Supabase (no server proxy)
    final putRes = await http.put(
      Uri.parse(signedUrl),
      headers: {
        'Content-Type': mimeType,
        'x-upsert': 'true', // overwrite on re-upload (e.g., avatar update)
      },
      body: bytes,
    );

    if (putRes.statusCode != 200 && putRes.statusCode != 201) {
      throw Exception(
          'Supabase upload failed (${putRes.statusCode}): ${putRes.body}');
    }

    // 3. Get a usable download URL for the just-uploaded file
    final downloadUrl = await getDownloadUrl(bucket: bucket, path: path);

    return StorageUploadResult(path: path, publicOrSignedUrl: downloadUrl);
  }

  // ---- Download URL ----

  Future<String> getDownloadUrl({
    required StorageBucket bucket,
    required String path,
  }) async {
    final safePath = path.replaceAll('"', '');
    final data = await _gql('''
{
  "query": "mutation DownloadUrl(\$userId: ID!, \$bucket: StorageBucket!, \$path: String!) { requestDownloadUrl(userId: \$userId, bucket: \$bucket, path: \$path) }",
  "variables": { "userId": "$userId", "bucket": "${bucket.value}", "path": "$safePath" }
}''');
    return data['requestDownloadUrl'] as String;
  }

  // ---- Delete ----

  Future<void> deleteFile({
    required StorageBucket bucket,
    required String path,
  }) async {
    final safePath = path.replaceAll('"', '');
    await _gql('''
{
  "query": "mutation Delete(\$userId: ID!, \$bucket: StorageBucket!, \$path: String!) { deleteStorageFile(userId: \$userId, bucket: \$bucket, path: \$path) }",
  "variables": { "userId": "$userId", "bucket": "${bucket.value}", "path": "$safePath" }
}''');
  }

  // ---- Utility ----

  /// Read bytes from a [File] (mobile/desktop). On web, pass bytes directly.
  static Future<Uint8List> readFileBytes(File file) => file.readAsBytes();
}

// Simple JSON decode helper
Map<String, dynamic> _jsonDecode(String body) =>
    jsonDecode(body) as Map<String, dynamic>;
