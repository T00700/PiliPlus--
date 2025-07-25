import 'package:PiliPlus/models_new/media_list/media_list.dart';

class MediaListData {
  List<MediaListItemModel>? mediaList;
  bool? hasMore;
  int? totalCount;
  String? nextStartKey;

  MediaListData({
    this.mediaList,
    this.hasMore,
    this.totalCount,
    this.nextStartKey,
  });

  factory MediaListData.fromJson(Map<String, dynamic> json) => MediaListData(
    mediaList: (json['media_list'] as List<dynamic>?)
        ?.map((e) => MediaListItemModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    hasMore: json['has_more'] as bool?,
    totalCount: json['total_count'] as int?,
    nextStartKey: json['next_start_key'] as String?,
  );
}
