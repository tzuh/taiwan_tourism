import 'dart:ui';

class Constants {
  /// Cities
  static const String TAIPEI = 'Taipei'; // 臺北市
  static const String NEW_TAIPEI = 'NewTaipei'; // 新北市
  static const String TAOYUAN = 'Taoyuan'; // 桃園市
  static const String TAICHUNG = 'Taichung'; // 臺中市
  static const String TAINAN = 'Tainan'; // 臺南市
  static const String KAOHSIUNG = 'Kaohsiung'; // 高雄市
  static const String KEELUNG = 'Keelung'; // 基隆市
  static const String HSINCHU = 'Hsinchu'; // 新竹市
  static const String HSINCHU_COUNTY = 'HsinchuCounty'; // 新竹縣
  static const String MIAOLI_COUNTY = 'MiaoliCounty'; // 苗栗縣
  static const String CHANGHUA_COUNTY = 'ChanghuaCounty'; // 彰化縣
  static const String NANTOU_COUNTY = 'NantouCounty'; // 南投縣
  static const String YUNLIN_COUNTY = 'YunlinCounty'; // 雲林縣
  static const String CHIAYI_COUNTY = 'ChiayiCounty'; // 嘉義縣
  static const String CHIAYI = 'Chiayi'; // 嘉義市
  static const String PINGTUNG_COUNTY = 'PingtungCounty'; // 屏東縣
  static const String YILAN_COUNTY = 'YilanCounty'; // 宜蘭縣
  static const String HUALIEN_COUNTY = 'HualienCounty'; // 花蓮縣
  static const String TAITUNG_COUNTY = 'TaitungCounty'; // 臺東縣
  static const String KINMEN_COUNTY = 'KinmenCounty'; // 金門縣
  static const String PENGHU_COUNTY = 'PenghuCounty'; // 澎湖縣
  static const String LIENCHIANG_COUNTY = 'LienchiangCounty'; // 連江縣
  static const String NONE_CITY = '';

  static const Map<String, String> CITY_NAMES = {
    TAIPEI: '臺北市',
    NEW_TAIPEI: '新北市',
    TAOYUAN: '桃園市',
    TAICHUNG: '臺中市',
    TAINAN: '臺南市',
    KAOHSIUNG: '高雄市',
    KEELUNG: '基隆市',
    HSINCHU: '新竹市',
    HSINCHU_COUNTY: '新竹縣',
    MIAOLI_COUNTY: '苗栗縣',
    CHANGHUA_COUNTY: '彰化縣',
    NANTOU_COUNTY: '南投縣',
    YUNLIN_COUNTY: '雲林縣',
    CHIAYI_COUNTY: '嘉義縣',
    CHIAYI: '嘉義市',
    PINGTUNG_COUNTY: '屏東縣',
    YILAN_COUNTY: '宜蘭縣',
    HUALIEN_COUNTY: '花蓮縣',
    TAITUNG_COUNTY: '臺東縣',
    KINMEN_COUNTY: '金門縣',
    PENGHU_COUNTY: '澎湖縣',
    LIENCHIANG_COUNTY: '連江縣',
    NONE_CITY: '　　　',
  };

  /// Datetime
  static const int SECONDS_FOR_QUIT = 2;

  /// Colors
  static const Color COLOR_THEME_BLUE_GREY = Color(0xFF607D8B);
  static const Color COLOR_THEME_RED = Color(0xFFE12525);
  static const Color COLOR_THEME_BLACK = Color(0xFF111111);
  static const Color COLOR_THEME_TRANSPARENT_BLACK = Color(0xB0000000);
  static const Color COLOR_THEME_WHITE = Color(0xFFFFFFFF);
  static const Color COLOR_THEME_DARK_WHITE = Color(0xFFEAEAEA);

  /// Dimensions
  static const double DIMEN_PRIMARY_MARGIN = 10;

  /// Links
  static const String LINK_PTX = 'https://ptx.transportdata.tw/PTX/';

  /// Preference
  static const bool PREF_SHOW_EXPIRED_EVENTS = true; // 顯示過期的活動
  static const int PREF_EVENT_SORT_BY = EVENT_SORT_BY_END_TIME; // 顯示過期的活動

  /// Event sort by
  static const int EVENT_SORT_BY_START_TIME = 0; // 依開始日期排序
  static const int EVENT_SORT_BY_END_TIME = 1; // 依結束日期排序

  /// HTTP status code
  static const int HTTP_STATUS_CODE_OK = 200;
  static const int HTTP_STATUS_CODE_UNAUTHORIZED = 401; // 未帶簽章，未經授權
  static const int HTTP_STATUS_CODE_SIGNATURE_ERROR = 403; // 簽章錯誤
  static const int HTTP_STATUS_CODE_CONNECTION_EXCEEDED =
      416; // 超過最大平行連接數（每個IP發60個連接）
  static const int HTTP_STATUS_CODE_REQUEST_EXCEEDED =
      423; // 超過單位時間請求數（50 request/秒）
  static const int HTTP_STATUS_CODE_API_RATE_EXCEEDED = 429; // 超過當日呼叫上限次數

  /// Strings for displaying
  static const String STRING_ACTIVITY = '活動公告';
  static const String STRING_SETTINGS = '設定';
  static const String STRING_BACK = '返回';
  static const String STRING_APP_VERSION = 'App 版本';
  static const String STRING_REFERENCES = '資料來源';
  static const String STRING_ORGANIZER = '主辦單位';
  static const String STRING_UPDATE_TIME = '最後更新時間';
  static const String STRING_OFFLINE = '無法連線';
  static const String STRING_CHECK_CONNECTION = '請檢查網路設定';
  static const String STRING_PTX = '交通部 PTX | (02)2349-2803 | ptx@motc.gov.tw';
  static const String STRING_SEVER_ERROR = '伺服器錯誤';
  static const String STRING_TRY_LATER = '請稍後再試';
  static const String STRING_OK = '確定';
  static const String STRING_PRESS_AGAIN_TO_QUIT = '再按一次返回鍵退出';
  static const String STRING_NO_SUITABLE_CONTENT = '沒有符合條件的資料';
  static const String STRING_SHOW_EXPIRED_EVENTS = '顯示過期的活動';
  static const String STRING_SORT_BY_START_TIME = '依開始日期排序';
  static const String STRING_SORT_BY_END_TIME = '依結束日期排序';
}
