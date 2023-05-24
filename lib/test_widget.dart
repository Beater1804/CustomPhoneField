import 'dart:developer';

import 'package:custom_phone_field_call_api/custom_phone_widget.dart';
import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneNumber = TextEditingController();
    final TextEditingController phoneLocationId =TextEditingController();
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 300,
          width: double.infinity,
          child: Column(
            children: [
              CustomPhoneWidget(phoneController: phoneNumber, phoneLocationId: phoneLocationId,),
              ElevatedButton(
                onPressed: () {
                  log(phoneNumber.text);
                  log(phoneLocationId.text);
                },
                child: const Text('Check'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
