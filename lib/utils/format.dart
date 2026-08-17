import 'package:intl/intl.dart';

/// Formats a dinar amount with thousands separators, e.g. 182500 -> "182,500".
/// IQD has no subunit, so the amount is shown as a whole number.
String formatIqd(num amount) => NumberFormat.decimalPattern('en').format(amount.round());

/// Formats a REAL money amount in [currency] — IQD = dinars, USD = dollars —
/// into a display string. IQD: "21,500 IQD" (suffix localizable via [iqdLabel]);
/// USD: "$14.00".
String formatMoney(num amount, String currency, {String iqdLabel = 'IQD'}) {
  if (currency.toUpperCase() == 'USD') {
    return '\$${amount.toStringAsFixed(2)}';
  }
  return '${formatIqd(amount)} $iqdLabel';
}
