class ApiConfig {
  const ApiConfig._();

  static const _worldBank = 'https://api.worldbank.org/v2';

  static const countriesUrl = '$_worldBank/country?format=json&per_page=300';

  static String populationUrl(String code) =>
      '$_worldBank/country/$code/indicator/SP.POP.TOTL?format=json&mrnev=1';

  static String currencyUrl(String code) =>
      'https://countriesnow.space/api/v0.1/countries/currency/q?iso2=$code';

  static String weatherUrl(double latitude, double longitude) =>
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code';

  static String flagUrl(String size, String code) =>
      'https://flagcdn.com/$size/${code.toLowerCase()}.png';

  static const mapTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const appPackageName = 'com.country.mapapi';

  static const requestTimeout = Duration(seconds: 15);

  static const countriesCacheAge = Duration(hours: 24);
  static const countryInfoCacheAge = Duration(days: 7);
  static const weatherCacheAge = Duration(minutes: 15);
  static const weatherKeepFor = Duration(days: 1);
}
