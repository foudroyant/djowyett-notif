import 'dart:ui';

//import OneSignal
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'package:ringtone_player/ringtone_player.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'dart:convert';

notif(String titlte, String body){
  AwesomeNotifications().createNotification(content: NotificationContent(
      id: 0,
      channelKey :"basic_channel",
      title: titlte,
      body: body
  ));
  FlutterRingtonePlayer().playNotification();
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  notif("${message.notification?.title}",'${message.notification?.body}');

  print("Handling a background message: ${message.messageId}");
  print("Handling a background message: ${message.notification?.title}");
  print("Handling a background message: ${message.notification?.body}");
}

Future<void> initPush() async {
  await FirebaseMessaging.instance.subscribeToTopic("nouvelle_navigation").then((value) => print("Nouvelle navigation"));

  FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  //final token = await messaging.getToken();

  //print('User granted permission: ${settings.authorizationStatus} : ${token}');
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message}');

    final notification = message.notification;
    if (notification != null) {
      print('Message also contained a notification: ${notification.title}');
      print('Message also contained a notification: ${notification.body}');
      notif("${notification.title}",'${notification.body}');
    }
  });
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //f65ca766-4b02-4d67-b70a-9839e5e6faca
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: "basic_channel", channelName: "Basic notifications", channelDescription: "Notification channel for basics tests",
      importance: NotificationImportance.Max, playSound: true, onlyAlertOnce: true, criticalAlerts: true
  ),
  ], debug: true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Djowyett Notif',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BottomMenuExample(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  FirebaseDatabase database = FirebaseDatabase.instance;
    final DatabaseReference  databaseReference = FirebaseDatabase.instance.ref("visites");
  late SharedPreferences _prefs;
  final List<String> processedDocumentIds = [];
  final player = AudioPlayer();
  bool _enableConsentButton = false;
  String _debugLabelString = "";

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadProcessedDocumentIds();
  }

  void _loadProcessedDocumentIds() {
    List<String>? storedIds = _prefs.getStringList('processedDocumentIds');
    if (storedIds != null) {
      setState(() {
        processedDocumentIds.addAll(storedIds);
      });
    }
  }

  void _saveProcessedDocumentIds() {
    _prefs.setStringList('processedDocumentIds', processedDocumentIds);
  }

  void _removeProcessedDocumentId(String documentId) {
    setState(() {
      processedDocumentIds.remove(documentId);
    });
    final db = FirebaseFirestore.instance;
    db.collection("visites").doc(documentId).delete().then(
          (doc) => print("Document deleted"),
      onError: (e) => print("Error updating document $e"),
    );
    // Sauvegardez les IDs traités après avoir retiré un ID
    _saveProcessedDocumentIds();
  }

  void _playNotificationSound(String documentId) async {
    setState(() {
      processedDocumentIds.add(documentId);
    });
    _saveProcessedDocumentIds();
  }

  lancerNotification(String body){
    AwesomeNotifications().createNotification(content: NotificationContent(
        id: 0,
      channelKey :"basic_channel",
      title: "Nouvelle navigation",
      body: body
    ));
  }

  initOneSignal() async{
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared.setAppId("f65ca766-4b02-4d67-b70a-9839e5e6faca");
    OneSignal.shared.promptUserForPushNotificationPermission().then((value){
      print(value);
    });
  }

  @override
  void initState() {
    super.initState();
    //initOneSignal();
    initPush();
    _initSharedPreferences();
    AwesomeNotifications().isNotificationAllowed()
    .then((isAllowed){
      if(!isAllowed){
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _visitesStream =
    FirebaseFirestore.instance.collection('visites').orderBy('time', descending: true).snapshots();

    return Scaffold(
      body: StreamBuilder(
          stream: _visitesStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if (snapshot.hasError) {
              return const Text("Il y'a eu une erreur, veuillez contacter le concepteur.");
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: const CircularProgressIndicator(),
              );
            }

            // Liste des documents actuels dans la collection
            List<DocumentSnapshot> currentDocuments = snapshot.data!.docs;

            // Détecter les changements apportés aux documents
            List<DocumentChange> documentChanges = snapshot.data!.docChanges;

            documentChanges.forEach((DocumentChange change) {
              if (change.type == DocumentChangeType.added) {
                // Un nouvel objet a été ajouté
                DocumentSnapshot newDocument = change.doc;
                String documentId = newDocument.id;

                // Vérifiez si le document a déjà été traité
                if (!processedDocumentIds.contains(documentId)) {
                  // Ajoutez l'ID à la liste des documents traités
                  //_playNotificationSound(documentId);
                  //lancerNotification("${newDocument["name"]} a été visité à ${newDocument["time"]}");
                  // Effectuez votre traitement ici pour le nouvel objet
                  print("Nouveau site visité : ${newDocument["name"]}");
                }
              }

              if(change.type == DocumentChangeType.removed){
                DocumentSnapshot deleteDocument = change.doc;
                String documentId = deleteDocument.id;
                _removeProcessedDocumentId(documentId);
                print(deleteDocument);
              }
            });


            return ListView.builder(
                itemCount: currentDocuments.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = currentDocuments[index];
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    child: Card(
                        child : ListTile(
                          title: Text("${document["name"]}"),
                          subtitle:  Text(document["time"], style: TextStyle(
                            color: Theme.of(context).colorScheme.primary
                          ),),
                          trailing: IconButton(icon: Icon(Icons.delete), color: Theme.of(context).colorScheme.error, onPressed: () async{
                            _removeProcessedDocumentId(document.id);
                          },),
                          onTap: (){

                          },
                        )
                    ),
                  );
                });
          }
      )// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class GestionSites extends StatefulWidget {
  @override
  _GestionSitesState createState() => _GestionSitesState();
}

class _GestionSitesState extends State<GestionSites> {
  TextEditingController _textFieldController = TextEditingController();
  final CollectionReference _sitesCollection = FirebaseFirestore.instance.collection('sites');
  late List<DocumentSnapshot> _sites = [];

  Future<void> _chargerDonnees() async {
    var result = await _sitesCollection.get();
    setState(() {
      _sites = result.docs;
    });
  }

  void _supprimerSite(String siteId) async {
    try {
      await _sitesCollection.doc(siteId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Site supprimé avec succès.'),
        ),
      );

      _chargerDonnees(); // Recharge les données après la suppression
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression du site : $e'),
        ),
      );
    }
  }

  void _ajouterSite(String nomDuSite) async {
    try {
      await _sitesCollection.add({
        'name': nomDuSite,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Site ajouté avec succès.'),
        ),
      );

      _chargerDonnees(); // Recharge les données après l'ajout
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout du site : $e'),
        ),
      );
    }
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter un site'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: 'Nom du site'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () {
                _ajouterSite(_textFieldController.text);
                _textFieldController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chargerDonnees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _sites != null
          ? ListView.builder(
        itemCount: _sites.length,
        itemBuilder: (context, index) {
          var site = _sites[index];
          return Card(child: ListTile(
            title: Text(site['name']),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              color: Theme.of(context).colorScheme.error,
              onPressed: () => _supprimerSite(site.id),
            ),
          ),);
        },
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        tooltip: 'Ajouter',
        child: Icon(Icons.add),
      ),
    );
  }

}


class BottomMenuExample extends StatefulWidget {
  @override
  _BottomMenuExampleState createState() => _BottomMenuExampleState();
}

class _BottomMenuExampleState extends State<BottomMenuExample> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    MyHomePage(title: "Djowyett Notif"),
    GestionSites()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Djowyett Notif"),
      ),
      body: PageView(
        children: _pages,
        onPageChanged: (index) {
          //print(index);
          setState(() {
            _currentPageIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.web),
            label: 'Sites',
          ),
        ],
      ),
    );
  }
}