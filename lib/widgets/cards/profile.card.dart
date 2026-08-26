import 'package:flutter/material.dart';
import 'package:mahilasaarthi/constants/app_images.dart';
import 'package:mahilasaarthi/view_models/profile.vm.dart';
import 'package:mahilasaarthi/views/pages/profile/manage_account.page.dart';
import 'package:mahilasaarthi/widgets/busy_indicator.dart';
import 'package:mahilasaarthi/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard(this.model, {Key? key}) : super(key: key);

  final ProfileViewModel model;
  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final subTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey.shade700;

    return VStack(
      [
        //profile card
        (model.currentUser == null && model.isBusy)
            ? BusyIndicator().centered().p20()
            : HStack(
                [
                  CustomImage(
                    imageUrl: model.currentUser?.photo ?? "",
                    defaultImage: AppImages.user,
                    width: Vx.dp64,
                    height: Vx.dp64,
                    boxFit: BoxFit.cover,
                  )
                      .box
                      .roundedFull
                      .clip(Clip.antiAlias)
                      .make(),

                  //
                  VStack(
                    [
                      "${model.currentUser?.name ?? ''}"
                          .text
                          .color(textColor)
                          .xl
                          .semiBold
                          .make(),
                      "${model.currentUser?.email ?? ''}"
                          .text
                          .color(subTextColor)
                          .light
                          .make(),
                    ],
                  ).px20().expand(),

                  //
                ],
              ).p12().onTap(() {
                context.nextPage(ManageAccountPage());
              }),
      ],
    ).wFull(context);
  }
}
