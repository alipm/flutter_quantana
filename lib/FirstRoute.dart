import 'package:flutter/material.dart';
import 'package:flutterquantana/src/api/api_keys.dart';
import 'package:flutterquantana/src/api/weather_api_client.dart';
import 'package:flutterquantana/src/bloc/weather_bloc.dart';
import 'package:flutterquantana/src/repository/weather_repository.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FirstRoute extends StatefulWidget{
  final WeatherRepository weatherRepository = WeatherRepository(
      weatherApiClient: WeatherApiClient(
          httpClient: http.Client(), apiKey: ApiKey.OPEN_WEATHER_MAP));

  @override
  _FirstRouteScreenState createState() => _FirstRouteScreenState();
}


class _FirstRouteScreenState extends State<FirstRoute> {
  WeatherBloc _weatherBloc;
  String _cityName = 'hyderabad';
  AnimationController _fadeController;
  Animation<double> _fadeAnimation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: TextStyle(
                  color: Colors.white,
            ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Material(
        child: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
              color: AppStateContainer.of(context).theme.primaryColor),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: BlocBuilder(
                bloc: _weatherBloc,
                builder: (_, WeatherState weatherState) {
                  if (weatherState is WeatherLoaded) {
                    this._cityName = weatherState.weather.cityName;
                    _fadeController.reset();
                    _fadeController.forward();
                    return WeatherWidget(
                      weather: weatherState.weather,
                    );
                  } else if (weatherState is WeatherError ||
                      weatherState is WeatherEmpty) {
                    String errorText =
                        'There was an error fetching weather data';
                    if (weatherState is WeatherError) {
                      if (weatherState.errorCode == 404) {
                        errorText =
                        'We have trouble fetching weather for $_cityName';
                      }
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 24,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          errorText,
                          style: TextStyle(
                              color: AppStateContainer.of(context)
                                  .theme
                                  .accentColor),
                        ),
                        FlatButton(
                          child: Text(
                            "Try Again",
                            style: TextStyle(
                                color: AppStateContainer.of(context)
                                    .theme
                                    .accentColor),
                          ),
                          onPressed: _fetchWeatherWithCity,
                        )
                      ],
                    );
                  } else if (weatherState is WeatherLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor:
                        AppStateContainer.of(context).theme.primaryColor,
                      ),
                    );
                  }
                }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
//        onPressed: ,//        tooltip: ,
        child: Icon(Icons.timelapse),
      ),
    );
  }
}