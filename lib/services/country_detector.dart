import 'dart:convert';

class CountryDetector {
  static final Map<String, String> _countryMappings = {
    'austria': 'AT',
    'at': 'AT',
    'belgium': 'BE',
    'be': 'BE',
    'switzerland': 'CH',
    'ch': 'CH',
    'czech': 'CZ',
    'cz': 'CZ',
    'germany': 'DE',
    'de': 'DE',
    'denmark': 'DK',
    'dk': 'DK',
    'spain': 'ES',
    'es': 'ES',
    'finland': 'FI',
    'fi': 'FI',
    'france': 'FR',
    'fr': 'FR',
    'uk': 'GB',
    'gb': 'GB',
    'united kingdom': 'GB',
    'england': 'GB',
    'croatia': 'HR',
    'hr': 'HR',
    'hungary': 'HU',
    'hu': 'HU',
    'italy': 'IT',
    'it': 'IT',
    'netherlands': 'NL',
    'nl': 'NL',
    'holland': 'NL',
    'norway': 'NO',
    'no': 'NO',
    'poland': 'PL',
    'pl': 'PL',
    'portugal': 'PT',
    'pt': 'PT',
    'romania': 'RO',
    'ro': 'RO',
    'sweden': 'SE',
    'se': 'SE',
    'canada': 'CA',
    'ca': 'CA',
    'usa': 'US',
    'us': 'US',
    'united states': 'US',
    'america': 'US',
    'brazil': 'BR',
    'br': 'BR',
    'mexico': 'MX',
    'mx': 'MX',
    'argentina': 'AR',
    'ar': 'AR',
    'japan': 'JP',
    'jp': 'JP',
    'singapore': 'SG',
    'sg': 'SG',
    'india': 'IN',
    'in': 'IN',
    'hong kong': 'HK',
    'hk': 'HK',
    'korea': 'KR',
    'kr': 'KR',
    'south korea': 'KR',
    'taiwan': 'TW',
    'tw': 'TW',
    'thailand': 'TH',
    'th': 'TH',
    'vietnam': 'VN',
    'vn': 'VN',
    'philippines': 'PH',
    'ph': 'PH',
    'indonesia': 'ID',
    'id': 'ID',
    'malaysia': 'MY',
    'my': 'MY',
    'turkey': 'TR',
    'tr': 'TR',
    'uae': 'AE',
    'ae': 'AE',
    'dubai': 'AE',
    'israel': 'IL',
    'il': 'IL',
    'australia': 'AU',
    'au': 'AU',
    'new zealand': 'NZ',
    'nz': 'NZ',
    'south africa': 'ZA',
    'za': 'ZA',
  };

  static String detectCountryCode(String remark, String address) {
    final searchText = '${remark.toLowerCase()} ${address.toLowerCase()}';
    
    for (var entry in _countryMappings.entries) {
      if (searchText.contains(entry.key)) {
        return entry.value;
      }
    }
    
    final regex = RegExp(r'[\[\(_]([A-Z]{2})[\]\)_]', caseSensitive: false);
    final match = regex.firstMatch(remark);
    if (match != null) {
      final code = match.group(1)?.toUpperCase();
      if (code != null && code.length == 2) {
        return code;
      }
    }
    
    final words = remark.toUpperCase().split(RegExp(r'[\s\-_|]'));
    for (var word in words) {
      if (word.length == 2 && _countryMappings.values.contains(word)) {
        return word;
      }
    }
    
    return 'XX';
  }

  static String getCountryName(String countryCode) {
    final Map<String, String> countryNames = {
      'AT': 'Austria',
      'AU': 'Australia',
      'BE': 'Belgium',
      'BR': 'Brazil',
      'CA': 'Canada',
      'CH': 'Switzerland',
      'CZ': 'Czech Republic',
      'DE': 'Germany',
      'DK': 'Denmark',
      'ES': 'Spain',
      'FI': 'Finland',
      'FR': 'France',
      'GB': 'United Kingdom',
      'HK': 'Hong Kong',
      'HR': 'Croatia',
      'HU': 'Hungary',
      'IN': 'India',
      'IT': 'Italy',
      'JP': 'Japan',
      'KR': 'South Korea',
      'MX': 'Mexico',
      'MY': 'Malaysia',
      'NL': 'Netherlands',
      'NO': 'Norway',
      'NZ': 'New Zealand',
      'PL': 'Poland',
      'PT': 'Portugal',
      'RO': 'Romania',
      'SE': 'Sweden',
      'SG': 'Singapore',
      'TH': 'Thailand',
      'TR': 'Turkey',
      'TW': 'Taiwan',
      'US': 'United States',
      'VN': 'Vietnam',
      'ZA': 'South Africa',
      'AE': 'United Arab Emirates',
      'AR': 'Argentina',
      'ID': 'Indonesia',
      'IL': 'Israel',
      'PH': 'Philippines',
      'XX': 'Unknown',
    };
    
    return countryNames[countryCode] ?? 'Unknown';
  }
  
  static String getFlagEmoji(String countryCode) {
    if (countryCode == 'XX') return '🌐';
    
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }
}
