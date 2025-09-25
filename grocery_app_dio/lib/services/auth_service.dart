
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://dummyjson.com",
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      "Content-Type": "application/json"
    }
  ));

  AuthService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
            String? token = await getToken();
            if(token != null){
              options.headers["Authorization"] = "Bearer $token";
            }
            return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException ex, handler) {
            if(ex.response?.statusCode == 401){
              print("UnAuthorized Access");
            }
            return handler.next(ex);
        }
      )
    );
  }

  Future<void> saveToken(String token) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setString("token", token);
  }

  Future<void> logout() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    await sharedPref.remove("token");
  }

  Future<String?> getToken() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    return sharedPref.getString("token");
  }

  Future<String?> login(String username, String password) async{
    try{
      Response response = await _dio.post("/auth/login", data: {
        "username": username,
        "password": password
      });

      if(response.statusCode == 200) {
        String token = response.data["accessToken"];
        await saveToken(token);
        return token;
      }
    } on DioException catch(ex) {
      throw Exception(_handleDioError(ex));
    }
    return null;
  }

  String _handleDioError(DioException ex){
    if(ex.response != null){
      return ex.response!.data["message"] ?? "Something went wrong";
    }
    return "Network Error!!! check internet connection";
  }

}