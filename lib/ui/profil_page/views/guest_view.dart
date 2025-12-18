import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/data_manager.dart';

class GuestView extends StatefulWidget {
  const GuestView({super.key});

  @override
  State<GuestView> createState() => _GuestViewState();
}

class _GuestViewState extends State<GuestView> {
  bool _isLogin = true;
  bool _isForgotPassword = false; 

  final _formKey = GlobalKey<FormState>();
  
  final _userOrEmailCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

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
    
    setState(() { 
      _isLoading = true; 
      _errorMessage = null; 
      _successMessage = null; 
    });
    
    try {
      if (_isForgotPassword) {
        await context.read<DataManager>().resetPassword(_userOrEmailCtrl.text);
        setState(() {
          _successMessage = "Email de réinitialisation envoyé !";
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() { _isForgotPassword = false; _successMessage = null; });
          });
        });

      } else if (_isLogin) {
        await context.read<DataManager>().signIn(_userOrEmailCtrl.text, _passCtrl.text);
      } else {
        await context.read<DataManager>().signUp(_usernameCtrl.text, _emailCtrl.text, _passCtrl.text);
      }
    } catch (e) {
      String msg = "Une erreur est survenue.";
      if (e is FirebaseAuthException) {
        msg = e.message ?? "Erreur d'authentification.";
        if (e.code == "user-not-found") msg = "Compte introuvable.";
        if (e.code == "wrong-password") msg = "Mot de passe incorrect.";
        if (e.code == "email-already-in-use") msg = "Cet email est déjà utilisé.";
        if (e.code == "username-already-in-use") msg = "Ce pseudo est déjà pris.";
        if (e.code == "no-email-linked") msg = "Ce compte n'a pas d'email valide.";
      } else {
        msg = e.toString(); 
      }
      setState(() => _errorMessage = msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = "Créer un compte";
    if (_isLogin) title = "Bon retour !";
    if (_isForgotPassword) title = "Récupération";

    String subtitle = "Rentre tes informations pour continuer.";
    if (_isForgotPassword) subtitle = "Entre ton email ou pseudo pour recevoir un lien.";

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 650),
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 40, offset: const Offset(0, 20)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(48),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(32), bottomLeft: Radius.circular(32)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 32),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        "Rejoignez\nl'aventure.",
                        style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, letterSpacing: -1),
                      ),
                      const SizedBox(height: 24),
                      _buildBenefit("Sauvegarde ta progression"),
                      _buildBenefit("Une expérience personnalisée"),
                      _buildBenefit("Gratuit, sans publicité"),
                    ],
                  ),
                ),
              ),
      
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title, 
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))
                        ),
                        const SizedBox(height: 6),
                        Text(subtitle, style: TextStyle(color: Colors.blueGrey[400], fontSize: 14)),
                        
                        const SizedBox(height: 24),
      
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Row(children: [const Icon(Icons.error_outline, color: Colors.red, size: 18), const SizedBox(width: 8), Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade800, fontSize: 13, fontWeight: FontWeight.bold)))])
                          ),
                        if (_successMessage != null)
                           Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Row(children: [const Icon(Icons.check_circle_outline, color: Colors.green, size: 18), const SizedBox(width: 8), Expanded(child: Text(_successMessage!, style: TextStyle(color: Colors.green.shade800, fontSize: 13, fontWeight: FontWeight.bold)))])
                          ),
                        
                        if (_isForgotPassword) ...[
                          _ModernInput(label: "Email ou Pseudo", icon: Icons.mail_outline, controller: _userOrEmailCtrl),
                        
                        ] else if (_isLogin) ...[
                          _ModernInput(label: "Email ou Pseudo", icon: Icons.person_outline, controller: _userOrEmailCtrl),
                          
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight, 
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isForgotPassword = true;
                                  _errorMessage = null;
                                  _successMessage = null;
                                });
                              },
                              child: const Text("Mot de passe oublié ?", style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600, fontSize: 12))
                            )
                          ),
                          const SizedBox(height: 6),

                          _ModernInput(label: "Mot de passe", icon: Icons.lock_outline, controller: _passCtrl, isPass: true),
                        
                        ] else ...[
                          _ModernInput(label: "Pseudo", icon: Icons.person, controller: _usernameCtrl),
                          const SizedBox(height: 24),
                          _ModernInput(label: "Email (facultatif)", icon: Icons.alternate_email, controller: _emailCtrl, isOptional: true),
                          const SizedBox(height: 24),
                          _ModernInput(label: "Mot de passe", icon: Icons.lock_outline, controller: _passCtrl, isPass: true),
                        ],
      
                        const SizedBox(height: 24),
                        
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1), 
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isLoading 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(
                                    _isForgotPassword ? "Envoyer le lien" : (_isLogin ? "Se connecter" : "S'inscrire"), 
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                                  ),
                          ),
                        ),
      
                        const SizedBox(height: 16),
                        
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          if (_isForgotPassword)
                             TextButton.icon(
                              onPressed: () => setState(() { _isForgotPassword = false; _errorMessage = null; _successMessage = null; }),
                              icon: const Icon(Icons.arrow_back, size: 14),
                              label: const Text("Retour à la connexion", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 13))
                            )
                          
                          else ...[
                            Text(_isLogin ? "Nouveau ici ?" : "Déjà un compte ?", style: TextStyle(color: Colors.blueGrey[400], fontSize: 13)),
                            TextButton(
                              onPressed: () => setState(() { _isLogin = !_isLogin; _errorMessage = null; _successMessage = null; }),
                              child: Text(_isLogin ? "Créer un compte" : "Se connecter", style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 13))
                            )
                          ]
                        ])
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 12),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500))
        ],
      ),
    );
  }
}

class _ModernInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool isPass;
  final bool isOptional;

  const _ModernInput({required this.label, required this.icon, required this.controller, this.isPass = false, this.isOptional = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPass,
      validator: (v) => (!isOptional && (v == null || v.isEmpty)) ? "Requis" : null,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueGrey[400], fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.blueGrey[300], size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        isDense: true,
      ),
    );
  }
}