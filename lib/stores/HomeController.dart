import 'package:get/get.dart';
import 'package:hm_shop/api/home.dart';
import 'package:hm_shop/viewmodels/home.dart';

class HomeController extends GetxController {
  // 被obs包裹的值取值与赋值都需要用.value的形式
  final bannerList = <BannerItem>[].obs;
  final categoryList = <CategoryItem>[].obs;
  final specialRecommend = SpecialRecommendResult(
    id: "",
    title: "",
    subTypes: [],
  ).obs;
  final inVogueResult = SpecialRecommendResult(
    id: "",
    title: "",
    subTypes: [],
  ).obs;
  final oneStopResult = SpecialRecommendResult(
    id: "",
    title: "",
    subTypes: [],
  ).obs;
  final recommendList = <GoodDetailItem>[].obs;

  final searchKeyword = ''.obs;
  final searchResults = <GoodDetailItem>[].obs;

  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  // onInit是GetX在控制器被第一次创建、注册之后，只会执行1次的方法，
  // 控制器的“初始化”，相当于StatefulWidget的initState。
  @override
  void onInit() {
    super.onInit();
    // loadAll()是请求方法的封装，也是下拉刷新的请求封装
    loadAll();
  }

  // 获取轮播图数据
  Future<void> loadBanner() async {
    try {
      bannerList.value = await getBannerListAPI();
    } catch (_) {
      // 单块失败可以不打扰用户
    }
  }

  //获取分类数据
  Future<void> loadCategoryList() async {
    try {
      categoryList.value = await getCategoryListAPI();
    } catch (_) {
      // 首页单块加载失败时，可以静默忽略，或提示用户
    }
  }

  //获取优惠推荐数据
  Future<void> loadSpecialRecommendList() async {
    try {
      specialRecommend.value = await getSpecialRecommendListAPI();
    } catch (_) {
      // 首页单块加载失败时，可以静默忽略，或提示用户
    }
  }

  //获取热榜推荐数据
  Future<void> loadInVogueList() async {
    try {
      inVogueResult.value = await getInVogueListAPI();
    } catch (_) {
      // 首页单块加载失败时，可以静默忽略，或提示用户
    }
  }

  //获取一战式买全数据
  Future<void> loadOneStopList() async {
    try {
      oneStopResult.value = await getOneStopListAPI();
    } catch (_) {
      // 首页单块加载失败时，可以静默忽略，或提示用户
    }
  }

  //获取推荐列表数据
  Future<void> loadRecommend() async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    try {
      final result = await getRecommendListAPI({"limit": page * 10});
      recommendList.value = result;
      if (result.length < page * 10) {
        hasMore = false;
      } else {
        page++;
      }
    } catch (_) {
      Get.snackbar("加载失败", "请稍后重试");
    } finally {
      isLoading = false;
    }
  }

  // 搜索方法定义
  void search(String keyword) {
    searchKeyword.value = keyword;
    if (keyword.isEmpty) {
      // clear()方法清空列表，集合内所有元素，而不是变为null
      searchResults.clear();
      return;
    }
    // 借用推荐商品列表做本地过滤：商品名包含关键词就匹配成功
    searchResults.value = recommendList
        .where((item) => item.name.contains(keyword))
        .toList();
  }

  // 封装loadAll()函数，实现下拉时和首页构建时的重置数据
  Future<void> loadAll() async {
    page = 1;
    isLoading = false;
    hasMore = true;

    await loadBanner();
    await loadCategoryList();
    await loadSpecialRecommendList();
    await loadInVogueList();
    await loadOneStopList();
    await loadRecommend();
  }
}
