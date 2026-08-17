/// Client-side UI enumerations (not server data).
class UiConstants {
  UiConstants._();

  /// Cities offered in the registration dropdown (l10n keys).
  static const List<String> cityKeys = [
    'cityErbil',
    'cityDuhok',
    'citySulaymaniyah',
    'cityHalabja',
    'cityKirkuk',
    'cityMosul',
    'cityBaghdad',
    'cityBasra',
  ];

  /// Storefront filter chips (l10n keys) → API category slug.
  static const List<String> sheinCatKeys = [
    'catAll',
    'catTops',
    'catDresses',
    'catBottoms',
    'catBags',
    'catShoes',
  ];

  /// Maps a category l10n key ("catTops") to the API slug ("tops").
  static String categorySlug(String catKey) =>
      catKey.replaceFirst('cat', '').toLowerCase();
}
