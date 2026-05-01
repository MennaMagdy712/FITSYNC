import 'package:dio/dio.dart';

/// Stub for web: SSL bypass not needed; always returns localUrl
void configureSsl(Dio dio) {
  // No-op on web
}

/// Stub for web: Platform not available, return localUrl
String getBaseUrlForPlatform(String physicalDevUrl, String localUrl) {
  return localUrl;
}
