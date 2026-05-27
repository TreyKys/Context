import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayService {
  static final OverlayService _instance = OverlayService._internal();
  factory OverlayService() => _instance;
  OverlayService._internal();

  Future<bool> isPermissionGranted() async {
    try {
      return await FlutterOverlayWindow.isPermissionGranted();
    } catch (_) {
      return false;
    }
  }

  Future<void> requestPermission(BuildContext context) async {
    try {
      final granted = await FlutterOverlayWindow.isPermissionGranted();
      if (!granted) {
        await FlutterOverlayWindow.requestPermission();
      }
    } catch (_) {}
  }

  Future<void> showOverlay() async {
    try {
      final granted = await FlutterOverlayWindow.isPermissionGranted();
      if (!granted) return;

      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: 'Context Dictionary',
        overlayContent: 'Floating search active',
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.auto,
        width: WindowSize.matchParent,
        height: 180,
      );
    } catch (_) {}
  }

  Future<void> hideOverlay() async {
    try {
      final active = await FlutterOverlayWindow.isActive();
      if (active) await FlutterOverlayWindow.closeOverlay();
    } catch (_) {}
  }
}
