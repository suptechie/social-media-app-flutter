import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:social_media_app/apis/providers/api_provider.dart';
import 'package:social_media_app/apis/services/auth_controller.dart';
import 'package:social_media_app/common/overlay.dart';
import 'package:social_media_app/constants/strings.dart';
import 'package:social_media_app/helpers/utils.dart';

class ChangePasswordController extends GetxController {
  static ChangePasswordController get find => Get.find();

  final _auth = AuthController.find;

  final _apiProvider = ApiProvider(http.Client());

  final oldPasswordTextController = TextEditingController();
  final newPasswordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  final FocusScopeNode focusNode = FocusScopeNode();

  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  Future<void> _changePassword(
    String oldPassword,
    String newPassword,
    String confPassword,
  ) async {
    if (oldPassword.isEmpty) {
      AppUtils.showSnackBar(
        StringValues.enterOldPassword,
        StringValues.warning,
      );
      return;
    }
    if (newPassword.isEmpty) {
      AppUtils.showSnackBar(
        StringValues.enterNewPassword,
        StringValues.warning,
      );
      return;
    }
    if (confPassword.isEmpty) {
      AppUtils.showSnackBar(
        StringValues.enterConfirmPassword,
        StringValues.warning,
      );
      return;
    }

    final body = {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confPassword,
    };

    _isLoading.value = true;
    await AppOverlay.showLoadingIndicator();
    update();

    try {
      final response = await _apiProvider.changePassword(body, _auth.token);

      final decodedData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        await _auth.logout();
        await AppOverlay.hideLoadingIndicator();
        _isLoading.value = false;
        update();
      } else {
        await AppOverlay.hideLoadingIndicator();
        _isLoading.value = false;
        update();
        AppUtils.showSnackBar(
          decodedData[StringValues.message],
          StringValues.error,
        );
      }
    } catch (err) {
      await AppOverlay.hideLoadingIndicator();
      _isLoading.value = false;
      update();
      debugPrint(err.toString());
      AppUtils.showSnackBar(
        '${StringValues.errorOccurred}: ${err.toString()}',
        StringValues.error,
      );
    }
  }

  Future<void> changePassword() async {
    AppUtils.closeFocus();
    await _changePassword(
      oldPasswordTextController.text.trim(),
      newPasswordTextController.text.trim(),
      confirmPasswordTextController.text.trim(),
    );
  }
}