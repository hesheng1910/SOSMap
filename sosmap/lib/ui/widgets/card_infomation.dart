import 'package:flutter/material.dart';
import 'package:sosmap/models/request.dart';
import 'package:sosmap/ui/widgets/rate_star.dart';
import 'package:url_launcher/url_launcher.dart';

class CardInfomation extends StatelessWidget {
  CardInfomation(
      {Key key,
      this.onCloseBtn,
      this.onConfirmBtn,
      this.onOpenMapBtn,
      this.requestModel})
      : super(key: key);
  final RequestModel requestModel;
  final VoidCallback onCloseBtn;
  final VoidCallback onOpenMapBtn;
  final VoidCallback onConfirmBtn;

  @override
  Widget build(BuildContext context) {
    final Widget card = Card(
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
                      onPressed: () =>
                          launch("tel://${requestModel.user.tel ?? ""}")),
                  IconButton(
                      icon: Icon(Icons.directions),
                      color: Colors.green,
                      onPressed: onOpenMapBtn),
                ],
              ),
              leading: CircleAvatar(
                radius: 25.0,
                child: Text(
                    "${requestModel.user.fullName != null ? requestModel.user.fullName.substring(0, 2) : ""}"),
              ),
              title: Text(
                "${requestModel.user.fullName ?? ""}",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RateStar(
                    rateScore: requestModel.user.rate ?? 5,
                  ),
                  Text(
                    requestModel.status == null
                        ? 'Chưa có ai trợ giúp'
                        : 'Đang có người đến',
                    style: TextStyle(
                        color: requestModel.status == null
                            ? Colors.red
                            : Colors.green,
                        fontSize: 15),
                  ),
                ],
              )),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lí do: ${requestModel.reason ?? "Khác"}",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "${requestModel.message ?? ""}",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ])),
          ButtonBar(
            alignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: onCloseBtn,
                style: TextButton.styleFrom(
                    primary: Colors.white, backgroundColor: Colors.red),
                child: const Text('ĐÓNG'),
              ),
              TextButton(
                onPressed: onConfirmBtn,
                style: TextButton.styleFrom(
                    primary: Colors.white, backgroundColor: Colors.green),
                child: const Text('TÔI ĐANG ĐẾN'),
              ),
            ],
          ),
        ],
      ),
    );
    return card;
  }
}
