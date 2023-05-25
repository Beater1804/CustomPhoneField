import 'dart:developer';

import 'package:custom_phone_field_call_api/country.dart';
import 'package:custom_phone_field_call_api/country_picker_dialog.dart';
import 'package:flutter/material.dart';

enum VerifyPhoneState { valid, empty, invalid }

class CustomPhoneWidget extends StatefulWidget {
  final TextEditingController phoneController;
  final List<Country>? countries;
  final VerifyPhoneState isValid;
  final double paddingHoz;
  final double paddingVer;
  final bool disableLengthCheck;
  final Function(String phone)? onChanged;
  final PickerDialogStyle? pickerDialogStyle;
  final bool enabled;
  final ValueChanged<Country>? onCountryChanged;
  final String searchText;
  final String? initialValue;
  final String? initialCountryCode;
  final TextEditingController phoneLocationId;

  const CustomPhoneWidget({
    Key? key,
    this.countries,
    this.paddingHoz = 20,
    this.paddingVer = 10,
    this.isValid = VerifyPhoneState.empty,
    this.onChanged,
    this.disableLengthCheck = false,
    required this.phoneController,
    this.pickerDialogStyle,
    this.enabled = true,
    this.onCountryChanged,
    @Deprecated('Use searchFieldInputDecoration of PickerDialogStyle instead') this.searchText = 'Search country',
    this.initialValue,
    this.initialCountryCode,
    required this.phoneLocationId,
  }) : super(key: key);

  @override
  State<CustomPhoneWidget> createState() => _CustomPhoneWidgetState();
}

class _CustomPhoneWidgetState extends State<CustomPhoneWidget> {
  var countPrevious = 0;
  var isDecrease = false;
  var previousPhoneNumber = "";
  TextEditingController phoneNumber = TextEditingController();
  late List<Country> _countryList;

  late Country _selectedCountry;
  late List<Country> filteredCountries;

  late String number;
  String? validatorMessage;
  VerifyPhoneState isValid = VerifyPhoneState.empty;

  void updatePhoneNumber(String phone) {
    countPrevious++;
    if (countPrevious > 1) {
      previousPhoneNumber = phoneNumber.text;
    }
    phoneNumber.text = phone;

    //* Check if current phoneNumber length == previous phoneNumber length - 1?

    isDecrease = phone.length == previousPhoneNumber.length - 1;

    if (phone.length == 5 || phone.length == 9) {
      var result = "";

      //CASE LENGTH = 5
      if (phone.length == 5 && !isDecrease) {
        result = "${phone.substring(0, 4)}-${phone.substring(4, 5)}";
      } else if (phone.length == 5 && isDecrease) {
        result = phone.substring(0, 4);
      }

      //CASE LENGTH = 9
      if (phone.length == 9 && !isDecrease) {
        result = "${phone.substring(0, 8)}-${phone.substring(8, 9)}";
      } else if (phone.length == 9 && isDecrease) {
        result = phone.substring(0, 8);
      }

      //APPLY CHANGED.

      widget.phoneController.text = result;
      log('controller${widget.phoneController.text}');
      phoneNumber.text = result;
      widget.phoneController.selection =
          TextSelection.fromPosition(TextPosition(offset: widget.phoneController.text.length));
    }
  }

  @override
  void initState() {
    super.initState();
    _countryList = widget.countries == null
        ? listCountry
        : widget.countries!;
    filteredCountries = _countryList;
    number = widget.initialValue ?? '';
    if (widget.initialCountryCode == null && number.startsWith('+')) {
      number = number.substring(1);
      // parse initial value
      _selectedCountry = listCountry.firstWhere((country) => number.startsWith(country.fullCountryCode),
          orElse: () => _countryList.first);

      // remove country code from the initial number value
      number = number.replaceFirst(RegExp("^${_selectedCountry.fullCountryCode}"), "");
    } else {
      _selectedCountry = _countryList.firstWhere((item) => item.countryISOCode == (widget.initialCountryCode ?? 'US'),
          orElse: () => _countryList.first);

      // remove country code from the initial number value
      if (number.startsWith('+')) {
        number = number.replaceFirst(RegExp("^\\+${_selectedCountry.fullCountryCode}"), "");
      } else {
        number = number.replaceFirst(RegExp("^${_selectedCountry.fullCountryCode}"), "");
      }
    }
  }

  bool isValidNumber() {
    Country country = Country.getCountry(completeNumber);
    log(country.countryISOCode);
    if (number.length < country.minLength) {
      throw NumberTooShortException();
    }

    if ((number.length > country.maxLength) && country.countryISOCode != "US") {
      throw NumberTooLongException();
    }

    return true;
  }

  String get completeNumber {
    return _selectedCountry.countryCode + number;
  }

  Future<void> _changeCountry() async {
    filteredCountries = _countryList;
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setState) => CountryPickerDialog(
          style: widget.pickerDialogStyle,
          filteredCountries: filteredCountries,
          searchText: widget.searchText,
          countryList: _countryList,
          selectedCountry: _selectedCountry,
          onCountryChanged: (Country country) {
            _selectedCountry = country;
            widget.onCountryChanged?.call(country);
            setState(() {});
          },
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget getSuffixIcon() {
      switch (isValid) {
        case VerifyPhoneState.valid:
          return const Icon(
            Icons.check_circle,
            color: Colors.green,
          );
        case VerifyPhoneState.empty:
          return const SizedBox(width: 0, height: 20);
        case VerifyPhoneState.invalid:
          return const Icon(
            Icons.error,
            color: Colors.red,
          );
        default:
          return const SizedBox();
      }
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.paddingHoz,
          vertical: widget.paddingVer,
        ),
        child: TextFormField(
          style: const TextStyle(fontSize: 12),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            isDense: true,
            counterText: "",
            hintText: '1234-567-890',
            hintStyle: const TextStyle(fontSize: 12),
            prefixIcon: _buildFlagsButton(),
            suffixIcon: getSuffixIcon(),
            contentPadding: const EdgeInsets.only(left: 10, right: 10, top: 5,bottom: 5),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black.withOpacity(0.5), width: 1),
                borderRadius: BorderRadius.circular(4)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black.withOpacity(0.5), width: 1),
                borderRadius: BorderRadius.circular(4)),
            disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black.withOpacity(0.5), width: 1),
                borderRadius: BorderRadius.circular(4)),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black.withOpacity(0.4), width: 1),
                borderRadius: BorderRadius.circular(4)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black.withOpacity(0.5), width: 1),
                borderRadius: BorderRadius.circular(4)),
          ),
          onChanged: (phone) {
            setState(() {
              var tempId = _selectedCountry.phoneLocationId.toString();
              widget.phoneLocationId.text = tempId;
            });
            log('phone chang $phone');
            widget.onChanged?.call(phone);
            if (phone.isEmpty) {
              setState(() {
                isValid = VerifyPhoneState.empty;
              });
            } else {
              setState(() {
                isValid = VerifyPhoneState.invalid;
              });
              try {
                if (phone.length ==
                    _selectedCountry.maxLength -
                        _selectedCountry.countryCode.length +
                        widget.phoneController.text.length -
                        widget.phoneController.text.replaceAll("-", "").length) {
                  setState(() {
                    isValid = VerifyPhoneState.valid;
                  });
                }
              } catch (e) {
                log(e.toString());
              }
            }
            updatePhoneNumber(phone);
          },
          controller: widget.phoneController,
          maxLength: widget.phoneController.text.length - widget.phoneController.text.replaceAll("-", "").length == 0
              ? _selectedCountry.maxLength - _selectedCountry.countryCode.length
              : _selectedCountry.maxLength -
                  _selectedCountry.countryCode.length +
                  widget.phoneController.text.length -
                  widget.phoneController.text.replaceAll("-", "").length,
          keyboardType: TextInputType.phone,
        ),
      ),
    );
  }

  Widget _buildFlagsButton() {
    return SizedBox(
      height: 50,
      width: 80,
      child: InkWell(
        onTap: widget.enabled ? _changeCountry : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 4),
            Text(
              _selectedCountry.flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 4),
            FittedBox(
              child: Text(
                '+${_selectedCountry.countryCode}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
