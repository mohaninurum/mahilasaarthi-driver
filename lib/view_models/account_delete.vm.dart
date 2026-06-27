import 'package:flutter/material.dart';
import 'package:mahilasaarthi/services/auth.service.dart';
import 'package:mahilasaarthi/view_models/base.view_model.dart';
import 'package:mahilasaarthi/requests/auth.request.dart';
import 'package:mahilasaarthi/views/pages/splash.page.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:mahilasaarthi/views/pages/shared/home.page.dart';

class AccountDeleteViewModel extends MyBaseViewModel {
  //
  // User currentUser;
  AuthRequest _authRequest = AuthRequest();
  bool otherReason = false;
  String? reason;

  AccountDeleteViewModel(BuildContext context) {
    this.viewContext = context;
  }

  processAccountDeletion() async {
    _authRequest.delete("");
    if (formBuilderKey.currentState!.saveAndValidate()) {
      //
      setBusy(true);
      try {
        final formValue = formBuilderKey.currentState!.value;
        final apiResponse = await _authRequest.deleteProfile(
          password: formValue["password"],
        );
        if (apiResponse.allGood) {
          toastSuccessful("${apiResponse.message}");
          if (AuthServices.currentUser != null) {
            AuthServices.currentUser!.deleteRequest = true;
            await AuthServices.saveUser(AuthServices.currentUser!.toJson());
          }
          viewContext.nextAndRemoveUntilPage(HomePage());
        } else {
          toastError("${apiResponse.message}");
        }
      } catch (error) {
        toastError("$error");
      }
      setBusy(false);
    }
  }
}
