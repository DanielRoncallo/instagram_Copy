import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:insta_test/provider/user_provider.dart';
import 'package:insta_test/responsive/mobileScreenLayout.dart';
import 'package:insta_test/responsive/responsive_layout_screen.dart';
import 'package:insta_test/responsive/webScreenLayout.dart';
import 'package:insta_test/tools/colors.dart';
import 'package:insta_test/ventanas/screen_login.dart';
import 'package:insta_test/ventanas/sign_up.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBtSFRLl8-57bm2siyQlb4-Cw8p4mRtRzw",
        appId: "1:344134944061:web:9af8ec476031d9fe963154",
        messagingSenderId: "344134944061",
        projectId: "instagra-clone-e52a2",
        storageBucket: "instagra-clone-e52a2.appspot.com",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram clone flutter',
        theme: ThemeData.dark()
            .copyWith(scaffoldBackgroundColor: mobileBackgroundColor),
        /* home: const ResponsiveLayout(
          mobileScreenLayout: MobileScreenLayout(),
          webScreenLayout: WebScreenLayout(),
        ), */
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              //Comprobación de si el snapshot tiene datos o no
              if (snapshot.hasData) {
                // si el snapshot tiene datos que significan que el usuario ha
                //iniciado la sesión, entonces comprobamos la anchura de la pantalla y,
                //en consecuencia, mostramos el diseño de la pantalla
                return const ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }

            // significa que la conexión con el futuro no se ha hecho todavía
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
