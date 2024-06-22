import 'package:casinoapp/pages/log_in.dart';
import 'package:casinoapp/pages/sign_up.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 600;
          double logoSize = isTablet ? 150 : 100;
          double imageWidthFactor = isTablet ? 0.4 : 0.8;
          double maxImageWidth = 400;
          double buttonWidthFactor = isTablet ? 0.3 : 0.4;
          double spacing = isTablet ? 30 : 20;
          double textSize = isTablet ? 24 : 16;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                bottom: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/image_front.png',
                  fit: BoxFit.cover,
                  width: constraints.maxWidth * imageWidthFactor > maxImageWidth
                      ? maxImageWidth
                      : constraints.maxWidth * imageWidthFactor,
                ),
              ),
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo_bernard.png',
                      height: logoSize,
                      width: logoSize,
                    ),
                    SizedBox(height: spacing),
                    Text(
                      'Welcome to,\nCasino Bernard',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(fontSize: textSize * 1.5),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing / 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Get ready for top games and big wins. Enjoy slots, table games, and live dealers, all in one place. Start playing now and experience the excitement!🎉',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontSize: textSize),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth * buttonWidthFactor,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUp()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text('Sign-Up'),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth * buttonWidthFactor,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LogIn()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          backgroundColor: Colors.white,
                        ),
                        child: const Text('Log-In'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
