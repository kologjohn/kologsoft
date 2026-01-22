/// Stub for dart:html on non-web platforms
/// This is used as a conditional import when running on mobile/desktop

class Blob {
  Blob(List<dynamic> parts, String type);
}

class Url {
  static String createObjectUrlFromBlob(Blob blob) {
    return '';
  }

  static void revokeObjectUrl(String url) {}
}

class Window {
  dynamic open(String url, String target) {
    return null;
  }

  void print() {}
}

class WindowBase {
  void print() {}
}

class AnchorElement {
  String href = '';
  String download = '';
  Map<String, String> style = {};

  void click() {}
}

class IFrameElement {
  String src = '';
  Map<String, String> style = {};
  WindowBase? contentWindow;
  Stream<dynamic> get onLoad => Stream.empty();
}

class Document {
  HtmlElement? body;

  dynamic createElement(String tag) {
    if (tag == 'iframe') {
      return IFrameElement();
    }
    return AnchorElement();
  }
}

class HtmlElement {
  List<dynamic> children = [];
}

final window = Window();
final document = Document();
