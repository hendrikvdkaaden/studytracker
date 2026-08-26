import 'package:flutter/material.dart';

/// A horizontal row of goal cards.
///
/// The dashboard used to stack every goal, so a handful of deadlines filled
/// the screen and the sections below fell off the bottom. Laying each section
/// out sideways keeps all three reachable no matter how many goals there are.
class GoalCarousel extends StatelessWidget {
  /// Width of a single card. Wide enough for a title and its subject, narrow
  /// enough that the next card peeks in and shows the row scrolls.
  static const double cardWidth = 280;

  final List<Widget> cards;

  /// Inset before the first card and after the last, matching the headings
  /// the cards sit under. Applied inside the scroll view so cards can travel
  /// all the way to the screen edge instead of stopping short of it.
  final double horizontalPadding;

  const GoalCarousel({
    super.key,
    required this.cards,
    this.horizontalPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            SizedBox(width: cardWidth, child: cards[i]),
          ],
        ],
      ),
    );
  }
}
