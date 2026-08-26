// Import necessary packages
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mahilasaarthi/constants/api.dart';
import 'package:mahilasaarthi/constants/app_colors.dart';
import 'package:mahilasaarthi/constants/app_page_settings.dart';
import 'package:mahilasaarthi/models/vehicle.dart';
import 'package:mahilasaarthi/services/custom_form_builder_validator.service.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/utils/utils.dart';
import 'package:mahilasaarthi/view_models/register.view_model.dart';
import 'package:mahilasaarthi/widgets/base.page.dart';
import 'package:mahilasaarthi/widgets/buttons/custom_button.dart';
import 'package:mahilasaarthi/widgets/cards/custom.visibility.dart';
import 'package:mahilasaarthi/widgets/cards/document_selection.view.dart';
import 'package:mahilasaarthi/widgets/custom_type_ahead_field.input.dart';
import 'package:mahilasaarthi/widgets/states/custom_loading.state.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class RegisterPage extends StatefulWidget {

  RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  File? newPhoto;

  Future<void> _pickImage(RegisterViewModel vm) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      vm.onSelfieSelected(File(pickedFile.path));
    }
  }


  @override
  Widget build(BuildContext context) {
    final inputDec = InputDecoration(
      border: OutlineInputBorder(),
    );

    return ViewModelBuilder<RegisterViewModel>.reactive(
      viewModelBuilder: () => RegisterViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          isLoading: vm.isBusy,
          body: FormBuilder(
            key: vm.formBuilderKey,
            autoFocusOnValidationFailure: false,
            child: VStack(
              [
                SafeArea(
                  child: HStack(
                    [
                      Icon(
                        FlutterIcons.close_ant,
                        size: 24,
                        color: Utils.textColorByTheme(),
                      ).p8().onInkTap(() {
                        Navigator.pop(context);
                      }).p12(),
                    ],
                  ),
                ).box.color(AppColor.primaryColor).make().wFull(context),

                VStack(
                  [
                    VStack(
                      [
                        "Become a partner"
                            .tr()
                            .text
                            .xl3
                            .color(Utils.textColorByTheme())
                            .bold
                            .make(),
                        "Fill form below to continue"
                            .tr()
                            .text
                            .light
                            .color(Utils.textColorByTheme())
                            .make(),
                      ],
                    )
                        .p20()
                        .box
                        .color(AppColor.primaryColor)
                        .make()
                        .wFull(context),



                    VStack(
                      [
                        // Stack(
                        //   children: [
                        //     //
                        //   Image.file(
                        //      newPhoto!,
                        //       fit: BoxFit.cover,
                        //     )
                        //         .wh(
                        //       Vx.dp64 * 1.3,
                        //       Vx.dp64 * 1.3,
                        //     )
                        //         .box
                        //         .rounded
                        //         .clip(Clip.antiAlias)
                        //         .make(),
                        //
                        //     //
                        //     Positioned(
                        //       bottom: 0,
                        //       right: 0,
                        //       child: Icon(
                        //         FlutterIcons.camera_ant,
                        //         size: 16,
                        //       )
                        //           .p8()
                        //           .box
                        //           .color(context.theme.colorScheme.background)
                        //           .roundedFull
                        //           .shadow
                        //           .make()
                        //           .onInkTap(changePhoto()),
                        //     ),
                        //   ],
                        // ).box.makeCentered(),


                        FormBuilderTextField(
                          name: "name",
                          validator: CustomFormBuilderValidator.required,
                          decoration: inputDec.copyWith(
                            labelText: "Name".tr(),
                          ),
                        ),
                        FormBuilderTextField(
                          name: "email",
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              CustomFormBuilderValidator.compose(
                                [
                                  CustomFormBuilderValidator.required(value),
                                  CustomFormBuilderValidator.email(value),
                                ],
                              ),
                          decoration: inputDec.copyWith(
                            labelText: "Email".tr(),
                          ),
                        ).py20(),

                        FormBuilderTextField(
                          name: "phone",
                          keyboardType: TextInputType.phone,
                          validator: CustomFormBuilderValidator.required,
                          decoration: inputDec.copyWith(
                            labelText: "Phone".tr(),
                            prefixIcon: HStack(
                              [
                                Flag.fromString(
                                  vm.selectedCountry.countryCode,
                                  width: 20,
                                  height: 20,
                                ),
                                UiSpacer.horizontalSpace(space: 5),
                                ("+" + vm.selectedCountry.phoneCode)
                                    .text
                                    .make(),
                              ],
                            ).px8().onInkTap(vm.showCountryDialPicker),
                          ),
                        ),

                        FormBuilderTextField(
                          name: "password",
                          obscureText: vm.hidePassword,
                          validator: CustomFormBuilderValidator.required,
                          decoration: inputDec.copyWith(
                            labelText: "Password".tr(),
                            suffixIcon: Icon(
                              vm.hidePassword
                                  ? FlutterIcons.ios_eye_ion
                                  : FlutterIcons.ios_eye_off_ion,
                            ).onInkTap(() {
                              vm.hidePassword = !vm.hidePassword;
                              vm.notifyListeners();
                            }),
                          ),
                        ).py20(),

                        FormBuilderTextField(
                          name: "referal_code",
                          decoration: inputDec.copyWith(
                            labelText: "Referral Code".tr(),
                          ),
                        ),

                        UiSpacer.divider().py20(),

                              UiSpacer.divider().py8(),
                              "Vehicle Details"
                                  .tr()
                                  .text
                                  .semiBold
                                  .xl
                                  .make()
                                  .py12(),
                              UiSpacer.vSpace(10),
                              CustomLoadingStateView(
                                loading: vm.busy(vm.carMakes),
                                child: CustomTypeAheadField<CarMake>(
                                  textEditingController: vm.carMakeTEC,
                                  title: "Vehicle Make".tr(),
                                  items: vm.carMakes,
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      title: Text("${suggestion.name}"),
                                    );
                                  },
                                  suggestionsCallback: (value) async {
                                    return vm.carMakes
                                        .where(
                                          (e) => e.name
                                          .toLowerCase()
                                          .contains(value.toLowerCase()),
                                    )
                                        .toList();
                                  },
                                  onSuggestionSelected: vm.onCarMakeSelected,
                                ),
                              ),
                              CustomLoadingStateView(
                                loading: vm.busy(vm.carModels),
                                child: CustomTypeAheadField<CarModel>(
                                  textEditingController: vm.carModelTEC,
                                  title: "Vehicle Model".tr(),
                                  items: vm.carModels,
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      title: Text("${suggestion.name}"),
                                    );
                                  },
                                  suggestionsCallback: (value) async {
                                    return vm.carModels
                                        .where(
                                          (e) => e.name
                                          .toLowerCase()
                                          .contains(value.toLowerCase()),
                                    )
                                        .toList();
                                  },
                                  onSuggestionSelected: vm.onCarModelSelected,
                                ).py20(),
                              ),
                              CustomLoadingStateView(
                                loading: vm.busy(vm.vehicleTypes),
                                child: FormBuilderDropdown(
                                  name: 'vehicle_type_id',
                                  decoration: inputDec.copyWith(
                                    labelText: "Vehicle Type".tr(),
                                    hintText: 'Select Vehicle Type'.tr(),
                                  ),
                                  validator:
                                  CustomFormBuilderValidator.required,
                                  items: vm.vehicleTypes
                                      .map(
                                        (type) => DropdownMenuItem(
                                      value: type.id,
                                      child: '${type.name}'.text.make(),
                                    ),
                                  )
                                      .toList(),
                                ),
                              ),
                              FormBuilderTextField(
                                name: "reg_no",
                                validator: CustomFormBuilderValidator.required,
                                decoration: inputDec.copyWith(
                                  labelText: "Registration Number".tr(),
                                ),
                              ).py20(),
                              FormBuilderTextField(
                                name: "color",
                                validator: CustomFormBuilderValidator.required,
                                decoration: inputDec.copyWith(
                                  labelText: "Color".tr(),
                                ),
                              ),
                              10.heightBox,
                              UiSpacer.divider(),

                        DocumentSelectionView(
                          title: "Documents".tr(),
                          instruction:
                          AppPageSettings.driverDocumentInstructions,
                          max: AppPageSettings.maxDriverDocumentCount,
                          onSelected: vm.onDocumentsSelected,
                        ).py(12),

                        Center(
                          child: InkWell(
                            onTap: () {
                                _pickImage(vm);
                          
                            } ,
                            child: Container(
                              height: 120, // Increased height to accommodate text
                              width: 120, // Increased width to accommodate text
                              decoration:
                              vm.selfieImage == null ?
                              BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey,
                                  )
                                  : BoxDecoration(
                                shape: BoxShape.circle,
                                // color: Colors.grey,
                                image: DecorationImage(image: FileImage(vm.selfieImage!))
                              )
                              ,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Profile Photo",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).py20(),
                        ),

                        UiSpacer.divider(),

                        FormBuilderCheckbox(
                          name: "agreed",
                          title: "I agree with"
                              .tr()
                              .richText
                              .semiBold
                              .withTextSpanChildren(
                            [
                              " ".textSpan.make(),
                              "terms and conditions"
                                  .tr()
                                  .textSpan
                                  .underline
                                  .semiBold
                                  .tap(() {
                                vm.openWebpageLink(Api.terms);
                              })
                                  .color(AppColor.primaryColor)
                                  .make(),
                            ],
                          ).make(),
                          validator: (value) {
                            if (value != true) {
                              return "Please confirm you have accepted our terms and conditions".tr();
                            }
                            return null;
                          },
                        ),

                        FormBuilderCheckbox(
                          name: "aadhaar_consent",
                          title: "I hereby consent to the collection and verification of my Aadhaar details for identity verification purposes."
                              .tr()
                              .text
                              .make(),
                          validator: (value) {
                            if (value != true) {
                              return "Please provide your consent for Aadhaar verification".tr();
                            }
                            return null;
                          },
                        ),

                        CustomButton(
                          title: "Sign Up".tr(),
                          loading: vm.isBusy,
                          onPressed: () {
                            if (vm.selfieImage != null) {
                              vm.processRegister();
                            } else {
                              vm.toastError("Please take a profile photo.".tr());
                            }
                          },
                        ).centered().py20(),
                      ],
                    ).p20(),
                  ],
                )
                    .wFull(context)
                    .scrollVertical()
                    .box
                    .color(context.cardColor)
                    .make()
                    .pOnly(
                  bottom: context.mq.viewInsets.bottom,
                )
                    .expand(),
              ],
            ),
          ),
        );
      },
    );
  }
}



