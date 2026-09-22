import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/ads_api.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/heama_toast.dart';
import '../../widgets/product_image.dart';

/// Admin only (Me → Home ads): the images in the Home page's ad slider — add
/// one from the photo library (with an optional link), hide or delete it.
class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  late final AdsApi _api = AdsApi(context.read<ApiClient>());
  List<Ad>? _ads;
  String? _error;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ads = await _api.adminList();
      if (mounted) setState(() => (_ads = ads, _error = null));
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _add() async {
    final l = AppLocalizations.of(context);
    // Downscaled on the phone: a banner needs no 12-megapixel original, and
    // a smaller file uploads fast and stays under the server's 5 MB limit.
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    final link = await showDialog<String>(
      context: context,
      builder: (_) => const _LinkDialog(),
    );
    if (link == null || !mounted) return; // cancelled

    setState(() => _uploading = true);
    try {
      final ad = await _api.upload(picked.path, linkUrl: link);
      if (!mounted) return;
      setState(() => _ads = [...?_ads, ad]);
      showHeamaToast(context, l.adsPublished);
    } on ApiException catch (e) {
      if (mounted) showHeamaToast(context, e.message);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _toggle(Ad ad) async {
    try {
      final updated = await _api.setActive(ad.id, !ad.isActive);
      if (!mounted) return;
      setState(() => _ads = [for (final a in _ads!) a.id == ad.id ? updated : a]);
    } on ApiException catch (e) {
      if (mounted) showHeamaToast(context, e.message);
    }
  }

  Future<void> _delete(Ad ad) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text(l.adsDeleteConfirm,
            style: AppFonts.body(fontSize: 13.5, color: AppColors.ink, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel,
                style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.adsDelete,
                style: AppFonts.body(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.pomegranate)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await _api.delete(ad.id);
      if (mounted) setState(() => _ads = _ads!.where((a) => a.id != ad.id).toList());
    } on ApiException catch (e) {
      if (mounted) showHeamaToast(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ads = _ads;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        title: Text(l.adsTitle, style: AppFonts.display(fontSize: 18)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploading ? null : _add,
        backgroundColor: AppColors.pomegranate,
        foregroundColor: Colors.white,
        child: _uploading
            ? const SizedBox(
                width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.add_photo_alternate_outlined),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 96),
          children: [
            Text(l.adsSub, style: AppFonts.body(fontSize: 12.5, color: AppColors.muted)),
            const SizedBox(height: 14),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(_error!,
                    textAlign: TextAlign.center,
                    style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
              )
            else if (ads == null)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (ads.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Text(l.adsEmpty,
                    textAlign: TextAlign.center,
                    style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
              )
            else
              ...ads.map((ad) => _card(l, ad)),
          ],
        ),
      ),
    );
  }

  Widget _card(AppLocalizations l, Ad ad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: AspectRatio(
              aspectRatio: 2,
              child: Opacity(
                opacity: ad.isActive ? 1 : 0.4,
                child: ProductImage(url: ad.imageUrl, gradient: const [AppColors.cloud, AppColors.line]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ad.linkUrl ?? (ad.isActive ? '' : l.adsHidden),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(fontSize: 11.5, color: AppColors.muted),
                  ),
                ),
                // Hide from the Home page without deleting.
                Switch(
                  value: ad.isActive,
                  activeThumbColor: AppColors.green,
                  onChanged: (_) => _toggle(ad),
                ),
                IconButton(
                  onPressed: () => _delete(ad),
                  icon: const Icon(Icons.delete_outline, color: AppColors.pomegranate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Asks for an optional link; returns '' for none, null when cancelled.
class _LinkDialog extends StatefulWidget {
  const _LinkDialog();

  @override
  State<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  final _link = TextEditingController();

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(l.adsLinkTitle, style: AppFonts.display(fontSize: 17)),
      content: TextField(
        controller: _link,
        keyboardType: TextInputType.url,
        textDirection: TextDirection.ltr,
        style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(isDense: true, hintText: l.adsLinkHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel,
              style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
        ),
        TextButton(
          onPressed: () {
            var link = _link.text.trim();
            if (link.isNotEmpty && !link.startsWith('http')) link = 'https://$link';
            Navigator.pop(context, link);
          },
          child: Text(l.adsPublish,
              style: AppFonts.body(
                  fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.pomegranate)),
        ),
      ],
    );
  }
}
