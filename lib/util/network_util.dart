import 'dart:io';

class NetworkUtil {
  NetworkUtil._();

  static Future<bool> isAvailable() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
