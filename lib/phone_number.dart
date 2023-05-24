import 'package:custom_phone_field_call_api/country.dart';

class NumberTooLongException implements Exception {}

class NumberTooShortException implements Exception {}

class InvalidCharactersException implements Exception {}

class PhoneNumber {
  final String phoneNumber;
  final String phoneLocationId;
  const PhoneNumber({
    required this.phoneNumber,
    required this.phoneLocationId,
});

  static Country getCountry(String phoneNumber) {
    phoneNumber = phoneNumber.replaceAll("-", "");
    if (phoneNumber == "") {
      throw NumberTooShortException();
    }

    final validPhoneNumber = RegExp(r'^[+\d]*\d*$');

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