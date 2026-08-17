/// A city/district within a governorate, with Arabic + English names.
class IqCity {
  final String ar;
  final String en;
  const IqCity(this.ar, this.en);
}

/// An Iraqi governorate (محافظة) with its cities/districts.
class IqGovernorate {
  final String ar;
  final String en;
  final List<IqCity> cities;
  const IqGovernorate(this.ar, this.en, this.cities);
}

/// Iraqi governorates and their main cities. The Arabic name is the canonical
/// stored value; the display name follows the app language (English or Arabic;
/// Kurdish falls back to the Arabic script form).
class IraqLocations {
  IraqLocations._();

  static const List<IqGovernorate> all = [
    IqGovernorate('بغداد', 'Baghdad', [
      IqCity('الكرخ', 'Karkh'), IqCity('الرصافة', 'Rusafa'),
      IqCity('الكاظمية', 'Kadhimiya'), IqCity('الأعظمية', 'Adhamiyah'),
      IqCity('المنصور', 'Mansour'), IqCity('الدورة', 'Dora'),
      IqCity('مدينة الصدر', 'Sadr City'), IqCity('أبو غريب', 'Abu Ghraib'),
      IqCity('الطارمية', 'Tarmiya'), IqCity('المحمودية', 'Mahmudiya'),
      IqCity('التاجي', 'Taji'), IqCity('النهروان', 'Nahrawan'),
    ]),
    IqGovernorate('البصرة', 'Basra', [
      IqCity('البصرة', 'Basra'), IqCity('الزبير', 'Zubair'),
      IqCity('أبو الخصيب', 'Abu Al-Khaseeb'), IqCity('القرنة', 'Qurna'),
      IqCity('الفاو', 'Faw'), IqCity('شط العرب', 'Shatt Al-Arab'),
      IqCity('المدينة', 'Madina'), IqCity('الهارثة', 'Hartha'),
    ]),
    IqGovernorate('نينوى', 'Nineveh', [
      IqCity('الموصل', 'Mosul'), IqCity('تلعفر', 'Tal Afar'),
      IqCity('سنجار', 'Sinjar'), IqCity('الحمدانية', 'Hamdaniya'),
      IqCity('الشيخان', 'Shekhan'), IqCity('تلكيف', 'Tel Keppe'),
      IqCity('البعاج', 'Baaj'), IqCity('الحضر', 'Hatra'), IqCity('مخمور', 'Makhmur'),
    ]),
    IqGovernorate('أربيل', 'Erbil', [
      IqCity('أربيل', 'Erbil'), IqCity('شقلاوة', 'Shaqlawa'),
      IqCity('سوران', 'Soran'), IqCity('كويسنجق', 'Koya'),
      IqCity('رواندز', 'Rawanduz'), IqCity('جومان', 'Choman'),
      IqCity('ديانا', 'Diyana'),
    ]),
    IqGovernorate('السليمانية', 'Sulaymaniyah', [
      IqCity('السليمانية', 'Sulaymaniyah'), IqCity('رانية', 'Raniya'),
      IqCity('دوكان', 'Dukan'), IqCity('بنجوين', 'Penjwen'),
      IqCity('جمجمال', 'Chamchamal'), IqCity('دربنديخان', 'Darbandikhan'),
      IqCity('كلار', 'Kalar'), IqCity('جوارتا', 'Chwarta'),
      IqCity('سيد صادق', 'Sayid Sadiq'),
    ]),
    IqGovernorate('دهوك', 'Duhok', [
      IqCity('دهوك', 'Duhok'), IqCity('زاخو', 'Zakho'),
      IqCity('عقرة', 'Akre'), IqCity('العمادية', 'Amadiya'),
      IqCity('سيميل', 'Sumel'), IqCity('شيخان', 'Shekhan'),
      IqCity('بردرش', 'Bardarash'),
    ]),
    IqGovernorate('كركوك', 'Kirkuk', [
      IqCity('كركوك', 'Kirkuk'), IqCity('الحويجة', 'Hawija'),
      IqCity('الدبس', 'Dibis'), IqCity('الرياض', 'Riyadh'),
      IqCity('داقوق', 'Daquq'),
    ]),
    IqGovernorate('النجف', 'Najaf', [
      IqCity('النجف', 'Najaf'), IqCity('الكوفة', 'Kufa'),
      IqCity('المشخاب', 'Mishkhab'), IqCity('المناذرة', 'Manadhira'),
      IqCity('الحيرة', 'Hira'),
    ]),
    IqGovernorate('كربلاء', 'Karbala', [
      IqCity('كربلاء', 'Karbala'), IqCity('الهندية', 'Hindiya'),
      IqCity('عين التمر', 'Ain Al-Tamur'), IqCity('الحسينية', 'Husseiniya'),
    ]),
    IqGovernorate('بابل', 'Babel', [
      IqCity('الحلة', 'Hilla'), IqCity('المسيب', 'Musayyib'),
      IqCity('المحاويل', 'Mahawil'), IqCity('الهاشمية', 'Hashimiya'),
      IqCity('القاسم', 'Qasim'), IqCity('المدحتية', 'Madhatiya'),
    ]),
    IqGovernorate('واسط', 'Wasit', [
      IqCity('الكوت', 'Kut'), IqCity('الصويرة', 'Suwaira'),
      IqCity('العزيزية', 'Aziziya'), IqCity('النعمانية', 'Numaniya'),
      IqCity('بدرة', 'Badra'), IqCity('الحي', 'Hay'),
      IqCity('الزبيدية', 'Zubaidiya'),
    ]),
    IqGovernorate('صلاح الدين', 'Saladin', [
      IqCity('تكريت', 'Tikrit'), IqCity('سامراء', 'Samarra'),
      IqCity('بلد', 'Balad'), IqCity('بيجي', 'Baiji'),
      IqCity('الدجيل', 'Dujail'), IqCity('الشرقاط', 'Shirqat'),
      IqCity('طوزخورماتو', 'Tuz Khurmatu'), IqCity('الدور', 'Dour'),
    ]),
    IqGovernorate('الأنبار', 'Anbar', [
      IqCity('الرمادي', 'Ramadi'), IqCity('الفلوجة', 'Fallujah'),
      IqCity('هيت', 'Hit'), IqCity('حديثة', 'Haditha'),
      IqCity('القائم', 'Al-Qaim'), IqCity('عنه', 'Ana'),
      IqCity('راوة', 'Rawa'), IqCity('الرطبة', 'Rutba'),
      IqCity('الكرمة', 'Karma'),
    ]),
    IqGovernorate('ديالى', 'Diyala', [
      IqCity('بعقوبة', 'Baqubah'), IqCity('المقدادية', 'Muqdadiya'),
      IqCity('الخالص', 'Khalis'), IqCity('بلدروز', 'Baladruz'),
      IqCity('خانقين', 'Khanaqin'), IqCity('المنصورية', 'Mansuriya'),
      IqCity('كفري', 'Kifri'), IqCity('جلولاء', 'Jalawla'),
    ]),
    IqGovernorate('ميسان', 'Maysan', [
      IqCity('العمارة', 'Amara'), IqCity('المجر الكبير', 'Majar Al-Kabir'),
      IqCity('قلعة صالح', "Qal'at Saleh"), IqCity('الميمونة', 'Maymouna'),
      IqCity('علي الغربي', 'Ali Al-Gharbi'), IqCity('الكحلاء', 'Kahla'),
    ]),
    IqGovernorate('المثنى', 'Muthanna', [
      IqCity('السماوة', 'Samawah'), IqCity('الرميثة', 'Rumaitha'),
      IqCity('الخضر', 'Khidhir'), IqCity('السلمان', 'Salman'),
      IqCity('الوركاء', 'Warka'),
    ]),
    IqGovernorate('القادسية', 'Al-Qadisiyah', [
      IqCity('الديوانية', 'Diwaniya'), IqCity('عفك', 'Afak'),
      IqCity('الشامية', 'Shamiya'), IqCity('الحمزة', 'Hamza'),
      IqCity('غماس', 'Ghammas'), IqCity('السنية', 'Sunniya'),
    ]),
    IqGovernorate('ذي قار', 'Dhi Qar', [
      IqCity('الناصرية', 'Nasiriyah'), IqCity('الشطرة', 'Shatra'),
      IqCity('سوق الشيوخ', 'Suq Al-Shuyukh'), IqCity('الرفاعي', 'Rifai'),
      IqCity('قلعة سكر', 'Qalat Sukkar'), IqCity('الجبايش', 'Chibayish'),
      IqCity('النصر', 'Nasr'),
    ]),
    IqGovernorate('حلبجة', 'Halabja', [
      IqCity('حلبجة', 'Halabja'), IqCity('خورمال', 'Khurmal'),
      IqCity('سيد صادق', 'Sayid Sadiq'), IqCity('بيارة', 'Biyara'),
    ]),
  ];

  /// Canonical (Arabic) governorate names — used as the stored/selected value.
  static List<String> get governorateNames => all.map((g) => g.ar).toList();

  static IqGovernorate? _gov(String ar) {
    for (final g in all) {
      if (g.ar == ar) return g;
    }
    return null;
  }

  /// Canonical (Arabic) city names for a governorate.
  static List<String> citiesOf(String governorateAr) =>
      _gov(governorateAr)?.cities.map((c) => c.ar).toList() ?? const [];

  /// Display name for a governorate in the given language ('en' → English).
  static String govDisplay(String ar, String lang) {
    if (lang != 'en') return ar;
    return _gov(ar)?.en ?? ar;
  }

  /// Best-effort parse of a stored "City, Governorate" label (in any supported
  /// language) back into canonical (Arabic) values, so a saved account city can
  /// pre-select the dropdowns. `city` is '' when it isn't a listed city — the
  /// caller can then use [rawCity] as a custom "other" city.
  static ({String governorate, String city, String rawCity}) parseLabel(String stored) {
    String norm(String s) => s.trim().toLowerCase();
    final parts = stored
        .split(RegExp(r'[,،]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return (governorate: '', city: '', rawCity: '');

    // 1) A part matches a governorate → then look for one of its cities.
    for (final g in all) {
      final gov = parts.any((p) => norm(p) == norm(g.ar) || norm(p) == norm(g.en));
      if (!gov) continue;
      for (final c in g.cities) {
        if (parts.any((p) => norm(p) == norm(c.ar) || norm(p) == norm(c.en))) {
          return (governorate: g.ar, city: c.ar, rawCity: '');
        }
      }
      final raw =
          parts.where((p) => norm(p) != norm(g.ar) && norm(p) != norm(g.en)).join(', ');
      return (governorate: g.ar, city: '', rawCity: raw);
    }

    // 2) No governorate matched — match a city directly and infer its governorate.
    for (final g in all) {
      for (final c in g.cities) {
        if (parts.any((p) => norm(p) == norm(c.ar) || norm(p) == norm(c.en))) {
          return (governorate: g.ar, city: c.ar, rawCity: '');
        }
      }
    }
    return (governorate: '', city: '', rawCity: '');
  }

  /// Display name for a city in the given language ('en' → English).
  static String cityDisplay(String governorateAr, String cityAr, String lang) {
    if (lang != 'en') return cityAr;
    final g = _gov(governorateAr);
    if (g == null) return cityAr;
    for (final c in g.cities) {
      if (c.ar == cityAr) return c.en;
    }
    return cityAr;
  }
}
