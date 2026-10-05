import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class IdentityService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyPublicId = 'gwp_public_id';
  static const _keySecretKey = 'gwp_secret_key';
  static const _keyRecoveryString = 'gwp_recovery_string';
  static const _keyPasswordHash = 'gwp_password_hash';
  static const _keyCreatedAt = 'gwp_created_at';

  static Future<bool> hasAccount() async {
    final id = await _storage.read(key: _keyPublicId);
    return id != null && id.isNotEmpty;
  }

  static Future<IdentityResult> createAccount({required String password}) async {
    final deviceFingerprint = await _collectDeviceFingerprint();
    final random = Random.secure();
    final randomBytes = List<int>.generate(32, (_) => random.nextInt(256));

    final publicIdMaterial = utf8.encode(deviceFingerprint) + randomBytes;
    final publicIdHash = sha256.convert(publicIdMaterial);
    final publicId = _toFriendlyId(publicIdHash.bytes);

    final secretKeyBytes = List<int>.generate(32, (_) => random.nextInt(256));
    final secretKey = base64Url.encode(secretKeyBytes).replaceAll('=', '');

    final passwordHash = sha256.convert(utf8.encode(password + secretKey)).toString();
    final recoveryString = '$secretKey.${base64Url.encode(utf8.encode(passwordHash))}';

    await _storage.write(key: _keyPublicId, value: publicId);
    await _storage.write(key: _keySecretKey, value: secretKey);
    await _storage.write(key: _keyRecoveryString, value: recoveryString);
    await _storage.write(key: _keyPasswordHash, value: passwordHash);
    await _storage.write(key: _keyCreatedAt, value: DateTime.now().toIso8601String());

    return IdentityResult(
      publicId: publicId,
      recoveryString: recoveryString,
      isNew: true,
    );
  }

  static Future<IdentityResult?> loginWithRecovery({
    required String recoveryString,
    required String password,
  }) async {
    try {
      final parts = recoveryString.split('.');
      if (parts.length != 2) return null;

      final secretKey = parts[0];
      final storedPasswordHashEncoded = parts[1];

      final expectedHash = sha256.convert(utf8.encode(password + secretKey)).toString();
      final storedHash = utf8.decode(base64Url.decode(storedPasswordHashEncoded));

      if (expectedHash != storedHash) return null;

      final publicIdMaterial = utf8.encode(secretKey);
      final publicIdHash = sha256.convert(publicIdMaterial);
      final publicId = _toFriendlyId(publicIdHash.bytes);

      await _storage.write(key: _keyPublicId, value: publicId);
      await _storage.write(key: _keySecretKey, value: secretKey);
      await _storage.write(key: _keyRecoveryString, value: recoveryString);
      await _storage.write(key: _keyPasswordHash, value: expectedHash);
      await _storage.write(key: _keyCreatedAt, value: DateTime.now().toIso8601String());

      return IdentityResult(
        publicId: publicId,
        recoveryString: recoveryString,
        isNew: false,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getPublicId() async {
    return await _storage.read(key: _keyPublicId);
  }

  static Future<String?> getRecoveryString() async {
    return await _storage.read(key: _keyRecoveryString);
  }

  static Future<String> _collectDeviceFingerprint() async {
    final deviceInfo = DeviceInfoPlugin();
    final buffer = StringBuffer();

    try {
      final android = await deviceInfo.androidInfo;
      buffer.write(android.id);
      buffer.write(android.brand);
      buffer.write(android.model);
      buffer.write(android.device);
      buffer.write(android.product);
      buffer.write(android.hardware);
      buffer.write(android.board);
      buffer.write(android.bootloader);
    } catch (_) {}

    try {
      final ios = await deviceInfo.iosInfo;
      buffer.write(ios.identifierForVendor ?? '');
      buffer.write(ios.name);
      buffer.write(ios.model);
      buffer.write(ios.systemName);
      buffer.write(ios.utsname.machine);
    } catch (_) {}

    try {
      final linux = await deviceInfo.linuxInfo;
      buffer.write(linux.machineId ?? '');
      buffer.write(linux.name);
      buffer.write(linux.version ?? '');
    } catch (_) {}

    try {
      final windows = await deviceInfo.windowsInfo;
      buffer.write(windows.deviceId);
      buffer.write(windows.computerName);
      buffer.write(windows.productName);
    } catch (_) {}

    buffer.write(const Uuid().v4());
    return buffer.toString();
  }

  static String _toFriendlyId(List<int> bytes) {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
    final sb = StringBuffer('GWP-');
    for (var i = 0; i < 16; i++) {
      final index = bytes[i % bytes.length] % alphabet.length;
      sb.write(alphabet[index]);
      if ((i + 1) % 4 == 0 && i != 15) sb.write('-');
    }
    return sb.toString();
  }
}

class IdentityResult {
  final String publicId;
  final String recoveryString;
  final bool isNew;

  IdentityResult({
    required this.publicId,
    required this.recoveryString,
    required this.isNew,
  });
}