// 参考: https://blog.csdn.net/O_time/article/details/86496537

import 'package:flutter/material.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:f_logs/f_logs.dart';

// ignore: must_be_immutable
class NetLoadingDialog extends StatefulWidget {
  String loadingText;
  bool outsideDismiss;
  bool loading;

  Future<dynamic> requestCallBack;

  NetLoadingDialog(
      {super.key,
      this.loadingText = "loading...",
      this.outsideDismiss = false,
      required this.loading,
      required this.requestCallBack});

  @override
  State<NetLoadingDialog> createState() => _LoadingDialog();
}

class _LoadingDialog extends State<NetLoadingDialog> {
  @override
  void initState() {
    super.initState();
    // ignore: unnecessary_null_comparison
    if (widget.requestCallBack != null) {
      widget.requestCallBack.then((err) {
        err;
        Global.operateDone = true;
        Navigator.pop(context);
      }).catchError((err) {
        FLog.error(
            className: 'NetLoadingDialog',
            methodName: 'initState',
            text: formatErrorMessage({}, err.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.loading) {
      return Container();
    }
    return GestureDetector(
      onTap: null,
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: SizedBox(
            width: 120.0,
            height: 120.0,
            child: Container(
              decoration: ShapeDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                    ),
                    child: Text(
                      widget.loadingText,
                      style: const TextStyle(fontSize: 12.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
