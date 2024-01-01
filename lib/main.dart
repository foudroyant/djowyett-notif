import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseOptions(
    apiKey: "AIzaSyBA8lgGtRSa88KEc1X_0BhHm0Xfeh4eOfg", 
    appId: "1:478289729883:web:80bbd6bde0d61f00b2627e", 
    messagingSenderId: "478289729883", 
    projectId: "djowyett"
    ));
    await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notif-Djowyett',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Djowyett-Notif'),
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
    String userInput = "";
    final db = FirebaseFirestore.instance;
    final List<Map> visites = [];
    final List sites = [];

     getData(String collection) {
      return db.collection(collection).get().then(
        (querySnapshot) {
          List<Map> data = [];
          //print("Successfully completed");
          for (var docSnapshot in querySnapshot.docs) {
            print('${docSnapshot.id} => ${docSnapshot.data()}');
            data.add({
              "id" : docSnapshot.id,
              "time" : docSnapshot.data()["time"],
              "name" : docSnapshot.data()["name"],
            });
            setState(() {
              visites.add({
              "id" : docSnapshot.id,
              "time" : docSnapshot.data()["time"].toString(),
              "name" : docSnapshot.data()["name"],
            });
            });
          }
          print(data);
        },
        onError: (e) => print("Error completing: $e"),
      );
    }

    getSites() {
      return db.collection("sites").get().then(
        (querySnapshot) {
          List<Map<String, dynamic>> data = [];
          //print("Successfully completed");
          for (var docSnapshot in querySnapshot.docs) {
            print('${docSnapshot.id} => ${docSnapshot.data()}');
            data.add({
              "id" : docSnapshot.id,
              "name" : docSnapshot.data()["name"]
            });
            setState(() {
            sites.add(data);
          });
          }
          print(data);
          
        },
        onError: (e) => print("Error completing: $e"),
      );
    }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("----------STRAT----------");
    getData("visites");
    getSites();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2, child : Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        bottom: TabBar(
              tabs: [
                Tab(text: 'Visites'),
                Tab(text: 'Sites'),
              ],
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _displayModal(context);
        },
        child: Icon(Icons.add),
      ),
      body: TabBarView(
            children: [
              // Contenu de la première vue
              ListView.builder(itemCount: visites.length, itemBuilder: (context, index) {
                final visite = visites[index];
                print(visite);
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Card(child: ListTile(
                    title: Text(visites[index]["time"]!),
                    subtitle: Text(visites[index]["name"]!),
                  ),),
                );
              }),
              // Contenu de la deuxième vue
              ListView.builder(itemCount: sites.length, itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Card(child: ListTile(
                    title: Text(sites[index]["name"].toString()),
                  ),),
                );
              }),
            ],
          ),// This trailing comma makes auto-formatting nicer for build methods.
    ));
  }

  _displayModal(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Ajouter une chaîne de caractères",
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 10.0),
              TextField(
                decoration: InputDecoration(labelText: "Entrez votre texte"),
                onChanged: (value) {
                  setState(() {
                    userInput = value;
                  });
                },
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  // Traitez la saisie de l'utilisateur ici
                  print("Chaîne de caractères ajoutée : $userInput");
                  Navigator.pop(context);
                },
                child: Text("Valider"),
              ),
            ],
          ),
        );
      },
    );
  }

}

