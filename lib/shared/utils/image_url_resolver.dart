import 'package:flutter/foundation.dart';

const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

String resolveBookImageUrl(dynamic rawValue) {
  final raw = (rawValue ?? '').toString().trim();
  if (raw.isEmpty || raw.toLowerCase() == 'null') {
    return '';
  }

  if (raw.startsWith('data:image/')) {
    return raw;
  }

  if (raw.startsWith('//')) {
    return 'https:$raw';
  }

  final parsed = Uri.tryParse(raw);
  if (parsed != null && parsed.hasScheme) {
    return Uri.encodeFull(raw);
  }

  if (raw.startsWith('www.')) {
    return Uri.encodeFull('https://$raw');
  }

  if (raw.startsWith('assets/')) {
    return raw;
  }

  final apiBase = _defaultApiBaseUrl();
  final apiUri = Uri.parse(apiBase);
  final rootUri = Uri(
    scheme: apiUri.scheme,
    host: apiUri.host,
    port: apiUri.hasPort ? apiUri.port : null,
  );

  if (raw.startsWith('/')) {
    return Uri.encodeFull(rootUri.resolve(raw).toString());
  }

  return Uri.encodeFull(apiUri.resolve(raw).toString());
}

/// Resolves user profile image URL
/// Handles relative paths, absolute URLs, and data URLs
String resolveUserImageUrl(dynamic rawValue) {
  return resolveBookImageUrl(rawValue);
}

bool isNetworkImageUrl(String value) {
  final url = value.trim();
  if (url.isEmpty) {
    return false;
  }
  if (url.startsWith('data:image/')) {
    return true;
  }
  final parsed = Uri.tryParse(url);
  if (parsed == null) {
    return false;
  }
  return parsed.hasScheme &&
      (parsed.scheme == 'http' || parsed.scheme == 'https' || parsed.scheme == 'data');
}

String _defaultApiBaseUrl() {
  if (_envBaseUrl.trim().isNotEmpty) {
    final url = _envBaseUrl.trim();
    return url.endsWith('/') ? url : '$url/';
  }

  if (kIsWeb) {
    return 'http://localhost:5000/api/';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      // Use your computer's local IP address for physical devices
      // Change this to 10.0.2.2 if using emulator
      return 'http://192.168.1.76:5000/api/';
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return 'http://localhost:5000/api/';
    default:
      return 'http://localhost:5000/api/';
  }
}
