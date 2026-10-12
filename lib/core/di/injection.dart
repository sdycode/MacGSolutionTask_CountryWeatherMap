import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/firebase_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/account_cubit.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/forgot_password_cubit.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/auth/presentation/cubit/sign_up_cubit.dart';
import '../../features/auth/presentation/cubit/verify_email_cubit.dart';
import '../../features/countries/data/datasources/countries_remote_data_source.dart';
import '../../features/countries/data/repositories/countries_repository_impl.dart';
import '../../features/countries/data/repositories/recent_search_repository_impl.dart';
import '../../features/countries/domain/entities/country.dart';
import '../../features/countries/domain/repositories/countries_repository.dart';
import '../../features/countries/domain/repositories/recent_search_repository.dart';
import '../../features/countries/domain/usecases/add_recent_search.dart';
import '../../features/countries/presentation/cubit/countries_cubit.dart';
import '../../features/countries/presentation/cubit/country_details_cubit.dart';
import '../../features/favorites/data/favorites_repository_impl.dart';
import '../../features/favorites/domain/favorites_repository.dart';
import '../../features/weather/data/datasources/weather_remote_data_source.dart';
import '../../features/weather/data/repositories/weather_repository_impl.dart';
import '../../features/weather/domain/repositories/weather_repository.dart';
import '../../features/weather/presentation/cubit/weather_cubit.dart';
import '../cache/cache_store.dart';
import '../network/api_client.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({
  required SharedPreferences prefs,
  required Box cacheBox,
}) async {
  await getIt.reset();

  getIt
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton<CacheStore>(CacheStore(cacheBox))
    ..registerLazySingleton<http.Client>(http.Client.new)
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt()))
    ..registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  getIt
    ..registerLazySingleton<AuthRepository>(
      () => FirebaseAuthRepository(getIt()),
    )
    ..registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<RecentSearchRepository>(
      () => RecentSearchRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => CountriesRemoteDataSource(getIt()))
    ..registerLazySingleton<CountriesRepository>(
      () => CountriesRepositoryImpl(getIt(), getIt()),
    )
    ..registerLazySingleton(() => WeatherRemoteDataSource(getIt()))
    ..registerLazySingleton<WeatherRepository>(
      () => WeatherRepositoryImpl(getIt(), getIt()),
    )
    ..registerFactory(() => AddRecentSearch(getIt()));

  getIt
    ..registerLazySingleton(() => AuthCubit(getIt()))
    ..registerFactory(() => LoginCubit(getIt()))
    ..registerFactory(() => SignUpCubit(getIt()))
    ..registerFactory(() => ForgotPasswordCubit(getIt()))
    ..registerFactory(() => VerifyEmailCubit(getIt()))
    ..registerFactory(() => AccountCubit(getIt(), getIt(), getIt()))
    ..registerFactory(() => CountriesCubit(getIt(), getIt(), getIt(), getIt()))
    ..registerFactoryParam<CountryDetailsCubit, Country, void>(
      (country, _) => CountryDetailsCubit(country, getIt(), getIt()),
    )
    ..registerFactory(() => WeatherCubit(getIt()));
}
