import 'dart:io';

class NetworkUtil {
  NetworkUtil._();

  static const Duration TIME_LIMIT = const Duration(seconds: 3);

  static Future<bool> isAvailable({Duration timeLimit = TIME_LIMIT}) async {
    try {
      final result =
          await InternetAddress.lookup('example.com').timeout(timeLimit);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on Exception catch (e) {
      print(e);
    } on Error catch (e) {
      print(e);
    }
    return false;
  }
}
