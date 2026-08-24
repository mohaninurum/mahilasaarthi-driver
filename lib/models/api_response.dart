class ApiResponse {
  int get totalDataCount => body["meta"]["total"];
  int get totalPageCount => body["pagination"]["total_pages"];
  List get data => body["data"] ?? [];
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
      if (body is Map && body.containsKey("message")) {
        message = body["message"]?.toString() ?? "";
      } else if (body is String) {
        message = body;
      }
    } catch (error) {
      print("Message reading error ==> $error");
    }

    if (code != 200) {
      if (message.isEmpty) {
        message = "Whoops! Something went wrong, please contact support.";
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
