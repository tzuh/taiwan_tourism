import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:taiwantourism/constants.dart';
import 'package:taiwantourism/helper/preference_helper.dart';
import 'package:taiwantourism/util/network_util.dart';

class TdxHelper {
  static Future<http.Response> getAccessToken() async {
    String uri =
        'https://tdx.transportdata.tw/auth/realms/TDXConnect/protocol/openid-connect/token';
    http.Response response =
        http.Response('', Constants.HTTP_STATUS_CODE_SEVER_ERROR);
    try {
      response = await http
          .post(
            Uri.parse(uri),
            headers: <String, String>{
              'content-type': 'application/x-www-form-urlencoded',
            },
            encoding: Encoding.getByName('utf-8'),
            body: {
              'grant_type': 'client_credentials',
              'client_id': _getClientI(),
              'client_secret': _getClientS(),
            },
          )
          .timeout(NetworkUtil.TIME_LIMIT);
    } on Exception catch (e) {
      print(e);
    } on Error catch (e) {
      print(e);
    }
    return response;
  }

  static Future<http.Response> getTdxEvents(int num) async {
    return getTdxEventsByCity('', num);
  }

  static Future<http.Response> getTdxEventsByCity(String city, int num) async {
    String uri = join(
            'https://tdx.transportdata.tw/api/basic/v2/Tourism/Activity',
            city) +
        '?\$orderby=EndTime%20desc&\$top=$num&\$format=JSON';
    http.Response response =
        http.Response('', Constants.HTTP_STATUS_CODE_SEVER_ERROR);
    try {
      response = await http.get(Uri.parse(uri), headers: <String, String>{
        'accept': 'application/json',
        'authorization': 'Bearer ' + await PreferenceHelper.getTdxAccessToken(),
        'If-Modified-Since': await PreferenceHelper.getTdxLastModifiedTime(),
      }).timeout(NetworkUtil.TIME_LIMIT);
    } on Exception catch (e) {
      print(e);
    } on Error catch (e) {
      print(e);
    }
    return response;
  }

  static String _getClientI() {
    return dotenv.env['TDX_U'].toString();
  }

  static String _getClientS() {
    var envK = dotenv.env['TDX_K'].toString();
    var k = '6dEEic48uR9rv3C0N2uc4Nc5x1F9u5Ze';
    return _codec(envK.substring(0, 8), k.substring(0, 8)) +
        '-' +
        _codec(envK.substring(8, 12), k.substring(8, 12)) +
        '-' +
        _codec(envK.substring(12, 16), k.substring(12, 16)) +
        '-' +
        _codec(envK.substring(16, 20), k.substring(16, 20)) +
        '-' +
        _codec(envK.substring(20, 32), k.substring(20, 32));
  }

  static String _codec(String str1, String str2) {
    List<int> list1 = base64.decode(str1);
    List<int> list2 = base64.decode(str2);
    List<int> result = [];
    for (int i = 0; i < list1.length; i++) {
      result.add(list1[i] ^ list2[i]);
    }
    return base64.encode(result);
  }
}
