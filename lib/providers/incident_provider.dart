import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/incident.dart';
import '../services/incident_service.dart';

class IncidentProvider extends ChangeNotifier {
  final _svc = IncidentService();
  StreamSubscription<List<Incident>>? _sub;
  String? _uid;

  List<Incident> _all = [];
  bool loading = false;
  String? error;

  // Filters
  String search = '';
  String? category;
  String? status;
  bool mineOnly = false;

  /// Called by ChangeNotifierProxyProvider whenever the auth state changes.
  void bind(User? user, bool verified) {
    final uid = verified ? user?.uid : null;
    if (uid == _uid) return;
    _uid = uid;
    _sub?.cancel();
    _all = [];
    search = '';
    category = null;
    status = null;
    mineOnly = false;
    error = null;
    if (uid == null) {
      loading = false;
      return;
    }
    loading = true;
    _sub = _svc.stream().listen((list) {
      _all = list;
      loading = false;
      error = null;
      notifyListeners();
    }, onError: (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    });
  }

  List<Incident> get incidents {
    final q = search.trim().toLowerCase();
    return _all.where((i) {
      if (category != null && i.category != category) return false;
      if (status != null && i.status != status) return false;
      if (mineOnly && i.reporterId != _uid) return false;
      if (q.isNotEmpty &&
          !(i.title.toLowerCase().contains(q) ||
              i.description.toLowerCase().contains(q) ||
              i.location.toLowerCase().contains(q))) {
        return false;
      }
      return true;
    }).toList();
  }

  Incident? byId(String id) {
    for (final i in _all) {
      if (i.id == id) return i;
    }
    return null;
  }

  void setSearch(String v) {
    search = v;
    notifyListeners();
  }

  void setCategory(String? v) {
    category = v;
    notifyListeners();
  }

  void setStatus(String? v) {
    status = v;
    notifyListeners();
  }

  void setMineOnly(bool v) {
    mineOnly = v;
    notifyListeners();
  }

  Future<void> submit({
    required String title,
    required String description,
    required String category,
    required String location,
    required User user,
    File? image,
  }) {
    final incident = Incident(
      id: '',
      title: title,
      description: description,
      category: category,
      location: location,
      status: 'Submitted',
      reporterId: user.uid,
      reporterEmail: user.email ?? '',
      createdAt: DateTime.now(),
    );
    return _svc.create(incident, image);
  }

  Future<void> updateStatus(String id, String status) =>
      _svc.updateStatus(id, status);

  Future<void> delete(String id) => _svc.delete(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
