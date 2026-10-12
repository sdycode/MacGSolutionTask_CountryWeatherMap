import '../../../../core/entities/cached.dart';
import '../../../../core/error/result.dart';
import '../entities/country.dart';
import '../entities/country_details.dart';

abstract interface class CountriesRepository {
  Future<Result<Cached<List<Country>>>> getCountries();

  Future<Result<CountryDetails>> getCountryDetails(String code);
}
