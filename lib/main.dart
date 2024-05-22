import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 183, 58, 58)),
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                const Color.fromARGB(255, 183, 58, 58)),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            minimumSize: MaterialStateProperty.all<Size>(
                const Size(double.infinity, 48.0)),
          ))),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final formKey = GlobalKey<FormState>();
  String? name;
  String? studentNumber;
  String? aioServer = dotenv.env['AIO_SERVER'];
  String? aioBrowserServer = dotenv.env['AIO_BROWSER_SERVER'];
  String? aioUsername = dotenv.env['AIO_USERNAME'];
  String? aioKey = dotenv.env['AIO_KEY'];
  String? aioFeedSubscribe = dotenv.env['AIO_FEED_SUBSCRIBE'];
  String? aioFeedUpdate = dotenv.env['AIO_FEED_UPDATE'];

  late dynamic client;

  Future<List> _checkPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    studentNumber = prefs.getString('studentNumber');
    name = prefs.getString('name');
    print(name);
    return [name, studentNumber];
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        child: FutureBuilder<List>(
          future: _checkPrefs(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data != null) {
              List? prefs = snapshot.data;
              if (prefs?[0] != null) {
                return _buildScaffoldWithUser();
              } else {
                return _buildScaffoldWithoutUser();
              }
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Widget _buildScaffoldWithUser() {
    connectToMqtt();
    final TextEditingController questionController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Welcome'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        maxLines: 8,
                        controller: questionController,
                        decoration: const InputDecoration(
                            labelText: 'Got a question?',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              // Process the form data here
                              String question = questionController.text;
                              // For now, just print the data
                              print('Question: $question');
                              Map<String, dynamic> data = {
                                "question": question,
                                "name": name,
                                "student_number": studentNumber,
                              };
                              publishMessage(data);
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> connectToMqtt() async {
    print('test1');
    if (kIsWeb) {
      client = MqttBrowserClient.withPort(aioBrowserServer!, '', 443);
    } else {
      client = MqttServerClient.withPort(aioServer!, '', 1883);
    }

    print('test2');
    client.logging(on: true);
    print('test3');
    client.keepAlivePeriod = 60;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;
    print('test4');
    final willMessage = {
      "name": name,
      "student_number": studentNumber,
      "message": "disconnected"
    };

    final connMessage = MqttConnectMessage()
        .authenticateAs(aioUsername, aioKey)
        .withClientIdentifier(studentNumber!)
        .withWillTopic(aioFeedUpdate!)
        .withWillMessage(willMessage.toString())
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected');
    } else {
      print(
          'ERROR: MQTT client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
      client.disconnect();
    }
  }

  void onConnected() {
    print('Connected');
  }

  void onDisconnected() {
    print('Disconnected');
  }

  void onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  void onSubscribeFail(String topic) {
    print('Failed to subscribe $topic');
  }

  void pong() {
    print('Ping response client callback invoked');
  }

  void publishMessage(Map<String, dynamic> message) async {
    if (client.connectionStatus!.state != MqttConnectionState.connected) {
      await connectToMqtt();
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(message.toString());

    client.publishMessage('$aioUsername/feeds/$aioFeedUpdate',
        MqttQos.exactlyOnce, builder.payload!);
  }

  Widget _buildScaffoldWithoutUser() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController studentNumberController =
        TextEditingController();
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Image.asset(
              'assets/logo.png',
              width: 150,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: studentNumberController,
                        decoration:
                            const InputDecoration(labelText: 'Student Number'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your student number';
                          }
                          // You can add more complex validation logic here
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              // Process the form data here
                              await saveData('name', nameController.text);
                              await saveData('studentNumber',
                                  studentNumberController.text);
                              setState(() {
                                name = nameController.text;
                                studentNumber = studentNumberController.text;
                              });
                              // For now, just print the data
                              print('Name: $name');
                              print('Student Number: $studentNumber');
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> saveData(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}
