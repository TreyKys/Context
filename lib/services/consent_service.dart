import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google User Messaging Platform (UMP) consent, required before requesting
/// ads for users in the EEA/UK. Outside those regions the calls are effectively
/// no-ops, so this is safe to run for everyone.
///
/// Flow (per Google's guidance):
///   1. requestConsentInfoUpdate — fetch the latest consent state
///   2. loadAndShowConsentFormIfRequired — show the form only when required
///   3. only request ads once canRequestAds() is true
class ConsentService {
  ConsentService._();
  static final ConsentService instance = ConsentService._();

  /// Requests the latest consent info and shows the consent form if required.
  /// Completes when consent has been gathered (or was not required / failed).
  /// Never throws — failures resolve so startup is never blocked.
  Future<void> gatherConsent() async {
    final completer = Completer<void>();
    void done() {
      if (!completer.isCompleted) completer.complete();
    }

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        // Info updated — show the form if the user needs to act on it.
        ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
          done();
        });
      },
      (FormError error) => done(),
    );

    return completer.future;
  }

  /// Whether ads may be requested yet. Returns false only for EEA/UK users who
  /// have not provided the necessary consent.
  Future<bool> canRequestAds() async {
    try {
      return await ConsentInformation.instance.canRequestAds();
    } catch (_) {
      // If the UMP state is unknown, fail closed for privacy.
      return false;
    }
  }

  /// True when a "privacy options" entry point must be exposed in the UI (so
  /// EEA/UK users can change their choice). Show a Settings button when true.
  Future<bool> isPrivacyOptionsRequired() async {
    try {
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      return status == PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  /// Re-opens the consent form so the user can change their ad-personalisation
  /// choice. Wired to a Settings entry when [isPrivacyOptionsRequired] is true.
  Future<void> showPrivacyOptionsForm() async {
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((FormError? error) {
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }
}
