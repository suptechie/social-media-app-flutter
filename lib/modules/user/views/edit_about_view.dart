import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_media_app/common/custom_app_bar.dart';
import 'package:social_media_app/common/primary_filled_btn.dart';
import 'package:social_media_app/constants/dimens.dart';
import 'package:social_media_app/constants/strings.dart';
import 'package:social_media_app/constants/styles.dart';
import 'package:social_media_app/modules/user/controllers/edit_about_controller.dart';

class EditAboutView extends StatelessWidget {
  const EditAboutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SizedBox(
            width: Dimens.screenWidth,
            height: Dimens.screenHeight,
            child: GetBuilder<AboutController>(
              builder: (logic) => Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const NxAppBar(
                        title: StringValues.about,
                      ),
                      _buildBody(logic),
                    ],
                  ),
                  Positioned(
                    bottom: Dimens.zero,
                    left: Dimens.zero,
                    right: Dimens.zero,
                    child: NxFilledButton(
                      borderRadius: Dimens.zero,
                      onTap: logic.updateAbout,
                      label: StringValues.save,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AboutController logic) => Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: Dimens.edgeInsets8,
            child: FocusScope(
              node: logic.focusNode,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Dimens.boxHeight20,
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: StringValues.writeSomethingAboutYou,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    style: AppStyles.style16Normal,
                    controller: logic.aboutTextController,
                    onEditingComplete: logic.focusNode.unfocus,
                  ),
                  Dimens.boxHeight16,
                ],
              ),
            ),
          ),
        ),
      );
}
