import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:mahilasaarthi/constants/app_colors.dart';
import 'package:mahilasaarthi/constants/app_ui_settings.dart';
import 'package:mahilasaarthi/extensions/dynamic.dart';
import 'package:mahilasaarthi/models/delivery_address.dart';
import 'package:mahilasaarthi/models/order.dart';
import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/view_models/order_details.vm.dart';
import 'package:mahilasaarthi/views/pages/order/widgets/driver_cash_delivery_note.view.dart';
import 'package:mahilasaarthi/views/pages/order/widgets/order_actions.dart';
import 'package:mahilasaarthi/views/pages/order/widgets/order_address.view.dart';
import 'package:mahilasaarthi/views/pages/order/widgets/order_payment_info.view.dart';
import 'package:mahilasaarthi/views/pages/order/widgets/recipient_info.dart';
import 'package:mahilasaarthi/widgets/base.page.dart';
import 'package:mahilasaarthi/widgets/busy_indicator.dart';
import 'package:mahilasaarthi/widgets/buttons/custom_button.dart';
import 'package:mahilasaarthi/widgets/cards/amount_tile.dart';
import 'package:mahilasaarthi/widgets/cards/order_summary.dart';
import 'package:mahilasaarthi/widgets/currency_hstack.dart';
import 'package:mahilasaarthi/widgets/custom_list_view.dart';
import 'package:mahilasaarthi/widgets/list_items/order_product.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../requests/auth.request.dart';
import '../../../services/auth.service.dart';
import '../../../utils/utils.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({
    required this.order,
    Key? key,
  }) : super(key: key);

  //
  final Order order;

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      body: ViewModelBuilder<OrderDetailsViewModel>.reactive(
        viewModelBuilder: () => OrderDetailsViewModel(context, order),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return BasePage(
            title: "Order Details".tr(),
            showAppBar: true,
            showLeadingAction: true,
            onBackPressed: vm.onBackPressed,
            isLoading: vm.isBusy,
            body: vm.isBusy
                ? BusyIndicator().centered()
                : VStack(
                    [
                      //code & total amount
                      HStack(
                        [
                          //
                          VStack(
                            [
                              "Code".tr().text.gray500.medium.sm.make(),
                              "#${vm.order.code}".text.medium.xl.make(),
                            ],
                          ).expand(),
                          //total amount
                          CurrencyHStack(
                            [
                              AppStrings.currencySymbol.text.medium.lg
                                  .make()
                                  .px4(),
                              "${(vm.order.total ?? 0.00).currencyValueFormat()}"
                                  .text
                                  .medium
                                  .xl2
                                  .make(),
                            ],
                          ),
                        ],
                      ).pOnly(bottom: Vx.dp20),

                      //order delivery/pickup location
                      OrderAddressView(vm),




                      vm.order.code.text.toString().lowerCamelCase  == "pending" ?   SizedBox(height: 10,):Center(),
                      vm.order.code.text.toString().lowerCamelCase  == "pending" ?        Align(alignment: Alignment.centerRight,child: GestureDetector(onTap: () async {
                        Utils.showLoadingDialog(context);
                        await AuthRequest().CallDriverApi(from: (await AuthServices.getCurrentUser()).phone ,to: order.user.phone);
                        Navigator.pop(context);
                      },child: Container(decoration: BoxDecoration(color: AppColor.primaryColor),padding: EdgeInsets.symmetric(horizontal: 10,vertical: 8),child: Center(child: Text("Call",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 17),)),))): Center(),
                      vm.order.code.text.toString().lowerCamelCase  == "pending" ?     SizedBox(height: 10,):Center(),

                      //status
                      "Status".tr().text.gray500.medium.sm.make(),
                      "${vm.order.status.tr().capitalized}"
                          .text
                          .color(AppColor.getStausColor(vm.order.status))
                          .medium
                          .xl
                          .make()
                          .pOnly(bottom: Vx.dp20),

                      //payment status
                      OrderPaymentInfoView(vm),

                      //vendor
                      HStack(
                        [
                          //
                          vm.order.vendor == null ? Center():  VStack(
                            [
                              "Vendor".tr().text.gray500.medium.sm.make(),
                              vm.order.vendor!.name.text.medium.xl
                                  .make()
                                  .pOnly(bottom: Vx.dp20),
                            ],
                          ).expand(),
                          //call
                          if (vm.order.canChatVendor &&
                              AppUISettings.canCallVendor)
                            CustomButton(
                              icon: FlutterIcons.phone_call_fea,
                              iconColor: Colors.white,
                              color: AppColor.primaryColor,
                              shapeRadius: Vx.dp20,
                              onPressed: vm.callVendor,
                            ).wh(Vx.dp64, Vx.dp40).p12(),
                        ],
                      ),

                      //vendor routing
                      vm.order.vendor == null ? Center():
                      HStack(
                        [
                           VStack(
                            [
                              "Vendor Address"
                                  .tr()
                                  .text
                                  .gray500
                                  .medium
                                  .sm
                                  .make(),
                              "${vm.order.vendor?.address}"
                                  .text
                                  .make()
                                  .pOnly(bottom: Vx.dp20),
                            ],
                          ).expand(),
                          //route
                          CustomButton(
                            icon: FlutterIcons.navigation_fea,
                            iconColor: Colors.white,
                            color: AppColor.primaryColor,
                            shapeRadius: Vx.dp20,
                            onPressed: (vm.order.vendor == null ||
                                    vm.order.vendor?.latitude == null)
                                ? null
                                : () => vm.routeToLocation(
                                      DeliveryAddress(
                                        name: vm.order.vendor!.name,
                                        latitude: double.parse(
                                            vm.order.vendor!.latitude),
                                        longitude: double.parse(
                                            vm.order.vendor!.longitude),
                                      ),
                                    ),
                          ).wh(80, Vx.dp40).p12(),
                        ],
                      ),

                      //chat
                      vm.order.canChatVendor
                          ? Visibility(
                              visible: AppUISettings.canVendorChat,
                              child: CustomButton(
                                icon: FlutterIcons.chat_ent,
                                iconColor: Colors.white,
                                title: "Chat with vendor".tr(),
                                color: AppColor.primaryColor,
                                onPressed: vm.chatVendor,
                              ).h(Vx.dp48).pOnly(top: Vx.dp12, bottom: Vx.dp20),
                            )
                          : UiSpacer.emptySpace(),

                      //customer
                      HStack(
                        [
                          //
                          VStack(
                            [
                              "Customer".tr().text.gray500.medium.sm.make(),
                              vm.order.user.name.text.medium.xl
                                  .make()
                                  .pOnly(bottom: Vx.dp20),
                            ],
                          ).expand(),
                          //call
                          if (vm.order.canChatCustomer &&
                              AppUISettings.canCallCustomer)
                            CustomButton(
                              icon: FlutterIcons.phone_call_fea,
                              iconColor: Colors.white,
                              color: AppColor.primaryColor,
                              shapeRadius: Vx.dp20,
                              onPressed: vm.callCustomer,
                            ).wh(80, Vx.dp40).p12(),
                        ],
                      ).py4(),
                      vm.order.canChatCustomer
                          ? Visibility(
                              visible: AppUISettings.canCustomerChat,
                              child: CustomButton(
                                icon: FlutterIcons.chat_ent,
                                iconColor: Colors.white,
                                title: "Chat with customer".tr(),
                                color: AppColor.primaryColor,
                                onPressed: vm.chatCustomer,
                              ).h(Vx.dp48).pOnly(top: Vx.dp12, bottom: Vx.dp20),
                            )
                          : UiSpacer.emptySpace(),

                      //recipient
                      RecipientInfo(
                        callRecipient: vm.callRecipient,
                        order: vm.order,
                      ),

                      //note
                      "Note".tr().text.gray500.medium.sm.make(),
                      "${vm.order.note}"
                          .text
                          .medium
                          .xl
                          .italic
                          .make()
                          .pOnly(bottom: Vx.dp20),

                      // either products/package details
                      (vm.order.isPackageDelivery
                              ? "Package Details"
                              : "Products")
                          .tr()
                          .text
                          .gray500
                          .semiBold
                          .xl
                          .make()
                          .pOnly(bottom: Vx.dp10),
                      vm.order.isPackageDelivery
                          ? VStack(
                              [
                                AmountTile(
                                  "Package Type".tr(),
                                  vm.order.packageType!.name,
                                ),
                                AmountTile(
                                  "Width".tr(),
                                  "${vm.order.width} cm",
                                ),
                                AmountTile(
                                  "Length".tr(),
                                  "${vm.order.length} cm",
                                ),
                                AmountTile(
                                  "Height".tr(),
                                  "${vm.order.height} cm",
                                ),
                                AmountTile(
                                  "Weight".tr(),
                                  "${vm.order.weight} kg",
                                ),
                              ],
                              crossAlignment: CrossAxisAlignment.end,
                            )
                          : CustomListView(
                              noScrollPhysics: true,
                              dataSet: vm.order.orderProducts ?? [],
                              itemBuilder: (context, index) {
                                //
                                final orderProduct =
                                    vm.order.orderProducts![index];
                                return OrderProductListItem(
                                  orderProduct: orderProduct,
                                );
                              },
                            ),

                      //show notice it driver should be paid in cash
                      CheckoutDriverCashDeliveryNoticeView(),

                      //order summary
                      OrderSummary(
                        subTotal: vm.order.subTotal,
                        discount: vm.order.discount,
                        deliveryFee: vm.order.deliveryFee,
                        tax: vm.order.tax,
                        driverTip: vm.order.tip,
                        vendorTax: vm.order.taxRate.toString(),
                        total: vm.order.total!,
                      ).pOnly(top: Vx.dp20, bottom: Vx.dp56),
                    ],
                  )
                    .p20()
                    .pOnly(bottom: context.percentHeight * 30)
                    .scrollVertical(),

            //
            bottomSheet: OrderActions(
              order: vm.order,
              canChatCustomer: vm.order.canChatCustomer,
              busy: vm.isBusy || vm.busy(vm.order),
              processOrderCompletion: vm.initiateOrderCompletion,
              processOrderEnroute: vm.processOrderEnroute,
            ),
          );
        },
      ),
    );
  }
}


