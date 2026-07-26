import 'package:flutter/material.dart';
import '../../widgets/common/paywall_bottom_sheet.dart';

/// Thin wrapper that immediately opens the paywall as a bottom sheet
/// and pops itself when done. Kept for any future deep-link / push usage.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final purchased = await showPaywallBottomSheet(context);
      if (mounted) Navigator.of(context).pop(purchased);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.transparent);
  }
}
