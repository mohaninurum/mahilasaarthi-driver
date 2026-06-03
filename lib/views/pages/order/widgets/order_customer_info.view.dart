import 'package:flutter/material.dart';
import 'package:mahilasaarthi/constants/app_colors.dart';
import 'package:mahilasaarthi/models/order.dart';
import 'package:mahilasaarthi/utils/ui_spacer.dart';
import 'package:mahilasaarthi/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../services/taxi/ongoing_taxi_booking.service.dart';
import '../../../../view_models/order_details.vm.dart';
import '../../../../view_models/taxi/taxi.vm.dart';

class OrderCustomerInfoView extends StatelessWidget {
  OrderCustomerInfoView(this.order,this.vm, {Key? key}) : super(key: key);

  final Order order;
  OrderDetailsViewModel vm;
  @override
  Widget build(BuildContext context) {
    double avatarSize = 40;

    //
    return VxBox(
      child: HStack(
        [
          //customer profile
          CustomImage(
            imageUrl: order.user.photo,
            width: avatarSize,
            height: avatarSize,
          ),
          UiSpacer.hSpace(12),

          VStack(
            [
              "${order.user.name}".text.medium.make(),
              VxRating(
                isSelectable: false,
                onRatingUpdate: (value) {},
                maxRating: 5.0,
                count: 5,
                size: 16,
                value: order.user.rating,
                selectionColor: AppColor.ratingColor,
              ),
            ],
          ).expand(),

          GestureDetector(onTap: (){
            vm.chatCustomer();
          },child: Container(padding: EdgeInsets.symmetric(horizontal: 18,vertical: 7),decoration: BoxDecoration(color: AppColor.primaryColor,borderRadius: BorderRadius.circular(10)),child: Text("Chat",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),))

        ],
        crossAlignment: CrossAxisAlignment.center,
      ).px20().py12(),
    ).shadowXs.color(context.theme.colorScheme.background).make();
  }
}
