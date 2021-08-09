import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:taiwantourism/model/event_model.dart';

import '../constants.dart';

class DatabaseHelper {
  static const String TABLE_EVENT = "event";
  static const String TABLE_PICTURE = "picture";
  static const String COLUMN_ID = "id";
  static const String COLUMN_SRC_ID = "src_id";
  static const String COLUMN_NAME = "name";
  static const String COLUMN_DESCRIPTION = "description";
  static const String COLUMN_PARTICIPATION = "participation";
  static const String COLUMN_LOCATION = "location";
  static const String COLUMN_ADDRESS = "address";
  static const String COLUMN_PHONE = "phone";
  static const String COLUMN_ORGANIZER = "organizer";
  static const String COLUMN_START_TIME = "start_time";
  static const String COLUMN_END_TIME = "end_time";
  static const String COLUMN_CYCLE = "cycle";
  static const String COLUMN_NON_CYCLE = "non_cycle";
  static const String COLUMN_WEBSITE_URL = "website_url";
  static const String COLUMN_POSITION_LON = "position_lon";
  static const String COLUMN_POSITION_LAT = "position_lat";
  static const String COLUMN_POSITION_GEO_HASH = "position_geo_hash";
  static const String COLUMN_CLASS_1 = "class_1";
  static const String COLUMN_CLASS_2 = "class_2";
  static const String COLUMN_MAP_URL = "map_url";
  static const String COLUMN_TRAVEL_INFO = "travel_info";
  static const String COLUMN_PARKING_INFO = "parking_info";
  static const String COLUMN_CHARGE = "charge";
  static const String COLUMN_REMARKS = "remarks";
  static const String COLUMN_CITY = "city";
  static const String COLUMN_SRC_UPDATE_TIME = "src_update_time";
  static const String COLUMN_PTX_UPDATE_TIME = "ptx_update_time";
  static const String COLUMN_SRC_TYPE = "src_type";
  static const String COLUMN_URL = "url";
  static const String COLUMN_NUMBER = "number";

  static final DateFormat dailyMemoDateFormat =
      DateFormat(Constants.EXPRESSION_ISO8601_UTC);

  DatabaseHelper._(); // Private constructor
  static final DatabaseHelper dh = DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async {
    return _database ??= await _initiateDatabase();
  }

  Future<Database> _initiateDatabase() async {
    String path = await getDatabasesPath();
    return await openDatabase(join(path, 'taiwan_tourism.db'), version: 1,
        onCreate: (Database database, int version) async {
      database.execute('CREATE TABLE $TABLE_EVENT ('
          '$COLUMN_ID INTEGER PRIMARY KEY,'
          '$COLUMN_SRC_TYPE TEXT,'
          '$COLUMN_SRC_ID TEXT,'
          '$COLUMN_NAME TEXT,'
          '$COLUMN_DESCRIPTION TEXT,'
          '$COLUMN_PARTICIPATION TEXT,'
          '$COLUMN_LOCATION TEXT,'
          '$COLUMN_ADDRESS TEXT,'
          '$COLUMN_PHONE TEXT,'
          '$COLUMN_ORGANIZER TEXT,'
          '$COLUMN_START_TIME TEXT,'
          '$COLUMN_END_TIME TEXT,'
          '$COLUMN_CYCLE TEXT,'
          '$COLUMN_NON_CYCLE TEXT,'
          '$COLUMN_WEBSITE_URL TEXT,'
          '$COLUMN_POSITION_LON REAL,'
          '$COLUMN_POSITION_LAT REAL,'
          '$COLUMN_POSITION_GEO_HASH TEXT,'
          '$COLUMN_CLASS_1 TEXT,'
          '$COLUMN_CLASS_2 TEXT,'
          '$COLUMN_MAP_URL TEXT,'
          '$COLUMN_TRAVEL_INFO TEXT,'
          '$COLUMN_PARKING_INFO TEXT,'
          '$COLUMN_CHARGE TEXT,'
          '$COLUMN_REMARKS TEXT,'
          '$COLUMN_CITY TEXT,'
          '$COLUMN_SRC_UPDATE_TIME TEXT,'
          '$COLUMN_PTX_UPDATE_TIME TEXT)');
      database.execute('CREATE TABLE $TABLE_PICTURE ('
          '$COLUMN_ID INTEGER PRIMARY KEY,'
          '$COLUMN_SRC_TYPE TEXT,'
          '$COLUMN_SRC_ID TEXT,'
          '$COLUMN_NUMBER INTEGER,'
          '$COLUMN_URL TEXT,'
          '$COLUMN_DESCRIPTION TEXT)');
    });
  }

  Future<List<EventModel>> getEventsByCity(String srcType, String city) async {
    return _getEvents(srcType, city);
  }

  Future<List<EventModel>> getAllEvents(String srcType) async {
    return _getEvents(srcType, '');
  }

  Future<List<EventModel>> _getEvents(String srcType, String city) async {
    final db = await database;
    var eventMapList = await db.query(TABLE_EVENT,
        columns: [
          COLUMN_ID,
          COLUMN_SRC_TYPE,
          COLUMN_SRC_ID,
          COLUMN_NAME,
          COLUMN_DESCRIPTION,
          COLUMN_PARTICIPATION,
          COLUMN_LOCATION,
          COLUMN_ADDRESS,
          COLUMN_PHONE,
          COLUMN_ORGANIZER,
          COLUMN_START_TIME,
          COLUMN_END_TIME,
          COLUMN_CYCLE,
          COLUMN_NON_CYCLE,
          COLUMN_WEBSITE_URL,
          COLUMN_POSITION_LON,
          COLUMN_POSITION_LAT,
          COLUMN_POSITION_GEO_HASH,
          COLUMN_CLASS_1,
          COLUMN_CLASS_2,
          COLUMN_MAP_URL,
          COLUMN_TRAVEL_INFO,
          COLUMN_PARKING_INFO,
          COLUMN_CHARGE,
          COLUMN_REMARKS,
          COLUMN_CITY,
          COLUMN_SRC_UPDATE_TIME,
          COLUMN_PTX_UPDATE_TIME,
        ],
        where: city.isEmpty
            ? '$COLUMN_SRC_TYPE = ?'
            : '$COLUMN_SRC_TYPE = ? and $COLUMN_CITY = ?',
        whereArgs: city.isEmpty ? [srcType] : [srcType, city]);
    List<EventModel> eventList = <EventModel>[];
    for (var eventMap in eventMapList) {
      var event = EventModel.fromMap(eventMap);
      event.picture = await _getTourismPicture(event.srcType, event.srcId);
      eventList.add(event);
    }
    return eventList;
  }

  Future<TourismPicture> _getTourismPicture(
      String srcType, String srcId) async {
    final db = await database;
    var mapList = await db.query(TABLE_PICTURE,
        columns: [
          COLUMN_SRC_TYPE,
          COLUMN_SRC_ID,
          COLUMN_NUMBER,
          COLUMN_URL,
          COLUMN_DESCRIPTION,
        ],
        where: '$COLUMN_SRC_TYPE = ? and $COLUMN_SRC_ID = ?',
        whereArgs: [srcType, srcId]);
    return TourismPicture.fromMapList(mapList);
  }

  /// Returns the id of the last inserted row.
  Future<int> insertEvent(EventModel event) async {
    List<Map<String, dynamic>> mappedPictureList =
        event.picture.toMapList(event.srcType, event.srcId);
    Map<String, dynamic> mappedEvent = event.toMap();
    final db = await database;
    for (var mappedPicture in mappedPictureList) {
      await db.insert(TABLE_PICTURE, mappedPicture);
    }
    return await db.insert(TABLE_EVENT, mappedEvent);
  }

  /// Returns the number of changes made.
  Future<int> updateEvent(EventModel event) async {
    List<Map<String, dynamic>> mappedPictureList =
        event.picture.toMapList(event.srcType, event.srcId);
    Map<String, dynamic> mappedEvent = event.toMap();
    final db = await database;
    await db.delete(TABLE_PICTURE,
        where: '$COLUMN_SRC_TYPE = ? and $COLUMN_SRC_ID = ?',
        whereArgs: [event.srcType, event.srcId]);
    for (var mappedPicture in mappedPictureList) {
      await db.insert(TABLE_PICTURE, mappedPicture);
    }
    return await db.update(TABLE_EVENT, mappedEvent,
        where: '$COLUMN_SRC_TYPE = ? and $COLUMN_SRC_ID = ?',
        whereArgs: [event.srcType, event.srcId]);
  }

  /// Returns the number of rows affected.
  Future<int> deleteEvent(String srcType, String srcId) async {
    final db = await database;
    return await db.delete(TABLE_EVENT,
        where: '$COLUMN_SRC_TYPE = ? and $COLUMN_SRC_ID = ?',
        whereArgs: [srcType, srcId]);
  }
}
