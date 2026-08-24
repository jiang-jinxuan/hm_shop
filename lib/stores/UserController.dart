import 'package:get/get.dart';
import 'package:hm_shop/api/user.dart';
import 'package:hm_shop/stores/TokenManager.dart';
import 'package:hm_shop/viewmodels/user.dart';

// 需要共享的对象 需要一些共享的属性 属性需要响应式更新
class UserController extends GetxController {
  // 因为被obs包裹，所以想要取值的话得用user.value的形式才能取值或赋值
  final user = UserInfo.fromJSON({}).obs;// user对象被监听了

  Future<void> login(String account, String password) async {
    // 登录时post发送请求，验证
    final result = await loginAPI({
      "account": account,
      "password": password,
    });
    // 赋值给user
    user.value = result;
    await tokenManager.setToken(result.token);
  }

  Future<void> logout() async {
    await tokenManager.removeToken();
    user.value = UserInfo.fromJSON({});
  }

  Future<void> loadUserInfo() async {
    if (tokenManager.getToken().isEmpty) return;
    user.value = await getuserinfoAPI();
  }
}