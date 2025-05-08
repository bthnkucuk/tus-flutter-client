import 'dart:io';
import 'dart:typed_data';
import '../options.dart';

/// BlobFileSource implements FileSource for File instances.
/// This is the primary file source for handling file uploads in Flutter.
class BlobFileSource implements FileSource {
  final File _file;
  final int _length;

  BlobFileSource(this._file) : _length = _file.lengthSync();

  @override
  Future<Uint8List> read(int start, int end) async {
    end = end.clamp(0, _length); // ensure end is within bounds
    final byteLength = end - start;

    final randomAccessFile = await _file.open(mode: FileMode.read);
    try {
      await randomAccessFile.setPosition(start);
      final bytes = await randomAccessFile.read(byteLength);
      return bytes;
    } finally {
      await randomAccessFile.close();
    }
  }

  @override
  int get length => _length;

  @override
  void close() {
    // Nothing to do here since we don't need to release any resources.
    // File handles are closed after each read operation.
  }
}
