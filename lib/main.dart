import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Пу пу пу',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'Пу пу пу'),
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
  int _currentValue = 0;
  final TextEditingController _controller = TextEditingController();

  void _processInput() {
    String input = _controller.text.trim();
    if (input.isEmpty) return;

    if (input.toLowerCase() == "люблю маму") {
      setState(() {
        _currentValue = 0;
      });
      _showMessage("🔄 Лічильник скинуто!");
    } else {
      int? value = int.tryParse(input);
      if (value != null) {
        setState(() {
          _currentValue = value;
        });
      } else {
        _showMessage("⚠️ Введіть число або секретну фразу для скидання!");
      }
    }

    _controller.clear();
  }

  void _increment() {
    setState(() {
      _currentValue++;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Кількість балів які мені мають поставити:'),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Text(
                '$_currentValue',
                key: ValueKey<int>(_currentValue),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Введіть число від 100 до скіко хоч або секретну фразу)))',
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onSubmitted: (_) => _processInput(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _processInput,
                  child: const Text('Підтвердити мою хорошу оцінку'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _increment,
                  child: const Text('+1'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}