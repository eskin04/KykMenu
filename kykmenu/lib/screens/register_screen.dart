import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/auth.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String? errorMessage = '';

  // Kayıt olma işlemi için gerekli fonksiyon
  Future<void> register() async {
    try {
      await Auth().creatUser(
        email: emailController.text,
        password: passwordController.text,
      );

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Başarılı"),
            content: Text("Kayıt işlemi başarılı!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Tamam"),
              ),
            ],
          );
        },
      );

      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ), // Giriş ekranına yönlendir
        );
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';

      // Firebase hata kodlarına göre Türkçe mesajlar döndürüyoruz
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Bu e-posta zaten kullanılıyor';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz e-posta adresi';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Bu işlem şu anda kullanılamıyor';
          break;
        case 'weak-password':
          errorMessage = 'Şifreniz çok zayıf, daha güçlü bir şifre girin';
          break;
        default:
          errorMessage = 'Bütün alanları doldurduğunuzdan emin olun';
          break;
      }

      setState(() {
        this.errorMessage = errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade300],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo kısmı
                Image.asset('assets/logo.png', height: 120),
                SizedBox(height: 24),

                // "Kayıt Ol" başlığı
                Text(
                  "Kayıt Ol",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),

                // E-mail alanı
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,

                  style: TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("E-mail", Icons.email),
                ),
                SizedBox(height: 16),

                // Kullanıcı adı alanı
                TextField(
                  controller: usernameController,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    "Kullanıcı Adı",
                    Icons.person,
                  ),
                ),
                SizedBox(height: 16),

                // Şifre alanı
                TextField(
                  controller: passwordController,
                  textInputAction: TextInputAction.next,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("Şifre", Icons.lock),
                ),
                SizedBox(height: 16),

                // Şifre tekrar alanı
                TextField(
                  controller: confirmPasswordController,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("Şifre Tekrar", Icons.lock),
                ),
                SizedBox(height: 20),

                errorMessage != null
                    ? Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    )
                    : const SizedBox.shrink(),

                // Kayıt Ol Butonu
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    register();
                  },
                  style: _buildButtonStyle(Colors.orangeAccent),
                  child: Text(
                    'Kayıt Ol',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 1),

                // Geri Dön Butonu
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Geri Dön',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Özel Input Alanı Stili
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(icon, color: Colors.white),
    );
  }

  // Özel Buton Stili
  ButtonStyle _buildButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
