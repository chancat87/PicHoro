import 'dart:io';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:external_path/external_path.dart';

import 'package:horopic/picture_host_manage/smms/upload_api/smms_upload_utils.dart';
import 'package:horopic/picture_host_manage/smms/download_api/smms_downloader.dart';
import 'package:horopic/picture_host_manage/common_page/download/pnc_download_task.dart';
import 'package:horopic/picture_host_manage/common_page/download/pnc_download_status.dart';
import 'package:horopic/picture_host_manage/common_page/upload/pnc_upload_task.dart';
import 'package:horopic/pages/upload_pages/upload_status.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
//修改自flutter_download_manager包 https://github.com/nabil6391/flutter_download_manager 作者@nabil6391

class SmmsUpDownloadManagePage extends StatefulWidget {
  final String downloadPath;
  final String tabIndex;
  const SmmsUpDownloadManagePage({super.key, required this.downloadPath, required this.tabIndex});

  @override
  SmmsUpDownloadManagePageState createState() => SmmsUpDownloadManagePageState();
}

class SmmsUpDownloadManagePageState extends State<SmmsUpDownloadManagePage> {
  var downloadManager = DownloadManager();
  var uploadManager = UploadManager();
  List<String> uploadPathList = [];
  List<String> uploadFileNameList = [];
  List<Map<String, dynamic>> uploadConfigMapList = [];
  var savedDir = '';

  @override
  void initState() {
    super.initState();
    downloadManager = DownloadManager();
    uploadManager = UploadManager();
    savedDir = '${widget.downloadPath}/PicHoro/Download/smms/';
    if (Global.smmsUploadList.isNotEmpty) {
      for (var i = 0; i < Global.smmsUploadList.length; i++) {
        var currentElement = jsonDecode(Global.smmsUploadList[i]);
        uploadPathList.add(currentElement[0]);
        uploadFileNameList.add(currentElement[1]);
        Map<String, dynamic> tempMap = currentElement[2];
        uploadConfigMapList.add(tempMap);
      }
    }
  }

  _createUploadListItem() {
    List<Widget> list = [];
    for (var i = Global.smmsUploadList.length - 1; i >= 0; i--) {
      list.add(GestureDetector(
          onLongPress: () {
            showCupertinoAlertDialogWithConfirmFunc(
                context: context,
                content: '是否从任务列表中删除?',
                title: '通知',
                onConfirm: () async {
                  Navigator.pop(context);
                  Global.smmsUploadList.remove(Global.smmsUploadList[i]);
                  Global.setSmmsUploadList(Global.smmsUploadList);
                  uploadPathList.removeAt(i);
                  uploadFileNameList.removeAt(i);
                  uploadConfigMapList.removeAt(i);
                  setState(() {});
                });
          },
          child: UploadListItem(
              onUploadPlayPausedPressed: (path, fileName, configMap) async {
                var task = uploadManager.getUpload(jsonDecode(Global.smmsUploadList[i])[1]);
                if (task != null && !task.status.value.isCompleted) {
                  switch (task.status.value) {
                    case UploadStatus.uploading:
                      await uploadManager.pauseUpload(path, fileName);
                    case UploadStatus.paused:
                      await uploadManager.resumeUpload(path, fileName);
                    default:
                      break;
                  }
                  setState(() {});
                } else {
                  await uploadManager.addUpload(path, fileName, configMap);
                  setState(() {});
                }
              },
              onDelete: (path, fileName) async {
                await uploadManager.removeUpload(path, fileName);
                setState(() {});
              },
              path: jsonDecode(Global.smmsUploadList[i])[0],
              fileName: jsonDecode(Global.smmsUploadList[i])[1],
              configMap: jsonDecode(Global.smmsUploadList[i])[2],
              uploadTask: uploadManager.getUpload(jsonDecode(Global.smmsUploadList[i])[1]))));
    }
    List<Widget> list2 = [
      const Divider(
        height: 5,
        color: Colors.transparent,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () async {
                await uploadManager.addBatchUploads(uploadPathList, uploadFileNameList, uploadConfigMapList);
                setState(() {});
              },
              child: const Text(
                "全部开始",
                style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
              )),
          TextButton(
              onPressed: () async {
                await uploadManager.cancelBatchUploads(uploadPathList, uploadFileNameList);
              },
              child: const Text(
                "全部取消",
                style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
              )),
          TextButton(
              onPressed: () async {
                Global.setSmmsUploadList([]);
                uploadPathList.clear();
                uploadFileNameList.clear();
                uploadConfigMapList.clear();
                setState(() {});
              },
              child: const Text(
                "全部清空",
                style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
              )),
        ],
      ),
      ValueListenableBuilder(
          valueListenable: uploadManager.getBatchUploadProgress(uploadPathList, uploadFileNameList),
          builder: (context, value, child) {
            return Container(
              color: const Color.fromARGB(255, 219, 239, 255),
              height: 10,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: LinearProgressIndicator(
                value: value,
              ),
            );
          }),
    ];
    list2.addAll(list);

    return list2;
  }

  _createDownloadListItem() {
    List<Widget> list = [];
    for (var i = Global.smmsDownloadList.length - 1; i >= 0; i--) {
      list.add(GestureDetector(
          onLongPress: () {
            showCupertinoAlertDialogWithConfirmFunc(
                context: context,
                content: '是否从任务列表中删除?',
                title: '通知',
                onConfirm: () async {
                  Navigator.pop(context);
                  Global.smmsDownloadList.remove(Global.smmsDownloadList[i]);
                  Global.setSmmsDownloadList(Global.smmsDownloadList);
                  Global.smmsSavedNameList.remove(Global.smmsSavedNameList[i]);
                  Global.setSmmsSavedNameList(Global.smmsSavedNameList);
                  setState(() {});
                });
          },
          child: ListItem(
              onDownloadPlayPausedPressed: (url) async {
                var task = downloadManager.getDownload(Global.smmsDownloadList[i]);
                if (task != null && !task.status.value.isCompleted) {
                  switch (task.status.value) {
                    case DownloadStatus.downloading:
                      await downloadManager.pauseDownload(url);
                    case DownloadStatus.paused:
                      await downloadManager.resumeDownload(url);
                    default:
                      break;
                  }
                  setState(() {});
                } else {
                  await downloadManager.addDownload(url, "$savedDir${Global.smmsSavedNameList[i]}");
                  setState(() {});
                }
              },
              onDelete: (url) async {
                var fileName = "$savedDir${Global.smmsSavedNameList[Global.smmsDownloadList.indexOf(url)]}";
                var file = File(fileName);
                try {
                  await file.delete();
                } catch (e) {
                  flogErr(
                      e,
                      {
                        'url': url,
                        'fileName': fileName,
                      },
                      'SmmsUpDownloadManagePageState',
                      '_createDownloadListItem');
                }
                await downloadManager.removeDownload(url);
                setState(() {});
              },
              index: i,
              savedFileNameList: Global.smmsSavedNameList,
              url: Global.smmsDownloadList[i],
              downloadTask: downloadManager.getDownload(Global.smmsDownloadList[i]))));
    }
    List<Widget> list2 = [
      const Divider(
        height: 5,
        color: Colors.transparent,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(
          width: 10,
        ),
        CupertinoButton(
          color: const Color.fromARGB(255, 78, 163, 233),
          padding: const EdgeInsets.all(10),
          onPressed: () async {
            String externalStorageDirectory =
                await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
            externalStorageDirectory = '$externalStorageDirectory/PicHoro/Download/smms';
            // ignore: use_build_context_synchronously
            Application.router.navigateTo(context,
                '${Routes.fileExplorer}?currentDirPath=${Uri.encodeComponent(externalStorageDirectory)}&rootPath=${Uri.encodeComponent(externalStorageDirectory)}',
                transition: TransitionType.cupertino);
          },
          child:
              const Text('打开下载文件目录', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(
          width: 10,
        ),
        CupertinoButton(
          color: const Color.fromARGB(255, 78, 163, 233),
          padding: const EdgeInsets.all(10),
          onPressed: () {
            Global.setSmmsDownloadList([]);
            Global.setSmmsSavedNameList([]);
            setState(() {});
          },
          child: const Row(
            children: [
              Icon(
                Icons.delete,
                color: Colors.white,
              ),
              Text('清空下载列表', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ]),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () async {
                String externalStorageDirectory =
                    await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
                externalStorageDirectory = '$externalStorageDirectory/PicHoro/Download/smms';
                List savedDirList = [];
                for (var i = 0; i < Global.smmsSavedNameList.length; i++) {
                  savedDirList.add('$externalStorageDirectory/${Global.smmsSavedNameList[i]}');
                }
                await downloadManager.addBatchDownloads(Global.smmsDownloadList, savedDirList);
                setState(() {});
              },
              child: const Text(
                "全部下载",
                style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
              )),
          TextButton(
              onPressed: () async {
                await downloadManager.pauseBatchDownloads(Global.smmsDownloadList);
              },
              child: const Text(
                "全部暂停",
                style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
              )),
          TextButton(
              onPressed: () async {
                await downloadManager.resumeBatchDownloads(Global.smmsDownloadList);
              },
              child: const Text(
                "全部继续",
                style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
              )),
          TextButton(
              onPressed: () async {
                await downloadManager.cancelBatchDownloads(Global.smmsDownloadList);
              },
              child: const Text(
                "全部取消",
                style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
              )),
        ],
      ),
      ValueListenableBuilder(
          valueListenable: downloadManager.getBatchDownloadProgress(Global.smmsDownloadList),
          builder: (context, value, child) {
            return Container(
              height: 10,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: LinearProgressIndicator(
                value: value,
              ),
            );
          }),
    ];
    list2.addAll(list);
    return list2;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: int.parse(widget.tabIndex),
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              elevation: 0,
              title: titleText(
                '上传下载管理',
              ),
              bottom: const TabBar(
                padding: EdgeInsets.all(0),
                indicatorColor: Colors.amber,
                indicatorPadding: EdgeInsets.symmetric(horizontal: 30),
                unselectedLabelColor: Colors.white,
                tabs: <Widget>[
                  Tab(
                      child:
                          Text('上传', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                  Tab(
                      child:
                          Text('下载', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: _createUploadListItem(),
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: _createDownloadListItem(),
                  ),
                )
              ],
            )));
  }
}

class ListItem extends StatefulWidget {
  final Function(String) onDownloadPlayPausedPressed;
  final Function(String) onDelete;
  final DownloadTask? downloadTask;
  final List savedFileNameList;
  final int index;
  final String url;
  const ListItem(
      {super.key,
      required this.onDownloadPlayPausedPressed,
      required this.onDelete,
      required this.savedFileNameList,
      required this.index,
      required this.url,
      this.downloadTask});

  @override
  ListItemState createState() => ListItemState();
}

class ListItemState extends State<ListItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 80, 183, 231),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '文件名:${widget.savedFileNameList[widget.index]}',
                    ),
                    if (widget.downloadTask != null)
                      ValueListenableBuilder(
                          valueListenable: widget.downloadTask!.status,
                          builder: (context, value, child) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child:
                                  Text("状态: ${downloadStatus[value.toString()]}", style: const TextStyle(fontSize: 14)),
                            );
                          }),
                  ],
                )),
                widget.downloadTask != null
                    ? ValueListenableBuilder(
                        valueListenable: widget.downloadTask!.status,
                        builder: (context, value, child) {
                          switch (widget.downloadTask!.status.value) {
                            case DownloadStatus.downloading:
                              return IconButton(
                                  onPressed: () async {
                                    await widget.onDownloadPlayPausedPressed(widget.url);
                                  },
                                  icon: const Icon(
                                    Icons.pause,
                                    color: Colors.blue,
                                  ));
                            case DownloadStatus.paused:
                              return IconButton(
                                onPressed: () async {
                                  await widget.onDownloadPlayPausedPressed(widget.url);
                                },
                                icon: const Icon(Icons.play_arrow),
                                color: Colors.blue,
                              );
                            case DownloadStatus.completed:
                              return IconButton(
                                  onPressed: () {
                                    widget.onDelete(widget.url);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ));
                            case DownloadStatus.failed:
                            case DownloadStatus.canceled:
                              return IconButton(
                                  onPressed: () async {
                                    await widget.onDownloadPlayPausedPressed(widget.url);
                                  },
                                  icon: const Icon(
                                    Icons.download,
                                    color: Colors.blue,
                                  ));
                            case DownloadStatus.queued:
                              return const Icon(
                                Icons.query_builder_rounded,
                                color: Colors.blue,
                              );
                          }
                        })
                    : IconButton(
                        onPressed: () async {
                          await widget.onDownloadPlayPausedPressed(widget.url);
                        },
                        icon: const Icon(
                          Icons.download,
                          color: Colors.green,
                        ))
              ],
            ),
            if (widget.downloadTask != null && !widget.downloadTask!.status.value.isCompleted)
              ValueListenableBuilder(
                  valueListenable: widget.downloadTask!.progress,
                  builder: (context, value, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: LinearProgressIndicator(
                        value: value,
                        color: widget.downloadTask!.status.value == DownloadStatus.paused ? Colors.grey : Colors.amber,
                      ),
                    );
                  }),
          ],
        ),
      ),
    );
  }
}

class UploadListItem extends StatefulWidget {
  final Function(String, String, Map<String, dynamic>) onUploadPlayPausedPressed;
  final Function(String, String) onDelete;
  final UploadTask? uploadTask;
  final String path;
  final String fileName;
  final Map<String, dynamic> configMap;
  const UploadListItem(
      {super.key,
      required this.onUploadPlayPausedPressed,
      required this.onDelete,
      required this.path,
      required this.fileName,
      required this.configMap,
      this.uploadTask});

  @override
  UploadListItemState createState() => UploadListItemState();
}

class UploadListItemState extends State<UploadListItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 203, 237, 253),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        padding: const EdgeInsets.all(1.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                getImageIcon(widget.path),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '文件名:${widget.fileName}',
                    ),
                    if (widget.uploadTask != null)
                      ValueListenableBuilder(
                          valueListenable: widget.uploadTask!.status,
                          builder: (context, value, child) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child:
                                  Text("状态: ${uploadStatus[value.toString()]}", style: const TextStyle(fontSize: 14)),
                            );
                          }),
                  ],
                )),
                widget.uploadTask != null
                    ? ValueListenableBuilder(
                        valueListenable: widget.uploadTask!.status,
                        builder: (context, value, child) {
                          switch (widget.uploadTask!.status.value) {
                            case UploadStatus.completed:
                              return IconButton(
                                  onPressed: () {
                                    widget.onDelete(widget.path, widget.fileName);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ));
                            case UploadStatus.failed:
                            case UploadStatus.canceled:
                              return IconButton(
                                  onPressed: () async {
                                    await widget.onUploadPlayPausedPressed(
                                        widget.path, widget.fileName, widget.configMap);
                                  },
                                  icon: const Icon(
                                    Icons.cloud_upload_outlined,
                                    color: Colors.blue,
                                  ));
                            default:
                              return widget.uploadTask == null || widget.uploadTask!.status.value == UploadStatus.queued
                                  ? const Icon(
                                      Icons.query_builder_rounded,
                                      color: Colors.blue,
                                    )
                                  : ValueListenableBuilder(
                                      valueListenable: widget.uploadTask!.progress,
                                      builder: (context, value, child) {
                                        return Container(
                                          height: 20,
                                          width: 20,
                                          margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                          child: CircularProgressIndicator(
                                            value: value,
                                            strokeWidth: 4,
                                            color: widget.uploadTask!.status.value == UploadStatus.paused
                                                ? Colors.grey
                                                : Colors.blue,
                                          ),
                                        );
                                      });
                          }
                        })
                    : IconButton(
                        onPressed: () async {
                          await widget.onUploadPlayPausedPressed(widget.path, widget.fileName, widget.configMap);
                        },
                        icon: const Icon(
                          Icons.cloud_upload_outlined,
                          color: Colors.green,
                        ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
