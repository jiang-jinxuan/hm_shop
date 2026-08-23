import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hm_shop/viewmodels/home.dart';

class HmSlider extends StatefulWidget {
  final List<BannerItem> BannerList;
  final void Function(String) onSearch; // 定义一个参数为String的回调函数，用于子传父
  HmSlider({Key? key, required this.BannerList, required this.onSearch}) : super(key: key);

  @override
  _HmSliderState createState() => _HmSliderState();
}

class _HmSliderState extends State<HmSlider> {
  CarouselSliderController _controller = CarouselSliderController(); //控制轮播图跳转的控制器
  TextEditingController _searchController = TextEditingController(); // 输入框内容控制器
  int _currentIndex = 0; //表示当前激活的导航灯

  @override
  void dispose() {
    _searchController.dispose();// 轮播图属于第三方不用释放，输入框需要
    super.dispose();
  }

  //轮播图组件封装到函数中
  Widget _getSlider() {
    // 在Flutter中获取屏幕宽度的方法
    final double screemWidth = MediaQuery.of(
      context,
    ).size.width; //这个context是这个Media Query自带的
    //官方轮播图插件CarouselSlider
    return CarouselSlider(
      carouselController: _controller, //绑定控制器
      items: List.generate(widget.BannerList.length, (int index) {
        return Image.network(
          widget.BannerList[index].imgUrl,
          fit: BoxFit.cover, //设置图片全覆盖
          width: screemWidth, //设置图片宽度
        );
      }), //返回List<widget>,长度和轮播图使用的Image
      options: CarouselOptions(
        viewportFraction: 1, //设置视口占比为1，即100%
        autoPlay: true, //设置为自动滚动，默认值3秒一次
        height: MediaQuery.of(context).size.width * (3 / 5), //可以设置图片高度,宽高比例5:3
        autoPlayInterval: Duration(seconds: 3), //更改自动滚动的时间间隔
        //一个轮播图切换就触发的回调函数
        onPageChanged: (int index, reason) {
          _currentIndex = index;//使_currentIndex与当前页面绑定
          setState(() {});//ui更新
        }
      ),
    );
  }

  //搜索栏的ui实现
  Widget _getSearch() {
    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: TextField(
          controller: _searchController,// 绑定控制器，获取内容
          textInputAction: TextInputAction.search,// 将搜索时，将键盘右下角按钮变成搜索按钮，而不是默认的换行 / 完成。
          style: const TextStyle(color: Colors.white, fontSize: 16),// 设置用户输入文字样式
          // InputDecoration用于定义输入框文本，样式等组件
          decoration: InputDecoration(
            hintText: "输入要搜索的商品",// 提示文字
            hintStyle: const TextStyle(color: Colors.white70),// 提示文字颜色（半透明）
            prefixIcon: const Icon(Icons.search, color: Colors.white),// 输入框前置图标Icon自带搜索图标
            filled: true,// 允许框内颜色出现
            fillColor: Colors.grey.withOpacity(0.2),// 设置输入框为灰色，透明度 0.2，淡淡的灰色
            contentPadding: EdgeInsets.zero,// contentPadding输入文字距边框的内边距
            border: OutlineInputBorder( // 设置输入框样式
              borderRadius: BorderRadius.circular(25),// 设置输入框为圆角
              borderSide: BorderSide.none// BorderSide.none去掉边框线条，只保留圆角背景，不显示描边
            ),
          ),
          // onSubmitted的原理是用户提交一次请求，onSubmitted执行一次里面的逻辑，value就是用户输入的值
          // 使用widget调用从父组件传来的回调匿名函数将处理好的用户搜索内容传到父组件,让父组件完成搜索
          onSubmitted: (value) {
            widget.onSearch(value.trim()); //这里value.trim()的.trim()用于去除输入内容前后空格；
          },
        ),
      ),
    );
  }

  //返回底部指示灯导航部件
  Widget _getDots() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 10,
      child: SizedBox(
        height: 40,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, //主轴居中
          //有几个轮播图图片就循环几次
          children: List.generate(widget.BannerList.length, (int index) {
            return GestureDetector(
              onTap: () {
                //跳转，index是导航灯的index，这边一个_controller绑定了两个组件，所以使用方法使页面跳转到点击触发的index
                _controller.animateToPage(index, duration: Duration(milliseconds: 300));
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),//设置动画效果过程为300毫秒
                height: 6,
                //在这边进行一个判断，如果导航灯的index==页面的index长度为40，否则为20
                width: index == _currentIndex ? 40 : 20,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  //在这边也进行一个判断如果导航灯的index==页面的index则为红色，否则为白色
                  color: index == _currentIndex ? Colors.white : Colors.blueGrey,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //Stack  -> 轮播图 -> 搜索框  -> 指示灯导航
    return Stack(children: [_getSlider(), _getSearch(), _getDots()]);
  }
}
