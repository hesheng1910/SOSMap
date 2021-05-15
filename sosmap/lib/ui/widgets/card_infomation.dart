import 'package:flutter/material.dart';
import 'package:sosmap/models/request.dart';
import 'package:sosmap/models/user.dart';
import 'package:sosmap/ui/widgets/rate_star.dart';
import 'package:sosmap/util/auth.dart';
import 'package:url_launcher/url_launcher.dart';

class CardInfomation extends StatefulWidget {
  final RequestModel requestModel;
  final VoidCallback onCloseBtn;
  final VoidCallback onOpenMapBtn;
  final VoidCallback onConfirmBtn;

  const CardInfomation(
      {Key key,
      this.requestModel,
      this.onCloseBtn,
      this.onOpenMapBtn,
      this.onConfirmBtn})
      : super(key: key);
  @override
  _CardInfomationState createState() => _CardInfomationState();
}

class _CardInfomationState extends State<CardInfomation> {
  _CardInfomationState();
  UserModel _userModel;
  @override
  void initState() {
    super.initState();
    _getUserModel();
  }

  void _getUserModel() async {
    _userModel = await Auth.getUserFirestore(widget.requestModel.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: Auth.getUserFirestore(widget.requestModel.userId),
      builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
        if (!snapshot.hasData) {
          // while data is loading:
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // data loaded:
          _userModel = snapshot.data;
          return Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.all(20),
            color: Colors.green[50],
            shadowColor: Colors.blueGrey,
            elevation: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                ListTile(
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                            icon: Icon(Icons.call),
                            color: Colors.green,
                            onPressed: () => launch(
                                "tel://${widget.requestModel.tel ?? ""}")),
                        IconButton(
                            icon: Icon(Icons.directions),
                            color: Colors.green,
                            onPressed: widget.onOpenMapBtn),
                      ],
                    ),
                    leading: CircleAvatar(
                      radius: 25.0,
                      child: Text(
                          "${_userModel?.fullName != null ? _userModel.fullName.substring(0, 2) : ""}"),
                    ),
                    title: Text(
                      "${_userModel?.fullName ?? ""}",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RateStar(
                          rateScore: _userModel?.rate ?? 5,
                        ),
                        Text(
                          widget.requestModel.status == null
                              ? 'Chưa có ai trợ giúp'
                              : (widget.requestModel.status == "waiting")
                                  ? 'Đang có người đến'
                                  : 'Đã được trợ giúp',
                          style: TextStyle(
                              color: widget.requestModel.status == null
                                  ? Colors.red
                                  : Colors.green,
                              fontSize: 15),
                        ),
                      ],
                    )),
                Divider(
                  color: Colors.grey,
                  indent: 20,
                  endIndent: 20,
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                              text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Người cần giúp:",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16),
                              ),
                              TextSpan(
                                text: " ${widget.requestModel.name ?? ""}",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              )
                            ],
                          )),
                          SizedBox(height: 10),
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
                                    " ${widget.requestModel.reason ?? "Khác"}",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
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
                                text: " ${widget.requestModel.message ?? ""}",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
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
                        ])),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: widget.onCloseBtn,
                      style: TextButton.styleFrom(
                          primary: Colors.white, backgroundColor: Colors.red),
                      child: const Text('ĐÓNG'),
                    ),
                    if (widget.requestModel.status == null)
                      TextButton(
                        onPressed: widget.onConfirmBtn,
                        style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.green),
                        child: const Text('TÔI ĐANG ĐẾN'),
                      ),
                  ],
                ),
              ],
            ),
          );
          ;
        }
      },
    );
  }
}
