import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_logo.dart';
import '../widgets/custom_loader.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Subtle AI Network Background
          Obx(() => AnimatedBackground(isReady: controller.isBackgroundReady.value)),

          // 2. Main Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Animated Logo with subtle glow
                  Obx(() => AnimatedLogo(isReady: controller.isLogoReady.value)),
                  
                  const SizedBox(height: 32),

                  // Title and Tagline
                  Obx(() => AnimatedOpacity(
                    opacity: controller.isTextReady.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOut,
                    child: Column(
                      children: [
                        Text(
                          'WatiBot',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.0,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intelligent automation starts here.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  )),

                  const Spacer(flex: 2),

                  // Custom minimal loader
                  Obx(() => CustomLoader(isReady: controller.isLoaderReady.value)),
                  
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
