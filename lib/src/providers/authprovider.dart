import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:codix_geofencing/src/models/dtos/userlogin.dart';

class AuthProvider {
  Future<LoginResponse> doLogin(String url, UserLogin userLoginObject, {Map body}) async {
      //final response = await http.get(variables.baseUrl + 'auth/login');
      //LoginResponse loginResponse = await createPost(variables.baseUrl + 'auth/login', body: userLogin.toMap());
      Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
      };

      return http.post(url, headers: requestHeaders, body: json.encode(body)).then((http.Response response) {
      final int statusCode = response.statusCode;

      if (statusCode == 200) {
        print('yes');
      } else {
       
      }

      if (statusCode == 404) {
        
        //throw new Exception("Error while fetching data");
      }
      return LoginResponse.fromJson(json.decode(response.body));
    }).catchError((e) {
      print("Got error: ${e.message}");
      //logger.d(e);
    });
  }
}