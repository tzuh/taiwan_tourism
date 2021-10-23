import 'package:intl/intl.dart';
import '../../constants.dart';
import '../forecast_model.dart';
import '../location_model.dart';
import 'cwb_location.dart';
import 'cwb_time.dart';

class CwbLocations {
  final String? datasetDescription; // 資料集描述
  final String? locationsName; // 地點集合名稱
  final String? dataId; // 類別唯一識別碼
  final List<CwbLocation?>? location; // 地點

  CwbLocations({
    this.datasetDescription,
    this.locationsName,
    this.dataId,
    this.location,
  });

  factory CwbLocations.fromJson(Map<String, dynamic> j) {
    final location = j['location'] as List<dynamic>?;
    return CwbLocations(
      datasetDescription: j['datasetDescription'],
      locationsName: j['locationsName'],
      dataId: j['dataid'],
      location: location != null
          ? location.map((s) => CwbLocation.fromJson(s)).toList()
          : <CwbLocation?>[],
    );
  }

  String _fixString(String? str) {
    return str == null ? '' : str.trim();
  }

  List<LocationModel> toLocationModelList() {
    List<LocationModel> outputModelList = <LocationModel>[];
    String cityName = _fixString(this.locationsName).replaceAll('台', '臺');
    String cityId = Constants.CITY_STRING_TO_ID[cityName] ?? '';
    // Validate city data
    if (cityId.isNotEmpty &&
        this.location != null &&
        this.location!.length > 0) {
      // Parse locations in the city
      this.location!.forEach((loc) {
        if (loc != null) {
          LocationModel model = new LocationModel(
            name: _fixString(loc.locationName).replaceAll('台', '臺'),
            positionLat:
                double.tryParse(loc.lat ?? '') ?? LocationModel.FLOAT_NONE,
            positionLon:
                double.tryParse(loc.lon ?? '') ?? LocationModel.FLOAT_NONE,
            geoCode: loc.geoCode ?? '',
          );
          outputModelList.add(model);
        }
      });
    }
    return outputModelList;
  }

  List<ForecastModel> toForecastModelList() {
    List<ForecastModel> outputModelList = <ForecastModel>[];
    String cityName = _fixString(this.locationsName).replaceAll('台', '臺');
    String cityId = Constants.CITY_STRING_TO_ID[cityName] ?? '';
    // Validate city name
    if (cityId.isNotEmpty &&
        this.location != null &&
        this.location!.length > 0) {
      // Parse locations in the city
      this.location!.forEach((loc) {
        // Check weather elements exist
        if (loc != null &&
            loc.weatherElement != null &&
            loc.weatherElement!.length > 0) {
          var firstElement = loc.weatherElement![0];
          if (firstElement != null) {
            List<ForecastModel> locationModelList = <ForecastModel>[];
            int numOfTimes = -1;
            // Add new models to the list
            if (firstElement.time != null && firstElement.time!.length > 0) {
              numOfTimes = firstElement.time!.length;
              loc.weatherElement![0]!.time!.forEach((time) {
                if (time != null) {
                  DateTime twStartTime =
                      new DateFormat(Constants.EXPRESSION_CWB_DATA)
                          .parse(_fixString(time.startTime), true);
                  DateTime twEndTime =
                      new DateFormat(Constants.EXPRESSION_CWB_DATA)
                          .parse(_fixString(time.endTime), true);
                  ForecastModel model = new ForecastModel(
                    srcType: Constants.SOURCE_CWB_DIST_12H,
                    srcId: _fixString(this.dataId),
                    cityId: cityId,
                    locationName:
                        _fixString(loc.locationName).replaceAll('台', '臺'),
                    startTime: twStartTime.add(Duration(hours: -8)),
                    endTime: twEndTime.add(Duration(hours: -8)),
                  );
                  model.positionLat = double.tryParse(loc.lat ?? '') ??
                      ForecastModel.FLOAT_NONE;
                  model.positionLon = double.tryParse(loc.lon ?? '') ??
                      ForecastModel.FLOAT_NONE;
                  model.geoCode = loc.geoCode ?? '';
                  locationModelList.add(model);
                }
              });
            }
            // Add more details to the created models
            if (numOfTimes == locationModelList.length) {
              loc.weatherElement!.forEach((element) {
                if (element != null) {
                  var elementType = _fixString(element.elementName);
                  for (int i = 0; i < locationModelList.length; i++) {
                    CwbTime? time = element.time![i];
                    if (time != null &&
                        time.elementValue != null &&
                        time.elementValue!.length > 0) {
                      switch (elementType) {
                        case Constants.WEATHER_ELEMENT_TYPE_WX:
                          locationModelList[i].wx =
                              time.elementValue![0]!.value ?? '';
                          break;
                        case Constants.WEATHER_ELEMENT_TYPE_MAX_T:
                          locationModelList[i].maxT = int.tryParse(
                                  time.elementValue![0]!.value ?? '') ??
                              ForecastModel.INT_NONE;
                          break;
                        case Constants.WEATHER_ELEMENT_TYPE_MIN_T:
                          locationModelList[i].minT = int.tryParse(
                                  time.elementValue![0]!.value ?? '') ??
                              ForecastModel.INT_NONE;
                          break;
                        case Constants.WEATHER_ELEMENT_TYPE_POP_12H:
                          locationModelList[i].pOP = int.tryParse(
                                  time.elementValue![0]!.value ?? '') ??
                              ForecastModel.INT_NONE;
                          break;
                      }
                    }
                  }
                }
              });
              outputModelList.addAll(locationModelList);
            }
          }
        }
      });
    }
    return outputModelList;
  }
}
