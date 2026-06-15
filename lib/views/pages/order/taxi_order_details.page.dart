import 'package:flutter/material.dart';
import 'package:mahilasaarthi/models/order.dart';
import 'package:mahilasaarthi/constants/app_strings.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/view_models/order_details.vm.dart';
import 'package:mahilasaarthi/views/pages/order/widgets/basic_taxi_trip_info.view.dart';
import 'package:mahilasaarthi/views/pages/order/widgets/order_payment_info.view.dart';
import 'package:mahilasaarthi/widgets/base.page.dart';
import 'package:mahilasaarthi/widgets/cards/order_summary.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../view_models/taxi/taxi.vm.dart';
import '../../../widgets/bottomsheets/user_rating.bottomsheet.dart';
import 'widgets/order_customer_info.view.dart';
import 'widgets/taxi_trip_map.preview.dart';

class TaxiOrderDetailPage extends StatefulWidget {
  const TaxiOrderDetailPage({
    required this.order,
    Key? key,
  }) : super(key: key);

  //
  final Order order;

  @override
  _TaxiOrderDetailPageState createState() => _TaxiOrderDetailPageState();
}

class _TaxiOrderDetailPageState extends State<TaxiOrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      body: ViewModelBuilder<OrderDetailsViewModel>.reactive(
        viewModelBuilder: () => OrderDetailsViewModel(context, widget.order),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return BasePage(
            title: "Trip Details".tr(),
            elevation: 0,
            showAppBar: true,
            showLeadingAction: true,
            isLoading: vm.isBusy,
            body: VStack(
              [
                //taxi trip map preview
                TaxiTripMapPreview(vm.order),
                //basic info
                BasicTaxiTripInfoView(vm.order),
                UiSpacer.vSpace(),

                //payment status
                OrderPaymentInfoView(vm)
                    .py12()
                    .px20()
                    .wFull(context)
                    .box
                    .shadowXs
                    .color(context.theme.colorScheme.background)
                    .make(),
                //customer
                OrderCustomerInfoView(vm.order,vm),
                // GestureDetector(onTap: () async {
                //   await context.push(
                //         (context) => UserRatingBottomSheet(
                //       order: vm.order,
                //       onSubmitted: () {
                //         Navigator.pop(context);
                //       },
                //     ),
                //   );
                // },child: Container(width: 200,height: 60,child: Center(child: Text("GIVE RATING"),),)),
                //order summary
                OrderSummary(
                  subTotal: vm.order.subTotal,
                  discount: vm.order.discount ?? 0,
                  driverTip: vm.order.tip,
                  total: vm.order.total!,
                  mCurrencySymbol:
                      "${vm.order.taxiOrder?.currency != null ? vm.order.taxiOrder?.currency?.symbol : AppStrings.currencySymbol}",
                  fees: vm.order.fees ?? [],
                )
                    .px20()
                    .py12()
                    .box
                    .shadowXs
                    .color(context.theme.colorScheme.background)
                    .make()
                    .pSymmetric(v: 20),
                UiSpacer.vSpace(),
              ],
            ).scrollVertical(),
          );
        },
      ),
    );
  }


}



