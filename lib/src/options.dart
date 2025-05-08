import 'dart:typed_data' show Uint8List;

import 'package:tus_flutter_client/src/detailed_error.dart' show DetailedError;

/// TUS protocol versions
const String protocolTusV1 = 'tus-v1';
const String protocolIetfDraft03 = 'ietf-draft-03';
const String protocolIetfDraft05 = 'ietf-draft-05';

/// Represents a file from React Native's image picker
class ReactNativeFile {
  final String uri;
  final String? name;
  final String? size;
  final Map<String, dynamic>? exif;

  ReactNativeFile({required this.uri, this.name, this.size, this.exif});
}

/// Represents a reference to a file on disk
class PathReference {
  final String path;
  final int? start;
  final int? end;

  PathReference({required this.path, this.start, this.end});
}

/// Represents the input types that can be uploaded
typedef UploadInput = dynamic; // File, Uint8List, Stream<List<int>>, PathReference, ReactNativeFile

/// Callback for upload progress
typedef ProgressCallback = void Function(int bytesSent, int? bytesTotal);

/// Callback for chunk completion
typedef ChunkCompleteCallback = void Function(int chunkSize, int bytesAccepted, int? bytesTotal);

/// Callback for upload success
typedef SuccessCallback = void Function(OnSuccessPayload payload);

/// Callback for upload error
typedef ErrorCallback = void Function(Exception error);

/// Callback for retry decision
typedef ShouldRetryCallback = bool Function(DetailedError error, int retryAttempt, UploadOptions options);

/// Callback for upload URL availability
typedef UploadUrlAvailableCallback = Future<void> Function();

/// Callback for before request
typedef BeforeRequestCallback = Future<void> Function(HttpRequest req);

/// Callback for after response
typedef AfterResponseCallback = Future<void> Function(HttpRequest req, HttpResponse res);

/// Payload returned on successful upload
class OnSuccessPayload {
  final HttpResponse lastResponse;

  OnSuccessPayload({required this.lastResponse});
}

/// Represents a previously stored upload
class PreviousUpload {
  final int? size;
  final Map<String, String> metadata;
  final String creationTime;
  final String? uploadUrl;
  final List<String>? parallelUploadUrls;
  final String urlStorageKey;

  PreviousUpload({
    this.size,
    required this.metadata,
    required this.creationTime,
    this.uploadUrl,
    this.parallelUploadUrls,
    required this.urlStorageKey,
  });
}

/// Interface for storing upload URLs
abstract class UrlStorage {
  Future<List<PreviousUpload>> findAllUploads();
  Future<List<PreviousUpload>> findUploadsByFingerprint(String fingerprint);
  Future<void> removeUpload(String urlStorageKey);
  Future<String?> addUpload(String fingerprint, PreviousUpload upload);
}

/// Interface for reading files
abstract class FileReader {
  Future<FileSource> openFile(UploadInput input, int chunkSize);
}

abstract class FileSource {
  Future<Uint8List> read(int start, int end);
  int get length;
  void close();
}

/// Interface for HTTP requests
abstract class HttpRequest {
  String getMethod();
  String getURL();
  void setHeader(String header, String value);
  String? getHeader(String header);
  void setProgressHandler(void Function(int bytesSent) handler);
  Future<HttpResponse> send([dynamic body]);
  Future<void> abort();
  dynamic getUnderlyingObject();
}

/// Interface for HTTP responses
abstract class HttpResponse {
  int getStatus();
  String? getHeader(String header);
  String getBody();
  dynamic getUnderlyingObject();
}

/// Interface for HTTP stack
abstract class HttpStack {
  HttpRequest createRequest(String method, String url);
  String getName();
}

/// Main configuration options for uploads
class UploadOptions {
  final String? endpoint;
  final String? uploadUrl;
  final Map<String, String> metadata;
  final Map<String, String> metadataForPartialUploads;
  final Future<String?> Function(UploadInput file, UploadOptions options) fingerprint;
  final int? uploadSize;
  final ProgressCallback? onProgress;
  final ChunkCompleteCallback? onChunkComplete;
  final SuccessCallback? onSuccess;
  final ErrorCallback? onError;
  final ShouldRetryCallback? onShouldRetry;
  final UploadUrlAvailableCallback? onUploadUrlAvailable;
  final bool overridePatchMethod;
  final Map<String, String> headers;
  final bool addRequestId;
  final BeforeRequestCallback? onBeforeRequest;
  final AfterResponseCallback? onAfterResponse;
  final int chunkSize;
  final List<int> retryDelays;
  final int parallelUploads;
  final List<Map<String, int>>? parallelUploadBoundaries;
  final bool storeFingerprintForResuming;
  final bool removeFingerprintOnSuccess;
  final bool uploadLengthDeferred;
  final bool uploadDataDuringCreation;
  final UrlStorage urlStorage;
  final FileReader fileReader;
  final HttpStack httpStack;
  final String protocol;

  UploadOptions({
    this.endpoint,
    this.uploadUrl,
    required this.metadata,
    required this.metadataForPartialUploads,
    required this.fingerprint,
    this.uploadSize,
    this.onProgress,
    this.onChunkComplete,
    this.onSuccess,
    this.onError,
    this.onShouldRetry,
    this.onUploadUrlAvailable,
    required this.overridePatchMethod,
    required this.headers,
    required this.addRequestId,
    this.onBeforeRequest,
    this.onAfterResponse,
    required this.chunkSize,
    required this.retryDelays,
    required this.parallelUploads,
    this.parallelUploadBoundaries,
    required this.storeFingerprintForResuming,
    required this.removeFingerprintOnSuccess,
    required this.uploadLengthDeferred,
    required this.uploadDataDuringCreation,
    required this.urlStorage,
    required this.fileReader,
    required this.httpStack,
    required this.protocol,
  });
}
