import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'constants.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    initVariables().then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Constants.COLOR_THEME_DARK_WHITE,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Constants.COLOR_THEME_WHITE,
                  size: 24,
                ),
                tooltip: Constants.STRING_BACK,
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(Constants.STRING_SETTINGS),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
            horizontal: Constants.DIMEN_PRIMARY_MARGIN,
            vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
        child: Column(
          children: [
            SizedBox(height: Constants.DIMEN_PRIMARY_MARGIN),
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
              child: Column(
                children: [
                  Text(Constants.STRING_APP_VERSION,
                      style: TextStyle(
                        fontSize: 20,
                        color: Constants.COLOR_THEME_BLACK,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center),
                  Text('$_version',
                      style: TextStyle(
                        fontSize: 16,
                        color: Constants.COLOR_THEME_BLACK,
                      ),
                      textAlign: TextAlign.center)
                ],
              ),
            ),
            SizedBox(height: Constants.DIMEN_PRIMARY_MARGIN),
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: Constants.DIMEN_PRIMARY_MARGIN / 2),
              child: Column(
                children: [
                  Text(Constants.STRING_REFERENCES,
                      style: TextStyle(
                        fontSize: 20,
                        color: Constants.COLOR_THEME_BLACK,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center),
                  Container(
                    width: screenWidth * 0.6,
                    child: Image.asset(
                      'assets/images/ptx_logo.png',
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> initVariables() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
  }
}
