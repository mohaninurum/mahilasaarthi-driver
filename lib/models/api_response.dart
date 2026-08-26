class ApiResponse {
  int get totalDataCount => (body is Map && body["meta"] != null && body["meta"]["total"] != null) ? body["meta"]["total"] : 0;
  int get totalPageCount => (body is Map && body["pagination"] != null && body["pagination"]["total_pages"] != null) ? body["pagination"]["total_pages"] : 0;
  List get data {
    if (body is List) {
      return body as List;
    } else if (body is Map && body.containsKey("data")) {
      return body["data"] is List ? body["data"] : [];
    }
    return [];
  }
  // Just a way of saying there was no error with the request and response return
  bool get allGood => errors == null || errors?.length == 0;
  bool hasError() => errors != null && ((errors?.length ?? 0) > 0);
  bool hasData() => data.isNotEmpty;
  int? code;
  String? message;
  dynamic body;
  List? errors;

  ApiResponse({
    this.code,
    this.message,
    this.body,
    this.errors,
  });

  factory ApiResponse.fromResponse(dynamic response) {
    //
    int code = response.statusCode ?? 500;
    dynamic body = response.data; // Would mostly be a Map
    List errors = [];
    String message = "";

    try {
      if (body is Map) {
        if (body.containsKey("message") &&
            body["message"] != null &&
            body["message"].toString().trim().isNotEmpty) {
          message = body["message"].toString();
        } else if (body.containsKey("error") && body["error"] != null) {
          if (body["error"] is String &&
              body["error"].toString().trim().isNotEmpty) {
            message = body["error"].toString();
          } else if (body["error"] is Map &&
              body["error"].containsKey("message") &&
              body["error"]["message"] != null) {
            message = body["error"]["message"].toString();
          }
        }
      } else if (body is String && body.trim().isNotEmpty) {
        message = body;
      }
    } catch (error) {
      print("Message reading error ==> $error");
    }

    if (code < 200 || code >= 300) {
      if (message.isEmpty) {
        message = (response.statusMessage != null &&
                response.statusMessage.toString().trim().isNotEmpty)
            ? response.statusMessage.toString()
            : "Whoops! Something went wrong, please contact support.";
      }
      errors.add(message);
    }

    return ApiResponse(
      code: code,
      message: message,
      body: body,
      errors: errors,
    );
  }
}
