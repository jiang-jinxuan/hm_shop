import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hm_shop/stores/MineController.dart';
import 'package:hm_shop/widgets/Home/HmMoreList.dart';
import 'package:hm_shop/widgets/Mine/HmGuess.dart';
import 'package:hm_shop/stores/UserController.dart';

class MineView extends StatefulWidget {
  MineView({Key? key}) : super(key: key);

  @override
  _MineViewState createState() => _MineViewState();
}

class _MineViewState extends State<MineView> {
  // 无论有几个页面，先把这个共享数据put在这里，谁都可以拿
  final UserController _userController = Get.find();
  // 注册一个GetX管理此页面状态，数据与请求方法这些需要实时更新的东西到MineController里去拿
  final MineController controller = Get.put(MineController());
  // 滚动容器控制器
  final ScrollController _controller = ScrollController();
  // 释放控制器
  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  // 返回退出登录方法
  Widget _getLogin() {
    return _userController.user.value.id.isNotEmpty
        ? Expanded(
            child: GestureDetector(
              onTap: () {
                // 点击退出登录，弹出确认弹窗
                showDialog(
                  context: context,
                  builder: (context) {
                    // 这里必须返回Dialog基础类
                    return AlertDialog(
                      title: Text("提示"), // 标题
                      content: Text("请确认是否退出登录"), // 主体内容
                      // 在actions里就可以放置各种组件
                      actions: [
                        TextButton(
                          onPressed: () async {
                            await _userController.logout();
                            Navigator.pop(context); // 返回上个页面，取消弹窗
                          },
                          child: Text("确认"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // 返回上个页面，取消弹窗
                          },
                          child: Text("取消"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text("退出", textAlign: TextAlign.end), // 设置文本为靠最后
            ),
          )
        : Text("");
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFFFF2E8), const Color(0xFFFDF6F1)],
        ),
      ),
      padding: const EdgeInsets.only(left: 20, right: 40, top: 80, bottom: 20),
      // 登录头像设置
      child: Row(
        children: [
          Obx(() {
            return CircleAvatar(
              // 用于展示圆形图片
              radius: 26, // 半径
              backgroundImage: _userController.user.value.avatar.isNotEmpty
                  ? NetworkImage(_userController.user.value.avatar)
                  : AssetImage("lib/assets/goods_avatar.png"),
              backgroundColor: Colors.white, // 底色
            );
          }),
          const SizedBox(width: 12),
          // 让子组件占满空间
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  // Obx中必须要有可检测的响应式数据，否则会报错
                  return GestureDetector(
                    // 设置按钮
                    onTap: () {
                      // 当用户登录信息为空时才可以进行登录
                      if (_userController.user.value.id.isEmpty) {
                        // 跳转到登录页面
                        Navigator.pushNamed(context, "/login");
                      }
                    },
                    child: Text(
                      // 有登录则显示用户信息，无登录则显示立即登录
                      // 用三元表达式判断用户是否登录，是则显示id
                      _userController.user.value.id.isNotEmpty
                          ? _userController.user.value.id
                          : "立即登录",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // 用Obx检测是否有用户登录，无则不显示，有则显示
          Obx(() => _getLogin()),
        ],
      ),
    );
  }

  Widget _buildVipCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 239, 197, 153),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Row(
          children: [
            Image.asset("lib/assets/ic_user_vip.png", width: 30, height: 30),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '升级美荟商城会员，尊享无限免邮',
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(128, 44, 26, 1),
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromRGBO(126, 43, 26, 1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('立即开通', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    Widget item(String pic, String label) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(pic, width: 30, height: 30, fit: BoxFit.cover),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            item("lib/assets/ic_user_collect.png", '我的收藏'),
            item("lib/assets/ic_user_history.png", '我的足迹'),
            item("lib/assets/ic_user_unevaluated.png", '我的客服'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderModule() {
    Widget orderItem(String pic, String label) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(pic, width: 30, height: 30, fit: BoxFit.cover),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),

          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '我的订单',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  orderItem("lib/assets/ic_user_order.png", '全部订单'),
                  orderItem("lib/assets/ic_user_obligation.png", '待付款'),
                  orderItem("lib/assets/ic_user_unreceived.png", '待发货'),
                  orderItem("lib/assets/ic_user_unshipped.png", '待收货'),
                  orderItem("lib/assets/ic_user_unevaluated.png", '待评价'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _registerEvent();
  }

  // 滚动距离判断
  void _registerEvent() {
    // 滚动触发
    _controller.addListener(() {
      // 滚动逻辑
      if (_controller.position.pixels >=
          (_controller.position.maxScrollExtent - 50)) {
        // 滚动到底触发请求
        controller.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      // 无限列表绑定控制器
      controller: _controller,
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildVipCard()),
        SliverToBoxAdapter(child: _buildQuickActions()),
        SliverToBoxAdapter(child: _buildOrderModule()),
        // pinned 表示吸住的意思
        SliverPersistentHeader(delegate: HmGuess(), pinned: true),
        // 猜你喜欢
        Obx(
          () => HmMoreList(recommendList: controller.guessList.value),
        ), // 上拉加载
      ],
    );
  }
}
