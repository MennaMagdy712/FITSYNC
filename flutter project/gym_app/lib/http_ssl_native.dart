import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Native (Android/iOS/Windows/macOS): bypass SSL certificate validation
void configureSsl(Dio dio) {
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
}

/// Native: use Platform to pick the right base URL
String getBaseUrlForPlatform(String physicalDevUrl, String localUrl) {
  if (Platform.isAndroid || Platform.isIOS) {
    return physicalDevUrl; // physical device uses LAN IP
  }
  return localUrl; // Windows / Linux / macOS uses localhost
}
