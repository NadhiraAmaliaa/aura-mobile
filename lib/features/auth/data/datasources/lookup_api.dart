import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/university_model.dart';

part 'lookup_api.g.dart';

/// Public reference-data endpoints used by the login screen. Paths are relative
/// to the versioned base URL and start with a leading slash (see auth_api.dart).
@RestApi()
abstract class LookupApi {
  factory LookupApi(Dio dio, {String baseUrl}) = _LookupApi;

  @GET('/universities')
  Future<List<University>> universities();
}
