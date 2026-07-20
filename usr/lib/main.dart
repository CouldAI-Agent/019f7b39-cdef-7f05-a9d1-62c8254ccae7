import 'package:flutter/material.dart';

void main() {
  runApp(const YouTubeScriptApp());
}

class YouTubeScriptApp extends StatelessWidget {
  const YouTubeScriptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI YouTube Script Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ScriptGeneratorScreen(),
      },
    );
  }
}

class ScriptGeneratorScreen extends StatefulWidget {
  const ScriptGeneratorScreen({super.key});

  @override
  State<ScriptGeneratorScreen> createState() => _ScriptGeneratorScreenState();
}

class _ScriptGeneratorScreenState extends State<ScriptGeneratorScreen> {
  final _topicController = TextEditingController();
  final _toneController = TextEditingController();
  bool _isGenerating = false;
  String? _generatedScript;

  @override
  void dispose() {
    _topicController.dispose();
    _toneController.dispose();
    super.dispose();
  }

  void _generateScript() async {
    final topic = _topicController.text;
    if (topic.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedScript = null;
    });

    // Simulate API call to AI service
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isGenerating = false;
      _generatedScript = """
[INTRO]
Hey everyone, welcome back to the channel! Today we're diving deep into $topic. 
If you've ever wondered how to master this, you're in the right place.

[HOOK]
Did you know that most people completely misunderstand $topic? It's true!

[BODY]
Let's break down the three main things you need to know:
1. The Basics
2. Common Mistakes
3. Pro Tips

[OUTRO]
Thanks for watching! Don't forget to like, subscribe, and hit that notification bell. See you in the next one!
""";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI YouTube Script Generator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Create Your Next Viral Video',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _topicController,
                      decoration: const InputDecoration(
                        labelText: 'Video Topic',
                        hintText: 'e.g., How to learn Flutter in 2026',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.video_library),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _toneController,
                      decoration: const InputDecoration(
                        labelText: 'Tone (Optional)',
                        hintText: 'e.g., Funny, Professional, Educational',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.mood),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _isGenerating ? null : _generateScript,
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(_isGenerating ? 'Generating...' : 'Generate Script'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    if (_generatedScript != null) ...[
                      const SizedBox(height: 32),
                      const Text(
                        'Generated Script',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: SelectableText(
                          _generatedScript!,
                          style: const TextStyle(
                            height: 1.5,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}