import 'package:intl/intl.dart';

/// Formats a dinar amount with thousands separators, e.g. 182500 -> "182,500".
/// IQD has no subunit, so the amount is shown as a whole number.
String formatIqd(num amount) => NumberFormat.decimalPattern('en').format(amount.round());

/// Formats a REAL money amount in [currency] into a display string:
/// IQD "21,500 IQD" (suffix localizable via [iqdLabel]), USD "$14.00",
/// TRY "350.00 TL", EUR "€9.99". An unknown code is shown with its code.
///
/// Anything unrecognised used to fall through to IQD, so a Trendyol price of
/// 350 lira read "350 IQD" — every currency is named now; only an empty one
/// (older data with no currency) still means dinars.
String formatMoney(num amount, String currency, {String iqdLabel = 'IQD'}) {
  final code = currency.trim().toUpperCase();
  switch (code) {
    case 'USD':
      return '\$${amount.toStringAsFixed(2)}';
    case 'TRY':
    case 'TL':
      return '${_twoDecimals.format(amount)} TL';
    case 'EUR':
      return '€${amount.toStringAsFixed(2)}';
    case '':
    case 'IQD':
      return '${formatIqd(amount)} $iqdLabel';
    default:
      return '${_twoDecimals.format(amount)} $code';
  }
}

final _twoDecimals = NumberFormat('#,##0.00', 'en');
