import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/app_document.dart';
import '../mappers/document_mapper.dart';
import '../services/auth_service.dart';
import '../services/file_service.dart';
import '../services/firebase_bootstrap_service.dart';
import '../services/remote_config_service.dart';

class FirebaseDocumentDataSource {
  const FirebaseDocumentDataSource(
    this._firebase,
    this._auth,
    this._config,
    this._files,
    this._mapper,
  );

  final FirebaseBootstrapService _firebase;
  final AuthService _auth;
  final RemoteConfigService _config;
  final FileService _files;
  final DocumentMapper _mapper;

  bool get enabled =>
      _firebase.available && _config.cloudEnabled && _auth.userId != null;

  CollectionReference<Map<String, dynamic>> _documents(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('products')
        .doc(AppConstants.productId)
        .collection('documents');
  }

  Future<AppDocument> upload(AppDocument document) async {
    if (!enabled) throw StateError('Cloud sync is not enabled.');

    final uid = _auth.userId!;
    final payload = _mapper.toMap(document);
    final pageMaps = <Map<String, dynamic>>[];

    for (final rawPage in payload['pages'] as List) {
      final page = Map<String, dynamic>.from(rawPage as Map);
      final localPath =
          (page['processedPath'] ?? page['originalPath'])?.toString() ?? '';
      final localFile = File(localPath);

      if (localPath.isNotEmpty && await localFile.exists()) {
        final pageId = page['id']?.toString() ?? 'page';
        final ref = FirebaseStorage.instance.ref(
          'users/$uid/${AppConstants.productId}/${document.id}/$pageId.jpg',
        );
        await ref.putFile(localFile);
        page['cloudUrl'] = await ref.getDownloadURL();
      }
      pageMaps.add(page);
    }

    payload
      ..['pages'] = pageMaps
      ..['productId'] = AppConstants.productId
      ..['ownerUid'] = uid
      ..['updatedAtServer'] = FieldValue.serverTimestamp();

    await _documents(
      uid,
    ).doc(document.id).set(payload, SetOptions(merge: true));

    return document.copyWith(cloudState: CloudState.synced);
  }

  Future<List<AppDocument>> fetchAll() async {
    if (!enabled) return const [];

    final snapshot = await _documents(
      _auth.userId!,
    ).orderBy('updatedAt', descending: true).get();

    final restored = <AppDocument>[];
    for (final doc in snapshot.docs) {
      final map = Map<String, dynamic>.from(doc.data());
      final remotePages = ((map['pages'] as List?) ?? const [])
          .whereType<Map>()
          .toList();
      final localPages = <Map<String, dynamic>>[];

      for (final raw in remotePages) {
        final page = Map<String, dynamic>.from(raw);
        final cloudUrl = page['cloudUrl']?.toString() ?? '';

        if (cloudUrl.isNotEmpty) {
          try {
            final pageId = page['id']?.toString() ?? 'page';
            final path = await _files.createExportPath(
              'cloud_${doc.id}_$pageId',
              'jpg',
            );
            await FirebaseStorage.instance
                .refFromURL(cloudUrl)
                .writeToFile(File(path));
            page
              ..['originalPath'] = path
              ..['processedPath'] = null;
          } catch (_) {
            // Metadata still restores if an individual cloud image is missing.
          }
        }

        page.remove('cloudUrl');
        localPages.add(page);
      }

      map['pages'] = localPages;
      restored.add(
        _mapper.fromMap(map).copyWith(cloudState: CloudState.synced),
      );
    }
    return restored;
  }

  Future<void> delete(String id) async {
    if (!enabled) return;

    final uid = _auth.userId!;
    await _documents(uid).doc(id).delete();

    try {
      final folder = FirebaseStorage.instance.ref(
        'users/$uid/${AppConstants.productId}/$id',
      );
      final list = await folder.listAll();
      await Future.wait(list.items.map((item) => item.delete()));
    } catch (_) {
      // Firestore deletion is authoritative; orphan cleanup can be retried.
    }
  }
}
