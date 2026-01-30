import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const TelemedApp());
}

// --- LOGIQUE BASE DE DONNÉES SQLITE ---
class DbHelper {
  static Database? _db;
  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      p.join(await getDatabasesPath(), 'telemed.db'),
      version: 1,
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY, email TEXT, password TEXT, role TEXT, name TEXT)",
        );
        db.execute(
          "CREATE TABLE appointments(id INTEGER PRIMARY KEY, patientName TEXT, doctorName TEXT, date TEXT, isDone INTEGER)",
        );
      },
    );
    return _db!;
  }
}

class TelemedApp extends StatelessWidget {
  const TelemedApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

// --- PAGES DE CONNEXION & INSCRIPTION (Identiques au précédent) ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  void login() async {
    final db = await DbHelper.db;
    List<Map> res = await db.query(
      "users",
      where: "email = ? AND password = ?",
      whereArgs: [emailCtrl.text, passCtrl.text],
    );
    if (res.isNotEmpty) {
      String role = res[0]['role'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              role == "Patient" ? const PatientHome() : const DoctorHome(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email ou mot de passe incorrect")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/fond.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.6)),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_hospital, size: 80, color: Colors.white),
                const Text(
                  "DOCTIME",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                _buildInput("Email", Icons.email, ctrl: emailCtrl),
                const SizedBox(height: 15),
                _buildInput(
                  "Mot de passe",
                  Icons.lock,
                  obscure: true,
                  ctrl: passCtrl,
                ),
                const SizedBox(height: 30),
                _buildBtn("SE CONNECTER", Colors.blue, login),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  ),
                  child: const Text(
                    "Créer un compte",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailCtrl = TextEditingController(),
      passCtrl = TextEditingController(),
      nameCtrl = TextEditingController();
  String role = "Patient";
  void register() async {
    final db = await DbHelper.db;
    await db.insert("users", {
      "email": emailCtrl.text,
      "password": passCtrl.text,
      "name": nameCtrl.text,
      "role": role,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInput(
              "Nom Complet",
              Icons.person,
              dark: true,
              ctrl: nameCtrl,
            ),
            const SizedBox(height: 10),
            _buildInput("Email", Icons.email, dark: true, ctrl: emailCtrl),
            const SizedBox(height: 10),
            _buildInput(
              "Mot de passe",
              Icons.lock,
              obscure: true,
              dark: true,
              ctrl: passCtrl,
            ),
            const SizedBox(height: 20),
            const Text("Je suis un :"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio(
                  value: "Patient",
                  groupValue: role,
                  onChanged: (v) => setState(() => role = v!),
                ),
                const Text("Patient"),
                Radio(
                  value: "Médecin",
                  groupValue: role,
                  onChanged: (v) => setState(() => role = v!),
                ),
                const Text("Médecin"),
              ],
            ),
            const Spacer(),
            _buildBtn("S'INSCRIRE", Colors.blue, register),
          ],
        ),
      ),
    );
  }
}

// --- ESPACE PATIENT ---
class PatientHome extends StatelessWidget {
  const PatientHome({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Espace Patient"),
        backgroundColor: Colors.blue[100],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children: [
          _buildMenuCard(
            context,
            "ChatDoc",
            Icons.chat,
            Colors.blue,
            const SelectDoctorChatPage(),
          ),
          _buildMenuCard(
            context,
            "Rendez-vous",
            Icons.calendar_today,
            Colors.green,
            const RdvPatientPage(),
          ),
          _buildMenuCard(
            context,
            "Dossier",
            Icons.folder,
            Colors.orange,
            const DossierPage(),
          ),
          _buildMenuCard(
            context,
            "Recherche",
            Icons.search,
            Colors.purple,
            const RecherchePage(),
          ),
        ],
      ),
    );
  }
}

// --- CONTENU DU DOSSIER MÉDICAL ---
class DossierPage extends StatelessWidget {
  const DossierPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Dossier Médical")),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text("Profil"),
              subtitle: Text("Groupe sanguin: O+"),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Analyses récentes",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          _fileItem("Analyse de sang.pdf", "12/01/2026"),
          _fileItem("Radio Thorax.jpg", "05/01/2026"),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload_file),
            label: const Text("Ajouter un document"),
          ),
        ],
      ),
    );
  }

  Widget _fileItem(String title, String date) => Card(
    child: ListTile(
      leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
      title: Text(title),
      subtitle: Text("Ajouté le $date"),
      trailing: const Icon(Icons.download),
    ),
  );
}

// --- RECHERCHE DE MÉDECIN ---
class RecherchePage extends StatelessWidget {
  const RecherchePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trouver un spécialiste")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Spécialité, nom...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  title: Text("Dr. Diallo"),
                  subtitle: Text("Dermatologue - Dakar"),
                  trailing: Text("4.8 ★"),
                ),
                ListTile(
                  title: Text("Dr. Traoré"),
                  subtitle: Text("Ophtalmologue - Bamako"),
                  trailing: Text("4.5 ★"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- CHOIX DU MÉDECIN + CHAT ---
class SelectDoctorChatPage extends StatelessWidget {
  const SelectDoctorChatPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choisir un médecin")),
      body: ListView(
        children: [
          _doctorItem(context, "Dr. Amadou Diallo", "Cardiologue"),
          _doctorItem(context, "Dr. Sophie Traoré", "Dentiste"),
        ],
      ),
    );
  }

  Widget _doctorItem(BuildContext context, String name, String job) => ListTile(
    leading: const CircleAvatar(
      backgroundColor: Colors.blue,
      child: Icon(Icons.person, color: Colors.white),
    ),
    title: Text(name),
    subtitle: Text(job),
    trailing: const Icon(Icons.chat_bubble_outline),
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPage(doctorName: name)),
    ),
  );
}

class ChatPage extends StatelessWidget {
  final String doctorName;
  const ChatPage({super.key, required this.doctorName});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(doctorName)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                _chatBubble("Bonjour Dr, j'ai mal à la poitrine.", true),
                _chatBubble(
                  "Bonjour, depuis quand ressentez-vous cela ?",
                  false,
                ),
              ],
            ),
          ),
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _chatBubble(String msg, bool isMe) => Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        msg,
        style: TextStyle(color: isMe ? Colors.white : Colors.black),
      ),
    ),
  );
  Widget _buildChatInput() => Container(
    padding: const EdgeInsets.all(8),
    color: Colors.white,
    child: Row(
      children: [
        const Expanded(
          child: TextField(
            decoration: InputDecoration(hintText: "Ecrivez ici..."),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.send, color: Colors.blue),
        ),
      ],
    ),
  );
}

// --- ESPACE MÉDECIN (Gestion RDV) ---
class DoctorHome extends StatelessWidget {
  const DoctorHome({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Tableau de Bord"),
          backgroundColor: Colors.teal[100],
          bottom: const TabBar(
            tabs: [
              Tab(text: "À faire"),
              Tab(text: "Réalisés"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [RdvList(showDone: false), RdvList(showDone: true)],
        ),
      ),
    );
  }
}

class RdvList extends StatelessWidget {
  final bool showDone;
  const RdvList({super.key, required this.showDone});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        RdvTile(
          patient: "Aminata B.",
          hour: showDone ? "Fait hier" : "10:30 Today",
          isDone: showDone,
        ),
        RdvTile(
          patient: "Oumar K.",
          hour: showDone ? "Fait ce matin" : "14:00 Today",
          isDone: showDone,
        ),
      ],
    );
  }
}

class RdvTile extends StatefulWidget {
  final String patient, hour;
  final bool isDone;
  const RdvTile({
    super.key,
    required this.patient,
    required this.hour,
    required this.isDone,
  });
  @override
  State<RdvTile> createState() => _RdvTileState();
}

class _RdvTileState extends State<RdvTile> {
  late bool done;
  @override
  void initState() {
    super.initState();
    done = widget.isDone;
  }

  @override
  Widget build(BuildContext context) => Card(
    child: CheckboxListTile(
      title: Text(widget.patient),
      subtitle: Text(widget.hour),
      value: done,
      onChanged: (v) => setState(() => done = v!),
    ),
  );
}

// --- WIDGETS DE MISE EN FORME ---
Widget _buildInput(
  String hint,
  IconData icon, {
  bool obscure = false,
  bool dark = false,
  TextEditingController? ctrl,
}) => TextField(
  controller: ctrl,
  obscureText: obscure,
  decoration: InputDecoration(
    filled: true,
    fillColor: dark ? Colors.grey[200] : Colors.white.withOpacity(0.9),
    hintText: hint,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
  ),
);
Widget _buildBtn(String text, Color color, VoidCallback tap) => SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
    ),
    onPressed: tap,
    child: Text(text),
  ),
);
Widget _buildMenuCard(
  BuildContext context,
  String title,
  IconData icon,
  Color color,
  Widget destination,
) => Card(
  elevation: 4,
  child: InkWell(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 40),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  ),
);

class RdvPatientPage extends StatelessWidget {
  const RdvPatientPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Mes RDV")),
    body: const Center(child: Text("Historique de vos rendez-vous.")),
  );
}
