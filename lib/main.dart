import 'package:flutter/material.dart';
import 'package:hm_shop/routes/index.dart';

void main(List<String> args) {
  //在mian里runApp启动应用
  //但并不在main里构建MaterialApp,在routes里去构建并配置路由
  runApp(getRouteWidget());
}
