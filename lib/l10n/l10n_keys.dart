import 'app_localizations.dart';

/// Resolves a string key (as stored in static data) to its localized value.
/// Used where content-driven keys can't call a fixed getter directly.
extension L10nKeys on AppLocalizations {
  String byKey(String key) {
    switch (key) {
      // Store categories
      case 'catFashion':
        return catFashion;
      case 'catEverything':
        return catEverything;
      case 'catApparel':
        return catApparel;
      case 'catGadgets':
        return catGadgets;
      case 'catTech':
        return catTech;
      // Cities
      case 'cityErbil':
        return cityErbil;
      case 'cityDuhok':
        return cityDuhok;
      case 'citySulaymaniyah':
        return citySulaymaniyah;
      case 'cityHalabja':
        return cityHalabja;
      case 'cityKirkuk':
        return cityKirkuk;
      case 'cityMosul':
        return cityMosul;
      case 'cityBaghdad':
        return cityBaghdad;
      case 'cityBasra':
        return cityBasra;
      // Product colours
      case 'colorLavender':
        return colorLavender;
      case 'colorRose':
        return colorRose;
      case 'colorSage':
        return colorSage;
      case 'colorSand':
        return colorSand;
      case 'colorBlack':
        return colorBlack;
      // Shein storefront categories
      case 'catAll':
        return catAll;
      case 'catTops':
        return catTops;
      case 'catDresses':
        return catDresses;
      case 'catBottoms':
        return catBottoms;
      case 'catBags':
        return catBags;
      case 'catShoes':
        return catShoes;
      // Tracking step titles
      case 'stepPlaced':
        return stepPlaced;
      case 'stepPurchased':
        return stepPurchased;
      case 'stepWarehouse':
        return stepWarehouse;
      case 'stepTransit':
        return stepTransit;
      case 'stepArrived':
        return stepArrived;
      case 'stepOutForDelivery':
        return stepOutForDelivery;
      default:
        return key;
    }
  }
}
