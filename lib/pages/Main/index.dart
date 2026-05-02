import 'package:flutter/material.dart';
import 'package:hm_shop/pages/Cart/index.dart';
import 'package:hm_shop/pages/Category/index.dart';
import 'package:hm_shop/pages/Home/index.dart';
import 'package:hm_shop/pages/mine/index.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //定义一个列表，用来装图标和对应的文本,用map使图标和文本一一对应
  //一般程序的导航是固定的可以加final
  final List<Map<String, String>> _tablist = [//这里最好用构造函数进行封装
    {
      "icon" : "lib/assets/ic_public_home_normal.png",//正常未激活时图标
      "active_icon" : "lib/assets/ic_public_home_active.png",//激活时图标
      "text" : "首页"
    },
    {
      "icon" : "lib/assets/ic_public_pro_normal.png",//正常未激活时图标
      "active_icon" : "lib/assets/ic_public_pro_active.png",//激活时图标
      "text" : "分类"
      },
    {
      "icon" : "lib/assets/ic_public_cart_normal.png",//正常未激活时图标
      "active_icon" : "lib/assets/ic_public_cart_active.png",//激活时图标
      "text" : "购物车"
      },
    {
      "icon" : "lib/assets/ic_public_my_normal.png",//正常未激活时图标
      "active_icon" : "lib/assets/ic_public_my_active.png",//激活时图标
      "text" : "我的"
      }
  ];
  
  int _currentIndex = 0;

  //items构造函数,专门为了上面icon数据准备的
  List<BottomNavigationBarItem> _getTabBarWidget () {
    return List.generate(_tablist.length, (int index) {
      return BottomNavigationBarItem(//按钮图标，按钮功能已自带，图片准备就行
        icon: Image.asset(_tablist[index]["icon"]!, width: 30, height: 30),
        activeIcon: Image.asset(_tablist[index]["active_icon"]!, width: 30, height: 30),
        label: _tablist[index]["text"]
      );
    });
  }

  //构建IndexedStack的页面组件,页面不是路由
  //所以用View，路由用Page
  List<Widget> _getChildren() {
    return [HomeView(), CategoryView(), CartView(), MineView()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //SafeArea避开安全区组件
      body: SafeArea(
        //IndexedStack索引堆叠组件
        child: IndexedStack(
          index: _currentIndex,
          children: _getChildren(),//放几个组件代表有几个页面
        )),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,//展示未激活的图标文本
        selectedItemColor: Colors.black,//设置激活文本颜色
        unselectedItemColor: Colors.blueGrey,//设置未激活文本颜色
        onTap: (int index) {
          //index就是当前的点击索引
          _currentIndex = index;//点击触发逻辑，赋值给对应的按钮索引
          setState(() {});//更新ui
        },
        //currentIndex是决定索引对应的图标
        currentIndex: _currentIndex,
        items: _getTabBarWidget()
        ),
    );
  }
}