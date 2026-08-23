import 'package:flutter/material.dart';
import 'package:hm_shop/api/home.dart';
import 'package:hm_shop/utils/Toastutils.dart';
import 'package:hm_shop/viewmodels/home.dart';
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
  //优惠推荐数据列表
  SpecialRecommendResult _SpecialRecommendList = SpecialRecommendResult(
    id: "",
    title: "",
    subTypes: [],
  );
  //分类数据列表
  List<CategoryItem> _CategoryList = [];
  //函数列表封装轮播图图片数据列表
  List<BannerItem> _BannerList = [
    // BannerItem(id: "1", imaUrl: "https://img95.699pic.com/photo/60030/5424.jpg_wh860.jpg"),
    // BannerItem(id: "2", imaUrl: "https://img95.699pic.com/photo/50120/1209.jpg_wh860.jpg"),
    // BannerItem(id: "3", imaUrl: "https://img95.699pic.com/photo/50478/8568.jpg_wh860.jpg")
  ];
  //热榜推荐数据列表
  SpecialRecommendResult _inVogueResult = SpecialRecommendResult(
    id: "",
    title: "",
    subTypes: [],
  );
  //一战式买全数据列表
  SpecialRecommendResult _oneStopResult = SpecialRecommendResult(
    id: "",
    title: "",
    subTypes: [],
  );
  //推荐列表数据列表
  List<GoodDetailItem> _recommendList = [];

  //搜索结果列表，可为空加？
  List<GoodDetailItem>? _searchResults;
  // 搜索内容初始化
  String _searchKeyword = "";

  //函数封装CustomScrollView内容
  List<Widget> _getScrollchildren() {
    return [
      //包裹普通Widget的sliver家族
      SliverToBoxAdapter(child: HmSlider(BannerList: _BannerList, onSearch: _handleSearch)), //轮播图.搜索功能
      // 这个...[]是展开运算符，可以把方括号里的多个 Widget 拆开，直接合并到外层大 List[]。
      if(_searchKeyword.isNotEmpty) ...[
        SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('“$_searchKeyword”的搜索结果'),
        ),
      ),
      // _searchResult的值可能是null，是则赋值为[]
      if ((_searchResults ?? []).isEmpty)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text("未找到相关商品"),
          ),
        )
      // 这边就是一个放错处理，防止recommendList是null，因为是null，拿不到任何东西还会报错
      else
        HmMoreList(recommendList: _searchResults ?? []),
      ]else...[
        //需要间隔放SizeBox
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      //SliverGridView和SliverListView都只能纵向滚动，不能横向
      SliverToBoxAdapter(child: HmCategory(categoryList: _CategoryList)), //分类
      SliverToBoxAdapter(child: SizedBox(height: 10)),

      SliverToBoxAdapter(
        child: HmSuggestion(SpecialRecommendList: _SpecialRecommendList),
      ), //推荐
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      //爆款推荐和热门推荐均分空间
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                child: HmHot(result: _inVogueResult, type: "hot"),
              ),
              SizedBox(width: 10),
              Expanded(
                child: HmHot(result: _oneStopResult, type: "step"),
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      //无限滚动利用SliverGridView就可以实现
      HmMoreList(recommendList: _recommendList),
      ]
    ];            
  }

  //初始化状态
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _getBannerList();
    // _getCategoryList();
    // _getSpecialRecommendList();
    // _getInVogueList();
    // _getOneStopList();
    // _getRecommendList();
    _registerEvent();
    Future.microtask(() {
      // 使用key操纵函数
      _key.currentState?.show();
    });
  }
  // 由于initState -> build -> 下拉刷新组件 -> 才可以操作它
  // 所以不能直接使用，因为在build阶段这个函数还未构建完成执行没有结果
  // 需要使用Future.micoTask微任务使其异步完成

  //释放滚动控制器，自己创建的控制器Flutter不会帮我们自动释放，需手动释放，否则内存泄漏
  @override
  void dispose() {
    _controller.dispose(); // 调用dispose释放滚动控制器，有几个控制器就dispose几个。
    super.dispose();       // 调用父类dispose方法，Flutter正常释放其他组件
  }

  //获取分类数据
  Future<void> _getCategoryList() async {
    try {
      final list = await getCategoryListAPI();
      if (!mounted) return;
      _CategoryList = list; // 这句的意思是当页面不存在了，就直接停止避免报错
      setState(() {});
    } catch (_) {
      // 首页单块加载失败时，可以静默忽略，或提示用户
    }
    setState(() {});
  }

  //获取轮播图数据
  Future<void> _getBannerList() async {
    try {
      final list = await getBannerListAPI();
      if (!mounted) return; // 这句的意思是当页面不存在了，就直接停止避免报错
      setState(() {
        _BannerList = list;
      });
    } catch (_) {
      // 首页单块加载失败时，可以静默忽略，或提示用户
    }
  }

  // 搜索方法定义
  void _handleSearch(String keyword) {
    setState(() {
      _searchKeyword = keyword;

      if (keyword.isEmpty) {
        _searchResults = null;
        return;
      }

      // 借用推荐商品列表做本地过滤：商品名包含关键词就匹配成功
      _searchResults = _recommendList
          .where((item) => item.name.contains(keyword))
          .toList();
    });
  }

  //获取优惠推荐数据
  Future<void> _getSpecialRecommendList() async {
    try {
      final list = await getSpecialRecommendListAPI();
      if (!mounted) return;
      _SpecialRecommendList = list;
      setState(() {});
    } catch (_) {
      // 首页单块加载失败时，可以静默忽略，或提示用户
    }
    setState(() {});
  }

  //获取热榜推荐数据
  Future<void> _getInVogueList() async {
    try {
      final result = await getInVogueListAPI();
      if (!mounted) return;
      _inVogueResult = result;
      setState(() {});
    } catch (_) {
      // 首页单块加载失败时，可以静默忽略，或提示用户
    }
    setState(() {});
  }

  //获取一战式买全数据
  Future<void> _getOneStopList() async {
    try {
      final result = await getOneStopListAPI();
      if (!mounted) return;
      _oneStopResult = result;
      setState(() {});
    } catch (_) {
      // 首页单块加载失败时，可以静默忽略，或提示用户
    }
    setState(() {});
  }

  //获取推荐列表数据
  int _page = 1;
  bool _isLoading = false; // 当前请求状态
  bool _hasMore = true; // 是否还有下一页

  Future<void> _getRecommendList() async {
    // 当正在请求状态或者没有下一页时，放弃请求
    if (_isLoading == true || _hasMore == false) {
      return;
    }
    _isLoading = true; // 占住位置，表示请求进行中
    try {
      // 这里用try，catch是因为要进行防错处理，防止异步请求结果发回已销毁的流程
      int requestLimit = _page * 10;
      _recommendList = await getRecommendListAPI({"limit": requestLimit});
      // 要10条请求给10条就进行下一次请求
      // 当要10条给不满10条则表示，数据已用光
      if (_recommendList.length < requestLimit) {
        _hasMore = false;
      } else {
        _page++; // 请求完成页码加一
      }
    } catch (_) {
      // 页面还在才提示,这里是做了一个widget组件在ui运行过程意外被中止，但是异步结果仍然返回的防错
      if (mounted) {
        Toastutils.showToast(context, "加载失败，请稍后重试");
      }
    } finally {
      // 不管成功还是失败，都恢复加载状态
      _isLoading = false;
    }
    // 页面存在才刷新 UI
    if (mounted) {
      setState(() {});
    }
  }

  // 监听滚动到底部的事件
  void _registerEvent() {
    // 这个addListener方法，当用户进行滚动行为时就会触发逻辑
    _controller.addListener(() {
      // 这个pixels指已滚动距离
      // 这个maxScrollExtent指滚动最大距离
      // 只要已滚动距离>最大滚动距离-50，则表示到底了可以请求了
      if (_controller.position.pixels >=
          (_controller.position.maxScrollExtent - 50)) {
        // 在这里执行加载下一页数据请求
        _getRecommendList();
      }
    });
  }

  final ScrollController _controller = ScrollController(); // 划动监听控制器

  // 封装onRefresh函数，实现下拉重置数据
  Future<void> _onRefresh() async {
    // 参数回归
    // 这里不能是bool _isLoading,因为Dart 的规则是：如果局部变量和成员变量同名，函数内部优先找局部变量。
    _page = 1;
    _isLoading = false;
    _hasMore = true;
    try {
      await _getBannerList();
      await _getCategoryList();
      await _getSpecialRecommendList();
      await _getInVogueList();
      await _getOneStopList();
      await _getRecommendList();

      if (mounted) {
        // 页面存在再去刷新和提示刷新成功
        Toastutils.showToast(context, "刷新成功");
      }
    } catch (_) {
      if (mounted) {
        Toastutils.showToast(context, "刷新失败，请检查网络");
      }
    }
  }

  // Globalkey是一个方法可以创建一个key绑定到Widget部件上，可以操作widget部件
  final GlobalKey<RefreshIndicatorState> _key =
      GlobalKey<RefreshIndicatorState>();
  @override
  Widget build(BuildContext context) {
    // 用RefreshIndicator包裹子组件，使其可以下拉
    return RefreshIndicator(
      key: _key, // 绑定key
      // 这个onRefresh需要返回一个异步函数
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _controller, // 给无限滚动绑定控制器
        slivers: _getScrollchildren(),
      ),
    );
    //只允许Sliver家族内容
  }
}
