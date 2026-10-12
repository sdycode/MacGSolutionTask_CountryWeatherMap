import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:country_weather_app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/api_config.dart';
import 'core/cache/cache_store.dart';
import 'core/di/injection.dart';
import 'features/weather/data/repositories/weather_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Hive.initFlutter();
  final cacheBox = await Hive.openBox('api_cache');
  final prefs = await SharedPreferences.getInstance();

  await configureDependencies(prefs: prefs, cacheBox: cacheBox);
  await getIt<CacheStore>().removeOlderThan(
    WeatherRepositoryImpl.keyPrefix,
    ApiConfig.weatherKeepFor,
  );

  runApp(const CountryWeatherApp());
}
