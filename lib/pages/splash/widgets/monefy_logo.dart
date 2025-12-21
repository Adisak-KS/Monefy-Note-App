import 'package:flutter/material.dart';
import 'package:monefy_note_app/core/theme/app_colors.dart';

class MonefyLogo extends StatelessWidget {
  final double size;

  const MonefyLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle with gradient
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.logoGradientStart,
                  AppColors.logoGradientEnd,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          // Wallet icon
          Icon(
            Icons.account_balance_wallet,
            size: size * 0.5,
            color: Colors.white,
          ),
          // Coin badge
          Positioned(
            right: size * 0.1,
            bottom: size * 0.1,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.coinGold,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '฿',
                  style: TextStyle(
                    fontSize: size * 0.18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.logoGradientEnd,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
