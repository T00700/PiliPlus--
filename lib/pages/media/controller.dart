import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models_new/fav/fav_video/data.dart';
import 'package:PiliPlus/pages/common/common_data_controller.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MediaController extends CommonDataController<FavVideoData, FavVideoData> {
  final list = <({IconData icon, String title, VoidCallback onTap})>[
    (
      icon: Icons.history,
      title: '观看记录',
      onTap: () => Get.toNamed('/history'),
    ),
    (
      icon: Icons.subscriptions_outlined,
      title: '我的订阅',
      onTap: () => Get.toNamed('/subscription'),
    ),
    (
      icon: Icons.watch_later_outlined,
      title: '稍后再看',
      onTap: () => Get.toNamed('/later'),
    ),
    (
      icon: Icons.create_outlined,
      title: '创作中心',
      onTap: () => Get.toNamed(
            '/webview',
            parameters: {
              'url': 'https://member.bilibili.com/platform/home',
            },
          ),
    ),
  ];
  int? mid;
  RxInt count = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    mid = Accounts.main.mid;
    if (mid != 0) {
      queryData();
    }
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<FavVideoData> response) {
    count.value = response.response.count ?? -1;
    loadingState.value = response;
    return true;
  }

  @override
  Future<LoadingState<FavVideoData>> customGetData() {
    mid ??= Accounts.main.mid;
    return FavHttp.userfavFolder(
      pn: 1,
      ps: 5,
      mid: mid,
    );
  }
}
