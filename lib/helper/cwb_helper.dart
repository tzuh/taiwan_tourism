import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:taiwantourism/constants.dart';
import 'package:taiwantourism/util/network_util.dart';

class CwbHelper {
  /// 鄉鎮天氣預報-單一鄉鎮市區預報資料 (未來1週天氣預報)
  static Future<http.Response> getCwb1WeekForecastsByCity(String city) async {
    var envK = dotenv.env['CWB_K'].toString();
    var k = 'KjAHZcRCs7V1YY20IURUONv2GzLupI84';
    var signature = _codec(envK.substring(4, 12), k.substring(0, 8)) +
        '-' +
        _codec(envK.substring(12, 16), k.substring(8, 12)) +
        '-' +
        _codec(envK.substring(16, 20), k.substring(12, 16)) +
        '-' +
        _codec(envK.substring(20, 24), k.substring(16, 20)) +
        '-' +
        _codec(envK.substring(24, 36), k.substring(20, 32));
    String uri = 'https://opendata.cwa.gov.tw/api/v1/rest/datastore/' +
        (Constants.CWB_API_ID_1WEEK[city] ?? '') +
        '?format=JSON&elementName=' +
        Constants.WEATHER_ELEMENT_TYPE_WX +
        ',' +
        Constants.WEATHER_ELEMENT_TYPE_MAX_T +
        ',' +
        Constants.WEATHER_ELEMENT_TYPE_MIN_T +
        ',' +
        Constants.WEATHER_ELEMENT_TYPE_POP_12H;
    http.Response response =
        http.Response('', Constants.HTTP_STATUS_CODE_SEVER_ERROR);
    try {
      response = await http.get(Uri.parse(uri), headers: <String, String>{
        'Accept': 'application/json',
        'Authorization': envK.substring(0, 4) + signature,
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
