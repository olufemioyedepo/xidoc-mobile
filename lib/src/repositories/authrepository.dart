import 'dart:async';
import 'package:codix_geofencing/src/models/dtos/userlogin.dart';
import 'package:codix_geofencing/src/providers/authprovider.dart';
import 'package:codix_geofencing/src/helpers/variables.dart' as environment_variables;

class AuthRepository {
  final authApiProvider = AuthProvider();

  Future<LoginResponse> loginAction(UserLogin userLogin)
  {
    return authApiProvider.doLogin(environment_variables.baseUrl + 'auth/login', userLogin);
  }

  Future<LoginResponse> login(UserLogin userLoginObject) =>
    authApiProvider.doLogin(environment_variables.baseUrl + 'auth/login', userLoginObject);
}