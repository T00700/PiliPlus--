import 'dart:math';

import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/icon_button.dart';
import 'package:PiliPlus/common/widgets/image_save.dart';
import 'package:PiliPlus/common/widgets/keep_alive_wrapper.dart';
import 'package:PiliPlus/common/widgets/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/spring_physics.dart';
import 'package:PiliPlus/common/widgets/stat/stat.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/bangumi/info.dart' as bangumi;
import 'package:PiliPlus/models/video_detail_res.dart' as video;
import 'package:PiliPlus/pages/common/common_slide_page.dart';
import 'package:PiliPlus/pages/video/detail/introduction/controller.dart';
import 'package:PiliPlus/pages/video/detail/introduction/widgets/page.dart';
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

enum EpisodeType { part, season, bangumi }

extension EpisodeTypeExt on EpisodeType {
  String get title => ['分P', '合集', '番剧'][index];
}

class EpisodePanel extends CommonSlidePage {
  const EpisodePanel({
    super.key,
    super.enableSlide,
    required this.videoIntroController,
    required this.heroTag,
    required this.type,
    // required this.count,
    // required this.name,
    required this.aid,
    required this.bvid,
    required this.cid,
    required this.cover,
    this.showTitle,
    required this.list,
    this.seasonId,
    this.initialTabIndex = 0,
    this.isSupportReverse,
    this.isReversed,
    this.onReverse,
    required this.changeFucCall,
    this.onClose,
  });

  final VideoIntroController videoIntroController;
  final String heroTag;
  final EpisodeType type;
  // final int count;
  // final String name;
  final int? aid;
  final String bvid;
  final int cid;
  final String? cover;
  final bool? showTitle;
  final List list;
  final int? seasonId;
  final int initialTabIndex;
  final bool? isSupportReverse;
  final bool? isReversed;
  final Function changeFucCall;
  final VoidCallback? onReverse;
  final VoidCallback? onClose;

  @override
  State<EpisodePanel> createState() => _EpisodePanelState();
}

class _EpisodePanelState extends CommonSlidePageState<EpisodePanel>
    with SingleTickerProviderStateMixin {
  // tab
  late final TabController _tabController = TabController(
    initialIndex: widget.initialTabIndex,
    length: widget.list.length,
    vsync: this,
  )..addListener(listener);
  late final RxInt _currentTabIndex = _tabController.index.obs;

  List get _getCurrEpisodes => widget.type == EpisodeType.season
      ? widget.list[_currentTabIndex.value].episodes
      : widget.list[_currentTabIndex.value];

  // item
  late RxInt _currentItemIndex;
  int get _findCurrentItemIndex => max(
        0,
        _getCurrEpisodes.indexWhere((item) => item.cid == widget.cid),
      );

  late final List<bool> _isReversed;
  late final List<ItemScrollController> _itemScrollController;

  // fav
  Rx<LoadingState>? _favState;

  late bool _isInit = true;
  late final Color primary = Theme.of(context).colorScheme.primary;
  final height = 120 / StyleString.aspectRatio + 10;

  void listener() {
    _currentTabIndex.value = _tabController.index;
  }

  @override
  void didUpdateWidget(EpisodePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showTitle != false) {
      return;
    }

    void jumpToCurrent() {
      int newItemIndex = _findCurrentItemIndex;
      if (_currentItemIndex.value != _findCurrentItemIndex) {
        _currentItemIndex.value = newItemIndex;
        try {
          _itemScrollController[_currentTabIndex.value].jumpTo(
            index: newItemIndex,
          );
        } catch (_) {}
      }
    }

    // jump to current
    if (_currentTabIndex.value != widget.initialTabIndex) {
      _tabController.animateTo(
        widget.initialTabIndex,
        duration: const Duration(milliseconds: 200),
      );
      Future.delayed(const Duration(milliseconds: 300)).then((_) {
        jumpToCurrent();
      });
    } else {
      jumpToCurrent();
    }
  }

  @override
  void initState() {
    super.initState();
    _itemScrollController =
        List.generate(widget.list.length, (_) => ItemScrollController());
    _isReversed = List.generate(widget.list.length, (_) => false);

    if (widget.type == EpisodeType.season && Accounts.main.isLogin) {
      _favState = LoadingState.loading().obs;
      VideoHttp.videoRelation(bvid: widget.bvid).then((result) {
        if (result['status']) {
          if (result['data']?['season_fav'] is bool) {
            _favState!.value =
                LoadingState.success(result['data']['season_fav']);
          }
        }
      });
    }

    _currentItemIndex = _findCurrentItemIndex.obs;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isInit = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            _itemScrollController[widget.initialTabIndex]
                .jumpTo(index: _currentItemIndex.value);
          } catch (_) {}
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(listener);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInit) {
      return CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
      );
    }

    return super.build(context);
  }

  @override
  Widget get buildPage => Material(
        color: widget.showTitle == false
            ? Colors.transparent
            : Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            _buildToolbar,
            if (widget.type == EpisodeType.season && widget.list.length > 1)
              TabBar(
                controller: _tabController,
                padding: const EdgeInsets.only(right: 60),
                isScrollable: true,
                tabs: widget.list.map((item) => Tab(text: item.title)).toList(),
                dividerHeight: 1,
                dividerColor: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            Expanded(
              child: widget.type == EpisodeType.season
                  ? Material(
                      color: Colors.transparent,
                      child: tabBarView(
                        controller: _tabController,
                        children: List.generate(
                          widget.list.length,
                          (index) => _buildBody(
                            index,
                            widget.list[index].episodes,
                          ),
                        ),
                      ),
                    )
                  : enableSlide
                      ? slideList()
                      : buildList,
            ),
          ],
        ),
      );

  @override
  Widget get buildList => Material(
        color: Colors.transparent,
        child: _buildBody(0, widget.list[0]),
      );

  Widget _buildBody(int index, episodes) {
    return KeepAliveWrapper(
      builder: (context) => ScrollablePositionedList.builder(
        padding: EdgeInsets.only(
          top: 5,
          bottom: MediaQuery.of(context).padding.bottom + 80,
        ),
        reverse: _isReversed[index],
        itemCount: episodes.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final episode = episodes[index];
          return widget.type == EpisodeType.season &&
                  widget.showTitle != false &&
                  episode.pages.length > 1
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => _buildEpisodeItem(
                        episode: episode,
                        index: index,
                        length: episodes.length,
                        isCurrentIndex:
                            _currentTabIndex.value == widget.initialTabIndex
                                ? _currentItemIndex.value == index
                                : false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      child: PagesPanel(
                        list:
                            widget.initialTabIndex == _currentTabIndex.value &&
                                    index == _currentItemIndex.value
                                ? null
                                : episode.pages,
                        cover: episode.arc?.pic,
                        heroTag: widget.heroTag,
                        videoIntroController: widget.videoIntroController,
                        bvid: IdUtils.av2bv(episode.aid),
                      ),
                    ),
                  ],
                )
              : Obx(
                  () => _buildEpisodeItem(
                    episode: episode,
                    index: index,
                    length: episodes.length,
                    isCurrentIndex:
                        _currentTabIndex.value == widget.initialTabIndex
                            ? _currentItemIndex.value == index
                            : false,
                  ),
                );
        },
        itemScrollController: _itemScrollController[index],
      ),
    );
  }

  Widget _buildEpisodeItem({
    required dynamic episode,
    required int index,
    required int length,
    required bool isCurrentIndex,
  }) {
    late String title;
    String? cover;
    num? duration;
    int? pubdate;
    int? view;
    int? danmaku;

    switch (episode) {
      case video.Part():
        cover = episode.firstFrame ?? widget.cover;
        title = episode.pagePart!;
        duration = episode.duration;
        pubdate = episode.ctime;
        break;
      case video.EpisodeItem():
        title = episode.title!;
        cover = episode.arc?.pic;
        duration = episode.arc?.duration;
        pubdate = episode.arc?.pubdate;
        view = episode.arc?.stat?.view;
        danmaku = episode.arc?.stat?.danmaku;
        break;
      case bangumi.EpisodeItem():
        if (episode.longTitle != null && episode.longTitle != "") {
          dynamic leading = episode.title ?? index + 1;
          title =
              "${Utils.isStringNumeric(leading) ? '第$leading话' : leading}  ${episode.longTitle!}";
        } else {
          title = episode.title!;
        }

        cover = episode.cover;
        duration = episode.duration == null ? null : episode.duration! ~/ 1000;
        pubdate = episode.pubTime;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: height,
        child: InkWell(
          onTap: () {
            if (episode.badge != null && episode.badge == "会员") {
              dynamic userInfo = GStorage.userInfo.get('userInfoCache');
              int vipStatus = 0;
              if (userInfo != null) {
                vipStatus = userInfo.vipStatus;
              }
              if (vipStatus != 1) {
                SmartDialog.showToast('需要大会员');
                // return;
              }
            }
            SmartDialog.showToast('切换到：$title');
            widget.onClose?.call();
            if (widget.showTitle == false) {
              _currentItemIndex.value = index;
            }
            widget.changeFucCall(
              episode is bangumi.EpisodeItem ? episode.epId : null,
              episode.runtimeType.toString() == "EpisodeItem"
                  ? episode.bvid
                  : widget.bvid,
              episode.cid,
              episode.runtimeType.toString() == "EpisodeItem"
                  ? episode.aid
                  : widget.aid,
              cover,
            );
          },
          onLongPress: () {
            if (cover?.isNotEmpty == true) {
              imageSaveDialog(context: context, title: title, cover: cover);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: StyleString.safeSpace,
              vertical: 5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (cover?.isNotEmpty == true)
                  AspectRatio(
                    aspectRatio: StyleString.aspectRatio,
                    child: LayoutBuilder(
                      builder: (context, boxConstraints) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            NetworkImgLayer(
                              src: cover,
                              width: boxConstraints.maxWidth,
                              height: boxConstraints.maxHeight,
                            ),
                            if (duration != null && duration > 0)
                              PBadge(
                                text: Utils.timeFormat(duration),
                                right: 6.0,
                                bottom: 6.0,
                                type: 'gray',
                              ),
                          ],
                        );
                      },
                    ),
                  )
                else if (isCurrentIndex)
                  Image.asset(
                    'assets/images/live.png',
                    color: primary,
                    height: 12,
                    semanticLabel: "正在播放：",
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .fontSize,
                            height: 1.42,
                            letterSpacing: 0.3,
                            fontWeight: isCurrentIndex ? FontWeight.bold : null,
                            color: isCurrentIndex ? primary : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (pubdate != null)
                        Text(
                          Utils.dateFormat(pubdate),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .fontSize,
                            height: 1,
                            color: Theme.of(context).colorScheme.outline,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      if (view != null) ...[
                        Row(
                          children: [
                            StatView(
                              context: context,
                              theme: 'gray',
                              value: view,
                            ),
                            if (danmaku != null) ...[
                              const SizedBox(width: 8),
                              StatDanMu(
                                context: context,
                                theme: 'gray',
                                value: danmaku,
                              ),
                            ],
                          ],
                        )
                      ],
                    ],
                  ),
                ),
                if (episode.badge != null) ...[
                  if (episode.badge == '会员')
                    Image.asset(
                      'assets/images/big-vip.png',
                      height: 20,
                      semanticLabel: "大会员",
                    )
                  else
                    Text(episode.badge),
                  const SizedBox(width: 10),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavBtn(LoadingState loadingState) {
    return switch (loadingState) {
      Success() => mediumButton(
          tooltip: loadingState.response ? '取消订阅' : '订阅',
          icon: loadingState.response
              ? Icons.notifications_off_outlined
              : Icons.notifications_active_outlined,
          onPressed: () async {
            dynamic result = await VideoHttp.seasonFav(
              isFav: loadingState.response,
              seasonId: widget.seasonId,
            );
            if (result['status']) {
              SmartDialog.showToast('${loadingState.response ? '取消' : ''}订阅成功');
              _favState!.value = LoadingState.success(!loadingState.response);
            } else {
              SmartDialog.showToast(result['msg']);
            }
          },
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget get _buildReverseBtn => mediumButton(
        tooltip: widget.isReversed == true ? '正序播放' : '倒序播放',
        icon: widget.isReversed == true
            ? MdiIcons.sortDescending
            : MdiIcons.sortAscending,
        onPressed: () {
          widget.onReverse?.call();
        },
      );

  Widget get _buildToolbar => Container(
        height: 45,
        padding: EdgeInsets.symmetric(
            horizontal: widget.showTitle != false ? 14 : 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            if (widget.showTitle != false)
              Text(
                widget.type.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            if (_favState != null) Obx(() => _buildFavBtn(_favState!.value)),
            mediumButton(
              tooltip: '跳至顶部',
              icon: Icons.vertical_align_top,
              onPressed: () {
                try {
                  _itemScrollController[_currentTabIndex.value].scrollTo(
                    index: !_isReversed[_currentTabIndex.value]
                        ? 0
                        : _getCurrEpisodes.length - 1,
                    duration: const Duration(milliseconds: 200),
                  );
                } catch (e) {
                  debugPrint('to top: $e');
                }
              },
            ),
            mediumButton(
              tooltip: '跳至底部',
              icon: Icons.vertical_align_bottom,
              onPressed: () {
                try {
                  _itemScrollController[_currentTabIndex.value].scrollTo(
                    index: !_isReversed[_currentTabIndex.value]
                        ? _getCurrEpisodes.length - 1
                        : 0,
                    duration: const Duration(milliseconds: 200),
                  );
                } catch (e) {
                  debugPrint('to bottom: $e');
                }
              },
            ),
            mediumButton(
              tooltip: '跳至当前',
              icon: Icons.my_location,
              onPressed: () async {
                try {
                  if (_currentTabIndex.value != widget.initialTabIndex) {
                    _tabController.animateTo(widget.initialTabIndex);
                    await Future.delayed(const Duration(milliseconds: 225));
                  }
                  _itemScrollController[_currentTabIndex.value].scrollTo(
                    index: _currentItemIndex.value,
                    duration: const Duration(milliseconds: 200),
                  );
                } catch (_) {}
              },
            ),
            if (widget.isSupportReverse == true)
              Obx(
                () {
                  return _currentTabIndex.value == widget.initialTabIndex
                      ? _buildReverseBtn
                      : const SizedBox.shrink();
                },
              ),
            const Spacer(),
            Obx(
              () => mediumButton(
                tooltip: _isReversed[_currentTabIndex.value] ? '顺序' : '倒序',
                icon: !_isReversed[_currentTabIndex.value]
                    ? MdiIcons.sortNumericAscending
                    : MdiIcons.sortNumericDescending,
                onPressed: () {
                  setState(() {
                    _isReversed[_currentTabIndex.value] =
                        !_isReversed[_currentTabIndex.value];
                  });
                },
              ),
            ),
            if (widget.onClose != null)
              mediumButton(
                tooltip: '关闭',
                icon: Icons.close,
                onPressed: widget.onClose,
              ),
          ],
        ),
      );
}
