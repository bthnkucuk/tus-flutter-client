import 'dart:typed_data';
import '../options.dart';

/// ArrayBufferViewFileSource implements FileSource for TypedData instances
/// (e.g. Uint8List, Int8List, etc.).
///
/// Note that the underlying data should not change once passed to tus-flutter-client
/// or it will lead to weird behavior.
class ArrayBufferViewFileSource implements FileSource {
  final TypedData _view;
  final int _length;

  ArrayBufferViewFileSource(this._view) : _length = _view.lengthInBytes;

  @override
  Future<Uint8List> read(int start, int end) async {
    end = end.clamp(0, _length); // ensure end is within bounds
    final byteLength = end - start;

    // Create a new Uint8List view of the underlying data
    final result = Uint8List(byteLength);
    final sourceData = _view.buffer.asUint8List();
    final startInBuffer = _view.offsetInBytes + start;

    for (var i = 0; i < byteLength; i++) {
      result[i] = sourceData[startInBuffer + i];
    }

    return result;
  }

  @override
  int get length => _length;

  @override
  void close() {
    // Nothing to do here since we don't need to release any resources.
  }
}
