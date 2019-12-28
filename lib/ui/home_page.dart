import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../util/utility.dart' as util;

class HomeApp extends StatefulWidget {
  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  String _cityEntered;
  Future<Map> getWeather(String appId, String city) async {
    String apiUrl =
        'http://api.openweathermap.org/data/2.5/weather?q=$city&appId=${util.appId}&units=metric';
    http.Response response = await http.get(apiUrl);
    return json.decode(response.body);
  }

  Widget updateTempWidget(String city) {
    final mediaQuery = MediaQuery.of(context);
    return FutureBuilder(
      future: getWeather(util.appId, city == null ? util.defaultCity : city),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            Map content = snapshot.data;
            var temp = content['main']['temp'];
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: mediaQuery.size.height * 0.1),
                    alignment: Alignment.center,
                    child: content['main']['temp'] < 15
                        ? Image.asset('images/flakes.png')
                        : Image.asset('images/sun_cloud.png'),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: (mediaQuery.size.width) * 0.1,
                      top: (mediaQuery.size.height) * 0.1,
                    ),
                    //alignment: Alignment.center,
                    child: ListTile(
                      title: Text(
                        content['main']['temp'].toString() + '\u00b0C',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: ListTile(
                        title: Text(
                          "Humidity:${content['main']['humidity']}\u00b0C\n"
                          "Min:${content['main']['temp_min']}\u00b0C\n"
                          "Max:${content['main']['temp_max']}\u00b0C",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: (temp > 0)
                            ? Image.asset('images/twenty.png')
                            : Image.asset('images/minus.png'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future _goToNextScreen(BuildContext context) async {
    Map results = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return ChangeCity();
        },
      ),
    );
    if (results != null && results.containsKey('enter')) {
      _cityEntered = results['enter'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text(
        'WeatherApp',
      ),
      backgroundColor: Colors.red,
      actions: <Widget>[
        IconButton(
          onPressed: () => _goToNextScreen(context),
          icon: Icon(Icons.search),
        )
      ],
    );
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: appBar,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(
          Icons.search,
          color: Colors.black,
        ),
        onPressed: () => _goToNextScreen(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset(
              './images/winter.jpg',
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            right: mediaQuery.size.width * 0.075,
            top: mediaQuery.size.height * 0.025,
            child: Container(
              child: Text(
                '${_cityEntered == null ? util.defaultCity : _cityEntered}',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 25,
                  fontStyle: FontStyle.italic,
                ),
              ),
              alignment: Alignment.topRight,
            ),
          ),
          Container(
            child: updateTempWidget(_cityEntered),
          ),
        ],
      ),
    );
  }
}

class ChangeCity extends StatelessWidget {
  var _cityFieldController = new TextEditingController();
  final appBar = AppBar(
    backgroundColor: Colors.red,
    title: Text('Change City!'),
    centerTitle: true,
  );
  @override
  Widget build(BuildContext context) {
    //final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset(
              'images/city.jpg',
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          ListView(
            children: <Widget>[
              ListTile(
                title: TextField(
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  decoration: InputDecoration(
                    hintText: 'Enter City',
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  controller: _cityFieldController,
                  keyboardType: TextInputType.text,
                ),
              ),
              ListTile(
                title: FlatButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      {
                        'enter': _cityFieldController.text,
                      },
                    );
                  },
                  child: Text(
                    'Get Weather!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  color: Colors.redAccent,
                  textColor: Colors.white,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
