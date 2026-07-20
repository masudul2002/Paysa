import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/design_tokens.dart';

/// Professional branded splash screen with a short animation.
final class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: DesignTokens.motionMedium, // ~500ms
    );

    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Start animation on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      // Navigate shortly after animation finishes. Do not block startup.
      Future.delayed(DesignTokens.motionMedium, () {
        if (mounted) {
          GoRouter.of(context).go('/home');
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Semantics(
            label: 'Paysa splash screen',
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo placeholder
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withAlpha(
                              (0.08 * 255).round(),
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 52,
                        color: colorScheme.onPrimaryContainer,
                        semanticLabel: 'Paysa logo',
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingLg),
                    Text(
                      'Paysa',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: DesignTokens.spacingXs),
                    Text(
                      'Offline First Personal Finance',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
