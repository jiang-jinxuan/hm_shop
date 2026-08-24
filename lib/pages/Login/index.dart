import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hm_shop/utils/Toastutils.dart';
import 'package:hm_shop/stores/UserController.dart';
import 'package:hm_shop/utils/loginDialog.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _phonController = TextEditingController(); // 账号控制器
  TextEditingController _codeController = TextEditingController(); // 密码控制器
  final UserController _userController = Get.find(); // 寻找对象

  // 释放一下控制器
  @override
  void dispose() {
    // TODO: implement dispose
    _phonController.dispose(); // 释放控制器
    _codeController.dispose(); // 有几个控制器就释放几个
    super.dispose(); // 调用父类dispose方法，Flutter正常释放其他组件
  }

  // 用户账号Widget
  Widget _buildPhoneTextField() {
    return TextFormField(
      validator: (value) {
        // 判断不能为空
        if (value == null || value.isEmpty) {
          return "手机号不能为空";
        }
        // 判断手机号格式
        if (RegExp(r"^1[3-9]\d{8}").hasMatch(value) == false) {
          return "手机号格式不正确";
        }
        return null;
      },
      controller: _phonController,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 20), // 内容内边距
        hintText: "请输入账号",
        fillColor: const Color.fromRGBO(243, 243, 243, 1),
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  // 用户密码Widget
  Widget _buildCodeTextField() {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "密码不能为空";
        }
        // 密码校验，6-16的数字 字母 下划线组合
        if (RegExp(r"^[a-zA-Z0-9_]{6,16}$").hasMatch(value) == false) {
          return "请输入6到16位的数字字母或下划线";
        }
        return null;
      },
      controller: _codeController,
      // 是否隐藏输入值
      obscureText: true,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 20), // 内容内边距
        hintText: "请输入密码",
        fillColor: const Color.fromRGBO(243, 243, 243, 1),
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  // 定义登录跳转函数
  _login() async {
    // 调用登录接口
    try {
      // 登录进度动画启动
      LoginDialog.show(context, message: "努力登录中");
      await _userController.login(
        _phonController.text,
        _codeController.text,
      );
      LoginDialog.hide(context); // 登录成功关闭进度动画
      Toastutils.showToast(context, "登录成功"); // 提示登录成功信息
      Navigator.pop(context); // 返回上个页面
    } catch (e) {
      LoginDialog.hide(context); // 登录异常也关闭进度动画
      // 这一步做了很多操作，非常难，主要针对一层一层的异常抛出问题，异常抛出的信息问题
      // 对上几步的异常抛出信息不进行处理，保留原有信息
      if(e is DioException){
        Toastutils.showToast(context, (e as DioException).message); // 提示登录失败信息
      }
      // 这里异常需要补充一下情况，不能单用DioException判断。
      //断网是 SocketException、JSON 解析失败是 FormatException。
      //类型不对e as 直接报错,用if判断一下类型
    }
  }

  // 登录按钮Widget
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // 登录逻辑
          if (_key.currentState!.validate() == true) {
            // 进行勾选框的判断
            if (_isChecked == true) {
              // 校验通过
              _login();
            } else {
              // 提示勾选用户协议
              Toastutils.showToast(context, "请勾选用户协议");
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text("登录", style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  // 头部Widget
  Widget _buildHeader() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            "账号密码登录",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // 勾选Widget
  bool _isChecked = false;
  Widget _buildCheckbox() {
    return Row(
      children: [
        // 设置勾选为圆角
        Checkbox(
          value: _isChecked, // 当前是否被勾选
          activeColor: Colors.black, // 勾选时的背景色
          checkColor: Colors.white, // 勾选时的对勾颜色
          onChanged: (bool? value) {
            _isChecked = value ?? false; // 空判断，为空则直接赋false
            setState(() {});
          },
          // 设置形状
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // 圆角大小
          ),
          // 可选：设置边框
          side: BorderSide(color: Colors.grey, width: 2.0),
        ),
        // 富文本设置样式
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: "查看并同意"),
              TextSpan(
                text: "《隐私条款》",
                style: TextStyle(color: Colors.blue),
              ),
              TextSpan(text: "和"),
              TextSpan(
                text: "《用户协议》",
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 创建globalkey控制From组件
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("惠多美登录", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        child: Form(
          key: _key,
          child: Container(
            padding: EdgeInsets.all(30),
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 20),
                _buildHeader(), // 头部Widegt
                SizedBox(height: 30),
                _buildPhoneTextField(), // 账号Widget
                SizedBox(height: 20),
                _buildCodeTextField(), // 密码Widget
                SizedBox(height: 20),
                _buildLoginButton(), // 登录按钮Widget
                SizedBox(height: 20),
                _buildCheckbox(), // 协议勾选Widget
              ],
            ),
          ),
        ),
      ),
    );
  }
}
