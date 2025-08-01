import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/fav_order_type.dart';
import 'package:PiliPlus/models_new/fav/fav_article/data.dart';
import 'package:PiliPlus/models_new/fav/fav_detail/data.dart';
import 'package:PiliPlus/models_new/fav/fav_folder/data.dart';
import 'package:PiliPlus/models_new/fav/fav_folder/list.dart';
import 'package:PiliPlus/models_new/fav/fav_note/list.dart';
import 'package:PiliPlus/models_new/fav/fav_pgc/data.dart';
import 'package:PiliPlus/models_new/fav/fav_topic/data.dart';
import 'package:PiliPlus/models_new/space/space_fav/data.dart';
import 'package:PiliPlus/models_new/sub/sub_detail/data.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/app_sign.dart';
import 'package:dio/dio.dart';

class FavHttp {
  static Future favFavFolder(mediaId) async {
    var res = await Request().post(
      Api.favFavFolder,
      data: {
        'media_id': mediaId,
        'csrf': Accounts.main.csrf,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return const {'status': true, 'msg': '收藏成功'};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future unfavFavFolder(mediaId) async {
    var res = await Request().post(
      Api.unfavFavFolder,
      data: {
        'media_id': mediaId,
        'csrf': Accounts.main.csrf,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return const {'status': true, 'msg': '取消收藏成功'};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future<LoadingState<FavDetailData>> userFavFolderDetail({
    required int mediaId,
    required int pn,
    required int ps,
    String keyword = '',
    FavOrderType order = FavOrderType.mtime,
    int type = 0,
  }) async {
    var res = await Request().get(
      Api.favResourceList,
      queryParameters: {
        'media_id': mediaId,
        'pn': pn,
        'ps': ps,
        'keyword': keyword,
        'order': order.name,
        'type': type,
        'tid': 0,
        'platform': 'web',
      },
    );
    if (res.data['code'] == 0) {
      return Success(FavDetailData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<SubDetailData>> favResourceList({
    required int id,
    required int pn,
    required int ps,
  }) async {
    var res = await Request().get(
      Api.favResourceList,
      queryParameters: {
        'media_id': id,
        'ps': ps,
        'pn': pn,
      },
    );
    if (res.data['code'] == 0) {
      return Success(SubDetailData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  // 取消订阅
  static Future cancelSub({required int id, required int type}) async {
    var res = type == 11
        ? await Request().post(
            Api.unfavFolder,
            queryParameters: {
              'media_id': id,
              'csrf': Accounts.main.csrf,
            },
          )
        : await Request().post(
            Api.unfavSeason,
            queryParameters: {
              'platform': 'web',
              'season_id': id,
              'csrf': Accounts.main.csrf,
            },
          );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future<LoadingState<SubDetailData>> favSeasonList({
    required int id,
    required int pn,
    required int ps,
  }) async {
    var res = await Request().get(
      Api.favSeasonList,
      queryParameters: {
        'season_id': id,
        'ps': ps,
        'pn': pn,
      },
    );
    if (res.data['code'] == 0) {
      return Success(SubDetailData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<FavTopicData>> favTopic({
    required int page,
  }) async {
    var res = await Request().get(
      Api.favTopicList,
      queryParameters: {
        'page_size': 24,
        'page_num': page,
        'web_location': 333.1387,
      },
    );
    if (res.data['code'] == 0) {
      return Success(FavTopicData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  static Future addFavTopic(topicId) async {
    var res = await Request().post(
      Api.addFavTopic,
      data: {
        'topic_id': topicId,
        'csrf': Accounts.main.csrf,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future delFavTopic(topicId) async {
    var res = await Request().post(
      Api.delFavTopic,
      data: {
        'topic_id': topicId,
        'csrf': Accounts.main.csrf,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future likeTopic(topicId, bool isLike) async {
    var res = await Request().post(
      Api.likeTopic,
      data: {
        'action': isLike ? 'cancel_like' : 'like',
        'up_mid': Accounts.main.mid,
        'topic_id': topicId,
        'csrf': Accounts.main.csrf,
        'business': 'topic',
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future<LoadingState<FavArticleData>> favArticle({
    required int page,
  }) async {
    var res = await Request().get(
      Api.favArticle,
      queryParameters: {
        'page_size': 20,
        'page': page,
      },
    );
    if (res.data['code'] == 0) {
      return Success(FavArticleData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  static Future addFavArticle({
    required dynamic id,
  }) async {
    var res = await Request().post(
      Api.addFavArticle,
      data: {
        'id': id,
        'csrf': Accounts.main.csrf,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future delFavArticle({
    required dynamic id,
  }) async {
    var res = await Request().post(
      Api.delFavArticle,
      data: {
        'id': id,
        'csrf': Accounts.main.csrf,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future<LoadingState<List<FavNoteItemModel>?>> userNoteList({
    required int page,
  }) async {
    var res = await Request().get(
      Api.userNoteList,
      queryParameters: {
        'pn': page,
        'ps': 10,
        'csrf': Accounts.main.csrf,
      },
    );
    if (res.data['code'] == 0) {
      List<FavNoteItemModel>? list = (res.data['data']?['list'] as List?)
          ?.map((e) => FavNoteItemModel.fromJson(e))
          .toList();
      return Success(list);
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<List<FavNoteItemModel>?>> noteList({
    required int page,
  }) async {
    var res = await Request().get(
      Api.noteList,
      queryParameters: {
        'pn': page,
        'ps': 10,
        'csrf': Accounts.main.csrf,
      },
    );
    if (res.data['code'] == 0) {
      List<FavNoteItemModel>? list = (res.data['data']?['list'] as List?)
          ?.map((e) => FavNoteItemModel.fromJson(e))
          .toList();
      return Success(list);
    } else {
      return Error(res.data['message']);
    }
  }

  static Future delNote({
    required bool isPublish,
    required List noteIds,
  }) async {
    final res = await Request().post(
      isPublish ? Api.delPublishNote : Api.delNote,
      data: {
        isPublish ? 'cvids' : 'note_ids': noteIds.join(','),
        'csrf': Accounts.main.csrf,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future<LoadingState<FavPgcData>> favPgc({
    required dynamic mid,
    required int type,
    required int pn,
    int? followStatus,
  }) async {
    var res = await Request().get(
      Api.favPgc,
      queryParameters: {
        'vmid': mid,
        'type': type,
        'follow_status': ?followStatus,
        'pn': pn,
      },
    );
    if (res.data['code'] == 0) {
      return Success(FavPgcData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  // 收藏夹
  static Future<LoadingState<FavFolderData>> userfavFolder({
    required int pn,
    required int ps,
    required dynamic mid,
  }) async {
    var res = await Request().get(
      Api.userFavFolder,
      queryParameters: {
        'pn': pn,
        'ps': ps,
        'up_mid': mid,
      },
    );
    if (res.data['code'] == 0) {
      return Success(FavFolderData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message'] ?? '账号未登录');
    }
  }

  static Future sortFavFolder({
    required List<int?> sort,
  }) async {
    Map<String, dynamic> data = {
      'sort': sort.join(','),
      'csrf': Accounts.main.csrf,
    };
    AppSign.appSign(data);
    var res = await Request().post(
      Api.sortFavFolder,
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future sortFav({
    required dynamic mediaId,
    required List<String> sort,
  }) async {
    Map<String, dynamic> data = {
      'media_id': mediaId,
      'sort': sort.join(','),
      'csrf': Accounts.main.csrf,
    };
    AppSign.appSign(data);
    var res = await Request().post(
      Api.sortFav,
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future cleanFav({
    required dynamic mediaId,
  }) async {
    var res = await Request().post(
      Api.cleanFav,
      data: {
        'media_id': mediaId,
        'platform': 'web',
        'csrf': Accounts.main.csrf,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future deleteFolder({
    required List<dynamic> mediaIds,
  }) async {
    var res = await Request().post(
      Api.deleteFolder,
      data: {
        'media_ids': mediaIds.join(','),
        'platform': 'web',
        'csrf': Accounts.main.csrf,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future addOrEditFolder({
    required bool isAdd,
    dynamic mediaId,
    required String title,
    required int privacy,
    required String cover,
    required String intro,
  }) async {
    var res = await Request().post(
      isAdd ? Api.addFolder : Api.editFolder,
      data: {
        'title': title,
        'intro': intro,
        'privacy': privacy,
        'cover': cover.isNotEmpty ? Uri.encodeFull(cover) : cover,
        'csrf': Accounts.main.csrf,
        'media_id': ?mediaId,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': FavFolderInfo.fromJson(res.data['data'])};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future favFolderInfo({
    dynamic mediaId,
  }) async {
    var res = await Request().get(
      Api.favFolderInfo,
      queryParameters: {
        'media_id': mediaId,
      },
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': FavFolderInfo.fromJson(res.data['data'])};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future seasonFav({
    required bool isFav,
    required dynamic seasonId,
  }) async {
    var res = await Request().post(
      isFav ? Api.unfavSeason : Api.favSeason,
      data: {
        'platform': 'web',
        'season_id': seasonId,
        'csrf': Accounts.main.csrf,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    if (res.data['code'] == 0) {
      return {
        'status': true,
      };
    } else {
      return {
        'status': false,
        'msg': res.data['message'],
      };
    }
  }

  static Future<LoadingState<List<SpaceFavData>?>> spaceFav({
    required int mid,
  }) async {
    Map<String, String> data = {
      'build': '8430300',
      'c_locale': 'zh_CN',
      'channel': 'bili',
      'mobi_app': 'android',
      'platform': 'android',
      's_locale': 'zh_CN',
      'statistics': Constants.statisticsApp,
      'up_mid': mid.toString(),
    };
    var res = await Request().get(
      Api.spaceFav,
      queryParameters: data,
      options: Options(
        headers: {
          'bili-http-engine': 'cronet',
          'user-agent': Constants.userAgentApp,
        },
      ),
    );
    if (res.data['code'] == 0) {
      return Success(
        (res.data['data'] as List?)
            ?.map((e) => SpaceFavData.fromJson(e))
            .toList(),
      );
    } else {
      return Error(res.data['message']);
    }
  }

  static Future communityAction({
    required dynamic opusId,
    required dynamic action,
  }) async {
    var res = await Request().post(
      Api.communityAction,
      queryParameters: {
        'csrf': Accounts.main.csrf,
      },
      data: {
        "entity": {
          "object_id_str": opusId,
          "type": {"biz": 2},
        },
        "action": action, // 3 fav, 4 unfav
      },
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  // （取消）收藏
  static Future favVideo({
    required String resources,
    String? addIds,
    String? delIds,
  }) async {
    var res = await Request().post(
      Api.favVideo,
      data: {
        'resources': resources,
        'add_media_ids': addIds ?? '',
        'del_media_ids': delIds ?? '',
        'csrf': Accounts.main.csrf,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  // （取消）收藏
  static Future unfavAll({
    required rid,
    required type,
  }) async {
    var res = await Request().post(
      Api.unfavAll,
      data: {
        'rid': rid,
        'type': type,
        'csrf': Accounts.main.csrf,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future copyOrMoveFav({
    required bool isCopy,
    required bool isFav,
    required dynamic srcMediaId,
    required dynamic tarMediaId,
    dynamic mid,
    required List resources,
  }) async {
    var res = await Request().post(
      isFav
          ? isCopy
                ? Api.copyFav
                : Api.moveFav
          : isCopy
          ? Api.copyToview
          : Api.moveToview,
      data: {
        'src_media_id': ?srcMediaId,
        'tar_media_id': tarMediaId,
        'mid': ?mid,
        'resources': resources.join(','),
        'platform': 'web',
        'csrf': Accounts.main.csrf,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future allFavFolders(mid) async {
    var res = await Request().get(
      Api.favFolder,
      queryParameters: {'up_mid': mid},
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': FavFolderData.fromJson(res.data['data'])};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  // 查看视频被收藏在哪个文件夹
  static Future<LoadingState<FavFolderData>> videoInFolder({
    dynamic mid,
    dynamic rid,
    dynamic type,
  }) async {
    var res = await Request().get(
      Api.favFolder,
      queryParameters: {
        'up_mid': mid,
        'rid': rid,
        'type': ?type,
      },
    );
    if (res.data['code'] == 0) {
      return Success(FavFolderData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }
}
