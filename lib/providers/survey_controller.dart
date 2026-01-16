

import '../models/workspace_registration.dart';
import 'Datafeed.dart';

class Survey extends  Datafeed {
  WorkspaceRegistration? selected;
  void setWorkspace(WorkspaceRegistration ws) {
    selected = ws;
    notifyListeners();
  }
  void clear() {
    selected = null;
    notifyListeners();
  }
}


