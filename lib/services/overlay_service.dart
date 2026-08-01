import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// True on OEM skins that gate overlays behind an *extra*, vendor-specific
  /// permission on top of SYSTEM_ALERT_WINDOW — "Display pop-up windows while
  /// running in background" on MIUI, similar wording on ColorOS/FuntouchOS.
  ///
  /// There is no manifest permission for this and no API to request it: it can
  /// only be toggled by hand in the vendor's own permission manager. Without it
  /// the overlay silently never appears even though isPermissionGranted()
  /// returns true, which users report as "the bubble is broken".
  Future<bool> needsVendorOverlayPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      final manufacturer = await _manufacturer();
      const gated = {'xiaomi', 'redmi', 'poco', 'oppo', 'realme', 'vivo', 'iqoo'};
      return gated.contains(manufacturer.toLowerCase().trim());
    } catch (_) {
      return false;
    }
  }

  Future<String> _manufacturer() async {
    const channel = MethodChannel('com.context.dictv1/device');
    final value = await channel.invokeMethod<String>('manufacturer');
    return value ?? '';
  }

  /// Opens this app's system settings page, the closest reliable jumping-off
  /// point for the vendor permission screen (deep links into MIUI's own
  /// permission editor are undocumented and break between versions).
  Future<void> openAppSettings() async {
    try {
      const channel = MethodChannel('com.context.dictv1/device');
      await channel.invokeMethod('openAppSettings');
    } catch (_) {}
  }
}
