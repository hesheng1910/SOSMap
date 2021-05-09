import 'package:flutter/material.dart';

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
      children: List.generate(5, (index) {
        if (index < rateScore.toInt())
          return fillStar;
        else if (index > rateScore.toInt()) return zeroStar;
        return halfStar;
      }),
    );
  }
}
