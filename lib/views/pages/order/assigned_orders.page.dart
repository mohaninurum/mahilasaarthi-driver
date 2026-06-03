import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/view_models/assigned_orders.vm.dart';
import 'package:mahilasaarthi/widgets/base.page.dart';
import 'package:mahilasaarthi/widgets/custom_list_view.dart';
import 'package:mahilasaarthi/widgets/list_items/order.list_item.dart';
import 'package:mahilasaarthi/widgets/states/error.state.dart';
import 'package:mahilasaarthi/widgets/states/order.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../services/app.service.dart';
import 'widgets/online_offline.fab.dart';

class AssignedOrdersPage extends StatefulWidget {
  const AssignedOrdersPage({Key? key}) : super(key: key);

  @override
  _AssignedOrdersPageState createState() => _AssignedOrdersPageState();
}

class _AssignedOrdersPageState extends State<AssignedOrdersPage>
    with AutomaticKeepAliveClientMixin<AssignedOrdersPage> {

  @override
  void initState() {
    Timer.periodic(Duration(seconds: 10), (timer) {
      AppService().refreshAssignedOrders.add(true);

    });

    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    //
    super.build(context);
    return SafeArea(
      child: ViewModelBuilder<AssignedOrdersViewModel>.reactive(
        viewModelBuilder: () => AssignedOrdersViewModel(),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return BasePage(
            body: VStack(
              [
                //online status
                OnlineOfflineFab().py(10),
                // .centered().safeArea(),
                UiSpacer.vSpace(),
                //
                CustomListView(
                  canRefresh: true,
                  canPullUp: true,
                  refreshController: vm.refreshController,
                  onRefresh: vm.fetchOrders,
                  onLoading: () => vm.fetchOrders(initialLoading: false),
                  isLoading: vm.isBusy,
                  dataSet: vm.orders,
                  hasError: vm.hasError,
                  errorWidget: LoadingError(
                    onrefresh: vm.fetchOrders,
                  ),
                  //
                  emptyWidget: VStack(
                    [
                      EmptyOrder(
                        title: "Assigned Orders".tr(),
                      ),
                    ],
                  ),
                  itemBuilder: (context, index) {
                    //
                    final order = vm.orders[index];
                    return OrderListItem(
                      order: order,
                      orderPressed: () => vm.openOrderDetails(order),
                    );
                  },
                ).expand(),
              ],
            ).px20(),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
