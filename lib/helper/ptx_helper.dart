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

class PtxHelper {
  static Future<http.Response> getPtxEvents(int num) async {
    return getPtxEventsByCity('', num);
  }

  static Future<http.Response> getPtxEventsByCity(String city, int num) async {
    var envU = dotenv.env['PTX_U'].toString();
    var envK = dotenv.env['PTX_K'].toString();
    var k = 's7vKtxHFA3EpBryNI3AH1e9K';
    var utcTime = DateFormat(Constants.EXPRESSION_PTX_HTTP)
        .format(DateTime.now().toUtc());
    var signature = base64.encode(Hmac(sha1,
            utf8.encode(envK.substring(0, 3) + _codec(envK.substring(3), k)))
        .convert(utf8.encode('x-date: $utcTime'))
        .bytes);
    String uri =
        join('https://ptx.transportdata.tw/MOTC/v2/Tourism/Activity', city) +
            '?\$orderby=EndTime%20desc&\$top=$num&\$format=JSON';
    http.Response response =
        http.Response('', Constants.HTTP_STATUS_CODE_SEVER_ERROR);
    try {
      response = await http.get(Uri.parse(uri), headers: <String, String>{
        'Accept': 'application/json',
        'Authorization':
            'hmac username="$envU", algorithm="hmac-sha1", headers="x-date", signature="$signature"',
        'x-date': '$utcTime',
        'Accept-Encoding': 'gzip',
        'If-Modified-Since': await PreferenceHelper.getPtxLastModifiedTime(),
      }).timeout(NetworkUtil.TIME_LIMIT);
    } on Exception catch (e) {
      print(e);
    } on Error catch (e) {
      print(e);
    }
    return response;
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
