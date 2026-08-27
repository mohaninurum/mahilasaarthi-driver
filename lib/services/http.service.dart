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
    String langCode = "en";
    try {
      langCode = translator.activeLocale.languageCode;
    } catch (_) {
      langCode = "en";
    }
    final headers = <String, String>{
      HttpHeaders.acceptHeader: "application/json",
      "lang": langCode,
    };
    if (userToken.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = "Bearer $userToken";
    }
    return headers;
  }

  HttpService() {
    LocalStorageService.getPrefs();

    baseOptions = new BaseOptions(
      baseUrl: host,
      validateStatus: (status) {
        return status != null && status <= 599;
      },
      connectTimeout: 60000,
      receiveTimeout: 60000,
    );
    dio = new Dio(baseOptions);
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    try {
      dio.interceptors.add(getCacheManager().interceptor);
    } catch (e) {
      print("DioCacheManager init error: $e");
    }
    // Add interceptor for handling API requests/responses and 401 Unauthorized globally
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final skipAuth = options.extra["skipAuth"] == true;
          String langCode = "en";
          try {
            langCode = translator.activeLocale.languageCode;
          } catch (_) {
            langCode = "en";
          }
          options.headers[HttpHeaders.acceptHeader] = "application/json";
          options.headers["lang"] = langCode;
          if (!skipAuth) {
            final userToken = await AuthServices.getAuthBearerToken();
            if (userToken.isNotEmpty) {
              options.headers[HttpHeaders.authorizationHeader] =
                  "Bearer $userToken";
            }
          } else {
            options.headers.remove(HttpHeaders.authorizationHeader);
          }
          try {
            List<String> curlParts = ["curl -X ${options.method.toUpperCase()}"];
            options.headers.forEach((k, v) {
              if (k != 'cookie') {
                curlParts.add("-H '$k: $v'");
              }
            });
            if (options.data != null) {
              if (options.data is FormData) {
                curlParts.add("-d 'FormData...'");
              } else {
                try {
                  curlParts.add("-d '${jsonEncode(options.data)}'");
                } catch (_) {
                  curlParts.add("-d '${options.data}'");
                }
              }
            }
            curlParts.add("'${options.uri.toString()}'");
            print("\n==================== API CURL ====================");
            print(curlParts.join(" \\\n  "));
            print("==================================================\n");
          } catch (e) {
            print("Error generating cURL: $e");
          }
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          try {
            print("\n==================== API RESPONSE [${response.statusCode}] ====================");
            print("PATH: ${response.requestOptions.path}");
            try {
              print("RESPONSE BODY: ${jsonEncode(response.data)}");
            } catch (_) {
              print("RESPONSE BODY: ${response.data}");
            }
            print("=================================================================\n");
          } catch (e) {
            print("Error printing API response: $e");
          }

          if (response.statusCode == 401) {
            try {
              final path = response.requestOptions.path;
              final skipAuth = response.requestOptions.extra["skipAuth"] == true;
              // Public/bootstrap + auth flows must never wipe the session.
              final isPublicOrAuthEndpoint = skipAuth ||
                  path.contains('/app/settings') ||
                  path.contains('/app/emergency') ||
                  path.contains('/app/onboarding') ||
                  path.contains('/app/faqs') ||
                  path.contains('/login') ||
                  path.contains('/otp/') ||
                  path.contains('/register') ||
                  path.contains('/verify') ||
                  path.contains('/password/');

              // Only force logout when a clearly session-bound profile call fails.
              // Periodic/order/location 401s after idle must not kick the driver out.
              final isSessionCheckEndpoint = path.contains('/my/profile') ||
                  path.contains('/profile/update') ||
                  path.contains('/logout');

              if (!isPublicOrAuthEndpoint && isSessionCheckEndpoint) {
                final token = await AuthServices.getAuthBearerToken();
                if (token.isNotEmpty) {
                  print(
                      "401 Unauthorized for session path $path. Logging out user...");
                  await AuthServices.logout();
                  AppService()
                      .navigatorKey
                      .currentState
                      ?.pushNamedAndRemoveUntil(
                        AppRoutes.welcomeRoute,
                        (route) => false,
                      );
                } else {
                  print(
                      "401 Unauthorized for path $path but token is empty. Skipping auto-logout redirect.");
                }
              } else {
                print(
                    "401 on path $path — keeping local session (not a session-check endpoint).");
              }
            } catch (error) {
              print("Logout error on 401: $error");
            }
          }
          return handler.next(response);
        },
        onError: (DioError e, handler) {
          try {
            print("\n==================== API ERROR [${e.response?.statusCode}] ====================");
            print("PATH: ${e.requestOptions.path}");
            print("MESSAGE: ${e.message}");
            print("RESPONSE BODY: ${e.response?.data}");
            print("=================================================================\n");
          } catch (err) {
            print("Error printing API error: $err");
          }
          return handler.next(e);
        },
      ),
    );
  }

  static DioCacheManager? _cacheManager;

  DioCacheManager getCacheManager() {
    _cacheManager ??= DioCacheManager(
      CacheConfig(
        baseUrl: host,
        defaultMaxAge: Duration(hours: 1),
      ),
    );
    return _cacheManager!;
  }

  //for get api calls
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    bool includeHeaders = true,
    bool skipAuth = false,
  }) async {
    //preparing the api uri/url
    String uri = "$host$url";

    //preparing the post options if header is required
    final mOptions = !includeHeaders
        ? Options(extra: {"skipAuth": skipAuth})
        : Options(
            headers: await getHeaders(),
            extra: {"skipAuth": skipAuth},
          );

    Response response;
    try {
      response = await dio.get(
        uri,
        options: mOptions,
        queryParameters: queryParameters,
      );
    } on DioError catch (error) {
      response = formatDioExecption(error);
    }
    return response;
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

    Response response;
    try {
      response = await dio.post(
        uri,
        data: body,
        options: mOptions,
      );
    } on DioError catch (error) {
      response = formatDioExecption(error);
    }
    return response;
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
    Response response;
    try {
      response = await dio.patch(
        uri,
        data: body,
        options: Options(
          headers: await getHeaders(),
        ),
      );
    } on DioError catch (error) {
      response = formatDioExecption(error);
    }
    return response;
  }

  //for delete api calls
  Future<Response> delete(
    String url,
  ) async {
    String uri = "$host$url";
    Response response;
    try {
      response = await dio.delete(
        uri,
        options: Options(
          headers: await getHeaders(),
        ),
      );
    } on DioError catch (error) {
      response = formatDioExecption(error);
    }
    return response;
  }

  Response formatDioExecption(DioError ex) {
    if (ex.response != null) {
      return ex.response!;
    }
    var response = Response(requestOptions: ex.requestOptions);
    response.statusCode = 400;
    try {
      if (ex.type == DioErrorType.connectTimeout ||
          ex.type == DioErrorType.receiveTimeout ||
          ex.type == DioErrorType.sendTimeout) {
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
        "message": "Please check your internet connection and try again",
      };
    }

    return response;
  }
}
