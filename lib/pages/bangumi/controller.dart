import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/bangumi/list.dart';
import 'package:PiliPlus/models/common/tab_type.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/http/bangumi.dart';
import 'package:PiliPlus/utils/storage.dart';

class BangumiController extends CommonListController<
    List<BangumiListItemModel>?, BangumiListItemModel> {
  BangumiController({required this.tabType});
  final TabType tabType;

  RxBool isLogin = false.obs;
  int? mid;

  @override
  void onInit() {
    super.onInit();
    mid = Accounts.main.mid;
    isLogin.value = mid != 0;

    queryData();
    queryBangumiFollow();
    if (isLogin.value) {
      followController = ScrollController();
    }
  }

  @override
  Future onRefresh() {
    if (isLogin.value) {
      followPage = 1;
      followEnd = false;
    }
    queryBangumiFollow();
    return super.onRefresh();
  }

  late int followPage = 1;
  late RxInt followCount = (-1).obs;
  late bool followLoading = false;
  late bool followEnd = false;
  late Rx<LoadingState> followState = LoadingState.loading().obs;
  ScrollController? followController;

  // 我的订阅
  Future queryBangumiFollow([bool isRefresh = true]) async {
    if (isLogin.value.not || followLoading || (isRefresh.not && followEnd)) {
      return;
    }
    followLoading = true;
    dynamic res = await BangumiHttp.bangumiFollowList(
      mid: mid,
      type: tabType == TabType.bangumi ? 1 : 2,
      pn: followPage,
    );

    if (res is Success) {
      BangumiListDataModel data = res.response;
      List<BangumiListItemModel>? list = data.list;
      followCount.value = data.total ?? -1;
      if (data.hasNext == 0) {
        followEnd = true;
      }

      if (list.isNullOrEmpty) {
        followEnd = true;
        if (isRefresh) {
          followState.value = LoadingState.success(list);
        }
        followLoading = false;
        return;
      }

      if (isRefresh) {
        if (list!.length >= followCount.value) {
          followEnd = true;
        }
        followState.value = LoadingState.success(list);
        followController?.animToTop();
      } else if (followState.value is Success) {
        List<BangumiListItemModel> currentList =
            (followState.value as Success).response;
        currentList.addAll(list!);
        if (currentList.length >= followCount.value) {
          followEnd = true;
        }
        followState.refresh();
      }
      followPage++;
    } else if (isRefresh) {
      followState.value = res;
    }
    followLoading = false;
  }

  @override
  Future<LoadingState<List<BangumiListItemModel>?>> customGetData() =>
      BangumiHttp.bangumiList(
        page: currentPage,
        indexType: tabType == TabType.cinema ? 102 : null, // TODO: sort
      );

  @override
  void onClose() {
    followController?.dispose();
    super.onClose();
  }
}
