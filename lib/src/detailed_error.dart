import 'package:tus_flutter_client/src/options.dart' show HttpRequest, HttpResponse;

class DetailedError implements Exception {
  String message;
  HttpRequest? originalRequest;
  HttpResponse? originalResponse;
  Exception? causingError;

  DetailedError(this.message, {this.causingError, this.originalRequest, this.originalResponse}) {
    String errorMessage = message;

    if (causingError != null) {
      errorMessage += ', caused by ${causingError.toString()}';
    }

    if (originalRequest != null) {
      final requestId = originalRequest!.getHeader('X-Request-ID') ?? 'n/a';
      final method = originalRequest!.getMethod();
      final url = originalRequest!.getURL();
      final status = originalResponse?.getStatus() ?? 'n/a';
      final body = originalResponse?.getBody() ?? 'n/a';
      errorMessage +=
          ', originated from request (method: $method, url: $url, response code: $status, response text: $body, request id: $requestId)';
    }

    message = errorMessage;
  }

  @override
  String toString() => message;
}
