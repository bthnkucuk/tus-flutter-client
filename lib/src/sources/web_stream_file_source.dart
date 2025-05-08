import 'dart:async';
import 'dart:typed_data';
import '../options.dart';

/// StreamFileSource implements FileSource for Dart Streams.
/// This class handles reading data from streams in chunks and buffering it
/// for efficient access.
class StreamFileSource implements FileSource {
  final Stream<List<int>> _stream;
  late final StreamController<List<int>> _controller;
  late final StreamSubscription<List<int>> _subscription;

  Uint8List? _buffer;
  int _bufferOffset = 0;
  bool _done = false;
  bool _hasError = false;
  String? _errorMessage;

  StreamFileSource(this._stream) {
    _controller = StreamController<List<int>>();
    _subscription = _stream.listen(
      (data) => _controller.add(data),
      onError: (error) {
        _hasError = true;
        _errorMessage = error.toString();
        _controller.addError(error);
      },
      onDone: () {
        _done = true;
        _controller.close();
      },
    );
  }

  @override
  Future<Uint8List> read(int start, int end) async {
    if (_hasError) {
      throw Exception('Stream error: $_errorMessage');
    }

    if (start < _bufferOffset) {
      throw Exception("Requested data is before the reader's current offset");
    }

    return await _readUntilEnoughDataOrDone(start, end);
  }

  Future<Uint8List> _readUntilEnoughDataOrDone(int start, int end) async {
    final hasEnoughData = _buffer != null && end <= _bufferOffset + _buffer!.length;

    if (_done || hasEnoughData) {
      final value = _getDataFromBuffer(start, end);
      if (value == null) {
        throw Exception('No more data available');
      }
      return value;
    }

    // Read more data from the stream
    try {
      final data = await _controller.stream.first;
      final chunk = Uint8List.fromList(data);

      if (_buffer == null) {
        _buffer = chunk;
      } else {
        final newBuffer = Uint8List(_buffer!.length + chunk.length);
        newBuffer.setAll(0, _buffer!);
        newBuffer.setAll(_buffer!.length, chunk);
        _buffer = newBuffer;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      throw Exception('Error reading from stream: $e');
    }

    return await _readUntilEnoughDataOrDone(start, end);
  }

  Uint8List? _getDataFromBuffer(int start, int end) {
    if (_buffer == null) {
      throw Exception('cannot _getDataFromBuffer because _buffer is unset');
    }

    // Remove data from buffer before `start`
    if (start > _bufferOffset) {
      final newStart = start - _bufferOffset;
      final newBuffer = Uint8List(_buffer!.length - newStart);
      newBuffer.setAll(0, _buffer!.sublist(newStart));
      _buffer = newBuffer;
      _bufferOffset = start;
    }

    // If the buffer is empty after removing old data, all data has been read
    if (_done && _buffer!.isEmpty) {
      return null;
    }

    // Return the requested portion of the buffer
    final length = end - start;
    return _buffer!.sublist(0, length);
  }

  @override
  int get length {
    throw Exception('Stream length cannot be determined in advance');
  }

  @override
  void close() {
    _subscription.cancel();
    _controller.close();
  }
}
