import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Single source of mock data for the whole app.
///
/// Every API call in the app is commented out and replaced with
/// `mockResponse(MockData.get('<dot.path>'))`, so the UI can be exercised
/// without a backend. The payloads live in [mockDataAsset] and are shaped to
/// match exactly what the controllers parse out of the real responses.
///
/// [load] must run before the first widget builds (see `main()`), because
/// [get] is synchronous — the call sites read it inline, the same way they
/// used to read `res.data`.
const String mockDataAsset = 'assets/mock/mock_data.json';

class MockData {
  MockData._();

  static Map<String, dynamic> _root = const <String, dynamic>{};
  static bool _loaded = false;

  /// True once [load] has parsed the bundled JSON.
  static bool get isLoaded => _loaded;

  /// Reads and caches `assets/mock/mock_data.json`.
  ///
  /// Safe to call more than once — later calls are no-ops unless [force] is
  /// set. Never throws: a missing or malformed asset leaves the store empty,
  /// and every [get] then falls back, so the UI still renders.
  static Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    try {
      final raw = await rootBundle.loadString(mockDataAsset);
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        _root = decoded;
        _loaded = true;
        debugPrint('MOCK DATA => loaded ${_root.length} sections '
            'from $mockDataAsset');
      } else {
        debugPrint('MOCK DATA => $mockDataAsset is not a JSON object');
      }
    } catch (e) {
      debugPrint('MOCK DATA => failed to load $mockDataAsset: $e');
    }
  }

  /// Looks up a dot-separated path, e.g. `'chat.list'` or `'liveMap.dashboard'`.
  ///
  /// Returns a deep copy so a screen that mutates what it got back (sorting a
  /// list, adding a sent message) cannot corrupt the store for the next read.
  /// Returns [fallback] when the path is missing, so an unmapped endpoint
  /// degrades to an empty screen instead of an exception.
  static dynamic get(String path, {dynamic fallback}) {
    if (!_loaded) {
      debugPrint('MOCK DATA => get("$path") before load() — returning fallback');
      return fallback;
    }

    dynamic node = _root;
    for (final segment in path.split('.')) {
      if (node is Map && node.containsKey(segment)) {
        node = node[segment];
      } else {
        debugPrint('MOCK DATA => missing path "$path"');
        return fallback;
      }
    }
    return _copy(node);
  }

  /// Convenience typed readers for the common cases.
  static Map<String, dynamic> getMap(String path) {
    final value = get(path);
    return value is Map<String, dynamic>
        ? value
        : (value is Map
            ? Map<String, dynamic>.from(value)
            : <String, dynamic>{});
  }

  static List<dynamic> getList(String path) {
    final value = get(path);
    return value is List ? value : const <dynamic>[];
  }

  static dynamic _copy(dynamic node) {
    if (node is Map) {
      return <String, dynamic>{
        for (final entry in node.entries) entry.key.toString(): _copy(entry.value),
      };
    }
    if (node is List) {
      return node.map<dynamic>(_copy).toList();
    }
    return node;
  }
}

/// Wraps mock data in a Dio [dio.Response] so call sites keep reading
/// `res.statusCode` / `res.data` / `res.statusMessage` unchanged.
dio.Response<dynamic> mockResponse(
  dynamic data, {
  int statusCode = 200,
  String statusMessage = 'OK',
  String path = '/mock',
}) {
  return dio.Response<dynamic>(
    requestOptions: dio.RequestOptions(path: path),
    data: data,
    statusCode: statusCode,
    statusMessage: statusMessage,
  );
}

/// Mock for the byte-download endpoints (`getBytes`). Returns an empty body —
/// there is no real file behind a mock URL — so callers get a well-formed
/// response instead of a network error.
dio.Response<dynamic> mockBytesResponse({String path = '/mock'}) {
  return mockResponse(Uint8List(0), path: path);
}

/// Wraps mock data in a `package:http` [http.Response], for the few call sites
/// that use the raw http client instead of Dio. Those read `response.body` as
/// a JSON string, so the payload is encoded the way the server sent it.
http.Response mockHttpResponse(
  dynamic data, {
  int statusCode = 200,
}) {
  return http.Response(
    json.encode(data ?? const <String, dynamic>{}),
    statusCode,
    headers: const {'content-type': 'application/json; charset=utf-8'},
  );
}
