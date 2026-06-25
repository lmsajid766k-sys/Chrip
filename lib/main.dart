import 'package:flutter/material.dart';

void main() {
  runApp(const ChripApp());
}

// ডাটা সেভ করার জন্য সিম্পল লিস্ট - পরে Firebase দিবা
List<Map<String, dynamic>> users = [];
List<Map<String, dynamic>> messages = [];
Map<String, dynamic>? currentUser;

class ChripApp extends StatelessWidget {
  const ChripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chrip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFECE5DD),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF075E54),
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

// লগিন / রেজিস্টার স্ক্রিন
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF075E54),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // তোমার লোগো এখানে
              const Icon(Icons.chat_bubble_outline, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text('Chrip', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: isLogin? LoginForm() : RegisterForm(),
              ),
              TextButton(
                onPressed: () => setState(() => isLogin =!isLogin),
                child: Text(
                  isLogin? 'একাউন্ট নাই? রেজিস্টার করো' : 'একাউন্ট আছে? লগিন করো',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// লগিন ফর্ম
class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  void _login() {
    var user = users.firstWhere(
      (u) => u['username'] == _userController.text && u['password'] == _passController.text,
      orElse: () => {},
    );
    if (user.isNotEmpty) {
      currentUser = user;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username বা Password ভুল')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('লগিন', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(controller: _userController, decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _login, child: const Text('লগিন করো')),
      ],
    );
  }
}

// রেজিস্টার ফর্ম
class RegisterForm extends StatefulWidget {
  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _nameController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  String gender = 'Male';

  void _register() {
    // Username ইউনিক চেক
    bool exists = users.any((u) => u['username'] == _userController.text);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('এই Username আগে নেয়া আছে')));
      return;
    }
    users.add({
      'fullName': _nameController.text,
      'username': _userController.text,
      'password': _passController.text,
      'gender': gender,
      'photo': '',
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('রেজিস্টার সাকসেস! এখন লগিন করো')));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('রেজিস্টার', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: _userController, decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: gender,
          items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (v) => setState(() => gender = v!),
          decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _register, child: const Text('রেজিস্টার করো')),
      ],
    );
  }
}

// হোম স্ক্রিন - সার্চ + চ্যাট লিস্ট
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  Map<String, dynamic>? selectedUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentUser!['fullName']),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              currentUser = null;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Username দিয়ে সার্চ করো...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView(
              children: users
                 .where((u) => u['username'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) && u['username']!= currentUser!['username'])
                 .map((u) => ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(u['fullName']),
                        subtitle: Text('@${u['username']}'),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(receiver: u))),
                      ))
                 .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// চ্যাট স্ক্রিন
class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> receiver;
  const ChatScreen({super.key, required this.receiver});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgController = TextEditingController();

  void _sendMsg() {
    if (_msgController.text.trim().isEmpty) return;
    setState(() {
      messages.add({
        'from': currentUser!['username'],
        'to': widget.receiver['username'],
        'msg': _msgController.text,
      });
      _msgController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    var chatMsgs = messages.where((m) =>
        (m['from'] == currentUser!['username'] && m['to'] == widget.receiver['username']) ||
        (m['from'] == widget.receiver['username'] && m['to'] == currentUser!['username'])).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.receiver['fullName']), subtitle: Text('@${widget.receiver['username']}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: chatMsgs.length,
              itemBuilder: (context, i) {
                bool isMe = chatMsgs[i]['from'] == currentUser!['username'];
                return Align(
                  alignment: isMe? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe? const Color(0xFFDCF8C6) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(chatMsgs[i]['msg']),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(child: TextField(controller: _msgController, decoration: const InputDecoration(hintText: 'মেসেজ লিখো...', border: InputBorder.none))),
                IconButton(icon: const Icon(Icons.send, color: Color(0xFF075E54)), onPressed: _sendMsg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// প্রোফাইল স্ক্রিন
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('প্রোফাইল')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 60, child: Icon(Icons.person, size: 60)),
            const SizedBox(height: 20),
            Text(currentUser!['fullName'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('@${currentUser!['username']}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            Text('Gender: ${currentUser!['gender']}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('ছবি আপলোড করো'),
              onPressed: () {
                // Firebase Storage লাগবে ছবি আপলোডের জন্য। আপাতত বাটন দিলাম
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Firebase Storage সেটাপ করলে ছবি আপলোড হবে')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
