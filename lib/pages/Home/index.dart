import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hm_shop/stores/HomeController.dart';
import 'package:hm_shop/widgets/Home/HmCategory.dart';
import 'package:hm_shop/widgets/Home/HmHot.dart';
import 'package:hm_shop/widgets/Home/HmMoreList.dart';
import 'package:hm_shop/widgets/Home/HmSlider.dart';
import 'package:hm_shop/widgets/Home/HmSuggestion.dart';

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // put一个Getx管理主页响应式数据及控制器，数据与请求方法都在HomeController拿
  final HomeController controller = Get.put(HomeController());
  // 划动监听控制器
  final ScrollController _controller = ScrollController();
  // Globalkey是一个方法可以创建一个key绑定到Widget部件上，可以操作widget部件
  final GlobalKey<RefreshIndicatorState> _key =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _registerEvent();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _registerEvent() {
    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 50) {
        controller.loadRecommend();
      }
    });
  }

  List<Widget> _getScrollchildren() {
    return [
      SliverToBoxAdapter(
        child: HmSlider(
          BannerList: controller.bannerList.value,
          onSearch: controller.search,
        ),
      ),
      if (controller.searchKeyword.value.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text('“${controller.searchKeyword.value}”的搜索结果'),
          ),
        ),
        if (controller.searchResults.value.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("未找到相关商品"),
            ),
          )
        else
          HmMoreList(recommendList: controller.searchResults.value),
      ] else ...[
        SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(
          child: HmCategory(categoryList: controller.categoryList.value),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(
          child: HmSuggestion(
            SpecialRecommendList: controller.specialRecommend.value,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                  child: HmHot(
                    result: controller.inVogueResult.value,
                    type: "hot",
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: HmHot(
                    result: controller.oneStopResult.value,
                    type: "step",
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10)),
        HmMoreList(recommendList: controller.recommendList.value),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _key,
      onRefresh: controller.loadAll,
      child: Obx(
        () => CustomScrollView(
          controller: _controller,
          slivers: _getScrollchildren(),
        ),
      ),
    );
  }
}
