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

class ListReview extends StatefulWidget {
  ListReviewState createState() => ListReviewState();
}

class ListReviewState extends State<ListReview> {
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
                                return Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        elevation: 10,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(padding: EdgeInsets.all(10)),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget> [
                                                Row(
                                                    children: <Widget> [
                                                      CircleAvatar(
                                                        backgroundImage: snap.data.avatarUrl == null
                                                            ? AssetImage('assets/images/as.png')
                                                            : NetworkImage(snap.data.avatarUrl),
                                                        backgroundColor: Colors.transparent,
                                                        radius: 10,
                                                      ),
                                                      Padding(padding: EdgeInsets.only(left: 15)),
                                                      Text(snap.data.fullName
                                                        // ,
                                                        // style: TextStyle(
                                                        //     fontWeight: FontWeight.bold,
                                                        //     fontSize: 18,
                                                        //     color: Colors.white
                                                        // ),
                                                      ),
                                                    ]
                                                ),
                                                Padding(padding: EdgeInsets.only(top : 5)),

                                                RateStarSmaller(
                                                    rateScore: report.rate.toDouble()
                                                ),
                                                Padding(padding: EdgeInsets.only(top: 10)),
                                                Text(report.reviewMessage,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.black
                                                    )
                                                ),
                                                Padding(padding: EdgeInsets.only(top : 10)),
                                                Text(readTimestamp(
                                                    report.createAt.millisecondsSinceEpoch),
                                                    style: TextStyle(
                                                        color: Colors.grey
                                                    )),

                                              ],
                                            ),
                                          ],
                                        )

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
