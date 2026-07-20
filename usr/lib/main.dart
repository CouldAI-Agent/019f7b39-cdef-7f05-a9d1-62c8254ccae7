import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
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
      await SupabaseConfig.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      await SupabaseConfig.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check your email to confirm registration.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(onPressed: _signIn, child: const Text('Sign In')),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _signUp,
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFD700)),
                        child: const Text('Create Account'),
                      ),
                    ],
                  ),
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
  String _selectedNiche = 'Technology';
  int _selectedLength = 5;
  String _selectedTone = 'Professional';
  
  final List<String> _niches = ['Motivation', 'Prayer', 'Business', 'Health', 'Finance', 'Technology', 'Lifestyle'];
  final List<int> _lengths = [1, 3, 5, 10, 15];
  final List<String> _tones = ['Inspirational', 'Professional', 'Friendly', 'Emotional', 'Storytelling'];
  
  bool _isGenerating = false;
  Map<String, dynamic>? _generatedContent;

  Future<void> _generateScript() async {
    if (_topicController.text.trim().isEmpty) return;
    
    setState(() => _isGenerating = true);
    
    // Simulate API delay for AI generation
    await Future.delayed(const Duration(seconds: 2));
    
    final result = {
      'topic': _topicController.text,
      'title': 'The Ultimate Guide to ${_topicController.text} in ${DateTime.now().year}',
      'hook': 'Are you tired of struggling with ${_topicController.text}? Watch this to the end to find out the secret.',
      'script': 'Welcome back to the channel! Today we are discussing ${_topicController.text}. \\n\\nFirst, let us explore why this is important for your $_selectedNiche journey... [Full generated script content would appear here]',
      'call_to_action': 'If you found this helpful, hit that like button and subscribe for more $_selectedNiche content!',
      'seo_description': 'In this video, we break down ${_topicController.text}. Perfect for $_selectedTone viewers looking for $_selectedNiche advice.',
      'hashtags': '#${_topicController.text.replaceAll(' ', '')} #$_selectedNiche #$_selectedTone #YouTubeTips #Success #Growth',
      'thumbnail_text': 'Stop doing THIS with ${_topicController.text}!'
    };
    
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user != null) {
        await SupabaseConfig.client.from('scripts').insert({
          'user_id': user.id,
          'topic': result['topic'],
          'niche': _selectedNiche,
          'length_minutes': _selectedLength,
          'tone': _selectedTone,
          'content': result,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Failed to save script: $e');
    }
    
    setState(() {
      _generatedContent = result;
      _isGenerating = false;
    });
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
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar / Input area
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
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
            ),
          ),
          
          // Results area
          Expanded(
            flex: 2,
            child: Container(
              color: const Color(0xFF151515),
              child: _generatedContent == null
                  ? const Center(child: Text('Enter a topic and click Generate to see your script.', style: TextStyle(color: Colors.grey)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildResultSection('Viral Title', _generatedContent!['title']),
                          _buildResultSection('Thumbnail Text Idea', _generatedContent!['thumbnail_text']),
                          _buildResultSection('15-Second Hook', _generatedContent!['hook']),
                          _buildResultSection('Main Script', _generatedContent!['script']),
                          _buildResultSection('Call to Action', _generatedContent!['call_to_action']),
                          _buildResultSection('SEO Description', _generatedContent!['seo_description']),
                          _buildResultSection('Hashtags', _generatedContent!['hashtags']),
                        ],
                      ),
                    ),
            ),
          ),
        ],
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
  List<dynamic> _scripts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScripts();
  }

  Future<void> _loadScripts() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user != null) {
        final data = await SupabaseConfig.client
            .from('scripts')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false);
        setState(() => _scripts = data);
      }
    } catch (e) {
      debugPrint('Error loading scripts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Scripts')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scripts.isEmpty
              ? const Center(child: Text('No saved scripts found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _scripts.length,
                  itemBuilder: (context, index) {
                    final script = _scripts[index];
                    return Card(
                      color: const Color(0xFF1A1A1A),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(script['topic'] ?? 'Unknown Topic', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
                        subtitle: Text('${script['niche']} • ${script['length_minutes']} mins • ${script['tone']}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Show details view
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF1A1A1A),
                              title: Text(script['topic'] ?? 'Script'),
                              content: SingleChildScrollView(
                                child: Text((script['content'] as Map)['script'] ?? 'No content'),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
