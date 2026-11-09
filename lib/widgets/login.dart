import 'package:flutter/material.dart';
import 'package:misbah_path/core/utils/constants/extensions/extensions.dart';
// import 'package:muslim/extensions/extensions.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * .6,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          )),
      child: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: context.customClose(),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  // customLottie(LottieConstants.assetsLottieLogin, width: 20.0),
                  SizedBox(
                      width: 20,
                      child: Center(
                          child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child:
                            // context
                            //         .watch<LoginCubit>()
                            //         .state
                            //         .status
                            //         .isInProgress
                            //     ? const SizedBox(
                            //         height: 25,
                            //         width: 25,
                            //         child: CircularProgressIndicator(),
                            //       )
                            //     :
                            ElevatedButton.icon(
                                key: const Key(
                                    'loginForm_googleLogin_raisedButton'),
                                label: const Text(
                                  'SIGN IN / SIGN UP WITH GOOGLE',
                                  style: TextStyle(color: Colors.red),
                                ),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  foregroundColor:
                                      Theme.of(context).colorScheme.tertiary,
                                  backgroundColor: Colors.white,
                                ),
                                icon: Image.asset(
                                  'assets/images/search.png',
                                  height: 24,
                                  width: 24,
                                ),
                                onPressed: () {}),
                      )))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 150.0),
              child: ListView(
                children: const [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
