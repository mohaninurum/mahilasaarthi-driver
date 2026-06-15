import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mahilasaarthi/constants/app_images.dart';
import 'package:mahilasaarthi/view_models/profile.vm.dart';
import 'package:mahilasaarthi/views/pages/profile/manage_account.page.dart';
import 'package:mahilasaarthi/widgets/busy_indicator.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard(this.model, {Key? key}) : super(key: key);

  final ProfileViewModel model;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //profile card
        (model.isBusy || model.currentUser == null)
            ? BusyIndicator().centered().p20()
            : HStack(
                [
                  (((model.currentUser?.photo ?? "").isEmpty ||
                              !(model.currentUser?.photo ?? "")
                                  .startsWith("http"))
                          ? Image.asset(
                              AppImages.user,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: model.currentUser?.photo ?? "",
                              progressIndicatorBuilder:
                                  (context, imageUrl, progress) {
                                return BusyIndicator();
                              },
                              errorWidget: (context, imageUrl, progress) {
                                return Image.asset(
                                  AppImages.user,
                                  fit: BoxFit.cover,
                                );
                              },
                              fit: BoxFit.cover,
                            ))
                      .wh(Vx.dp64, Vx.dp64)
                      .box
                      .roundedFull
                      .clip(Clip.antiAlias)
                      .make(),

                  //
                  VStack(
                    [
                      "${model.currentUser?.name}".text.xl.semiBold.make(),
                      "${model.currentUser?.email}".text.light.make(),
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
