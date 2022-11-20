import 'dart:ui';

class Constants {
  /// City identifications (also for TDX HTTP)
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

  /// City ID to String
  static const Map<String, String> CITY_ID_TO_STRING = {
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
  };

  /// City String to ID
  static const Map<String, String> CITY_STRING_TO_ID = {
    '臺北市': TAIPEI,
    '新北市': NEW_TAIPEI,
    '桃園市': TAOYUAN,
    '臺中市': TAICHUNG,
    '臺南市': TAINAN,
    '高雄市': KAOHSIUNG,
    '基隆市': KEELUNG,
    '新竹市': HSINCHU,
    '新竹縣': HSINCHU_COUNTY,
    '苗栗縣': MIAOLI_COUNTY,
    '彰化縣': CHANGHUA_COUNTY,
    '南投縣': NANTOU_COUNTY,
    '雲林縣': YUNLIN_COUNTY,
    '嘉義縣': CHIAYI_COUNTY,
    '嘉義市': CHIAYI,
    '屏東縣': PINGTUNG_COUNTY,
    '宜蘭縣': YILAN_COUNTY,
    '花蓮縣': HUALIEN_COUNTY,
    '臺東縣': TAITUNG_COUNTY,
    '金門縣': KINMEN_COUNTY,
    '澎湖縣': PENGHU_COUNTY,
    '連江縣': LIENCHIANG_COUNTY,
  };

  /// City ID to CWB API ID
  static const Map<String, String> CWB_API_ID_1WEEK = {
    TAIPEI: 'F-D0047-063',
    NEW_TAIPEI: 'F-D0047-071',
    TAOYUAN: 'F-D0047-007',
    TAICHUNG: 'F-D0047-075',
    TAINAN: 'F-D0047-079',
    KAOHSIUNG: 'F-D0047-067',
    KEELUNG: 'F-D0047-051',
    HSINCHU: 'F-D0047-055',
    HSINCHU_COUNTY: 'F-D0047-011',
    MIAOLI_COUNTY: 'F-D0047-015',
    CHANGHUA_COUNTY: 'F-D0047-019',
    NANTOU_COUNTY: 'F-D0047-023',
    YUNLIN_COUNTY: 'F-D0047-027',
    CHIAYI_COUNTY: 'F-D0047-031',
    CHIAYI: 'F-D0047-059',
    PINGTUNG_COUNTY: 'F-D0047-035',
    YILAN_COUNTY: 'F-D0047-003',
    HUALIEN_COUNTY: 'F-D0047-043',
    TAITUNG_COUNTY: 'F-D0047-039',
    KINMEN_COUNTY: 'F-D0047-087',
    PENGHU_COUNTY: 'F-D0047-047',
    LIENCHIANG_COUNTY: 'F-D0047-083',
  };

  /// Weather element types
  static const String WEATHER_ELEMENT_TYPE_WX = 'Wx'; // 天氣現象
  static const String WEATHER_ELEMENT_TYPE_MAX_T = 'MaxT'; // 最高溫度 (攝氏度)
  static const String WEATHER_ELEMENT_TYPE_MIN_T = 'MinT'; // 最低溫度 (攝氏度)
  static const String WEATHER_ELEMENT_TYPE_POP_12H = 'PoP12h'; // 降雨機率 (%)

  /// Source types
  static const String SOURCE_TDX = 'PTX'; // TDX整合的是PTX的資料服務
  static const String SOURCE_CWB_DIST_12H = 'CWB_DIST_12H';

  /// Event status
  static const int EVENT_STATUS_NONE = 0;
  static const int EVENT_STATUS_NEW = 1;

  /// Formats
  static const String EXPRESSION_PTX_HTTP = 'EEE, dd MMM yyyy HH:mm:ss GMT';
  static const String EXPRESSION_PTX_DATA = 'yyyy-MM-ddTHH:mm:ss';
  static const String EXPRESSION_TDX_HTTP = 'EEE, dd MMM yyyy HH:mm:ss GMT';
  static const String EXPRESSION_TDX_DATA = 'yyyy-MM-ddTHH:mm:ss';
  static const String EXPRESSION_CWB_DATA = 'yyyy-MM-dd HH:mm:ss';
  static const String EXPRESSION_ISO8601 = 'yyyy-MM-ddTHH:mm:ss+HH:mm';
  static const String EXPRESSION_ISO8601_UTC = 'yyyy-MM-ddTHH:mm:ss.mmmuuuZ';
  static const String EXPRESSION_DISPLAY = 'yyyy/MM/dd HH:mm:ss';

  /// Datetime
  static const int SECONDS_FOR_QUIT = 2;

  /// Colors
  static const Color COLOR_TRANSPARENT = Color(0x00000000);
  static const Color COLOR_THEME_BLUE_GREY = Color(0xFF607D8B);
  static const Color COLOR_THEME_RED = Color(0xFFD11515);
  static const Color COLOR_THEME_BLACK = Color(0xFF111111);
  static const Color COLOR_THEME_LIGHT_BLACK = Color(0xFF303030);
  static const Color COLOR_THEME_TRANSPARENT_BLACK = Color(0xB0000000);
  static const Color COLOR_THEME_WHITE = Color(0xFFFFFFFF);
  static const Color COLOR_THEME_DARK_WHITE = Color(0xFFEAEAEA);

  /// Dimensions
  static const double DIMEN_PRIMARY_MARGIN = 10;
  static const double DIMEN_ICON_BUTTON = 40;

  /// Links
  static const String LINK_PTX = 'https://ptx.transportdata.tw/PTX/';
  static const String LINK_TDX = 'https://tdx.transportdata.tw/';

  /// Preference defaults
  static const bool PREF_DEF_SHOW_EXPIRED_EVENTS = false; // 顯示過期的活動
  static const int PREF_DEF_EVENT_SORT_BY = EVENT_SORT_BY_START_TIME; // 依開始日期排序

  /// Event sort by
  static const int EVENT_SORT_BY_START_TIME = 0; // 依開始日期排序
  static const int EVENT_SORT_BY_END_TIME = 1; // 依結束日期排序

  /// HTTP
  static const int HTTP_STATUS_CODE_OK = 200;
  static const int HTTP_STATUS_CODE_SEVER_ERROR = 500;

  /// PTX HTTP
  // static const String PTX_RESPONSE_HEADER_LAST_MODIFIED = 'last-modified';
  // static const int PTX_STATUS_CODE_IS_UP_TO_DATE = 304;
  // static const int PTX_STATUS_CODE_UNAUTHORIZED = 401; // 未帶簽章，未經授權
  // static const int PTX_STATUS_CODE_SIGNATURE_ERROR = 403; // 簽章錯誤
  // static const int PTX_STATUS_CODE_CONNECTION_EXCEEDED = 416; // 超過最大平行連接數（每個IP發60個連接）
  // static const int PTX_STATUS_CODE_REQUEST_EXCEEDED = 423; // 超過單位時間請求數（50 request/秒）
  // static const int PTX_STATUS_CODE_API_RATE_EXCEEDED = 429; // 超過當日呼叫上限次數

  /// TDX HTTP
  static const String TDX_RESPONSE_HEADER_LAST_MODIFIED = 'last-modified';
  static const int TDX_STATUS_CODE_IS_UP_TO_DATE = 304;
  static const int TDX_STATUS_CODE_UNAUTHORIZED = 401; // 簽章錯誤

  /// Strings for displaying
  static const String STRING_EVENT = '活動公告';
  static const String STRING_SETTINGS = '設定';
  static const String STRING_BACK = '返回';
  static const String STRING_APP_VERSION = 'App 版本';
  static const String STRING_REFERENCES = '資料來源';
  static const String STRING_ORGANIZER = '主辦單位：';
  static const String STRING_UPDATE_TIME = '最後更新時間：';
  static const String STRING_OFFLINE = '無法連線';
  static const String STRING_CHECK_CONNECTION = '請檢查網路設定後再試一次';
  static const String STRING_DISCLAIMER = '資料來自交通部PTX平臺　詳情請洽各活動主辦單位';
  static const String STRING_SEVER_ERROR = '伺服器錯誤';
  static const String STRING_TRY_LATER = '請稍後再試';
  static const String STRING_CHECKING_DATA = '正在讀取資料...';
  static const String STRING_UPDATING_DATA = '正在更新資料...';
  static const String STRING_RETRY = '再試一次';
  static const String STRING_CANCEL = '取消';
  static const String STRING_PRESS_AGAIN_TO_QUIT = '再按一次返回鍵退出';
  static const String STRING_NO_SUITABLE_CONTENT = '沒有符合條件的資料';
  static const String STRING_SHOW_EXPIRED_EVENTS = '顯示過期的活動';
  static const String STRING_EVENT_EXPIRED = '活動已結束';
  static const String STRING_EVENT_RUNNING = '活動進行中';
  static const String STRING_BEGIN_AFTER_DAYS = '天後開始';
  static const String STRING_BEGIN_AFTER_WEEKS = '週後開始';
  static const String STRING_NEW = 'NEW';
  static const String STRING_FORECAST = '天氣預報';
  static const String STRING_TODAY = '今日';
  static const String STRING_DAY = '白天';
  static const String STRING_NIGHT = '晚上';
  static const String STRING_DEGREE_CELSIUS = '°C';

  /// String Array for displaying
  static const Map<int, String> STRING_ARRAY_EVENT_SORT_BY = {
    EVENT_SORT_BY_START_TIME: '依開始日期排序',
    EVENT_SORT_BY_END_TIME: '依結束日期排序',
  };
}
