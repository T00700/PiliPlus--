import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/widgets/loading_widget.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/pages/member/new/content/member_contribute/content/article/member_article_ctr.dart';
import 'package:PiliPlus/pages/member/new/content/member_contribute/content/article/widget/item.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberArticle extends StatefulWidget {
  const MemberArticle({
    super.key,
    required this.heroTag,
    required this.mid,
  });

  final String? heroTag;
  final int mid;

  @override
  State<MemberArticle> createState() => _MemberArticleState();
}

class _MemberArticleState extends State<MemberArticle>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final _controller = Get.put(
    MemberArticleCtr(mid: widget.mid),
    tag: widget.heroTag,
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() => _buildBody(_controller.loadingState.value));
  }

  _buildBody(LoadingState loadingState) {
    return switch (loadingState) {
      Loading() => loadingWidget,
      Success() => (loadingState.response as List?)?.isNotEmpty == true
          ? refreshIndicator(
              onRefresh: () async {
                await _controller.onRefresh();
              },
              child: CustomScrollView(
                slivers: [
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      mainAxisSpacing: 2,
                      maxCrossAxisExtent: Grid.mediumCardWidth * 2,
                      childAspectRatio: StyleString.aspectRatio * 2.2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == loadingState.response.length - 1) {
                          _controller.onLoadMore();
                        }
                        return MemberArticleItem(
                          item: loadingState.response[index],
                        );
                      },
                      childCount: loadingState.response.length,
                    ),
                  ),
                ],
              ),
            )
          : scrollErrorWidget(
              callback: _controller.onReload,
            ),
      Error() => scrollErrorWidget(
          errMsg: loadingState.errMsg,
          callback: _controller.onReload,
        ),
      LoadingState() => throw UnimplementedError(),
    };
  }
}
