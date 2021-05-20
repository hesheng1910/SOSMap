import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sosmap/models/report.dart';
import 'package:sosmap/models/request.dart';
import 'package:sosmap/models/user.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sosmap/util/auth.dart';

class RatingCard extends StatefulWidget {
  RatingCard({
    Key key,
    this.requestModel,
    this.reportModel,
  }) : super(key: key);
  final RequestModel requestModel;

  ReportModel reportModel;
  @override
  _RatingCardState createState() => _RatingCardState();
}

class _RatingCardState extends State<RatingCard> {
  _RatingCardState();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RatingBar.builder(
            initialRating: 5,
            itemCount: 5,
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return Icon(
                    Icons.sentiment_very_dissatisfied,
                    color: Colors.red,
                  );
                case 1:
                  return Icon(
                    Icons.sentiment_dissatisfied,
                    color: Colors.redAccent,
                  );
                case 2:
                  return Icon(
                    Icons.sentiment_neutral,
                    color: Colors.amber,
                  );
                case 3:
                  return Icon(
                    Icons.sentiment_satisfied,
                    color: Colors.lightGreen,
                  );
                case 4:
                  return Icon(
                    Icons.sentiment_very_satisfied,
                    color: Colors.green,
                  );
              }
            },
            onRatingUpdate: (rating) {
              widget.reportModel.rate = rating.toInt();
            }),
        SizedBox(
          height: 10,
        ),
        TextField(
          decoration: new InputDecoration(
            border: new OutlineInputBorder(
                borderSide: new BorderSide(color: Colors.teal)),
            helperText:
                'Đánh giá của bạn sẽ được hiện trong hồ sơ của người giúp',
            helperMaxLines: 2,
            labelText: 'Viết đánh giá',
            prefixIcon: const Icon(
              Icons.rate_review,
              color: Colors.green,
            ),
          ),
          minLines: 1,
          maxLines: 5,
          onChanged: (value) {
            widget.reportModel.reviewMessage = value;
          },
        ),
      ],
    );
  }
}
