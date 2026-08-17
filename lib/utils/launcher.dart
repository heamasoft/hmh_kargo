import 'package:url_launcher/url_launcher.dart';

/// Opens a URL / tel: / wa.me link in the right external app. We do NOT gate on
/// canLaunchUrl — on Android 11+ it returns false unless every scheme is declared
/// in the manifest, which would make links silently do nothing. Instead we just
/// try to launch (external app first, then the platform default) and swallow any
/// error so the UI never crashes.
Future<void> openUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  } catch (_) {
    try {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (_) {
      // no handler available (e.g. no browser / dialer) — nothing to do
    }
  }
}
