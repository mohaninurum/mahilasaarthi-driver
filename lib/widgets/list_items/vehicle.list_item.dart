import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:mahilasaarthi/models/vehicle.dart';
import 'package:mahilasaarthi/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class VehicleListItem extends StatefulWidget {
  VehicleListItem({
    required this.vehicle,
    Key? key,
    this.onpress,
    required this.onLongpress,
  }) : super(key: key);

//
  final Vehicle vehicle;
  final Function()? onpress;
  final Function() onLongpress;
  @override
  State<VehicleListItem> createState() => _VehicleListItemState();
}

class _VehicleListItemState extends State<VehicleListItem> {
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        HStack(
          [
            //
            CustomImage(
              imageUrl: widget.vehicle.vehicleType.photo,
            ).wh(60, 60),
            VStack(
              [
                //

                "${widget.vehicle.vehicleType.name}".text.semiBold.lg.make(),

                "${widget.vehicle.carModel.carMake?.name} - ${widget.vehicle.carModel.name}"
                    .text
                    .medium
                    .make(),
                "${widget.vehicle.regNo} - ${widget.vehicle.color}"
                    .text
                    .light
                    .sm
                    .make(),
              ],
            ).px(20).expand(),

            Visibility(
              visible: widget.vehicle.isActive == 1,
              child: Icon(
                FlutterIcons.verified_oct,
                color: Colors.green,
              ),
            ),
          ],
        )
            .p12()
            .box
            .outerShadow
            .roundedSM
            .color(!widget.vehicle.verified
                ? Colors.grey.shade400
                : Colors.grey.shade100)
            .make()
            .material()
            .onInkTap(widget.onpress != null ? () => widget.onpress!() : null)
            .onInkLongPress(() => widget.onLongpress()),
        Visibility(
          visible: widget.vehicle.verified && widget.vehicle.isActive != 1,
          child: "Tap to switch vehicle".tr().text.sm.light.make().p(5),
        ),
      ],
    );
  }
}
