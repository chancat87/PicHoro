import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as my_path;

import 'package:horopic/utils/common_functions.dart';

class AliyunImageUploadUtils {
  static uploadApi({
    required String path,
    required String name,
    required Map configMap,
    Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      String keyId = configMap['keyId'] ?? '';
      String keySecret = configMap['keySecret'] ?? '';
      String bucket = configMap['bucket'] ?? '';
      String area = configMap['area'] ?? '';
      String aliyunpath = configMap['path'] ?? 'None';
      String customUrl = configMap['customUrl'] ?? 'None';
      String options = configMap['options'] ?? 'None';

      if (customUrl != "None" && !customUrl.startsWith(RegExp(r'http(s)?://'))) {
        customUrl = 'http://$customUrl';
      }

      if (aliyunpath != 'None') {
        aliyunpath = '${aliyunpath.replaceAll(RegExp(r'^/*|/*$'), '')}/';
      }

      String host = '$bucket.$area.aliyuncs.com';
      //云存储的路径 阿里云不能以/开头
      String urlpath = aliyunpath != 'None' ? '$aliyunpath$name' : name;

      Map<String, dynamic> uploadPolicy = {
        "expiration": "2034-12-01T12:00:00.000Z",
        "conditions": [
          {"bucket": bucket},
          ["content-length-range", 0, 104857600],
          {"key": urlpath}
        ]
      };
      String base64Policy = base64.encode(utf8.encode(json.encode(uploadPolicy)));
      String singature = base64.encode(Hmac(sha1, utf8.encode(keySecret)).convert(utf8.encode(base64Policy)).bytes);
      Map<String, dynamic> formMap = {
        'key': urlpath,
        'OSSAccessKeyId': keyId,
        'policy': base64Policy,
        'Signature': singature,
        'file': await MultipartFile.fromFile(path, filename: my_path.basename(name)),
      };
      formMap['x-oss-content-type'] = getContentType(my_path.extension(path));

      FormData formData = FormData.fromMap(formMap);
      BaseOptions baseoptions = setBaseOptions();
      File uploadFile = File(path);
      String contentLength = await uploadFile.length().then((value) {
        return value.toString();
      });
      baseoptions.headers = {
        'Host': host,
        'Content-Length': contentLength,
      };
      Dio dio = Dio(baseoptions);

      var response = await dio.post(
        'https://$host',
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      if (response.statusCode != 204) {
        return ['failed'];
      }

      String returnUrl = '';
      String displayUrl = '';

      if (customUrl != 'None') {
        customUrl = customUrl.replaceAll(RegExp(r'/*$'), '');
        returnUrl = '$customUrl/$urlpath';
        displayUrl = returnUrl;
      } else {
        returnUrl = 'https://$host/$urlpath';
        displayUrl = returnUrl;
      }

      if (options == 'None') {
        displayUrl = displayUrl;
      } else {
        returnUrl = '$returnUrl$options';
        displayUrl = '$displayUrl$options';
      }

      String formatedURL = getFormatedUrl(returnUrl, name);
      String pictureKey = jsonEncode(configMap);
      return ["success", formatedURL, returnUrl, pictureKey, displayUrl];
    } catch (e) {
      flogErr(
          e,
          {
            'path': path,
            'name': name,
          },
          "AliyunImageUploadUtils",
          "uploadApi");
      return ['failed'];
    }
  }

  static deleteApi({required Map deleteMap, required Map configMap}) async {
    try {
      String fileName = deleteMap['name'];
      Map configMapFromPictureKey = jsonDecode(deleteMap['pictureKey']);
      String keyId = configMapFromPictureKey['keyId'];
      String keySecret = configMapFromPictureKey['keySecret'];
      String bucket = configMapFromPictureKey['bucket'];
      String area = configMapFromPictureKey['area'];
      String aliyunpath = configMapFromPictureKey['path'];
      String deleteHost = 'https://$bucket.$area.aliyuncs.com';
      String urlpath = '';
      if (aliyunpath != 'None') {
        if (aliyunpath.startsWith('/')) {
          aliyunpath = aliyunpath.substring(1);
        }
        if (!aliyunpath.endsWith('/')) {
          aliyunpath = '$aliyunpath/';
        }
        deleteHost = '$deleteHost/$aliyunpath$fileName';
        urlpath = '$aliyunpath$fileName';
      } else {
        deleteHost = '$deleteHost/$fileName';
        urlpath = fileName;
      }
      BaseOptions baseOptions = setBaseOptions();
      String authorization = 'OSS $keyId:';
      var date = HttpDate.format(DateTime.now());
      String verb = 'DELETE';
      String contentMD5 = '';
      String contentType = 'application/json';
      String canonicalizedOSSHeaders = '';
      String canonicalizedResource = '/$bucket/$urlpath';
      String stringToSign = '$verb\n$contentMD5\n$contentType\n$date\n$canonicalizedOSSHeaders$canonicalizedResource';
      String signature = base64.encode(Hmac(sha1, utf8.encode(keySecret)).convert(utf8.encode(stringToSign)).bytes);

      baseOptions.headers = {
        'Host': '$bucket.$area.aliyuncs.com',
        'Authorization': '$authorization$signature',
        'Date': date,
        'Content-type': 'application/json',
      };
      Dio dio = Dio(baseOptions);

      var response = await dio.delete(
        deleteHost,
      );
      return response.statusCode == 204 ? ["success"] : ["failed"];
    } catch (e) {
      flogErr(
          e,
          {
            'deleteMap': deleteMap,
            'configMap': configMap,
          },
          "AliyunImageUploadUtils",
          "deleteApi");
      return ["failed"];
    }
  }
}
