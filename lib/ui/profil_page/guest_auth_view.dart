// lib/ui/profil_page/guest_auth_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/data_manager.dart';
import 'widgets/auth_widgets.dart';

class GuestAuthView extends StatefulWidget {
  const GuestAuthView({super.key});
  @override
  State<GuestAuthView> createState() => _GuestAuthViewState();
}

class _GuestAuthViewState extends State<GuestAuthView> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _userOrEmailCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(); 
  final _usernameCtrl = TextEditingController(); 
  final _passCtrl = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _userOrEmailCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      if (_isLogin) {
        await context.read<DataManager>().signIn(_userOrEmailCtrl.text, _passCtrl.text);
      } else {
        await context.read<DataManager>().signUp(_usernameCtrl.text, _emailCtrl.text, _passCtrl.text);
      }
    } catch (e) {
      String msg = e.toString().replaceAll("firebase_auth/", "").replaceAll("[", "").replaceAll("]", "");
      if (msg.contains("user-not-found")) msg = "Utilisateur introuvable.";
      if (msg.contains("wrong-password")) msg = "Mot de passe incorrect.";
      if (msg.contains("email-already-in-use")) msg = "Cet email/pseudo est déjà pris.";
      setState(() => _errorMessage = msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final resetCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Mot de passe oublié"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Entre ton email OU ton pseudo pour recevoir un lien de réinitialisation."),
            const SizedBox(height: 16),
            TextField(controller: resetCtrl, decoration: const InputDecoration(labelText: "Email ou Pseudo", border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.pop(ctx);
                await context.read<DataManager>().resetPassword(resetCtrl.text);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email de réinitialisation envoyé ! (Vérifie tes spams)"), backgroundColor: Colors.green));
              } catch (e) {
                String err = e.toString();
                if (err.contains("no-email-linked")) err = "Impossible : Ce compte n'a pas d'email valide.";
                if (err.contains("user-not-found")) err = "Compte introuvable.";
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
              }
            },
            child: const Text("Envoyer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // GAUCHE (Promo)
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.stars_rounded, size: 60, color: Colors.white),
                SizedBox(height: 20),
                Text("Sauvegarde ta progression", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2)),
                SizedBox(height: 20),
                BenefitRow(text: "Grimpe dans le classement"),
                BenefitRow(text: "Email facultatif pour commencer"),
                BenefitRow(text: "100% Gratuit"),
              ],
            ),
          ),
        ),

        // DROITE (Form)
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24))),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(_isLogin ? "Connexion" : "Inscription", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_isLogin ? "Rentre tes identifiants" : "Choisis un pseudo pour démarrer", style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 30),

                  if (_errorMessage != null)
                    Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade800, fontSize: 12))),

                  if (_isLogin) ...[
                    AuthField(label: "Email ou Pseudo", icon: Icons.person_outline, controller: _userOrEmailCtrl),
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _showForgotPasswordDialog, child: const Text("Mot de passe oublié ?", style: TextStyle(fontSize: 12)))),
                  ] else ...[
                    AuthField(label: "Pseudo", icon: Icons.person, controller: _usernameCtrl),
                    const SizedBox(height: 16),
                    AuthField(label: "Email (Optionnel pour récupérer mdp)", icon: Icons.email_outlined, controller: _emailCtrl, isOptional: true),
                  ],

                  if (!_isLogin) const SizedBox(height: 16),
                  AuthField(label: "Mot de passe", icon: Icons.lock_outline, controller: _passCtrl, isPass: true),

                  const SizedBox(height: 30),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_isLogin ? "Se connecter" : "S'inscrire", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_isLogin ? "Pas de compte ?" : "Déjà membre ?", style: TextStyle(color: Colors.grey[600])),
                    TextButton(onPressed: () => setState(() { _isLogin = !_isLogin; _errorMessage = null; }), child: Text(_isLogin ? "Créer un compte" : "Se connecter"))
                  ])
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}