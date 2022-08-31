import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_media_app/constants/colors.dart';
import 'package:social_media_app/constants/dimens.dart';
import 'package:social_media_app/constants/strings.dart';
import 'package:social_media_app/constants/styles.dart';
import 'package:social_media_app/global_widgets/custom_app_bar.dart';
import 'package:social_media_app/global_widgets/primary_text_btn.dart';
import 'package:social_media_app/modules/home/views/widgets/user_widget.dart';
import 'package:social_media_app/modules/post/controllers/post_liked_users_controller.dart';

class PostLikedUsersView extends StatelessWidget {
  const PostLikedUsersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NxAppBar(
              title: StringValues.likes,
              padding: Dimens.edgeInsets8_16,
            ),
            Dimens.boxHeight16,
            _buildBody(),
          ],
        ),
      ),
    );
  }

  _buildBody() {
    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: Dimens.edgeInsets0_16,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetBuilder<PostLikedUsersController>(
                builder: (commentsLogic) {
                  if (commentsLogic.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (commentsLogic.postLikedUsersList.isEmpty) {
                    return const SizedBox();
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: commentsLogic.postLikedUsersList
                            .map((e) => UserWidget(
                                  user: e.likedBy!,
                                  avatarSize: Dimens.twenty,
                                  bottomMargin: Dimens.sixTeen,
                                ))
                            .toList(),
                      ),
                      if (commentsLogic.isMoreLoading) Dimens.boxHeight8,
                      if (commentsLogic.isMoreLoading)
                        const Center(child: CircularProgressIndicator()),
                      if (!commentsLogic.isMoreLoading &&
                          commentsLogic.postLikedUsersData.hasNextPage!)
                        NxTextButton(
                          label: 'View more',
                          onTap: commentsLogic.loadMore,
                          labelStyle: AppStyles.style14Bold.copyWith(
                            color: ColorValues.primaryLightColor,
                          ),
                          padding: Dimens.edgeInsets8_0,
                        ),
                      Dimens.boxHeight16,
                    ],
                  );
                },
              ),
              Dimens.boxHeight64,
            ],
          ),
        ),
      ),
    );
  }
}
