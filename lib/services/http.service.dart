import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:mahilasaarthi/constants/api.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth.service.dart';
import 'local_storage.service.dart';
import 'package:mahilasaarthi/constants/app_routes.dart';
import 'package:mahilasaarthi/services/app.service.dart';

class HttpService {
  String host = Api.baseUrl;
  late BaseOptions baseOptions;
  late Dio dio;
  late SharedPreferences prefs;

  Future<Map<String, String>> getHeaders() async {
    final userToken = await AuthServices.getAuthBearerToken();
    return {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $userToken",
      "lang": translator.activeLocale.languageCode,
    };
  }

  HttpService() {
    LocalStorageService.getPrefs();

    baseOptions = new BaseOptions(
      baseUrl: host,
      validateStatus: (status) {
        return status != null && status <= 500;
      },
      // connectTimeout: 300,
    );
    dio = new Dio(baseOptions);
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    dio.interceptors.add(getCacheManager().interceptor);
    dio.interceptors.add(CurlLoggerInterceptor());
    
    // Add interceptor for handling API responses and 401 Unauthorized globally
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) async {
          if (kDebugMode) {
            print("🟢 API RESPONSE [${response.statusCode}] => ${response.requestOptions.path}");
            print("Data: ${response.data}");
            print("----------------------------------------------------------");
          }

          if (response.statusCode == 401) {
            try {
              final path = response.requestOptions.path;
              bool isAuthEndpoint = path.contains('/login') || path.contains('/otp/') || path.contains('/register');
              
              if (!isAuthEndpoint) {
                await AuthServices.logout();
                AppService().navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      AppRoutes.welcomeRoute,
                      (route) => false,
                    );
              }
            } catch (error) {
              print("Logout error on 401: $error");
            }
          }
          return handler.next(response);
        },
        onError: (DioError e, handler) {
          if (kDebugMode) {
            print("🔴 API ERROR [${e.response?.statusCode}] => ${e.requestOptions.path}");
            print("Message: ${e.message}");
            print("Data: ${e.response?.data}");
            print("----------------------------------------------------------");
          }
          return handler.next(e);
        },
      ),
    );
  }

  DioCacheManager getCacheManager() {
    return DioCacheManager(
      CacheConfig(
        baseUrl: host,
        defaultMaxAge: Duration(hours: 1),
      ),
    );
  }

  //for get api calls
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    bool includeHeaders = true,
  }) async {
    //preparing the api uri/url
    String uri = "$host$url";

    //preparing the post options if header is required
    final mOptions = !includeHeaders
        ? null
        : Options(
            headers: await getHeaders(),
          );

    return dio.get(
      uri,
      options: mOptions,
      queryParameters: queryParameters,
    );
  }

  //for post api calls
  Future<Response> post(
    String url,
    body, {
    bool includeHeaders = true,
  }) async {
    //preparing the api uri/url
    String uri = "$host$url";

    //preparing the post options if header is required
    final mOptions = !includeHeaders
        ? null
        : Options(
            headers: await getHeaders(),
          );

    return dio.post(
      uri,
      data: body,
      options: mOptions,
    );
  }

  //for post api calls with file upload
  Future<Response> postWithFiles(
    String url,
    body, {
    bool includeHeaders = true,
  }) async {
    //preparing the api uri/url
    String uri = "$host$url";
    //preparing the post options if header is required
    final mOptions = !includeHeaders
        ? null
        : Options(
            headers: await getHeaders(),
          );

    Response response;

    try {
      response = await dio.post(
        uri,
        data: FormData.fromMap(body),
        options: mOptions,
      );
    } on DioError catch (error) {
      response = formatDioExecption(error);
    }

    return response;
  }

  Future<Response> postCustomFiles(
    String url,
    body, {
    FormData? formData,
    bool includeHeaders = true,
  }) async {
    //preparing the api uri/url
    String uri = "$host$url";
    //preparing the post options if header is required
    final mOptions = !includeHeaders
        ? null
        : Options(
            headers: await getHeaders(),
          );

    Response response;

    try {
      response = await dio.post(
        uri,
        data: formData != null ? formData : FormData.fromMap(body),
        options: mOptions,
      );
    } on DioError catch (error) {
      response = formatDioExecption(error);
    }

    return response;
  }

  //for patch api calls
  Future<Response> patch(String url, Map<String, dynamic> body) async {
    String uri = "$host$url";
    return dio.patch(
      uri,
      data: body,
      options: Options(
        headers: await getHeaders(),
      ),
    );
  }

  //for delete api calls
  Future<Response> delete(
    String url,
  ) async {
    String uri = "$host$url";
    return dio.delete(
      uri,
      options: Options(
        headers: await getHeaders(),
      ),
    );
  }

  Response formatDioExecption(DioError ex) {
    var response = Response(requestOptions: ex.requestOptions);
    response.statusCode = 400;
    try {
      if (ex.type == DioErrorType.connectTimeout) {
        response.data = {
          "message":
              "Connection timeout. Please check your internet connection and try again",
        };
      } else {
        response.data = {
          "message": "Please check your internet connection and try again",
        };
      }
    } catch (error) {
      response.statusCode = 400;
      response.data = {
        "message": (error is Map && error.containsKey("message"))
            ? "${error["message"]}"
            : "Please check your internet connection and try again",
      };
    }

    return response;
  }
}

class CurlLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      if (kDebugMode) {
        print(" ");
        print("┌──────────────────────────────────────────────────────────");
        print("│ Curl command for: ${options.method.toUpperCase()} ${options.path}");
        print("├──────────────────────────────────────────────────────────");
        print(toCurl(options));
        print("└──────────────────────────────────────────────────────────");
        print(" ");
      }
    } catch (e) {
      print("Error generating curl: $e");
    }
    super.onRequest(options, handler);
  }

  String toCurl(RequestOptions options) {
    List<String> components = ['curl'];

    // Method
    components.add('-X ${options.method.toUpperCase()}');

    // Headers
    options.headers.forEach((k, v) {
      if (k != 'cookie') {
        components.add('-H "$k: $v"');
      }
    });

    // Data / Body
    if (options.data != null) {
      var data = options.data;
      if (data is FormData) {
        for (var field in data.fields) {
          components.add('-F "${field.key}=${field.value}"');
        }
        for (var file in data.files) {
          components.add('-F "${file.key}=@${file.value.filename ?? 'file'}"');
        }
      } else if (data is Map || data is List) {
        try {
          final jsonString = json.encode(data);
          components.add('-d \'$jsonString\'');
        } catch (_) {
          components.add('-d \'${data.toString()}\'');
        }
      } else {
        components.add('-d \'${data.toString()}\'');
      }
    }

    // URL
    var url = options.path;
    if (options.queryParameters.isNotEmpty) {
      final queryStr = options.queryParameters.entries
          .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value.toString())}')
          .join('&');
      if (url.contains('?')) {
        url += '&$queryStr';
      } else {
        url += '?$queryStr';
      }
    }

    if (!url.startsWith('http')) {
      String baseUrl = options.baseUrl;
      if (baseUrl.endsWith('/') && url.startsWith('/')) {
        url = baseUrl + url.substring(1);
      } else if (!baseUrl.endsWith('/') && !url.startsWith('/')) {
        url = '$baseUrl/$url';
      } else {
        url = baseUrl + url;
      }
    }

    components.add('"$url"');

    return components.join(' \\\n  ');
  }
}
