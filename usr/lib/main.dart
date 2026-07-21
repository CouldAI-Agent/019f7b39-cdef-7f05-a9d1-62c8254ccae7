import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'integrations/supabase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI YouTube Script Generator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFFD700), // Gold
        scaffoldBackgroundColor: const Color(0xFF121212), // Dark
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Color(0xFFFFD700),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFFFFFFFF),
          surface: Color(0xFF1A1A1A),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: SupabaseConfig.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final session = snapshot.data?.session;
        if (session != null) {
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
        throw Exception('Please enter an email and password.');
      }
      await SupabaseConfig.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
        throw Exception('Please enter an email and password.');
      }
      await SupabaseConfig.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        emailRedirectTo: 'https://motiscript.couldai.app',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check your email to confirm registration.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Script Generator')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_filled, size: 80, color: Color(0xFFFFD700)),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _signIn,
                      child: const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _signUp,
                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFFFD700)),
                      child: const Text('Create Account'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _topicController = TextEditingController();
  String _selectedNiche = 'Motivation';
  int _selectedLength = 5;
  String _selectedTone = 'Inspirational';
  bool _isGenerating = false;
  Map<String, dynamic>? _generatedContent;

  final _niches = ['Motivation', 'Prayer', 'Business', 'Health', 'Finance', 'Technology', 'Lifestyle'];
  final _lengths = [1, 3, 5, 10, 15];
  final _tones = ['Inspirational', 'Professional', 'Friendly', 'Emotional', 'Storytelling'];

  Future<void> _generateScript() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a topic.')));
      return;
    }

    setState(() => _isGenerating = true);
    
    try {
      final response = await SupabaseConfig.client.functions.invoke(
        'generate_script',
        body: {
          'topic': topic,
          'niche': _selectedNiche,
          'length_mins': _selectedLength,
          'tone': _selectedTone,
        },
      );

      if (response.status != 200) {
        final errorMsg = response.data != null && response.data is Map && response.data['error'] != null 
          ? response.data['error'] 
          : 'Failed to generate script (Status: ${response.status})';
        throw Exception(errorMsg);
      }

      Map<String, dynamic> result;
      if (response.data is Map) {
         result = Map<String, dynamic>.from(response.data);
      } else if (response.data is String) {
         result = jsonDecode(response.data);
      } else {
         throw Exception('Unexpected response format.');
      }

      final user = SupabaseConfig.client.auth.currentUser;
      if (user != null) {
        await SupabaseConfig.client.from('scripts').insert({
          'user_id': user.id,
          'topic': topic,
          'niche': _selectedNiche,
          'length_mins': _selectedLength,
          'tone': _selectedTone,
          'content': result,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      if (mounted) {
        setState(() {
          _generatedContent = result;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => SupabaseConfig.client.auth.signOut(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          
          final inputArea = SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create New Script', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
                const SizedBox(height: 24),
                TextField(
                  controller: _topicController,
                  decoration: const InputDecoration(
                    labelText: 'Video Topic',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., How to start an online business',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedNiche,
                  decoration: const InputDecoration(labelText: 'Niche', border: OutlineInputBorder()),
                  items: _niches.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                  onChanged: (v) => setState(() => _selectedNiche = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedLength,
                  decoration: const InputDecoration(labelText: 'Length (Minutes)', border: OutlineInputBorder()),
                  items: _lengths.map((l) => DropdownMenuItem(value: l, child: Text('$l mins'))).toList(),
                  onChanged: (v) => setState(() => _selectedLength = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedTone,
                  decoration: const InputDecoration(labelText: 'Tone', border: OutlineInputBorder()),
                  items: _tones.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _selectedTone = v!),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateScript,
                    icon: _isGenerating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(Icons.auto_awesome),
                    label: Text(_isGenerating ? 'Generating...' : 'Generate Script'),
                  ),
                ),
              ],
            ),
          );

          final resultsArea = Container(
            color: const Color(0xFF151515),
            child: _generatedContent == null
                ? const Center(child: Text('Enter a topic and click Generate to see your script.', style: TextStyle(color: Colors.grey)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildResultSection('Viral Title', _generatedContent!['title'] ?? ''),
                        _buildResultSection('Thumbnail Text Idea', _generatedContent!['thumbnail_text'] ?? ''),
                        _buildResultSection('15-Second Hook', _generatedContent!['hook'] ?? ''),
                        _buildResultSection('Main Script', _generatedContent!['script'] ?? ''),
                        _buildResultSection('Call to Action', _generatedContent!['call_to_action'] ?? ''),
                        _buildResultSection('SEO Description', _generatedContent!['seo_description'] ?? ''),
                        _buildResultSection('Hashtags', _generatedContent!['hashtags'] ?? ''),
                      ],
                    ),
                  ),
          );

          if (isMobile) {
            return Column(
              children: [
                Expanded(flex: 1, child: inputArea),
                const Divider(height: 1, color: Color(0xFF333333)),
                Expanded(flex: 1, child: resultsArea),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: inputArea),
              Expanded(flex: 2, child: resultsArea),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResultSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: SelectableText(content, style: const TextStyle(fontSize: 16, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user != null) {
        final data = await SupabaseConfig.client
            .from('scripts')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false);
        if (mounted) {
          setState(() {
            _history = data;
          });
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading history: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Script History')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(child: Text('No scripts generated yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      color: const Color(0xFF1A1A1A),
                      child: ListTile(
                        title: Text(item['topic'] ?? 'Unknown Topic', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
                        subtitle: Text('${item['niche']} • ${item['length_mins']} mins • ${item['tone']}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Show detail if needed
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
