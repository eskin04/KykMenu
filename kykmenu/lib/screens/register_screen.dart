import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatelessWidget {
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
                  style: TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("E-mail", Icons.email),
                ),
                SizedBox(height: 16),

                // Kullanıcı adı alanı
                TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    "Kullanıcı Adı",
                    Icons.person,
                  ),
                ),
                SizedBox(height: 16),

                // Şifre alanı
                TextField(
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("Şifre", Icons.lock),
                ),
                SizedBox(height: 16),

                // Şifre tekrar alanı
                TextField(
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("Şifre Tekrar", Icons.lock),
                ),
                SizedBox(height: 24),

                // Kayıt Ol Butonu
                ElevatedButton(
                  onPressed: () {},
                  style: _buildButtonStyle(Colors.orangeAccent),
                  child: Text(
                    'Kayıt Ol',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 16),

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
