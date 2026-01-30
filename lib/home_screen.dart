import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ma Télé-médecine"),
        backgroundColor: Colors.blueAccent,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.person))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bonjour, comment allez-vous ?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Grille de services
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildServiceCard(
                    Icons.medical_services,
                    "Consultation",
                    Colors.blue,
                  ),
                  _buildServiceCard(Icons.chat, "Chat Docteur", Colors.green),
                  _buildServiceCard(
                    Icons.calendar_month,
                    "Rendez-vous",
                    Colors.orange,
                  ),
                  _buildServiceCard(Icons.history, "Mon Dossier", Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Petit widget pour créer les boutons de service rapidement
  Widget _buildServiceCard(IconData icon, String title, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {}, // On ajoutera la navigation plus tard
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
