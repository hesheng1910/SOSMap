import 'package:flutter/material.dart';
import 'package:rating_bar/rating_bar.dart';

class RateStar extends StatelessWidget {
  RateStar({Key key, this.rateScore}) : super(key: key);
  final double rateScore;
  @override
  Widget build(BuildContext context) {
    final Widget fillStar = Icon(Icons.star, color: Colors.orange);
    final Widget halfStar = Icon(Icons.star_half, color: Colors.orange);
    final Widget zeroStar = Icon(Icons.star_outline, color: Colors.orange);
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RatingBar.readOnly(
            initialRating: rateScore != null ? rateScore : 5,
            isHalfAllowed: true,
            halfFilledIcon: Icons.star_half,
            filledIcon: Icons.star,
            emptyIcon: Icons.star_border,
            filledColor: Colors.orange,
            emptyColor: Colors.orange,
            size: 24,
          ),
        ]);
  }
}
