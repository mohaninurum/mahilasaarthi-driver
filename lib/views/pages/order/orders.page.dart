import 'package:flutter/material.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/view_models/orders.vm.dart';
import 'package:mahilasaarthi/widgets/base.page.dart';
import 'package:mahilasaarthi/widgets/custom_list_view.dart';
import 'package:mahilasaarthi/widgets/list_items/order.list_item.dart';
import 'package:mahilasaarthi/widgets/list_items/taxi_order.list_item.dart';
import 'package:mahilasaarthi/widgets/list_items/unpaid_order.list_item.dart';
import 'package:mahilasaarthi/widgets/states/error.state.dart';
import 'package:mahilasaarthi/widgets/states/order.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with AutomaticKeepAliveClientMixin<OrdersPage>, WidgetsBindingObserver {
  //
  late OrdersViewModel vm;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      vm.fetchMyOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    vm = OrdersViewModel(context);
    super.build(context);
    return BasePage(
      title: "Orders".tr(),
      showAppBar: true,
      showLeadingAction: true,
      backgroundColor: Colors.grey.shade200,
      body: ViewModelBuilder<OrdersViewModel>.reactive(
        viewModelBuilder: () => vm,
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return CustomListView(
            canRefresh: true,
            canPullUp: true,
            refreshController: vm.refreshController,
            onRefresh: vm.fetchMyOrders,
            onLoading: () => vm.fetchMyOrders(initialLoading: false),
            isLoading: vm.isBusy,
            dataSet: vm.orders,
            hasError: vm.hasError,
            padding: EdgeInsets.all(20),
            errorWidget: LoadingError(
              onrefresh: vm.fetchMyOrders,
            ),
            //
            emptyWidget: EmptyOrder(),
            itemBuilder: (context, index) {
              //
              final order = vm.orders[index];
              //for taxi tye of order
              if (order.taxiOrder != null) {
                return TaxiOrderListItem(
                  order: order,
                  orderPressed: () => vm.openOrderDetails(order),
                );
              } else if (order.isUnpaid) {
                return UnPaidOrderListItem(order: order);
              }
              return OrderListItem(
                order: order,
                orderPressed: () => vm.openOrderDetails(order),
              );
            },
            separatorBuilder: (context, index) => UiSpacer.vSpace(10),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
