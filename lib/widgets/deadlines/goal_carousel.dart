import 'package:flutter/material.dart';

/// A horizontal row of goal cards.
///
/// The dashboard used to stack every goal, so a handful of deadlines filled
/// the screen and the sections below fell off the bottom. Laying each section
/// out sideways keeps all three reachable no matter how many goals there are.
class GoalCarousel extends StatelessWidget {
  /// Width of a single card.
  ///
  /// Capped so the next card still shows on the narrowest iPhone: at 310 an
  /// SE leaves 29pt of it visible, which reads as another card. Much past
  /// this and that sliver starts to look like a cut-off edge instead.
  static const double cardWidth = 310;

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
    // A lone card has nothing to scroll to, so a fixed width would just leave
    // dead space beside it. It takes the full width instead, the way the
    // section looked before these rows existed.
    if (cards.length == 1) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: cards.first,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      // IntrinsicHeight rather than CrossAxisAlignment.stretch: inside a
      // vertical list the row has unbounded height, so stretching collapses
      // it to nothing. This measures the tallest card and matches the rest
      // to it.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              SizedBox(width: cardWidth, child: cards[i]),
            ],
          ],
        ),
      ),
    );
  }
}
