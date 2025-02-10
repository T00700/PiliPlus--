import 'dart:math';

import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/imageview.dart';
import 'package:PiliPlus/grpc/app/main/community/reply/v1/reply.pb.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/pages/video/detail/reply/widgets/zan_grpc.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/common/widgets/network_img_layer.dart';
import 'package:PiliPlus/models/common/reply_type.dart';
import 'package:PiliPlus/pages/video/detail/index.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/url_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import '../../../../../utils/app_scheme.dart';
import 'package:html/parser.dart' show parse;

class ReplyItemGrpc extends StatelessWidget {
  const ReplyItemGrpc({
    super.key,
    required this.replyItem,
    this.replyLevel,
    this.showReplyRow = true,
    this.replyReply,
    this.replyType,
    this.needDivider = true,
    this.onReply,
    this.onDelete,
    this.upMid,
    this.isTop = false,
    this.showDialogue,
    this.getTag,
    this.onViewImage,
    this.onDismissed,
    this.callback,
  });
  final ReplyInfo replyItem;
  final String? replyLevel;
  final bool showReplyRow;
  final Function? replyReply;
  final ReplyType? replyType;
  final bool needDivider;
  final Function()? onReply;
  final Function(dynamic rpid, dynamic frpid)? onDelete;
  final dynamic upMid;
  final bool isTop;
  final VoidCallback? showDialogue;
  final Function? getTag;
  final VoidCallback? onViewImage;
  final ValueChanged<int>? onDismissed;
  final Function(List<String>, int)? callback;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // 点击整个评论区 评论详情/回复
        onTap: () {
          feedBack();
          replyReply?.call(replyItem, null, isTop);
        },
        onLongPress: () {
          feedBack();
          // showDialog(
          //   context: Get.context!,
          //   builder: (context) => AlertDialog(
          //     content: SelectableText(jsonEncode(replyItem.toProto3Json())),
          //   ),
          // );
          showModalBottomSheet(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (context) {
              return morePanel(
                context: context,
                item: replyItem,
                onDelete: (rpid) {
                  onDelete?.call(rpid, null);
                },
              );
            },
          );
        },
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildAuthorPanel(context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 8, 5),
        child: content(context),
      );

  Widget _buildContent(context) {
    print(replyItem.member.garbCardImage);
    return Column(
      children: [
        if (ModuleAuthorModel.showDynDecorate &&
            replyItem.member.hasGarbCardImage())
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 8,
                right: 12,
                // child: GestureDetector(
                //   onTap: replyItem.member.garbCardJumpUrl.isNotEmpty
                //       ? () {
                //           Get.toNamed(
                //             'webview',
                //             parameters: {
                //               'url': replyItem.member.garbCardJumpUrl
                //             },
                //           );
                //         }
                //       : null,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    CachedNetworkImage(
                      height: 38,
                      imageUrl: replyItem.member.garbCardImage,
                    ),
                    if (replyItem.member.hasGarbCardNumber())
                      Text(
                        'NO.\n${replyItem.member.garbCardNumber}',
                        style: replyItem.member.garbCardFanColor.startsWith('#')
                            ? TextStyle(
                                fontSize: 8,
                                fontFamily: 'digital_id_num',
                                color: Color(
                                  int.parse(
                                    replyItem.member.garbCardFanColor
                                        .replaceFirst('#', '0xFF'),
                                  ),
                                ),
                              )
                            : null,
                      ),
                  ],
                ),
              ),
              // ),
              _buildAuthorPanel(context),
            ],
          )
        else
          _buildAuthorPanel(context),
        if (needDivider)
          Divider(
            indent: 55,
            endIndent: 15,
            height: 0.3,
            color:
                Theme.of(context).colorScheme.onInverseSurface.withOpacity(0.5),
          )
      ],
    );
  }

  Widget lfAvtar(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (ModuleAuthorModel.showDynDecorate &&
            replyItem.member.hasGarbPendantImage()) ...[
          Padding(
            padding: const EdgeInsets.all(2),
            child: NetworkImgLayer(
              src: replyItem.member.face,
              width: 30,
              height: 30,
              type: 'avatar',
            ),
          ),
          Positioned(
            left: -9,
            top: -9,
            child: IgnorePointer(
              child: CachedNetworkImage(
                width: 52,
                height: 52,
                imageUrl: replyItem.member.garbPendantImage,
              ),
            ),
          ),
        ] else
          NetworkImgLayer(
            src: replyItem.member.face,
            width: 34,
            height: 34,
            type: 'avatar',
          ),
        if (replyItem.member.vipStatus > 0)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                //borderRadius: BorderRadius.circular(7),
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Image.asset(
                'assets/images/big-vip.png',
                height: 14,
                semanticLabel: "大会员",
              ),
            ),
          ),
        //https://www.bilibili.com/blackboard/activity-whPrHsYJ2.html
        if (replyItem.member.officialVerifyType == 0)
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(8),
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface,
              ),
              child: const Icon(
                Icons.offline_bolt,
                color: Colors.yellow,
                size: 14,
                semanticLabel: "认证个人",
              ),
            ),
          )
        else if (replyItem.member.officialVerifyType == 1)
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(8),
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface,
              ),
              child: const Icon(
                Icons.offline_bolt,
                color: Colors.lightBlueAccent,
                size: 14,
                semanticLabel: "认证机构",
              ),
            ),
          ),
      ],
    );
  }

  Widget content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        /// fix Stack内GestureDetector  onTap无效
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            feedBack();
            Get.toNamed('/member?mid=${replyItem.mid}');
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              lfAvtar(context),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        replyItem.member.name,
                        style: TextStyle(
                          color: (replyItem.member.vipStatus > 0 &&
                                  replyItem.member.vipType == 2)
                              ? context.vipColor
                              : Theme.of(context).colorScheme.outline,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Image.asset(
                        'assets/images/lv/lv${replyItem.member.level}.png',
                        height: 11,
                        semanticLabel: "等级：${replyItem.member.level}",
                      ),
                      const SizedBox(width: 6),
                      if (replyItem.mid == upMid)
                        const PBadge(
                          text: 'UP',
                          size: 'small',
                          stack: 'normal',
                          fs: 9,
                        ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        Utils.dateFormat(replyItem.ctime.toInt()),
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.labelSmall!.fontSize,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      if (replyItem.replyControl.location.isNotEmpty)
                        Text(
                          ' • ${replyItem.replyControl.location}',
                          style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .fontSize,
                              color: Theme.of(context).colorScheme.outline),
                        ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        // title
        Padding(
          padding:
              const EdgeInsets.only(top: 10, left: 45, right: 6, bottom: 4),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              String text = replyItem.content.message;
              TextStyle style = TextStyle(
                height: 1.75,
                fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
              );
              TextPainter? textPainter;
              bool? didExceedMaxLines;
              if (replyLevel == '1' && GlobalData().replyLengthLimit != 0) {
                textPainter = TextPainter(
                  text: TextSpan(text: text, style: style),
                  maxLines: GlobalData().replyLengthLimit,
                  textDirection: Directionality.of(context),
                )..layout(maxWidth: constraints.maxWidth);
                didExceedMaxLines = textPainter.didExceedMaxLines;
              }
              return Semantics(
                label: text,
                child: Text.rich(
                  style: style,
                  TextSpan(
                    children: [
                      if (isTop) ...[
                        const WidgetSpan(
                          alignment: PlaceholderAlignment.top,
                          child: PBadge(
                            text: 'TOP',
                            size: 'small',
                            stack: 'normal',
                            type: 'line',
                            fs: 9,
                            semanticsLabel: '置顶',
                            textScaleFactor: 1,
                          ),
                        ),
                        const TextSpan(text: ' '),
                      ],
                      buildContent(
                        context,
                        replyItem,
                        replyReply,
                        null,
                        textPainter,
                        didExceedMaxLines,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // 操作区域
        buttonAction(context, replyItem.replyControl),
        // 一楼的评论
        if (( //replyItem.replyControl!.isShow! ||
                replyItem.replies.isNotEmpty ||
                    replyItem.replyControl.subReplyEntryText.isNotEmpty) &&
            showReplyRow) ...[
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 12),
            child: replyItemRow(
              context: context,
            ),
          ),
        ],
      ],
    );
  }

  get _style => TextButton.styleFrom(
        padding: const EdgeInsets.all(0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity(horizontal: -2, vertical: -2),
      );

  // 感谢、回复、复制
  Widget buttonAction(BuildContext context, replyControl) {
    return Row(
      children: <Widget>[
        const SizedBox(width: 36),
        SizedBox(
          height: 32,
          child: TextButton(
            style: _style,
            onPressed: () {
              feedBack();
              onReply?.call();
            },
            child: Row(children: [
              Icon(
                Icons.reply,
                size: 18,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.8),
              ),
              const SizedBox(width: 3),
              Text(
                '回复',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 2),
        if (replyItem.replyControl.upLike) ...[
          SizedBox(
            height: 32,
            child: TextButton(
              onPressed: null,
              style: _style,
              child: Text(
                'UP主觉得很赞',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
        ],
        if (replyItem.replyControl.cardLabels
            .map((item) => item.textContent)
            .toList()
            .contains('热评'))
          Text(
            '热评',
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: Theme.of(context).textTheme.labelMedium!.fontSize),
          ),
        if (replyLevel == '2' &&
            needDivider &&
            replyItem.id != replyItem.dialog)
          SizedBox(
            height: 32,
            child: TextButton(
              onPressed: showDialogue,
              style: _style,
              child: Text(
                '查看对话',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        const Spacer(),
        ZanButtonGrpc(replyItem: replyItem, replyType: replyType),
        const SizedBox(width: 5)
      ],
    );
  }

  Widget replyItemRow({required BuildContext context}) {
    final bool extraRow = replyItem.replies.length < replyItem.count.toInt();
    return Container(
      margin: const EdgeInsets.only(left: 42, right: 4, top: 0),
      child: Material(
        color: Theme.of(context).colorScheme.onInverseSurface,
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.hardEdge,
        animationDuration: Duration.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (replyItem.replies.isNotEmpty)
              for (int i = 0; i < replyItem.replies.length; i++) ...[
                InkWell(
                  // 一楼点击评论展开评论详情
                  onTap: () => replyReply?.call(
                      replyItem, replyItem.replies[i].id.toInt(), isTop),
                  onLongPress: () {
                    feedBack();
                    showModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      isScrollControlled: true,
                      builder: (context) {
                        return morePanel(
                          context: context,
                          item: replyItem.replies[i],
                          onDelete: (rpid) {
                            onDelete?.call(rpid, replyItem.id.toInt());
                          },
                        );
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      8,
                      i == 0 && (extraRow || replyItem.replies.length > 1)
                          ? 8
                          : 4,
                      8,
                      i == 0 && (extraRow || replyItem.replies.length > 1)
                          ? 4
                          : 6,
                    ),
                    child: Semantics(
                      label:
                          '${replyItem.replies[i].member.name} ${replyItem.replies[i].content.message}',
                      excludeSemantics: true,
                      child: Text.rich(
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .fontSize,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.85),
                            height: 1.6),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        TextSpan(
                          children: [
                            TextSpan(
                              text: replyItem.replies[i].member.name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  feedBack();
                                  Get.toNamed(
                                    '/member?mid=${replyItem.replies[i].member.mid}',
                                  );
                                },
                            ),
                            if (replyItem.replies[i].mid == upMid) ...[
                              const TextSpan(text: ' '),
                              const WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: PBadge(
                                  text: 'UP',
                                  size: 'small',
                                  stack: 'normal',
                                  fs: 9,
                                  textScaleFactor: 1,
                                ),
                              ),
                              const TextSpan(text: ' '),
                            ],
                            TextSpan(
                              text: replyItem.replies[i].root ==
                                      replyItem.replies[i].parent
                                  ? ': '
                                  : replyItem.replies[i].mid == upMid
                                      ? ''
                                      : ' ',
                            ),
                            buildContent(
                              context,
                              replyItem.replies[i],
                              replyReply,
                              replyItem,
                              null,
                              null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            if (extraRow)
              InkWell(
                // 一楼点击【共xx条回复】展开评论详情
                onTap: () => replyReply?.call(replyItem, null, isTop),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(8, 5, 8, 8),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.labelMedium!.fontSize,
                      ),
                      children: [
                        if (replyItem.replyControl.upReply)
                          TextSpan(
                            text: 'UP主等人 ',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.85),
                            ),
                          ),
                        TextSpan(
                          text: replyItem.replyControl.subReplyEntryText,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  InlineSpan buildContent(
    BuildContext context,
    replyItem,
    replyReply,
    fReplyItem,
    textPainter,
    didExceedMaxLines,
  ) {
    final String routePath = Get.currentRoute;
    bool isVideoPage = routePath.startsWith('/video');

    // replyItem 当前回复内容
    // replyReply 查看二楼回复（回复详情）回调
    // fReplyItem 父级回复内容，用作二楼回复（回复详情）展示
    final Content content = replyItem.content;
    String message = content.message;
    final List<InlineSpan> spanChildren = <InlineSpan>[];

    if (didExceedMaxLines == true) {
      final textSize = textPainter.size;
      final double maxHeight = textPainter.preferredLineHeight * 6;
      var position = textPainter.getPositionForOffset(
        Offset(
          textSize.width,
          maxHeight, // textSize.height,
        ),
      );
      // final endOffset = textPainter.getOffsetBefore(position.offset);
      message = message.substring(0, position.offset);
    }

    // return TextSpan(text: message);

    // 投票
    if (content.hasVote()) {
      message.splitMapJoin(RegExp(r"\{vote:\d+?\}"), onMatch: (Match match) {
        // String matchStr = match[0]!;
        spanChildren.add(
          TextSpan(
            text: '投票: ${content.vote.title}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Get.toNamed(
                  '/webview',
                  parameters: {
                    'url':
                        'https://t.bilibili.com/vote/h5/index/#/result?vote_id=${content.vote.id}',
                  },
                );
              },
          ),
        );
        return '';
      }, onNonMatch: (String str) {
        return str;
      });
      message = message.replaceAll(RegExp(r"\{vote:\d+?\}"), "");
    }
    message = parse(message).body?.text ?? message;
    // .replaceAll('&amp;', '&')
    // .replaceAll('&lt;', '<')
    // .replaceAll('&gt;', '>')
    // .replaceAll('&quot;', '"')
    // .replaceAll('&apos;', "'")
    // .replaceAll('&nbsp;', ' ');
    // 构建正则表达式
    final List<String> specialTokens = [
      ...content.emote.keys,
      ...content.topic.keys.map((e) => '#$e#'),
      ...content.atNameToMid.keys.map((e) => '@$e'),
    ];
    List<String> jumpUrlKeysList = content.url.keys.map<String>((String e) {
      return e;
    }).toList();
    specialTokens.sort((a, b) => b.length.compareTo(a.length));
    String patternStr = specialTokens.map(RegExp.escape).join('|');
    if (patternStr.isNotEmpty) {
      patternStr += "|";
    }
    patternStr += r'(\b(?:\d+[:：])?\d+[:：]\d+\b)';
    if (jumpUrlKeysList.isNotEmpty) {
      patternStr += '|${jumpUrlKeysList.map(RegExp.escape).join('|')}';
    }
    patternStr += r'|https?://\S+\b';
    final RegExp pattern = RegExp(patternStr);
    List<String> matchedStrs = [];
    void addPlainTextSpan(str) {
      spanChildren.add(TextSpan(
        text: str,
      ));
      // TextSpan(
      //
      //     text: str,
      //     recognizer: TapGestureRecognizer()
      //       ..onTap = () => replyReply
      //           ?.call(replyItem.root == 0 ? replyItem : fReplyItem)))));
    }

    late final bool enableWordRe =
        GStorage.setting.get(SettingBoxKey.enableWordRe, defaultValue: false);

    // 分割文本并处理每个部分
    message.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        String matchStr = match[0]!;
        if (content.emote.containsKey(matchStr)) {
          // 处理表情
          final int size = content.emote[matchStr]!.size.toInt();
          spanChildren.add(WidgetSpan(
            child: ExcludeSemantics(
                child: NetworkImgLayer(
              src: content.emote[matchStr]?.hasGifUrl() == true
                  ? content.emote[matchStr]?.gifUrl
                  : content.emote[matchStr]?.url,
              type: 'emote',
              width: size * 20,
              height: size * 20,
              semanticsLabel: matchStr,
            )),
          ));
        } else if (matchStr.startsWith("@") &&
            content.atNameToMid.containsKey(matchStr.substring(1))) {
          // 处理@用户
          final String userName = matchStr.substring(1);
          final int userId = content.atNameToMid[userName]!.toInt();
          spanChildren.add(
            TextSpan(
              text: matchStr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Get.toNamed('/member?mid=$userId');
                },
            ),
          );
        } else if (RegExp(r'^\b(?:\d+[:：])?\d+[:：]\d+\b$').hasMatch(matchStr)) {
          matchStr = matchStr.replaceAll('：', ':');
          bool isValid = false;
          try {
            List<int> split = matchStr
                .split(':')
                .map((item) => int.parse(item))
                .toList()
                .reversed
                .toList();
            int seek = 0;
            for (int i = 0; i < split.length; i++) {
              seek += split[i] * pow(60, i).toInt();
            }
            int duration = Get.find<VideoDetailController>(
                  tag: getTag?.call() ?? Get.arguments['heroTag'],
                ).data.timeLength ??
                0;
            isValid = seek * 1000 <= duration;
          } catch (e) {
            debugPrint('failed to validate: $e');
          }
          spanChildren.add(
            TextSpan(
              text: isValid ? ' $matchStr ' : matchStr,
              style: isValid && isVideoPage
                  ? TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              recognizer: isValid
                  ? (TapGestureRecognizer()
                    ..onTap = () {
                      // 跳转到指定位置
                      if (isVideoPage) {
                        try {
                          SmartDialog.showToast('跳转至：$matchStr');
                          Get.find<VideoDetailController>(
                                  tag: Get.arguments['heroTag'])
                              .plPlayerController
                              .seekTo(
                                  Duration(seconds: Utils.duration(matchStr)),
                                  type: 'slider');
                        } catch (e) {
                          SmartDialog.showToast('跳转失败: $e');
                        }
                      }
                    })
                  : null,
            ),
          );
        } else {
          String appUrlSchema = '';
          if (content.url[matchStr] != null &&
              !matchedStrs.contains(matchStr)) {
            appUrlSchema = content.url[matchStr]!.appUrlSchema;
            if (appUrlSchema.startsWith('bilibili://search') && !enableWordRe) {
              addPlainTextSpan(matchStr);
              return "";
            }
            spanChildren.addAll(
              [
                if (content.url[matchStr]?.hasPrefixIcon() == true) ...[
                  WidgetSpan(
                    child: Image.network(
                      content.url[matchStr]!.prefixIcon.http2https,
                      height: 19,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                ],
                TextSpan(
                  text: content.url[matchStr]!.title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      late final String title = content.url[matchStr]!.title;
                      if (appUrlSchema == '') {
                        if (RegExp(r'^(av|bv)', caseSensitive: false)
                            .hasMatch(matchStr)) {
                          UrlUtils.matchUrlPush(matchStr, '');
                        } else if (RegExp(r'^cv\d+$', caseSensitive: false)
                            .hasMatch(matchStr)) {
                          String cvid = 'cv${matchStr.substring(2)}';
                          Get.toNamed('/htmlRender', parameters: {
                            'url': 'https://www.bilibili.com/read/$cvid',
                            'title': title,
                            'id': cvid,
                            'dynamicType': 'read'
                          });
                        } else {
                          String? cvId = RegExp(r'/read/(cv\d+)')
                              .firstMatch(matchStr)
                              ?.group(1);
                          if (cvId != null) {
                            Get.toNamed('/htmlRender', parameters: {
                              'url': matchStr,
                              'title': title,
                              'id': cvId,
                              'dynamicType': 'read'
                            });
                            return;
                          }
                          final String redirectUrl =
                              (await UrlUtils.parseRedirectUrl(matchStr)) ??
                                  matchStr;
                          // if (redirectUrl == matchStr) {
                          //   Clipboard.setData(ClipboardData(text: matchStr));
                          //   SmartDialog.showToast('地址可能有误');
                          //   return;
                          // }
                          Uri uri = Uri.parse(redirectUrl);
                          PiliScheme.routePush(uri);
                          // final String pathSegment = Uri.parse(redirectUrl).path;
                          // final String lastPathSegment =
                          //     pathSegment.split('/').last;
                          // if (lastPathSegment.startsWith('BV')) {
                          //   UrlUtils.matchUrlPush(
                          //     lastPathSegment,
                          //     title,
                          //     redirectUrl,
                          //   );
                          // } else {
                          //   Get.toNamed(
                          //     '/webview',
                          //     parameters: {
                          //       'url': redirectUrl,
                          //       'type': 'url',
                          //       'pageTitle': title
                          //     },
                          //   );
                          // }
                        }
                      } else {
                        if (appUrlSchema.startsWith('bilibili://search')) {
                          Get.toNamed('/searchResult',
                              parameters: {'keyword': title});
                        } else if (matchStr.startsWith('https://b23.tv')) {
                          final String redirectUrl =
                              (await UrlUtils.parseRedirectUrl(matchStr)) ??
                                  matchStr;
                          final String pathSegment =
                              Uri.parse(redirectUrl).path;
                          final String lastPathSegment =
                              pathSegment.split('/').last;
                          if (lastPathSegment.startsWith('BV')) {
                            UrlUtils.matchUrlPush(
                              lastPathSegment,
                              redirectUrl,
                            );
                          } else {
                            Utils.handleWebview(redirectUrl);
                          }
                        } else {
                          Utils.handleWebview(matchStr);
                        }
                      }
                    },
                )
              ],
            );
            // 只显示一次
            matchedStrs.add(matchStr);
          } else if (matchStr.length > 1 &&
              content.topic[matchStr.substring(1, matchStr.length - 1)] !=
                  null) {
            spanChildren.add(
              TextSpan(
                text: matchStr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    final String topic =
                        matchStr.substring(1, matchStr.length - 1);
                    Get.toNamed('/searchResult',
                        parameters: {'keyword': topic});
                  },
              ),
            );
          } else if (RegExp(r'https?://\S+\b').hasMatch(matchStr)) {
            spanChildren.add(
              TextSpan(
                text: ' $matchStr ',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    if (matchStr.startsWith('https://b23.tv')) {
                      final String redirectUrl =
                          (await UrlUtils.parseRedirectUrl(matchStr)) ??
                              matchStr;
                      final String pathSegment = Uri.parse(redirectUrl).path;
                      final String lastPathSegment =
                          pathSegment.split('/').last;
                      if (lastPathSegment.startsWith('BV')) {
                        UrlUtils.matchUrlPush(
                          lastPathSegment,
                          redirectUrl,
                        );
                      } else {
                        PiliScheme.routePush(Uri.parse(matchStr));
                      }
                    } else {
                      PiliScheme.routePush(Uri.parse(matchStr));
                    }
                  },
              ),
            );
          } else {
            addPlainTextSpan(matchStr);
          }
        }
        return '';
      },
      onNonMatch: (String nonMatchStr) {
        addPlainTextSpan(nonMatchStr);
        return nonMatchStr;
      },
    );

    if (content.url.keys.isNotEmpty) {
      List<String> unmatchedItems = content.url.keys
          .toList()
          .where((item) => !content.message.contains(item))
          .toList();
      if (unmatchedItems.isNotEmpty) {
        for (int i = 0; i < unmatchedItems.length; i++) {
          String patternStr = unmatchedItems[i];
          if (content.url[patternStr]?.extra.isWordSearch == true &&
              enableWordRe.not) {
            continue;
          }
          spanChildren.addAll(
            [
              if (content.url[patternStr]?.hasPrefixIcon() == true) ...[
                WidgetSpan(
                  child: Image.network(
                    content.url[patternStr]!.prefixIcon.http2https,
                    height: 19,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              ],
              TextSpan(
                text: content.url[patternStr]!.title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    String? cvid = RegExp(r'note-app/view\?cvid=(\d+)')
                        .firstMatch(patternStr)
                        ?.group(1);
                    if (cvid != null) {
                      Get.toNamed('/htmlRender', parameters: {
                        'url': 'https://www.bilibili.com/read/cv$cvid',
                        'title': '',
                        'id': 'cv$cvid',
                        'dynamicType': 'read'
                      });
                      return;
                    }

                    Utils.handleWebview(patternStr);
                  },
              )
            ],
          );
        }
      }
    }

    if (didExceedMaxLines == true) {
      spanChildren.add(
        TextSpan(
          text: '\n查看更多',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    // 图片渲染
    if (content.pictures.isNotEmpty) {
      spanChildren.add(const TextSpan(text: '\n'));
      spanChildren.add(
        WidgetSpan(
          child: LayoutBuilder(
            builder: (context, constraints) => imageview(
              constraints.maxWidth,
              content.pictures
                  .map(
                    (item) => ImageModel(
                      width: item.imgWidth,
                      height: item.imgHeight,
                      url: item.imgSrc,
                    ),
                  )
                  .toList(),
              onViewImage: onViewImage,
              onDismissed: onDismissed,
              callback: callback,
            ),
          ),
        ),
      );
    }

    // 笔记链接
    if (content.hasRichText()) {
      spanChildren.add(
        TextSpan(
          text: ' 笔记',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => Utils.handleWebview(content.richText.note.clickUrl),
        ),
      );
    }
    // spanChildren.add(TextSpan(text: matchMember));
    return TextSpan(children: spanChildren);
  }

  Widget morePanel({
    required BuildContext context,
    required dynamic item,
    required onDelete,
  }) {
    Future<dynamic> menuActionHandler(String type) async {
      String message = item.content.message;
      switch (type) {
        case 'report':
          Get.back();
          dynamic result = await Get.toNamed(
            '/webview',
            parameters: {
              'url':
                  'https://www.bilibili.com/h5/comment/report?mid=${item.mid}&oid=${item.oid}&pageType=1&rpid=${item.id}&platform=android',
            },
          );
          if (result == true) {
            onDelete?.call(item.id.toInt());
          }
          break;
        case 'copyAll':
          Get.back();
          Utils.copyText(message);
          break;
        case 'copyFreedom':
          Get.back();
          showDialog(
            context: Get.context!,
            builder: (context) {
              return Dialog(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: SelectableText(message),
                ),
              );
            },
          );
          break;
        // case 'block':
        //   SmartDialog.showToast('加入黑名单');
        //   break;
        // case 'report':
        //   SmartDialog.showToast('举报');
        //   break;
        case 'delete':
          //弹出确认提示：
          Get.back();
          bool? isDelete = await showDialog<bool>(
            context: Get.context!,
            builder: (context) {
              return AlertDialog(
                title: const Text('删除评论（测试）'),
                content: Text(
                    '确定尝试删除这条评论吗？\n\n$message\n\n注：只能删除自己的评论，或自己管理的评论区下的评论'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Get.back(result: false);
                    },
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back(result: true);
                    },
                    child: const Text('确定'),
                  ),
                ],
              );
            },
          );
          if (isDelete == null || !isDelete) {
            return;
          }
          SmartDialog.showLoading(msg: '删除中...');
          var result = await VideoHttp.replyDel(
            type: item.type.toInt(),
            oid: item.oid.toInt(),
            rpid: item.id.toInt(),
          );
          SmartDialog.dismiss();
          if (result['status']) {
            SmartDialog.showToast('删除成功');
            onDelete?.call(item.id.toInt());
          } else {
            SmartDialog.showToast('删除失败, ${result["msg"]}');
          }
          break;
        default:
      }
    }

    Color errorColor = Theme.of(context).colorScheme.error;
    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQueryData.fromView(
                      WidgetsBinding.instance.platformDispatcher.views.single)
                  .padding
                  .bottom +
              20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => Get.back(),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            child: Container(
              height: 35,
              padding: const EdgeInsets.only(bottom: 2),
              child: Center(
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: const BorderRadius.all(Radius.circular(3))),
                ),
              ),
            ),
          ),
          // 已登录用户才显示删除
          if (GStorage.userInfo.get('userInfoCache') != null) ...[
            ListTile(
              onTap: () async => await menuActionHandler('delete'),
              minLeadingWidth: 0,
              leading: Icon(Icons.delete_outlined, color: errorColor, size: 19),
              title: Text('删除',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: errorColor)),
            ),
            ListTile(
              onTap: () async => await menuActionHandler('report'),
              minLeadingWidth: 0,
              leading: Icon(Icons.error_outline, color: errorColor, size: 19),
              title: Text('举报',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: errorColor)),
            ),
          ],
          ListTile(
            onTap: () async => await menuActionHandler('copyAll'),
            minLeadingWidth: 0,
            leading: const Icon(Icons.copy_all_outlined, size: 19),
            title: Text('复制全部', style: Theme.of(context).textTheme.titleSmall),
          ),
          ListTile(
            onTap: () async => await menuActionHandler('copyFreedom'),
            minLeadingWidth: 0,
            leading: const Icon(Icons.copy_outlined, size: 19),
            title: Text('自由复制', style: Theme.of(context).textTheme.titleSmall),
          ),

          // ListTile(
          //   onTap: () async => await menuActionHandler('block'),
          //   minLeadingWidth: 0,
          //   leading: Icon(Icons.block_outlined, color: errorColor),
          //   title: Text('加入黑名单', style: TextStyle(color: errorColor)),
          // ),
          // ListTile(
          //   onTap: () async => await menuActionHandler('report'),
          //   minLeadingWidth: 0,
          //   leading: Icon(Icons.report_outlined, color: errorColor),
          //   title: Text('举报', style: TextStyle(color: errorColor)),
          // ),
        ],
      ),
    );
  }
}
