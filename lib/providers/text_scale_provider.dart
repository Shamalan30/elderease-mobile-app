import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Holds the user's chosen text size (Small/Medium/Large/Extra Large) as a
/// scale multiplier, and notifies the whole app to rebuild when it changes.
/// This is what makes the Settings "Text Size" option actually take effect
/// everywhere instead of just being saved and ignored.
class TextScaleProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  double _scale = 1.15; // default: Large

  double get scale => _scale;

  Future<void> load() async {
    _scale = await _storage.loadTextScale();
    notifyListeners();
  }

  Future<void> setScale(double newScale) async {
    _scale = newScale;
    notifyListeners();
    await _storage.saveTextScale(newScale);
  }

  String get label {
    if (_scale <= 0.95) return 'Small';
    if (_scale <= 1.05) return 'Medium';
    if (_scale <= 1.2) return 'Large';
    return 'Extra Large';
  }
}