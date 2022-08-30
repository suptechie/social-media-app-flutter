import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:social_media_app/apis/models/entities/notification.dart';
import 'package:social_media_app/apis/models/responses/notification_response.dart';
import 'package:social_media_app/apis/providers/api_provider.dart';
import 'package:social_media_app/apis/services/auth_service.dart';
import 'package:social_media_app/constants/strings.dart';
import 'package:social_media_app/helpers/utils.dart';

class NotificationController extends GetxController {
  static NotificationController get find => Get.find();

  final _auth = AuthService.find;
  final _apiProvider = ApiProvider(http.Client());

  final _isLoading = false.obs;
  final _isMoreLoading = false.obs;
  final _notificationData = const NotificationResponse().obs;

  final List<ApiNotification> _notificationList = [];

  bool get isLoading => _isLoading.value;

  bool get isMoreLoading => _isMoreLoading.value;

  NotificationResponse? get notificationData => _notificationData.value;

  List<ApiNotification> get notificationList => _notificationList;

  set setNotificationData(NotificationResponse value) =>
      _notificationData.value = value;

  Future<void> _fetchNotifications() async {
    AppUtils.printLog("Fetching Notifications Request");
    _isLoading.value = true;
    update();

    try {
      final response = await _apiProvider.getNotifications(_auth.token);

      final decodedData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        setNotificationData = NotificationResponse.fromJson(decodedData);
        _notificationList.clear();
        _notificationList.addAll(_notificationData.value.results!);
        _isLoading.value = false;
        update();
        AppUtils.printLog("Fetching Notifications Success");
      } else {
        _isLoading.value = false;
        update();
        AppUtils.printLog("Fetching Notifications Error");
        AppUtils.showSnackBar(
          decodedData[StringValues.message],
          StringValues.error,
        );
      }
    } on SocketException {
      _isLoading.value = false;
      update();
      AppUtils.printLog("Fetching Notifications Error");
      AppUtils.printLog(StringValues.internetConnError);
      AppUtils.showSnackBar(StringValues.internetConnError, StringValues.error);
    } on TimeoutException {
      _isLoading.value = false;
      update();
      AppUtils.printLog("Fetching Notifications Error");
      AppUtils.printLog(StringValues.connTimedOut);
      AppUtils.printLog(StringValues.connTimedOut);
      AppUtils.showSnackBar(StringValues.connTimedOut, StringValues.error);
    } on FormatException catch (e) {
      _isLoading.value = false;
      update();
      AppUtils.printLog("Fetching Notifications Error");
      AppUtils.printLog(StringValues.formatExcError);
      AppUtils.printLog(e);
      AppUtils.showSnackBar(StringValues.errorOccurred, StringValues.error);
    } catch (exc) {
      _isLoading.value = false;
      update();
      AppUtils.printLog("Fetching Notifications Error");
      AppUtils.printLog(StringValues.errorOccurred);
      AppUtils.printLog(exc);
      AppUtils.showSnackBar(StringValues.errorOccurred, StringValues.error);
    }
  }

  Future<void> _loadMore({int? page}) async {
    AppUtils.printLog("Fetching More Notifications Request");
    _isMoreLoading.value = true;
    update();

    try {
      final response =
          await _apiProvider.getNotifications(_auth.token, page: page);

      final decodedData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        setNotificationData = NotificationResponse.fromJson(decodedData);
        _notificationList.addAll(_notificationData.value.results!);
        _isMoreLoading.value = false;
        update();
        AppUtils.printLog("Fetching More Notifications Success");
      } else {
        _isMoreLoading.value = false;
        update();
        AppUtils.printLog("Fetching More Notifications Error");
        AppUtils.showSnackBar(
          decodedData[StringValues.message],
          StringValues.error,
        );
      }
    } on SocketException {
      _isMoreLoading.value = false;
      update();
      AppUtils.printLog("Fetching More Notifications Error");
      AppUtils.printLog(StringValues.internetConnError);
      AppUtils.showSnackBar(StringValues.internetConnError, StringValues.error);
    } on TimeoutException {
      _isMoreLoading.value = false;
      update();
      AppUtils.printLog("Fetching More Notifications Error");
      AppUtils.printLog(StringValues.connTimedOut);
      AppUtils.printLog(StringValues.connTimedOut);
      AppUtils.showSnackBar(StringValues.connTimedOut, StringValues.error);
    } on FormatException catch (e) {
      _isMoreLoading.value = false;
      update();
      AppUtils.printLog("Fetching More Notifications Error");
      AppUtils.printLog(StringValues.formatExcError);
      AppUtils.printLog(e);
      AppUtils.showSnackBar(StringValues.errorOccurred, StringValues.error);
    } catch (exc) {
      _isMoreLoading.value = false;
      update();
      AppUtils.printLog("Fetching More Notifications Error");
      AppUtils.printLog(StringValues.errorOccurred);
      AppUtils.printLog(exc);
      AppUtils.showSnackBar(StringValues.errorOccurred, StringValues.error);
    }
  }

  Future<void> getNotifications() async => await _fetchNotifications();

  Future<void> loadMore() async =>
      await _loadMore(page: _notificationData.value.currentPage! + 1);

  @override
  void onInit() {
    _fetchNotifications();
    super.onInit();
  }
}
