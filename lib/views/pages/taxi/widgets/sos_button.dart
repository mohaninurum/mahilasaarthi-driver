import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:mahilasaarthi/services/alert.service.dart';
import 'package:mahilasaarthi/services/toast.service.dart';
import 'package:mahilasaarthi/utils/utils.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';

class SOSButton extends StatelessWidget {
  const SOSButton({Key? key}) : super(key: key);

  Future<void> _makeCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.trim();
    if (cleanPhone.isEmpty) return;
    final telUrl = "tel:$cleanPhone";

    try {
      if (await canLaunchUrlString(telUrl)) {
        await launchUrlString(telUrl, mode: LaunchMode.externalApplication);
      } else {
        final uri = Uri.parse(telUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } on MissingPluginException catch (e) {
      print("SOS MissingPluginException: $e");
      ToastService.toastError("Platform plugin error. Please rebuild/restart app.".tr());
    } catch (error) {
      print("SOS Launch Error: $error");
      try {
        await launchUrl(Uri.parse(telUrl), mode: LaunchMode.externalApplication);
      } catch (err) {
        ToastService.toastError("Could not launch phone dialer: $cleanPhone");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      right: Utils.isArabic ? null : 20,
      left: !Utils.isArabic ? null : 20,
      child: VxBox(
        child: "SOS".text.xl2.extraBold.white.make().p8(),
      )
          .p8
          .color(Colors.red.shade600)
          .roundedFull
          .outerShadow
          .shadowXl
          .make()
          .onTap(
        () async {
          try {
            final contacts = AppStrings.emergencyContact.split(',').where((e) => e.trim().isNotEmpty).toList();
            if (contacts.isEmpty) {
              ToastService.toastError("No emergency contacts found".tr());
              return;
            }
            if (contacts.length == 1) {
              await _makeCall(contacts.first);
            } else {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SafeArea(
                    child: VStack([
                      "Select Emergency Contact".tr().text.xl.bold.make().p12(),
                      ...contacts.map((contact) => ListTile(
                        leading: Icon(Icons.phone),
                        title: contact.trim().text.make(),
                        onTap: () async {
                          Navigator.pop(context);
                          await _makeCall(contact);
                        },
                      )).toList(),
                    ]),
                  );
                },
              );
            }
          } catch (error) {
            AlertService.error(title: "SOS".tr(), text: "$error");
          }
        },
      ).safeArea(),
    );
  }
}
