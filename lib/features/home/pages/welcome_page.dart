
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  final Widget child;

  const WelcomePage({
    super.key,
    required this.child,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _entered = false;

  @override
  Widget build(BuildContext context) {
    if (_entered) {
      return widget.child;
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF080D1A),
              Color(0xFF142747),
              Color(0xFF101827),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 520,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF243C60),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFF719CDE),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3985FF)
                                .withValues(alpha: 0.20),
                            blurRadius: 35,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.forum_rounded,
                        color: Color(0xFF9BC5FF),
                        size: 52,
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'أهلاً وسهلاً بك',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'في مشروع أحمد هادي',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Color(0xFF91BEFF),
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Container(
                      width: 65,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF619EFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 26),

                    const Text(
                      'مساحتك للتواصل ومشاركة الأفكار '
                      'والمنشورات والصور مع الآخرين.',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Color(0xFFCAD4E5),
                        fontSize: 17,
                        height: 1.9,
                      ),
                    ),

                    const SizedBox(height: 38),

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _entered = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF528FFF),
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: const Color(0xFF528FFF)
                              .withValues(alpha: 0.30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'الدخول إلى المشروع',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(
                              Icons.arrow_back_rounded,
                              size: 23,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    const Text(
                      'صُنع بشغف بواسطة أحمد هادي',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Color(0xFF8494AD),
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'AHMED HADI  •  SOCIAL PROJECT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
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
