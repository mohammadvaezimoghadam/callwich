import 'package:flutter/foundation.dart';

/// Global state manager for handling app-wide state changes
/// This follows the Git pattern for state management
class AppStateManager extends ChangeNotifier {
  static final AppStateManager _instance = AppStateManager._internal();
  factory AppStateManager() => _instance;
  AppStateManager._internal();

  // State flags for different operations
  bool _shouldReloadDashboard = false;
  bool _shouldReloadInventory = false;
  bool _shouldReloadProducts = false;
  bool _shouldReloadReports = false;

  // Getters for state flags
  bool get shouldReloadDashboard => _shouldReloadDashboard;
  bool get shouldReloadInventory => _shouldReloadInventory;
  bool get shouldReloadProducts => _shouldReloadProducts;
  bool get shouldReloadReports => _shouldReloadReports;

  /// Trigger reload for all bottom navigation pages
  void triggerAllPagesReload() {
    _shouldReloadDashboard = true;
    _shouldReloadInventory = true;
    _shouldReloadProducts = true;
    _shouldReloadReports = true;
    notifyListeners();
  }

  /// Reset reload flags after pages have been reloaded
  void resetReloadFlags() {
    _shouldReloadDashboard = false;
    _shouldReloadInventory = false;
    _shouldReloadProducts = false;
    _shouldReloadReports = false;
    
    notifyListeners();
  }

  /// Reset specific page reload flag
  void resetPageReloadFlag(String pageName) {
    switch (pageName.toLowerCase()) {
      case 'dashboard':
        _shouldReloadDashboard = false;
        break;
      case 'inventory':
        _shouldReloadInventory = false;
        break;
      case 'products':
        _shouldReloadProducts = false;
        break;
      case 'reports':
        _shouldReloadReports = false;
        break;
    }
    notifyListeners();
  }

  /// Check if any page needs reload
  bool get hasAnyReloadPending {
    return _shouldReloadDashboard || 
           _shouldReloadInventory || 
           _shouldReloadProducts || 
           _shouldReloadReports;
  }
}