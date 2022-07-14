import 'dart:typed_data';

import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const htmlData = """
<html>
<body>

<h1>Getting server updates</h1>
<div id="result"></div>

<script>
if(typeof(EventSource) !== "undefined") {
  var source = new EventSource("demo_sse.php");
  source.onmessage = function(event) {
    document.getElementById("result").innerHTML += event.data + "<br>";
  };
} else {
  document.getElementById("result").innerHTML = "Sorry, your browser does not support server-sent events...";
}
</script>


</body>
</html>

 """;

class _MyHomePageState extends State<MyHomePage> {
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screnchot Page", style: TextStyle(fontSize: 30)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Screenshot(
              controller: screenshotController,
              child: Html(
                data: htmlData,
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              child: const Text('Capture Above Widget'),
              onPressed: () {
                screenshotController
                    .capture(delay: const Duration(milliseconds: 6))
                    .then(
                  (capturedImage) async {
                    ShowCapturedWidget(context, capturedImage!);
                  },
                ).catchError(
                  (onError) {
                    print(onError);
                  },
                );
              },
            ),
            ElevatedButton(
              child: const Text('Capture An Invisible Widget'),
              onPressed: () {
                var container = Container(
                    padding: const EdgeInsets.all(30.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 5.0),
                      color: Colors.redAccent,
                    ),
                    child: Text("This is an invisible widget",
                        style: Theme.of(context).textTheme.headline6));
                screenshotController
                    .captureFromWidget(
                        InheritedTheme.captureAll(
                            context, Material(child: container)),
                        delay: const Duration(seconds: 1))
                    .then(
                  (capturedImage) {
                    ShowCapturedWidget(context, capturedImage);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> ShowCapturedWidget(
      BuildContext context, Uint8List capturedImage) {
    return showDialog(
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
            title:
                const Text("rasim tushirdi", style: TextStyle(fontSize: 32))),
        body: Center(
          child:
              capturedImage != null ? Image.memory(capturedImage) : Container(),
        ),
      ),
    );
  }
}
