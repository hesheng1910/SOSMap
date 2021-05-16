import 'package:flutter/material.dart';
import 'package:sosmap/models/request.dart';
import 'package:expandable/expandable.dart';
import 'package:sosmap/ui/widgets/rate_star.dart';

class HelpInfo extends StatefulWidget {
  final RequestModel helpRequest;

  const HelpInfo({Key key, this.helpRequest}) : super(key: key);
  @override
  _HelpInfoState createState() => _HelpInfoState();
}

class _HelpInfoState extends State<HelpInfo> {
  _HelpInfoState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                                    color: Colors.green,
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
                                    color: Colors.green,
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
                                    color: Colors.green,
                                  ),
                                ),
                                TextSpan(
                                    text: " 4.5",
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
                                    color: Colors.green,
                                  ),
                                ),
                                TextSpan(
                                    text: " 100.000 VNĐ",
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
                    onPressed: () => {},
                    style: TextButton.styleFrom(
                        primary: Colors.white, backgroundColor: Colors.red),
                    child: const Text('HỦY TRỢ GIÚP'),
                  ),
                  if (widget.helpRequest.status == "waiting")
                    TextButton(
                      onPressed: () => {},
                      style: TextButton.styleFrom(
                          primary: Colors.white, backgroundColor: Colors.green),
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
                      text: " 63, Trần Quốc Vượng, Cầu Giấy, Hà Nội, Việt Nam",
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
                      text: " ${widget.helpRequest.message}",
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
