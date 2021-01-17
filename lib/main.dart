import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'package:beyya/Models/InvitationPendingResponse.dart';
import 'package:beyya/Models/ListInUse.dart';
import 'package:beyya/Models/SignedInUser.dart';
import 'package:beyya/Models/UserDocument.dart';

import 'package:beyya/Screens/Alert.dart';
import 'package:beyya/Screens/Settings.dart';
import 'package:beyya/Screens/ChangePassword.dart';
import 'package:beyya/Screens/DeleteAccount.dart';
import 'package:beyya/Screens/ErrorScreen.dart';
import 'package:beyya/Screens/ForgotPassword.dart';
import 'package:beyya/Screens/Share.dart';
import 'package:beyya/Screens/Loading.dart';
import 'package:beyya/Screens/Startup.dart';
import 'package:beyya/Screens/ShowCategories.dart';
import 'package:beyya/Screens/ShowStores.dart';
import 'package:beyya/Screens/ShowTabs.dart';

import 'package:beyya/Services/AuthService.dart';
import 'package:beyya/Services/DatabaseServices.dart';
import 'package:beyya/Services/KeyboardHeightProvider.dart';

import 'package:beyya/CustomWidgets/StoreFilterDropdown.dart';


//Toggle this to cause an async error to be thrown during initialization
// and to test that runZonedGuarded() catches the error
final _kshouldTestAsyncErrorOnInit = false;

//Toggle this for testing Crashlytics locally
final _kTestingCrashlytics = true;

main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  runZonedGuarded(() {
    runApp(InitializeFirebase());
  }, (error, stackTrace) {
    print('runZonedGuarded :Caught error in my root zone');
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class InitializeFirebase extends StatefulWidget {
  @override
  _InitializeFirebaseState createState() => _InitializeFirebaseState();
}

class _InitializeFirebaseState extends State<InitializeFirebase> {
  Future<void> _initializeFlutterFireFuture;

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }

  //Define an async function to initialize FlutterFire
  Future<void> _initializeFlutterFire() async {
    //Wait for Firebase to initialize
    await Firebase.initializeApp();
    if (_kTestingCrashlytics) {
      //Force enable crashlytics if we are testing it
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      //Else only enable it in non-dbug builds.
      //Extend this to allow users to opt in
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }
    //Pass all uncaught error to Crashlytics
    Function originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      originalOnError(errorDetails);
    };

    if (_kshouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeFlutterFireFuture = _initializeFlutterFire();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFlutterFireFuture,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasError) {
              return ErrorScreen(
                errorMessage: snapshot.error.toString(),
              );
            } else {
              return Beyya();
            }
            break;
          default:
            return Loading();
        }
      },
    );
  }
}

//Root widget; rebuilds when the auth state changes (signing in, signing out).
class Beyya extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: AuthService().user,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.done:
            case ConnectionState.waiting:
              return Loading();
              break;
            case ConnectionState.active:
              if (snapshot.data == null) {
                return Startup(); //show register screen if the user is not signed in
              }
              else if (snapshot.hasError){
                return ErrorScreen(errorMessage: snapshot.error.toString(),);
              }
              else {
                return Provider<SignedInUser>(
                    create: (_) => snapshot.data, child: Wrapper());
              }
              break;
            default:
              return Loading();
          }
        });
  }
}

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      StreamProvider<ListInUse>.value(
          value: DatabaseService(
                  dbOwner: Provider.of<SignedInUser>(context).userEmail,
                  dbDocId: Provider.of<SignedInUser>(context).uid)
              .idOfListInUse,
          initialData: const LoadingListInUse(),
          catchError: (_, err) => ErrorFetchingListInUSe(err: err.toString())),
      StreamProvider<InvitationPendingResponse>.value(
        value: DatabaseService(
                dbOwner: Provider.of<SignedInUser>(context).userEmail,
                dbDocId: Provider.of<SignedInUser>(context).uid)
            .invitationPendingResponse,
        initialData: InvitationPendingResponse(),
        catchError: (_, err) => InvitationPendingResponse(),
      )
    ], child: Root());
  }
}

//Root widget provides the UserDocument(UserData), and redirects to
// appropriate screen
class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ListInUse>(
      builder: (_, data, __) {
        if (data is LoadingListInUse) {
          return Loading();
        } else if (data is ErrorFetchingListInUSe) {
          String err = data.err.toString();
          FirebaseCrashlytics.instance
              .log('Error streaming list in use: $err');
          FirebaseCrashlytics.instance.recordError(err, null,
              reason: 'Error streaming list in use');
          return ErrorScreen(
            errorMessage: data.err.toString(),
          );
        } else if (data is ListInUseId) {
          return MultiProvider(
            providers: [
              StreamProvider<UserDocument>.value(
                value: DatabaseService(
                        dbOwner: data.ownerOfListInUse,
                        dbDocId: data.docIdOfListInUse)
                    .userDocument,
                initialData: const LoadingUserDocument(),
                catchError: (_, err) =>
                    ErrorFetchingUserDocument(err: err.toString()),
              ),
              ChangeNotifierProvider(
                  create: (context) => StoreFilterProvider()),
              ChangeNotifierProvider(
                  create: (context) => KeyboardHeightProvider())
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  primaryColor: Colors.red[500],
                  accentColor: Colors.red[500],
                  buttonBarTheme: ButtonBarThemeData(
                    alignment: MainAxisAlignment.center,
                  )),
              initialRoute: '/',
              routes: {
                '/': (context) =>
                    DefaultTabController(child: ShowTabs(), length: 2),
                '/Alert': (context) => Alert(),
                '/Share': (context) => Share(),
                '/ShowCategories': (context) => ShowCategories(),
                '/ShowStores': (context) => ShowStores(),
                '/Settings': (context) => Settings(),
                '/ChangePassword': (context) => ChangePassword(),
                '/ForgotPassword': (context) => ForgotPassword(),
                '/DeleteAccount': (context) => DeleteAccount(),
              },
            ),
          );
        }
        throw FallThroughError();
      },
    );
  }
}
