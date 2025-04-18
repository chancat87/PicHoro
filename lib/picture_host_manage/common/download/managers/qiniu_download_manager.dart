import 'dart:async';

import 'package:horopic/picture_host_manage/common/download/common_service/base_download_manager.dart';

class DownloadManager extends BaseDownloadManager {
  static final DownloadManager _dm = DownloadManager._internal();

  DownloadManager._internal();

  factory DownloadManager({int? maxConcurrentTasks}) {
    if (maxConcurrentTasks != null) {
      _dm.maxConcurrentTasks = maxConcurrentTasks;
    }
    return _dm;
  }

  @override
  Future<void> download(String url, String savePath, cancelToken, {Map? configMap = const {}}) async {
    await processDownload(url, savePath, cancelToken, 'qiniu_DownloadManager', configMap: configMap);
  }
}
