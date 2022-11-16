import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:fluro/fluro.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/imgur_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/ftp_manage_api.dart';

class PsHostHomePage extends StatefulWidget {
  const PsHostHomePage({super.key});

  @override
  PsHostHomePageState createState() => PsHostHomePageState();
}

class PsHostHomePageState extends State<PsHostHomePage>
    with AutomaticKeepAliveClientMixin<PsHostHomePage> {
  List psHostHomePageOrder = [];

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    initOrder();
  }

  initOrder() {
    List temppsHostHomePageOrder = Global.psHostHomePageOrder;
    setState(() {
      for (var i = 0; i < temppsHostHomePageOrder.length; i++) {
        psHostHomePageOrder.add(int.parse(temppsHostHomePageOrder[i]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<DraggableGridItem> listOfDraggableGridItem = [
      DraggableGridItem(
        child: Card(
          borderOnForeground: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    Application.router.navigateTo(
                      context,
                      Routes.tencentBucketList,
                      transition: TransitionType.inFromRight,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/tcyun.png',
                        width: 80,
                        height: 80,
                      ),
                      const Text('腾讯云'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    Application.router.navigateTo(
                      context,
                      Routes.smmsManageHomePage,
                      transition: TransitionType.inFromRight,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/smms.png',
                        width: 80,
                        height: 80,
                      ),
                      const Text('SM.MS'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    Application.router.navigateTo(
                      context,
                      Routes.aliyunBucketList,
                      transition: TransitionType.inFromRight,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/aliyun.png',
                        width: 80,
                        height: 80,
                      ),
                      const Text('阿里云'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () async {
                    Application.router.navigateTo(
                      context,
                      Routes.qiniuBucketList,
                      transition: TransitionType.inFromRight,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/qiniu.png',
                        width: 80,
                        height: 80,
                      ),
                      const Text('七牛云'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                  child: InkWell(
                onTap: () async {
                  String currentPicHoroUser = await Global.getUser();
                  String currentPicHoroPasswd = await Global.getPassword();
                  var usernamecheck =
                      await MySqlUtils.queryUser(username: currentPicHoroUser);

                  if (usernamecheck == 'Empty') {
                    return showToast('请先去设置页面注册');
                  } else if (currentPicHoroPasswd !=
                      usernamecheck['password']) {
                    return showToast('请先去设置页面登录');
                  }
                  var queryUpyunManage = await MySqlUtils.queryUpyunManage(
                      username: currentPicHoroUser);
                  if (queryUpyunManage == 'Empty') {
                    if (mounted) {
                      Application.router.navigateTo(
                        context,
                        Routes.upyunLogIn,
                        transition: TransitionType.inFromRight,
                      );
                    }
                  } else if (queryUpyunManage == 'Error') {
                    return showToast('获取数据库错误');
                  } else {
                    showToast('开始校验');
                    String token = queryUpyunManage['token'];
                    var checkTokenResult =
                        await UpyunManageAPI.checkToken(token);
                    if (checkTokenResult[0] == 'success') {
                      if (mounted) {
                        Application.router.navigateTo(
                          context,
                          Routes.upyunBucketList,
                          transition: TransitionType.inFromRight,
                        );
                      }
                    } else {
                      if (mounted) {
                        Application.router.navigateTo(
                          context,
                          Routes.upyunLogIn,
                          transition: TransitionType.inFromRight,
                        );
                      }
                    }
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/icons/upyun.png',
                      width: 80,
                      height: 80,
                    ),
                    const Text('又拍云'),
                  ],
                ),
              )),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () async {
                    Application.router.navigateTo(
                      context,
                      Routes.lskyproManageHomePage,
                      transition: TransitionType.inFromRight,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/lskypro.png',
                        width: 80,
                        height: 80,
                      ),
                      const Text('兰空图床'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () async {
                    Application.router.navigateTo(
                      context,
                      Routes.githubManageHomePage,
                      transition: TransitionType.inFromRight,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/github.png',
                        width: 80,
                        height: 80,
                      ),
                      const Text('Github'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () async {
                    String currentPicHoroUser = await Global.getUser();
                    String currentPicHoroPasswd = await Global.getPassword();
                    var usernamecheck = await MySqlUtils.queryUser(
                        username: currentPicHoroUser);

                    if (usernamecheck == 'Empty') {
                      return showToast('请先去设置页面注册');
                    } else if (currentPicHoroPasswd !=
                        usernamecheck['password']) {
                      return showToast('请先去设置页面登录');
                    }
                    var queryImgurManage = await MySqlUtils.queryImgurManage(
                        username: currentPicHoroUser);
                    if (queryImgurManage == 'Empty') {
                      if (mounted) {
                        Application.router.navigateTo(
                          context,
                          Routes.imgurLogIn,
                          transition: TransitionType.inFromRight,
                        );
                      }
                    } else if (queryImgurManage == 'Error') {
                      return showToast('获取数据库错误');
                    } else {
                      showToast('开始校验');
                      String imguruser = queryImgurManage['imguruser'];
                      String token = queryImgurManage['accesstoken'];
                      String proxy = queryImgurManage['proxy'];
                      if (token == 'None') {
                        if (mounted) {
                          Application.router.navigateTo(
                            context,
                            Routes.imgurLogIn,
                            transition: TransitionType.inFromRight,
                          );
                        }
                        return;
                      }
                      var checkTokenResult = await ImgurManageAPI.checkToken(
                          imguruser, token, proxy);
                      if (checkTokenResult[0] == 'success') {
                        if (mounted) {
                          Application.router.navigateTo(
                            context,
                            '${Routes.imgurFileExplorer}?userProfile=${Uri.encodeComponent(jsonEncode(queryImgurManage))}&albumInfo=${Uri.encodeComponent(jsonEncode({}))}&allImages=${Uri.encodeComponent(jsonEncode([]))}',
                            transition: TransitionType.inFromRight,
                          );
                        }
                      } else {
                        if (mounted) {
                          Application.router.navigateTo(
                            context,
                            Routes.imgurLogIn,
                            transition: TransitionType.inFromRight,
                          );
                        }
                      }
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/fakesmms.png',
                        width: 70,
                        height: 80,
                      ),
                      const Text('Imgur'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () async {
                    String currentPicHoroUser = await Global.getUser();
                    String currentPicHoroPasswd = await Global.getPassword();
                    var usernamecheck = await MySqlUtils.queryUser(
                        username: currentPicHoroUser);
                    if (usernamecheck == 'Empty') {
                      return showToast('请先去设置页面注册');
                    } else if (currentPicHoroPasswd !=
                        usernamecheck['password']) {
                      return showToast('请先去设置页面登录');
                    }
                    String currentUser = await Global.getUser();
                    var queryFTP =
                        await MySqlUtils.queryFTP(username: currentUser);
                    if (queryFTP == 'Empty') {
                      return showToast('请先去配置FTP');
                    }
                    Map configMap = await FTPManageAPI.getConfigMap();
                    if (mounted && configMap['ftpType'] == 'SFTP') {
                      String startDir = configMap['ftpHomeDir'];
                      if (startDir == 'None') {
                        startDir = '/';
                      } else {
                        if (!startDir.endsWith('/')) {
                          startDir = '$startDir/';
                        }
                        if (!startDir.startsWith('/')) {
                          startDir = '/$startDir';
                        }
                      }
                      Application.router.navigateTo(context,
                          '${Routes.sftpFileExplorer}?element=${Uri.encodeComponent(jsonEncode(configMap))}&bucketPrefix=${Uri.encodeComponent(startDir)}',
                          transition: TransitionType.cupertino);
                    } else {
                      showToast('仅支持管理SFTP');
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/ftp.png',
                        width: 80,
                        height: 80,
                      ),
                      const Text('SSH/SFTP'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
    ];
    List<DraggableGridItem> newItems = [];
    for (int i = 0; i < listOfDraggableGridItem.length; i++) {
      newItems.add(listOfDraggableGridItem[psHostHomePageOrder[i]]);
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(
          '图床管理-拖动排序',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: DraggableGridViewBuilder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
        ),
        children: newItems,
        dragCompletion: (List<DraggableGridItem> list, int beforeIndex,
            int afterIndex) async {
          List<String> newOrder = [];
          for (int i = 0; i < list.length; i++) {
            newOrder.add(listOfDraggableGridItem.indexOf(list[i]).toString());
          }
          await Global.setpsHostHomePageOrder(newOrder);
        },
        dragFeedback: (List<DraggableGridItem> list, int index) {
          return SizedBox(
            width: 200,
            height: 150,
            child: list[index].child,
          );
        },
        dragPlaceHolder: (List<DraggableGridItem> list, int index) {
          return PlaceHolderWidget(
            child: Container(
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
