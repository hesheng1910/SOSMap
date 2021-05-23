import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sosmap/models/list_report.dart';
import 'package:sosmap/models/report.dart';
import 'package:sosmap/models/state.dart';
import 'package:sosmap/ui/widgets/rate_star.dart';
import 'package:sosmap/util/list_report.dart';
import 'package:sosmap/util/state_widget.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'profile.dart';

class HistoryScreen extends StatefulWidget {
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  StateModel appState;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
  }

  void _onRefresh() async {
    // monitor network fetch
    await getListReport();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await getListReport();
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    _refreshController.loadComplete();
  }

  Future getListReport() async {
    if (appState.user.userId != null) {
      ListReportModel result =
          await ReportAPI.getListReportFirestore(appState.user.userId);
      return result.listReport;
    }
    return [];
  }

  String readTimestamp(int timestamp) {
    var now = new DateTime.now();
    var format = new DateFormat('dd/MM/yyyy HH:mm a');
    var date = new DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
    var diff = date.difference(now);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' ngày trước';
      } else {
        time = diff.inDays.toString() + ' ngày trước';
      }
    }

    return time;
  }

  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Lịch sử giúp đỡ',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SafeArea(
            child: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.none &&
                snapshot.hasData == null) {
              //print('project snapshot data is: ${projectSnap.data}');
              return Container();
            }
            return SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                header: WaterDropHeader(),
                footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus mode) {
                    Widget body;
                    if (mode == LoadStatus.idle) {
                      body = Text("Kéo xuống để làm mới");
                    } else if (mode == LoadStatus.loading) {
                      body = CupertinoActivityIndicator();
                    } else if (mode == LoadStatus.failed) {
                      body = Text("Không lấy được data. Vui lòng thử lại!");
                    } else if (mode == LoadStatus.canLoading) {
                      body = Text("Tải thêm dữ liệu");
                    } else {
                      body = Text("Không còn dữ liệu");
                    }
                    return Container(
                      height: 55.0,
                      child: Center(child: body),
                    );
                  },
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: ListView.builder(
                  itemCount: snapshot?.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    ReportModel report = snapshot.data[index];
                    return ListTile(
                      title: Text(report.request.name),
                      subtitle: Text(readTimestamp(
                          report.createAt.millisecondsSinceEpoch)),
                      leading: CircleAvatar(
                        child: Text('CH'),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      trailing: RateStar(
                        rateScore: report.rate.toDouble(),
                      ),
                      onTap: () {
                        Alert(
                          title: "CHI TIẾT",
                          context: context,
                          style: AlertStyle(
                            isCloseButton: true,
                            isButtonVisible: false,
                            animationType: AnimationType.grow,
                            titleStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                          closeIcon: Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                  leading: CircleAvatar(
                                    radius: 25.0,
                                    child: Text(
                                        "${report?.request?.name != null ? report?.request?.name?.substring(0, 2) : ""}"),
                                  ),
                                  title: InkWell(
                                      child: Text(
                                        "${report?.request?.name ?? ""}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16),
                                      ),
                                      onTap: () {
                                        Navigator.pushNamed(context, '/profile',
                                            arguments: ScreenProfileArguments(
                                                report.request.userId));
                                      }),
                                  subtitle: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        report.request.status == null
                                            ? 'Chưa có ai trợ giúp'
                                            : 'Đã được trợ giúp',
                                        style: TextStyle(
                                            color: report.request.status == null
                                                ? Colors.red
                                                : Theme.of(context)
                                                    .primaryColor,
                                            fontSize: 15),
                                      ),
                                    ],
                                  )),
                              Divider(
                                color: Colors.grey,
                                indent: 0,
                                endIndent: 0,
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 10, 15, 0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        RichText(
                                            text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Lý do:",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16),
                                            ),
                                            TextSpan(
                                              text:
                                                  " ${report?.request?.reason ?? "Khác"}",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16),
                                            )
                                          ],
                                        )),
                                        SizedBox(height: 10),
                                        RichText(
                                            text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Lời nhắn:",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16),
                                            ),
                                            TextSpan(
                                              text:
                                                  " ${report?.request?.message ?? ""}",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16),
                                            )
                                          ],
                                        )),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Divider(
                                          color: Colors.grey,
                                          indent: 0,
                                          endIndent: 0,
                                        ),
                                        RichText(
                                            text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Đánh giá:",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16),
                                            ),
                                            TextSpan(
                                              text: " ${report?.rate ?? "5"} ",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16),
                                            ),
                                            WidgetSpan(
                                              child: Icon(
                                                Icons.star,
                                                size: 16,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ],
                                        )),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        RichText(
                                            text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Nhận xét:",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16),
                                            ),
                                            TextSpan(
                                              text:
                                                  " ${report?.reviewMessage ?? ""}",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16),
                                            )
                                          ],
                                        )),
                                        SizedBox(height: 10),
                                      ])),
                            ],
                          ),
                        ).show();
                      },
                    );
                  },
                ));
          },
          future: getListReport(),
        )));
  }
}
