import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_media_app/constants/colors.dart';
import 'package:social_media_app/constants/dimens.dart';
import 'package:social_media_app/constants/strings.dart';
import 'package:social_media_app/constants/styles.dart';
import 'package:social_media_app/global_widgets/circular_progress_indicator.dart';
import 'package:social_media_app/global_widgets/custom_app_bar.dart';
import 'package:social_media_app/global_widgets/custom_refresh_indicator.dart';
import 'package:social_media_app/global_widgets/primary_text_btn.dart';
import 'package:social_media_app/modules/chat/controllers/chat_controller.dart';
import 'package:social_media_app/modules/chat/widgets/chat_widget.dart';
import 'package:social_media_app/modules/home/controllers/profile_controller.dart';
import 'package:social_media_app/routes/route_management.dart';

class ChatsTabView extends StatelessWidget {
  const ChatsTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
      child: SafeArea(
        child: SizedBox(
          width: Dimens.screenWidth,
          height: Dimens.screenHeight,
          child: NxRefreshIndicator(
            onRefresh: ChatController.find.fetchLastMessages,
            showProgress: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NxAppBar(
                  title: StringValues.chats,
                  padding: Dimens.edgeInsets8_16,
                  showBackBtn: false,
                ),
                Dimens.boxHeight8,
                _buildBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final profile = ProfileController.find;

    return Expanded(
      child: GetBuilder<ChatController>(
        builder: (logic) {
          if (!logic.initialized) {
            return const Center(child: NxCircularProgressIndicator());
          }

          logic.lastMessageList
              .sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: Dimens.edgeInsets0_16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (logic.isLoading)
                  const Center(child: NxCircularProgressIndicator()),
                if (logic.isLoading) Dimens.boxHeight16,
                if (logic.lastMessageData == null ||
                    logic.lastMessageList.isEmpty)
                  Center(
                    child: Text(
                      StringValues.noConversation,
                      style: AppStyles.style32Bold.copyWith(
                        color:
                            Theme.of(Get.context!).textTheme.subtitle1!.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ListView.builder(
                    itemCount: logic.lastMessageList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = logic.lastMessageList[index];
                      final isMe =
                          item.senderId == profile.profileDetails!.user!.id;
                      final isUserOnline = logic.isUserOnline(
                          isMe ? item.receiverId! : item.senderId!);
                      return ChatWidget(
                        chat: item,
                        totalLength: logic.lastMessageList.length,
                        index: logic.lastMessageList.indexOf(item),
                        onTap: () => RouteManagement.goToChatDetailsView(
                          isMe ? item.receiverId! : item.senderId!,
                          isMe ? item.receiver!.uname : item.sender!.uname,
                          isMe ? item.receiver!.avatar! : item.sender!.avatar!,
                        ),
                        isOnline: isUserOnline,
                      );
                    },
                  ),
                if (logic.isMoreLoading) Dimens.boxHeight8,
                if (logic.isMoreLoading)
                  const Center(child: NxCircularProgressIndicator()),
                if (!logic.isMoreLoading &&
                    logic.lastMessageData!.results != null &&
                    logic.lastMessageData!.hasNextPage!)
                  Center(
                    child: NxTextButton(
                      label: 'Load more',
                      onTap: logic.loadMore,
                      labelStyle: AppStyles.style14Bold.copyWith(
                        color: ColorValues.primaryLightColor,
                      ),
                      padding: Dimens.edgeInsets8_0,
                    ),
                  ),
                Dimens.boxHeight16,
              ],
            ),
          );
        },
      ),
    );
  }
}
