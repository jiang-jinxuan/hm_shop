import 'package:get/get.dart';
import 'package:hm_shop/api/mine.dart';
import 'package:hm_shop/viewmodels/home.dart';

class MineController extends GetxController {
  final guessList = <GoodDetailItem>[].obs;

  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void onInit() {
    super.onInit();
    loadMore();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    try {
      final res = await getGuessListAPI({"page": page, "pageSize": 10});
      guessList.addAll(res.items);

      if (page >= res.pages) {
        hasMore = false;
      } else {
        page++;
      }
    } finally {
      isLoading = false;
    }
  }
}