import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sosmap/models/list_report.dart';
import 'package:sosmap/models/report.dart';
import 'package:sosmap/models/request.dart';
import 'package:expandable/expandable.dart';
import 'package:sosmap/models/user.dart';
import 'package:sosmap/ui/widgets/rating_card.dart';
import 'package:sosmap/util/auth.dart';
import 'package:sosmap/util/list_report.dart';
import 'package:sosmap/util/notiFCM.dart';
import 'package:sosmap/util/request.dart';
import 'package:sosmap/wemap/route.dart';
import 'package:intl/intl.dart';

import 'package:wemapgl/wemapgl.dart';

class HelpInfo extends StatefulWidget {
  final RequestModel helpRequest;
  final bool haveHelpRequest;
  final myLocation;

  const HelpInfo(
      {Key key, this.helpRequest, this.haveHelpRequest, this.myLocation})
      : super(key: key);
  @override
  _HelpInfoState createState() => _HelpInfoState();
}

class _HelpInfoState extends State<HelpInfo> {
  _HelpInfoState();
  UserModel _userHelp;
  UserModel _userNeedHelp;
  @override
  void initState() {
    _getUserHelp();
    _getUserNeedHelp();
    super.initState();
  }

  Future<void> _getUserHelp() async {
    if (widget.helpRequest.helperId != null)
      _userHelp = await Auth.getUserFirestore(widget.helpRequest.helperId);
  }

  Future<void> _getUserNeedHelp() async {
    if (widget.helpRequest.userId != null)
      _userNeedHelp = await Auth.getUserFirestore(widget.helpRequest.userId);
  }

  Future<void> _cancelHelp() async {
    widget.helpRequest.status = null;
    widget.helpRequest.helperId = null;
    RequestAPI.editRequestDB(widget.helpRequest);

    //gửi notification
    String token = _userNeedHelp.tokens;
    if (token != null) {
      String title =
          _userHelp.fullName ?? "Người dùng chưa đặt tên" + " đã huỷ giúp đỡ";
      String message = "Xin lỗi! Mình không thể đến giúp bạn được";
      NotiFCM.sendPushMessage(token, title, message, 'cancel');
    }
  }

  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat('###,###,000');
    if (widget.haveHelpRequest) {
      if (widget.helpRequest.status == "waiting") {
        _getUserHelp();
        return Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.all(10),
          shadowColor: Colors.blueGrey,
          elevation: 5,
          color: Colors.green.shade50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/gif/running.gif",
                    width: 150,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                              "ĐÃ CÓ NGƯỜI ĐỒNG Ý ĐẾN GIÚP",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(
                                    Icons.people,
                                    size: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                TextSpan(
                                    text: " ${_userHelp?.fullName}",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16)),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(
                                    Icons.phone,
                                    size: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                TextSpan(
                                    text: " ${_userHelp?.tel}",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16)),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                TextSpan(
                                    text:
                                        " ${_userHelp?.rate?.toStringAsFixed(2) ?? 0}",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16)),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(
                                    Icons.money,
                                    size: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                TextSpan(
                                    text: widget.helpRequest.price != null
                                        ? " ${formatter.format(int.parse(widget.helpRequest.price ?? "0"))} VNĐ"
                                        : " Miễn phí",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      RatingCard ratingCard = new RatingCard(
                          requestModel: widget.helpRequest,
                          reportModel: new ReportModel(
                              request: widget.helpRequest,
                              rate: 5,
                              reviewMessage: null));
                      Alert(
                          style: AlertStyle(
                              animationType: AnimationType.grow,
                              titleStyle: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                          context: context,
                          title: "XÁC NHẬN HOÀN THÀNH TRỢ GIÚP",
                          closeIcon: Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                          content: ratingCard,
                          buttons: [
                            DialogButton(
                              child: Text(
                                'XÁC NHẬN',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                ratingCard.reportModel.createAt =
                                    Timestamp.now();
                                if (widget.helpRequest.userId != null) {
                                  ListReportModel listReportModel =
                                      await ReportAPI.getListReportFirestore(
                                          widget.helpRequest.userId);
                                  if (listReportModel == null)
                                    listReportModel = new ListReportModel(
                                        userId: widget.helpRequest.userId);
                                  if (listReportModel.listReport == null)
                                    listReportModel.listReport = [
                                      ratingCard.reportModel
                                    ];
                                  else
                                    listReportModel.listReport
                                        .add(ratingCard.reportModel);
                                  await ReportAPI.addReportDB(listReportModel);
                                  await RequestAPI.deleteRequestDB(
                                      widget.helpRequest.userId);

                                  // cập nhật rate user
                                  setState(() {
                                    _userHelp.rate = (_userHelp.rate ??
                                            5.0 +
                                                ratingCard.reportModel.rate
                                                    .toDouble()) /
                                        2;
                                  });

                                  Auth.updateUser(_userHelp);
                                }
                                Navigator.pop(context);
                              },
                              color: Theme.of(context).primaryColor,
                            )
                          ]).show();
                    },
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Theme.of(context).primaryColor),
                    child: const Text('HOÀN THÀNH'),
                  ),
                ],
              ),
            ],
          ),
        );
      } else {
        _getUserNeedHelp();
        return Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.all(10),
          shadowColor: Colors.blueGrey,
          elevation: 5,
          color: Colors.green.shade50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/gif/running.gif",
                    width: 150,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                              "ĐANG CHỜ AI ĐÓ ĐẾN GIÚP",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(
                                    Icons.money,
                                    size: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                TextSpan(
                                    text: widget.helpRequest.price == null
                                        ? " Miễn phí"
                                        : " ${formatter.format(int.parse(widget.helpRequest.price ?? "0"))} VNĐ",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16)),
                              ],
                            ),
                          ),
                          RichText(
                              text: TextSpan(children: [
                            WidgetSpan(
                              child: Icon(
                                Icons.warning,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            TextSpan(
                                text:
                                    " ${widget.helpRequest?.reason ?? "Khác"}",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16)),
                          ])),
                          RichText(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(
                                    Icons.message,
                                    size: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                TextSpan(
                                    text:
                                        " ${widget.helpRequest?.message ?? ""}",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Alert(
                              title: "XÁC NHẬN HUỶ YÊU CẦU",
                              content:
                                  Text('Bạn muốn huỷ yêu cầu trợ giúp chứ ?'),
                              type: AlertType.warning,
                              closeIcon: Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                              style: AlertStyle(
                                  animationType: AnimationType.grow,
                                  titleStyle: TextStyle(
                                      color: Theme.of(context).primaryColor)),
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    'XÁC NHẬN',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    RequestAPI.deleteRequestDB(
                                        widget.helpRequest.userId);
                                    Navigator.of(context).pop();
                                  },
                                  color: Theme.of(context).primaryColor,
                                )
                              ],
                              context: context)
                          .show();
                    },
                    style: TextButton.styleFrom(
                        primary: Colors.white, backgroundColor: Colors.red),
                    child: const Text('HỦY YÊU CẦU'),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    } else
      return ExpandablePanel(
          header: Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.all(10),
            shadowColor: Colors.blueGrey,
            elevation: 5,
            color: Colors.green.shade50,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/gif/running.gif",
                      width: 150,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: SizedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                "ĐANG ĐẾN TRỢ GIÚP",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              trailing: ExpandableButton(
                                child: ExpandableIcon(),
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(
                                      Icons.people,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  TextSpan(
                                      text: " ${widget.helpRequest.name}",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(
                                      Icons.phone,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  TextSpan(
                                      text: " ${widget.helpRequest.tel}",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  TextSpan(
                                      text: " ${_userNeedHelp?.rate ?? 0}",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(
                                      Icons.money,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  TextSpan(
                                      text: widget.helpRequest.price == null
                                          ? " Miễn phí"
                                          : " ${formatter.format(int.parse(widget.helpRequest.price ?? "0"))} VNĐ",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        _cancelHelp();
                      },
                      style: TextButton.styleFrom(
                          primary: Colors.white, backgroundColor: Colors.red),
                      child: const Text('HỦY TRỢ GIÚP'),
                    ),
                    if (widget.helpRequest.status == "waiting")
                      TextButton(
                        onPressed: () {
                          WeMapPlace destination = widget.helpRequest.place;
                          WeMapPlace origin =
                              WeMapPlace(location: widget.myLocation);
                          Navigator.pushNamed(context, '/route-page',
                              arguments:
                                  ScreenRouteArguments(origin, destination));
                        },
                        style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Theme.of(context).primaryColor),
                        child: const Text('CHỈ ĐƯỜNG'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          expanded: Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.all(10),
            shadowColor: Colors.blueGrey,
            elevation: 5,
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  new Align(
                    child: new Text(
                      "THÔNG TIN CHI TIẾT",
                      style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                    alignment: FractionalOffset.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  RichText(
                      text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Địa chỉ:",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                      TextSpan(
                        text: " ${widget.helpRequest.place.placeName}",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      )
                    ],
                  )),
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
                        text: " ${widget.helpRequest.reason}",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      )
                    ],
                  )),
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
                        text: " ${widget.helpRequest.message ?? ""}",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      )
                    ],
                  )),
                ],
              ),
            ),
          ),
          collapsed: null,
          theme: ExpandableThemeData(hasIcon: false));
  }
}
