class NumberTooLongException implements Exception {}

class NumberTooShortException implements Exception {}

class InvalidCharactersException implements Exception {}

class Country{
  final int phoneLocationId;
  final String name;
  final String flag;
  final String countryISOCode;
  final String countryCode;
  final String regionCode;
  final int minLength;
  final int maxLength;

  const Country({
    required this.phoneLocationId,
    required this.name,
    required this.flag,
    required this.countryISOCode,
    required this.countryCode,
    required this.minLength,
    required this.maxLength,
    this.regionCode = "",
  });
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      phoneLocationId: json['phoneLocationId'],
      name: json['name'],
      flag: json['flag'],
      countryISOCode: json['countryISOCode'],
      countryCode: json['countryCode'],
      regionCode: json['regionCode'] ?? "",
      minLength: json['minLength'],
      maxLength: json['maxLength'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneLocationId': phoneLocationId,
      'name': name,
      'flag': flag,
      'countryISOCode': countryISOCode,
      'countryCode': countryCode,
      'regionCode': regionCode,
      'minLength': minLength,
      'maxLength': maxLength,
    };
  }


  String get fullCountryCode {
    return countryCode + regionCode;
  }

  static Country getCountry(String phoneNumber) {
    phoneNumber = phoneNumber.replaceAll("-", "");
    if (phoneNumber == "") {
      throw NumberTooShortException();
    }

    final validPhoneNumber = RegExp(r'^[+0-9]*[0-9]*$');

    if (!validPhoneNumber.hasMatch(phoneNumber)) {
      throw InvalidCharactersException();
    }

    if (phoneNumber.startsWith('+')) {
      return listCountry.firstWhere((country) => phoneNumber
          .substring(1)
          .startsWith(country.countryCode + country.regionCode));
    }
    return listCountry.firstWhere((country) =>
        phoneNumber.startsWith(country.countryCode + country.regionCode));
  }
}

const List<Country> listCountry = [
  Country(
    phoneLocationId: 0,
    name: "Vietnam",
    flag: "🇻🇳",
    countryISOCode: "VN",
    countryCode: "84",
    minLength: 12,
    maxLength: 12,
  ),
  Country(
    phoneLocationId: 1,
    name: "Virgin Islands, U.S.",
    flag: "🇻🇮",
    countryISOCode: "VI",
    countryCode: "1340",
    minLength: 7,
    maxLength: 7,
  ),
  Country(
    phoneLocationId: 2,
    name: "Wallis and Futuna",
    flag: "🇼🇫",
    countryISOCode: "WF",
    countryCode: "681",
    minLength: 6,
    maxLength: 6,
  ),
  Country(
    phoneLocationId: 3,
    name: "Yemen",
    flag: "🇾🇪",
    countryISOCode: "YE",
    countryCode: "967",
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    phoneLocationId: 4,
    name: "Zambia",
    flag: "🇿🇲",
    countryISOCode: "ZM",
    countryCode: "260",
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    phoneLocationId: 5,
    name: "Zimbabwe",
    flag: "🇿🇼",
    countryISOCode: "ZW",
    countryCode: "263",
    minLength: 9,
    maxLength: 9,
  ),
];