/// Web stub for path_provider and dart:io packages
/// This is used as a conditional import when running on web platform
/// where path_provider's getTemporaryDirectory and dart:io are not available

class Directory {
  final String path;
  Directory(this.path);
}

class File {
  final String path;
  File(this.path);
  
  Future<void> writeAsBytes(List<int> bytes) async {
    // No-op on web - we handle file operations differently
  }
}

/// Returns a dummy directory for web platform
/// On web, we don't use the file system - instead we use Blob/download
Future<Directory> getTemporaryDirectory() async {
  return Directory('/tmp');
}
