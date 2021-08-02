import 'dart:math';

import 'package:flutter/material.dart';

import 'constants.dart';
import 'home_page.dart';

class SelectionPage extends StatefulWidget {
  SelectionPage();

  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  var _lastPressedBackButton = DateTime.now()
      .toUtc()
      .add(Duration(seconds: -Constants.SECONDS_FOR_QUIT));
  late double _screenDiagonal;
  late double _scale;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    _screenDiagonal = sqrt(pow(screenHeight, 2) + pow(screenWidth, 2));
    _scale = _screenDiagonal / 900;

    print('($screenHeight,$screenWidth) $_screenDiagonal');
    return WillPopScope(
        onWillPop: () async {
          var now = DateTime.now().toUtc();
          if (now.difference(_lastPressedBackButton).inSeconds >
              Constants.SECONDS_FOR_QUIT) {
            _lastPressedBackButton = now;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(Constants.STRING_PRESS_AGAIN_TO_QUIT)));
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          backgroundColor: Constants.COLOR_THEME_BLUE_GREY,
          body: Container(
              margin: EdgeInsets.symmetric(vertical: screenHeight / 30),
              decoration: BoxDecoration(
                color: Constants.COLOR_THEME_BLUE_GREY,
                image: DecorationImage(
                  image: AssetImage('assets/images/selection_bg.png'),
                  fit: BoxFit.contain,
                ),
              ),
              child: Container(
                  margin: EdgeInsets.only(
                      left: screenWidth * 0.07,
                      right: screenWidth * 0.07,
                      top: screenHeight * 0.03,
                      bottom: screenHeight * 0.01),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.TAOYUAN]
                                      .toString(),
                                  Constants.TAOYUAN),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.HSINCHU]
                                      .toString(),
                                  Constants.HSINCHU),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.HSINCHU_COUNTY]
                                      .toString(),
                                  Constants.HSINCHU_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.MIAOLI_COUNTY]
                                      .toString(),
                                  Constants.MIAOLI_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.TAICHUNG]
                                      .toString(),
                                  Constants.TAICHUNG),
                              buildCityButton(
                                  Constants
                                      .CITY_NAMES[Constants.CHANGHUA_COUNTY]
                                      .toString(),
                                  Constants.CHANGHUA_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.YUNLIN_COUNTY]
                                      .toString(),
                                  Constants.YUNLIN_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.CHIAYI]
                                      .toString(),
                                  Constants.CHIAYI),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.CHIAYI_COUNTY]
                                      .toString(),
                                  Constants.CHIAYI_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.TAINAN]
                                      .toString(),
                                  Constants.TAINAN),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.KAOHSIUNG]
                                      .toString(),
                                  Constants.KAOHSIUNG),
                            ]),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.KEELUNG]
                                      .toString(),
                                  Constants.KEELUNG),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.TAIPEI]
                                      .toString(),
                                  Constants.TAIPEI),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.NEW_TAIPEI]
                                      .toString(),
                                  Constants.NEW_TAIPEI),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.YILAN_COUNTY]
                                      .toString(),
                                  Constants.YILAN_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.HUALIEN_COUNTY]
                                      .toString(),
                                  Constants.HUALIEN_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.NANTOU_COUNTY]
                                      .toString(),
                                  Constants.NANTOU_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.TAITUNG_COUNTY]
                                      .toString(),
                                  Constants.TAITUNG_COUNTY),
                              buildCityButton(
                                  Constants
                                      .CITY_NAMES[Constants.PINGTUNG_COUNTY]
                                      .toString(),
                                  Constants.PINGTUNG_COUNTY),
                              buildCityButton(
                                  Constants
                                      .CITY_NAMES[Constants.LIENCHIANG_COUNTY]
                                      .toString(),
                                  Constants.LIENCHIANG_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.KINMEN_COUNTY]
                                      .toString(),
                                  Constants.KINMEN_COUNTY),
                              buildCityButton(
                                  Constants.CITY_NAMES[Constants.PENGHU_COUNTY]
                                      .toString(),
                                  Constants.PENGHU_COUNTY),
                            ]),
                      ]))),
        ));
  }

  OutlinedButton buildCityButton(String displayName, String urlName) {
    return OutlinedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.only(
              left: 15 * _scale,
              right: 15 * _scale,
              top: 5 * _scale,
              bottom: 7 * _scale)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          side: MaterialStateProperty.all<BorderSide>(
              BorderSide(color: Constants.COLOR_THEME_WHITE, width: 1)),
          backgroundColor: MaterialStateProperty.all<Color>(
              Constants.COLOR_THEME_TRANSPARENT_BLACK),
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(currentCity: urlName)));
        },
        child: Text(
          displayName,
          style: TextStyle(color: Constants.COLOR_THEME_WHITE, fontSize: 24),
        ));
  }
}
