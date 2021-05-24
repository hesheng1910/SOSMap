import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sosmap/models/list_report.dart';
import 'package:sosmap/models/report.dart';
import 'package:sosmap/models/state.dart';
import 'package:sosmap/models/user.dart';
import 'package:sosmap/ui/widgets/rate_star.dart';
import 'package:sosmap/util/auth.dart';
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
  bool isLoadAvt = false;
  @override
  void initState() {
    super.initState();
  }

  void _onRefresh() async {
    // monitor network fetch
    setState(() {});
    await getListReport();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    setState(() {});
    await getListReport();
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    _refreshController.loadComplete();
  }

  Future<List<ReportModel>> getListReport() async {
    if (appState.user.userId != null) {
      ListReportModel result =
          await ReportAPI.getListReportFirestore(appState.user.userId);
      return result.listReport;
    }
    return null;
  }

  Future<UserModel> getUser(String uid) async {
    UserModel userModel = await Auth.getUserFirestore(uid);
    return userModel;
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
            'Lịch sử trợ giúp',
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
                header: WaterDropMaterialHeader(),
                footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus mode) {
                    Widget body;
                    if (mode == LoadStatus.idle) {
                      body = Text("Kéo xuống để tải thêm");
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
                      return FutureBuilder<UserModel>(
                        future: getUser(report.request.helperId),
                        builder: (context, AsyncSnapshot<UserModel> snap) {
                          if (snap.hasData) {
                            bool isHelper =
                                snap.data.userId == appState.user.userId;
                            return ListTile(
                              title: RichText(
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      child: isHelper
                                          ? Icon(
                                              CupertinoIcons
                                                  .arrowshape_turn_up_right_circle_fill,
                                              size: 18,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            )
                                          : Icon(
                                              CupertinoIcons
                                                  .arrowshape_turn_up_left_circle_fill,
                                              size: 18,
                                              color: Colors.orange,
                                            ),
                                    ),
                                    TextSpan(
                                        text: snap.data.fullName,
                                        style: TextStyle(color: Colors.black)),
                                  ],
                                ),
                              ),
                              subtitle: Text(readTimestamp(
                                  report.createAt.millisecondsSinceEpoch)),
                              leading: CircleAvatar(
                                backgroundImage: snap.data.avatarUrl == null
                                    ? AssetImage('assets/images/as.png')
                                    : NetworkImage(snap.data.avatarUrl),
                                backgroundColor: Colors.transparent,
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
                                    overlayColor: Colors.black54,
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
                                            backgroundImage:
                                                snap.data.avatarUrl == null
                                                    ? AssetImage(
                                                        'assets/images/as.png')
                                                    : NetworkImage(
                                                        snap.data.avatarUrl),
                                            backgroundColor: Colors.transparent,
                                          ),
                                          title: InkWell(
                                              child: Text(
                                                "${snap?.data?.fullName ?? "Người dùng chưa đặt tên"}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16),
                                              ),
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, '/profile',
                                                    arguments:
                                                        ScreenProfileArguments(
                                                            snap.data.userId));
                                              }),
                                          subtitle: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isHelper
                                                    ? 'Đã được bạn trợ giúp'
                                                    : 'Đã trợ giúp bạn',
                                                style: TextStyle(
                                                    color: isHelper
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Colors.orange,
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
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 10, 15, 0),
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
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 16),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          " ${report?.rate ?? "5"} ",
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
                                                          fontWeight:
                                                              FontWeight.w500,
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
                          } else {
                            return SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      );
                    }));
          },
          future: getListReport(),
        )));
  }
}
