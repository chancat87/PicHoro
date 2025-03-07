import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluro/fluro.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_configure/configure_page/configure_export.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/aliyun_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/aws_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/ftp_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/github_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/imgur_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/lskypro_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/qiniu_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/smms_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/tencent_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/webdav_manage_api.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/utils/common_functions.dart';

class ConfigureStorePage extends StatefulWidget {
  final String psHost;
  const ConfigureStorePage({super.key, required this.psHost});

  @override
  ConfigureStorePageState createState() => ConfigureStorePageState();
}

class ConfigureStorePageState extends State<ConfigureStorePage> {
  Map<String, String> psNameTranslate = {
    'aliyun': '阿里云',
    'qiniu': '七牛云',
    'tencent': '腾讯云',
    'upyun': '又拍云',
    'aws': 'S3兼容平台',
    'ftp': 'FTP',
    'github': 'GitHub',
    'sm.ms': 'SM.MS',
    'imgur': 'Imgur',
    'lsky.pro': '兰空图床',
    'alist': 'Alist V3',
    'webdav': 'WebDAV',
  };

  Map psNameToRouter = {
    'alist': '/alistConfigureStoreEditPage',
    'aliyun': '/aliyunConfigureStoreEditPage',
    'aws': '/awsConfigureStoreEditPage',
    'ftp': '/ftpConfigureStoreEditPage',
    'github': '/githubConfigureStoreEditPage',
    'imgur': '/imgurConfigureStoreEditPage',
    'lsky.pro': '/lskyConfigureStoreEditPage',
    'qiniu': '/qiniuConfigureStoreEditPage',
    'sm.ms': '/smmsConfigureStoreEditPage',
    'tencent': '/tencentConfigureStoreEditPage',
    'upyun': '/upyunConfigureStoreEditPage',
    'webdav': '/webdavConfigureStoreEditPage',
  };

  @override
  void initState() {
    super.initState();
  }

  initConfigMap() async {
    Map configMap = await ConfigureStoreFile().readConfigureFile(widget.psHost);
    return configMap;
  }

  List<Widget> buildPsInfoListTile(String storeName, Map pictureHostInfo) {
    String remarkName = pictureHostInfo['remarkName']!;
    List keys = pictureHostInfo.keys.toList();
    List values = pictureHostInfo.values.toList();
    List<Widget> psInfoListTile = [];

    bool isConfigured = !ConfigureStoreFile().checkIfOneUndetermined(pictureHostInfo);

    psInfoListTile.add(
      Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isConfigured ? const Color.fromARGB(255, 88, 171, 240) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: isConfigured ? const Color.fromARGB(255, 88, 171, 240) : Colors.grey.shade300,
                child: Text(
                  storeName,
                  style: TextStyle(
                    color: isConfigured ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                remarkName == ConfigureTemplate.placeholder ? '配置$storeName' : '配置$storeName->$remarkName',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: isConfigured
                  ? const Text('已配置', style: TextStyle(color: Colors.green))
                  : const Text('未配置', style: TextStyle(color: Colors.grey)),
              trailing: IconButton(
                icon: const Icon(Icons.more_horiz_outlined, color: Colors.amber),
                onPressed: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return buildBottomSheetWidget(context, storeName, pictureHostInfo);
                      });
                },
              ),
            ),
            if (!isConfigured)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    '尚未配置',
                    style: TextStyle(
                      color: Color.fromARGB(255, 88, 171, 240),
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: List.generate(keys.length, (i) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: SelectableText(
                                keys[i],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: SelectableText(
                              values[i] == ConfigureTemplate.placeholder ? '未配置' : values[i],
                              style: TextStyle(
                                color: values[i] == ConfigureTemplate.placeholder ? Colors.grey : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );

    return psInfoListTile;
  }

  buildAllPsInfoListTile(Map configMap) {
    List<Widget> allPsInfoListTile = [];
    String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (var element in alphabet.split('')) {
      allPsInfoListTile.addAll(buildPsInfoListTile(element, configMap[element]!));
    }
    return allPsInfoListTile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: titleText(psNameTranslate[widget.psHost]!),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withAlpha(204)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_forever,
              size: 30,
              color: Colors.redAccent,
            ),
            onPressed: () async {
              showCupertinoAlertDialogWithConfirmFunc(
                title: '通知',
                content: '是否重置所有已保存配置?',
                context: context,
                onConfirm: () async {
                  Navigator.pop(context);
                  await ConfigureStoreFile().resetConfigureFile(widget.psHost);
                  setState(() {
                    showToast('重置成功');
                  });
                },
              );
            },
          ),
        ],
      ),
      body: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return FutureBuilder(
            future: initConfigMap(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: buildAllPsInfoListTile(snapshot.data),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 198, 135, 235),
            heroTag: 'exportConfig',
            onPressed: () async {
              var result = await ConfigureStoreFile().exportConfigureToJson(widget.psHost);
              await Clipboard.setData(ClipboardData(text: result));
              showToast('已导出到剪贴板');
            },
            child: const Icon(Icons.outbox_outlined, color: Colors.white),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 127, 165, 37),
            heroTag: 'importConfig',
            onPressed: () async {
              var clipboardData = await Clipboard.getData('text/plain');
              if (clipboardData == null) {
                showToast('剪贴板为空');
                return;
              }
              try {
                await ConfigureStoreFile().importConfigureFromJson(widget.psHost, clipboardData.text!);
                setState(() {
                  showToast('导入成功');
                });
              } catch (e) {
                showToast('导入失败');
                return;
              }
            },
            child: const Icon(Icons.inbox_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  validateUndetermined(List toCheckList) {
    for (var element in toCheckList) {
      if (element == ConfigureTemplate.placeholder) {
        return false;
      }
    }
    return true;
  }

  Widget buildBottomSheetWidget(BuildContext context, String storeName, Map psInfo) {
    String remarkName = psInfo['remarkName']!;
    bool isConfigured = !ConfigureStoreFile().checkIfOneUndetermined(psInfo);

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 6,
              width: 40,
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundColor: isConfigured ? const Color.fromARGB(255, 88, 171, 240) : Colors.grey.shade300,
                child: Text(
                  storeName,
                  style: TextStyle(
                    color: isConfigured ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                remarkName == ConfigureTemplate.placeholder ? '配置$storeName' : '配置$storeName-$remarkName',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: isConfigured
                  ? const Text('已配置', style: TextStyle(color: Colors.green))
                  : const Text('未配置', style: TextStyle(color: Colors.grey)),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.edit,
                color: Color.fromARGB(255, 97, 141, 236),
              ),
              minLeadingWidth: 0,
              title: const Text('修改配置'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                Navigator.pop(context);
                Application.router
                    .navigateTo(
                      context,
                      '${psNameToRouter[widget.psHost]!}?storeKey=${Uri.encodeComponent(storeName)}&psInfo=${Uri.encodeComponent(jsonEncode(psInfo))}',
                      transition: TransitionType.cupertino,
                    )
                    .then((value) => setState(() {}));
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.outbox_outlined,
                color: Color.fromARGB(255, 97, 141, 236),
              ),
              minLeadingWidth: 0,
              title: const Text('导出'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                Navigator.pop(context);
                var result = await ConfigureStoreFile().exportConfigureKeyToJson(widget.psHost, storeName);
                await Clipboard.setData(ClipboardData(text: result));
                showToast('已复制到剪贴板');
              },
            ),
            const Divider(),
            ListTile(
                leading: const Icon(
                  Icons.check_box_outlined,
                  color: Color.fromARGB(255, 97, 141, 236),
                ),
                minLeadingWidth: 0,
                title: const Text('替代图床默认配置'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  if (widget.psHost == 'aliyun') {
                    try {
                      String keyId = psInfo['keyId']!;
                      String keySecret = psInfo['keySecret']!;
                      String bucket = psInfo['bucket']!;
                      String area = psInfo['area']!;
                      String path = psInfo['path']!;
                      String customUrl = psInfo['customUrl']!;
                      String options = psInfo['options']!;
                      bool valid = validateUndetermined([
                        keyId,
                        keySecret,
                        bucket,
                        area,
                      ]);
                      if (!valid) {
                        showToast('请先去设置参数');
                        return;
                      }
                      if (path == ConfigureTemplate.placeholder) {
                        path = 'None';
                      }
                      if (customUrl == ConfigureTemplate.placeholder) {
                        customUrl = 'None';
                      }
                      if (options == ConfigureTemplate.placeholder) {
                        options = 'None';
                      }

                      final aliyunConfig = AliyunConfigModel(keyId, keySecret, bucket, area, path, customUrl, options);
                      final aliyunConfigJson = jsonEncode(aliyunConfig);
                      final aliyunConfigFile = await AliyunManageAPI.localFile;
                      await aliyunConfigFile.writeAsString(aliyunConfigJson);
                      return showToast('设置成功');
                    } catch (e) {
                      FLog.error(
                          className: 'AliyunConfigureStorePage',
                          methodName: 'saveAliyunConfig',
                          text: formatErrorMessage({}, e.toString()),
                          dataLogType: DataLogType.ERRORS.toString());
                      return showToast('保存失败');
                    }
                  } else if (widget.psHost == 'aws') {
                    try {
                      String accessKeyId = psInfo['accessKeyId']!;
                      String secretAccessKey = psInfo['secretAccessKey']!;
                      String bucket = psInfo['bucket']!;
                      String endpoint = psInfo['endpoint']!;
                      String region = psInfo['region']!;
                      String uploadPath = psInfo['uploadPath']!;
                      String customUrl = psInfo['customUrl']!;
                      bool isS3PathStyle = psInfo['isS3PathStyle'] ?? false;
                      bool isEnableSSL = psInfo['isEnableSSL'] ?? true;
                      bool valid = validateUndetermined([
                        accessKeyId,
                        secretAccessKey,
                        bucket,
                        endpoint,
                      ]);
                      if (!valid) {
                        showToast('请先去设置参数');
                        return;
                      }
                      if (uploadPath == ConfigureTemplate.placeholder) {
                        uploadPath = 'None';
                      }
                      if (customUrl == ConfigureTemplate.placeholder) {
                        customUrl = 'None';
                      }
                      if (region == ConfigureTemplate.placeholder) {
                        region = 'None';
                      }

                      final awsConfig = AwsConfigModel(accessKeyId, secretAccessKey, bucket, endpoint, region,
                          uploadPath, customUrl, isS3PathStyle, isEnableSSL);
                      final awsConfigJson = jsonEncode(awsConfig);
                      final awsConfigFile = await AwsManageAPI.localFile;
                      await awsConfigFile.writeAsString(awsConfigJson);
                      return showToast('设置成功');
                    } catch (e) {
                      FLog.error(
                          className: 'AwsConfigureStorePage',
                          methodName: 'saveAwsConfig',
                          text: formatErrorMessage({}, e.toString()),
                          dataLogType: DataLogType.ERRORS.toString());
                      return showToast('保存失败');
                    }
                  } else if (widget.psHost == 'ftp') {
                    try {
                      String ftpHost = psInfo['ftpHost']!;
                      String ftpPort = psInfo['ftpPort']!;
                      String ftpUser = psInfo['ftpUser']!;
                      String ftpPassword = psInfo['ftpPassword']!;
                      String ftpType = psInfo['ftpType']!;
                      String isAnonymous = psInfo['isAnonymous']!.toString();
                      String uploadPath = psInfo['uploadPath']!;
                      String ftpHomeDir = psInfo['ftpHomeDir']!;
                      String? ftpCustomUrl = psInfo['ftpCustomUrl'];
                      String? ftpWebPath = psInfo['ftpWebPath'];
                      bool valid = validateUndetermined([
                        ftpHost,
                        ftpPort,
                        ftpType,
                        isAnonymous,
                      ]);
                      if (!valid) {
                        showToast('请先去设置参数');
                        return;
                      }
                      if (ftpUser == ConfigureTemplate.placeholder) {
                        ftpUser = 'None';
                      }
                      if (ftpPassword == ConfigureTemplate.placeholder) {
                        ftpPassword = 'None';
                      }
                      if (uploadPath == ConfigureTemplate.placeholder) {
                        uploadPath = 'None';
                      }
                      if (ftpHomeDir == ConfigureTemplate.placeholder) {
                        ftpHomeDir = 'None';
                      }
                      if (ftpCustomUrl == ConfigureTemplate.placeholder || ftpCustomUrl == null) {
                        ftpCustomUrl = 'None';
                      }
                      if (ftpWebPath == ConfigureTemplate.placeholder || ftpWebPath == null) {
                        ftpWebPath = 'None';
                      }

                      final ftpConfig = FTPConfigModel(
                        ftpHost,
                        ftpPort,
                        ftpUser,
                        ftpPassword,
                        ftpType,
                        isAnonymous,
                        uploadPath,
                        ftpHomeDir,
                        ftpCustomUrl,
                        ftpWebPath,
                      );
                      final ftpConfigJson = jsonEncode(ftpConfig);
                      final ftpConfigFile = await FTPManageAPI.localFile;
                      await ftpConfigFile.writeAsString(ftpConfigJson);
                      return showToast('设置成功');
                    } catch (e) {
                      FLog.error(
                          className: 'FtpConfigureStorePage',
                          methodName: 'saveFtpConfig',
                          text: formatErrorMessage({}, e.toString()),
                          dataLogType: DataLogType.ERRORS.toString());
                      return showToast('保存失败');
                    }
                  } else if (widget.psHost == 'github') {
                    try {
                      String githubusername = psInfo['githubusername']!;
                      String repo = psInfo['repo']!;
                      String token = psInfo['token']!;
                      String storePath = psInfo['storePath']!;
                      String branch = psInfo['branch']!;
                      String customDomain = psInfo['customDomain']!;
                      bool valid = validateUndetermined([githubusername, repo, token, branch]);
                      if (!valid) {
                        showToast('请先去设置参数');
                        return;
                      }
                      if (storePath == ConfigureTemplate.placeholder) {
                        storePath = 'None';
                      }
                      if (customDomain == ConfigureTemplate.placeholder) {
                        customDomain = 'None';
                      }

                      final githubConfig = GithubConfigModel(
                        githubusername,
                        repo,
                        token,
                        storePath,
                        branch,
                        customDomain,
                      );
                      final githubConfigJson = jsonEncode(githubConfig);
                      final githubConfigFile = await GithubManageAPI.localFile;
                      await githubConfigFile.writeAsString(githubConfigJson);
                      return showToast('设置成功');
                    } catch (e) {
                      FLog.error(
                          className: 'GithubConfigureStorePage',
                          methodName: 'saveGithubConfig',
                          text: formatErrorMessage({}, e.toString()),
                          dataLogType: DataLogType.ERRORS.toString());
                      return showToast('保存失败');
                    }
                  } else if (widget.psHost == 'imgur') {
                    try {
                      String clientId = psInfo['clientId']!;
                      String proxy = psInfo['proxy']!;
                      bool valid = validateUndetermined([
                        clientId,
                      ]);
                      if (!valid) {
                        showToast('请先去设置参数');
                        return;
                      }
                      if (proxy == ConfigureTemplate.placeholder) {
                        proxy = 'None';
                      }
                      final imgurConfig = ImgurConfigModel(
                        clientId,
                        proxy,
                      );
                      final imgurConfigJson = jsonEncode(imgurConfig);
                      final imgurConfigFile = await ImgurManageAPI.localFile;
                      await imgurConfigFile.writeAsString(imgurConfigJson);
                      return showToast('设置成功');
                    } catch (e) {
                      FLog.error(
                          className: 'ImgurConfigureStorePage',
                          methodName: 'saveImgurConfig',
                          text: formatErrorMessage({}, e.toString()),
                          dataLogType: DataLogType.ERRORS.toString());
                      return showToast('保存失败');
                    }
                  } else if (widget.psHost == 'lsky.pro') {
                    try {
                      String host = psInfo['host']!;
                      String token = psInfo['token']!;
                      String strategyId = psInfo['strategy_id']!.toString();
                      String albumId = psInfo['album_id']!.toString();
                      bool valid = validateUndetermined([
                        host,
                        token,
                        strategyId,
                      ]);
                      if (!valid) {
                        showToast('请先去设置参数');
                        return;
                      }
                      if (albumId == ConfigureTemplate.placeholder) {
                        albumId = 'None';
                      }

                      final lskyproConfig = HostConfigModel(
                        host,
                        token,
                        strategyId,
                        albumId,
                      );
                      final lskyproConfigJson = jsonEncode(lskyproConfig);
                      final lskyproConfigFile = await LskyproManageAPI.localFile;
                      await lskyproConfigFile.writeAsString(lskyproConfigJson);
                      return showToast('设置成功');
                    } catch (e) {
                      FLog.error(
                          className: 'LskyproConfigureStorePage',
                          methodName: 'saveLskyProConfig',
                          text: formatErrorMessage({}, e.toString()),
                          dataLogType: DataLogType.ERRORS.toString());
                      return showToast('保存失败');
                    }
                  } else if (widget.psHost == 'qiniu') {
                    try {
                      String accessKey = psInfo['accessKey']!;
                      String secretKey = psInfo['secretKey']!;
                      String bucket = psInfo['bucket']!;
                      String url = psInfo['url']!;
                      String area = psInfo['area']!;
                      String options = psInfo['options']!;
                      String path = psInfo['path']!;
                      bool valid = validateUndetermined([
                        accessKey,
                        secretKey,
                        bucket,
                        url,
                        area,
                      ]);
                      if (!valid) {
                        showToast('请先去设置参数');
                        return;
                      }
                      if (options == ConfigureTemplate.placeholder) {
                        options = 'None';
                      }
                      if (path == ConfigureTemplate.placeholder) {
                        path = 'None';
                      }

                      final qiniuConfig = QiniuConfigModel(
                        accessKey,
                        secretKey,
                        bucket,
                        url,
                        area,
                        options,
                        path,
                      );
                      final qiniuConfigJson = jsonEncode(qiniuConfig);
                      final qiniuConfigFile = await QiniuManageAPI.localFile;
                      await qiniuConfigFile.writeAsString(qiniuConfigJson);
                      return showToast('设置成功');
                    } catch (e) {
                      FLog.error(
                          className: 'QiniuConfigureStorePage',
                          methodName: 'saveQiniuConfig',
                          text: formatErrorMessage({}, e.toString()),
                          dataLogType: DataLogType.ERRORS.toString());
                      return showToast('保存失败');
                    }
                  } else if (widget.psHost == 'sm.ms') {
                    try {
                      String token = psInfo['token']!;
                      bool valid = validateUndetermined([
                        token,
                      ]);
                      if (!valid) {
                        showToast('请先去设置参数');
                        return;
                      }

                      final smmsConfig = SmmsConfigModel(
                        token,
                      );
                      final smmsConfigJson = jsonEncode(smmsConfig);
                      final smmsConfigFile = await SmmsManageAPI.localFile;
                      await smmsConfigFile.writeAsString(smmsConfigJson);
                      return showToast('设置成功');
                    } catch (e) {
                      FLog.error(
                          className: 'SmmsConfigureStorePage',
                          methodName: 'saveSmmsConfig',
                          text: formatErrorMessage({}, e.toString()),
                          dataLogType: DataLogType.ERRORS.toString());
                      return showToast('保存失败');
                    }
                  } else if (widget.psHost == 'tencent') {
                    try {
                      String secretId = psInfo['secretId']!;
                      String secretKey = psInfo['secretKey']!;
                      String bucket = psInfo['bucket']!;
                      String appId = psInfo['appId']!;
                      String area = psInfo['area']!;
                      String path = psInfo['path']!;
                      String customUrl = psInfo['customUrl']!;
                      String options = psInfo['options']!;
                      bool valid = validateUndetermined([
                        secretId,
                        secretKey,
                        bucket,
                        appId,
                        area,
                      ]);
                      if (!valid) {
                        showToast('请先去设置参数');
                        return;
                      }
                      if (path == ConfigureTemplate.placeholder) {
                        path = 'None';
                      }
                      if (customUrl == ConfigureTemplate.placeholder) {
                        customUrl = 'None';
                      }
                      if (options == ConfigureTemplate.placeholder) {
                        options = 'None';
                      }

                      final tencentConfig =
                          TencentConfigModel(secretId, secretKey, bucket, appId, area, path, customUrl, options);
                      final tencentConfigJson = jsonEncode(tencentConfig);
                      final tencentConfigFile = await TencentManageAPI.localFile;
                      await tencentConfigFile.writeAsString(tencentConfigJson);
                      return showToast('设置成功');
                    } catch (e) {
                      FLog.error(
                          className: 'TencentConfigureStorePage',
                          methodName: 'saveTencentConfig',
                          text: formatErrorMessage({}, e.toString()),
                          dataLogType: DataLogType.ERRORS.toString());
                      return showToast('保存失败');
                    }
                  } else if (widget.psHost == 'upyun') {
                    try {
                      String bucket = psInfo['bucket']!;
                      String operator = psInfo['operator']!;
                      String password = psInfo['password']!;
                      String url = psInfo['url']!;
                      String options = psInfo['options']!;
                      String path = psInfo['path']!;
                      String antiLeechToken = psInfo['antiLeechToken']!;
                      String antiLeechType = psInfo['antiLeechType']!;

                      bool valid = validateUndetermined([
                        bucket,
                        operator,
                        password,
                        url,
                      ]);
                      if (!valid) {
                        showToast('请先去设置参数');
                        return;
                      }
                      if (path == ConfigureTemplate.placeholder) {
                        path = 'None';
                      }

                      final upyunConfig = UpyunConfigModel(
                          bucket, operator, password, url, options, path, antiLeechToken, antiLeechType);
                      final upyunConfigJson = jsonEncode(upyunConfig);
                      final upyunConfigFile = await UpyunManageAPI.localFile;
                      await upyunConfigFile.writeAsString(upyunConfigJson);
                      return showToast('设置成功');
                    } catch (e) {
                      FLog.error(
                          className: 'UpyunConfigureStorePage',
                          methodName: 'saveUpyunConfig',
                          text: formatErrorMessage({}, e.toString()),
                          dataLogType: DataLogType.ERRORS.toString());
                      return showToast('保存失败');
                    }
                  } else if (widget.psHost == 'alist') {
                    try {
                      String host = psInfo['host'];
                      String? adminToken = psInfo['adminToken'];
                      String alistusername = psInfo['alistusername'];
                      String password = psInfo['password'];
                      String token = psInfo['token'];
                      String uploadPath = psInfo['uploadPath'];
                      String? webPath = psInfo['webPath'];
                      String? customUrl = psInfo['customUrl'];
                      bool valid = validateUndetermined([
                        host,
                      ]);
                      if (!valid) {
                        showToast('请先去设置参数');
                        return;
                      }
                      uploadPath = checkPlaceholder(uploadPath);
                      adminToken = checkPlaceholder(adminToken);
                      alistusername = checkPlaceholder(alistusername);
                      password = checkPlaceholder(password);
                      webPath = checkPlaceholder(webPath);
                      customUrl = checkPlaceholder(customUrl);

                      final alistConfig = AlistConfigModel(
                        host,
                        adminToken,
                        alistusername,
                        password,
                        token,
                        uploadPath,
                        webPath,
                        customUrl,
                      );
                      final alistConfigJson = jsonEncode(alistConfig);
                      final alistConfigFile = await AlistManageAPI.localFile;
                      await alistConfigFile.writeAsString(alistConfigJson);
                      return showToast('设置成功');
                    } catch (e) {
                      FLog.error(
                          className: 'AlistConfigureStorePage',
                          methodName: 'saveAlistConfig',
                          text: formatErrorMessage({}, e.toString()),
                          dataLogType: DataLogType.ERRORS.toString());
                      return showToast('保存失败');
                    }
                  } else if (widget.psHost == 'webdav') {
                    try {
                      String host = psInfo['host']!;
                      String webdavusername = psInfo['webdavusername']!;
                      String password = psInfo['password']!;
                      String uploadPath = psInfo['uploadPath']!;
                      String? customUrl = psInfo['customUrl'];
                      String? webPath = psInfo['webPath'];
                      bool valid = validateUndetermined([
                        host,
                        webdavusername,
                        password,
                      ]);
                      if (!valid) {
                        showToast('请先去设置参数');
                        return;
                      }
                      if (uploadPath == ConfigureTemplate.placeholder) {
                        uploadPath = 'None';
                      }
                      if (customUrl == ConfigureTemplate.placeholder || customUrl == null) {
                        customUrl = 'None';
                      }
                      if (webPath == ConfigureTemplate.placeholder || webPath == null) {
                        webPath = 'None';
                      }

                      final webdavConfig = WebdavConfigModel(
                        host,
                        webdavusername,
                        password,
                        uploadPath,
                        customUrl,
                        webPath,
                      );
                      final webdavConfigJson = jsonEncode(webdavConfig);
                      final webdavConfigFile = await WebdavManageAPI.localFile;
                      await webdavConfigFile.writeAsString(webdavConfigJson);
                      return showToast('设置成功');
                    } catch (e) {
                      FLog.error(
                          className: 'WebdavConfigureStorePage',
                          methodName: 'saveWebdavConfig',
                          text: formatErrorMessage({}, e.toString()),
                          dataLogType: DataLogType.ERRORS.toString());
                      return showToast('保存失败');
                    }
                  }
                }),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.refresh,
                color: Color.fromARGB(255, 240, 85, 131),
              ),
              minLeadingWidth: 0,
              title: const Text('重置配置'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                showCupertinoAlertDialogWithConfirmFunc(
                  title: '通知',
                  content: '是否重置配置$storeName?',
                  context: context,
                  onConfirm: () async {
                    await ConfigureStoreFile().resetConfigureFileKey(
                      widget.psHost,
                      storeName,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                    }
                    setState(() {
                      showToast('重置成功');
                    });
                  },
                );
              },
            ),
            // Add padding at the bottom to ensure better visibility with system navigation
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
