import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ringtone_player/ringtone_player.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'dart:convert';

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: "basic_channel", channelName: "Basic notifications", channelDescription: "Notification channel for basics tests",
      importance: NotificationImportance.Max, playSound: true, onlyAlertOnce: true, criticalAlerts: true
  ),
  ], debug: true);
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
      home: const MyHomePage(title: 'Djowyett Notif'),
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

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
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
                  _playNotificationSound(documentId);
                  lancerNotification("${newDocument["name"]} a été visité à ${newDocument["time"]}");
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
