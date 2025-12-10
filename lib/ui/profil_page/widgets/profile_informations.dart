import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/data_manager.dart';

class ProfileInformations extends StatefulWidget {
  const ProfileInformations({super.key});
  @override
  State<ProfileInformations> createState() => _ProfileInformationsState();
}

class _ProfileInformationsState extends State<ProfileInformations> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  
  // Contrôleur pour le changement de mdp
  final _newPassCtrl = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final user = context.read<DataManager>().currentUser;
    _usernameCtrl.text = user.username;
    _emailCtrl.text = user.hasFakeEmail ? "" : user.email;
  }
  
  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      // NOUVEAU : On passe aussi l'email
      await context.read<DataManager>().updateProfile(
        newUsername: _usernameCtrl.text,
        newEmail: _emailCtrl.text.isNotEmpty ? _emailCtrl.text : null
      );
      
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil mis à jour ! (Vérifie tes emails si tu l'as changé)"), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // NOUVEAU : Popup pour changer le mot de passe
  void _showChangePasswordDialog() {
    _newPassCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Changer le mot de passe"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Saisis ton nouveau mot de passe ci-dessous."),
            const SizedBox(height: 16),
            TextField(
              controller: _newPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Nouveau mot de passe", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              try {
                if (_newPassCtrl.text.length < 6) throw "Le mot de passe doit faire 6 caractères minimum.";
                Navigator.pop(ctx);
                
                // Appel au DataManager
                await context.read<DataManager>().updatePassword(_newPassCtrl.text);
                
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mot de passe modifié avec succès !"), backgroundColor: Colors.green));
              } catch (e) {
                // Gestion de l'erreur "requires-recent-login"
                String err = e.toString();
                if (err.contains("requires-recent-login")) {
                  err = "Par sécurité, tu dois te reconnecter avant de changer ton mot de passe.";
                  // On pourrait déconnecter l'utilisateur ici pour forcer la reco
                }
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
              }
            },
            child: const Text("Valider"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Mes Informations", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            if (!_isEditing)
              IconButton(onPressed: () => setState(() => _isEditing = true), icon: const Icon(Icons.edit_outlined), tooltip: "Modifier"),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileField(label: "Nom d'utilisateur", controller: _usernameCtrl, icon: Icons.person_outline_rounded, enabled: _isEditing),
              const SizedBox(height: 20),
              // NOUVEAU : Champ email activé en édition
              _ProfileField(label: "Adresse Email", controller: _emailCtrl, icon: Icons.email_outlined, enabled: _isEditing),
              
              const SizedBox(height: 20),
              
              // NOUVEAU : Bouton Changer de mot de passe (Seulement en mode édition)
              if (_isEditing)
                OutlinedButton.icon(
                  onPressed: _showChangePasswordDialog,
                  icon: const Icon(Icons.lock_reset, size: 18),
                  label: const Text("Changer mon mot de passe"),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.grey[700], side: BorderSide(color: Colors.grey.shade300)),
                ),

              if (_isEditing) ...[
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () { 
                      setState(() => _isEditing = false); 
                      _refreshData(); // Reset les champs
                    }, child: const Text("Annuler")),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                      child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Sauvegarder"),
                    )
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool enabled;
  const _ProfileField({required this.label, required this.icon, required this.controller, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(color: enabled ? Colors.black : Colors.grey[700], fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent.withValues(alpha: 0.7)),
        border: InputBorder.none,
        filled: true,
        fillColor: enabled ? Colors.blue.withValues(alpha: 0.05) : Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
      ),
    );
  }
}