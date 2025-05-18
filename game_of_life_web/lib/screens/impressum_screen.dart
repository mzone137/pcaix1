// lib/screens/impressum_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ImpressumScreen extends StatelessWidget {
  const ImpressumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impressum'),
        backgroundColor: AppTheme.primaryAccent,
        elevation: 0,
      ),
      backgroundColor: AppTheme.creamBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryAccent,
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'IMPRESSUM',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32),

            // Kontaktinformationen
            _buildSectionTitle('Angaben gemäß § 5 TMG'),
            _buildContactInfo(
              name: 'Max Mustermann',
              organization: 'Neural Nexus Systems',
              address: 'Musterstraße 123\n12345 Musterstadt\nDeutschland',
            ),

            SizedBox(height: 24),

            _buildSectionTitle('Kontakt'),
            _buildContactDetails(
              phone: '+49 123 456789',
              email: 'info@neural-nexus.systems',
              website: 'www.neural-nexus.systems',
            ),

            SizedBox(height: 24),

            _buildSectionTitle('Umsatzsteuer-ID'),
            _buildTextParagraph('Umsatzsteuer-Identifikationsnummer gemäß § 27 a Umsatzsteuergesetz: DE123456789'),

            SizedBox(height: 24),

            _buildSectionTitle('Redaktionell verantwortlich'),
            _buildTextParagraph('Max Mustermann (Anschrift wie oben)'),

            SizedBox(height: 24),

            _buildSectionTitle('EU-Streitschlichtung'),
            _buildTextParagraph('Die Europäische Kommission stellt eine Plattform zur Online-Streitbeilegung (OS) bereit: https://ec.europa.eu/consumers/odr/\nUnsere E-Mail-Adresse finden Sie oben im Impressum.'),

            SizedBox(height: 24),

            _buildSectionTitle('Verbraucher­streit­beilegung/Universal­schlichtungs­stelle'),
            _buildTextParagraph('Wir sind nicht bereit oder verpflichtet, an Streitbeilegungsverfahren vor einer Verbraucherschlichtungsstelle teilzunehmen.'),

            SizedBox(height: 24),

            // Feedback oder Fragen
            Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryAccent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feedback oder Fragen?',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Wir freuen uns über Ihr Feedback zu unseren interaktiven Spielen! Schreiben Sie uns gerne eine E-Mail.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppTheme.primaryText.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // E-Mail-Aktion hier (könnte zu einer E-Mail-App führen)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('E-Mail-Feature kommt bald!')),
                      );
                    },
                    icon: Icon(Icons.email),
                    label: Text('E-Mail senden'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 50), // Extra Raum am Ende
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryAccent,
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: 4),
        Divider(
          color: AppTheme.primaryAccent.withOpacity(0.3),
          thickness: 1,
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildContactInfo({
    required String name,
    required String organization,
    required String address,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            organization,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primaryText.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 8),
          Text(
            address,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppTheme.primaryText.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetails({
    required String phone,
    required String email,
    required String website,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildContactRow(Icons.phone, 'Telefon', phone),
          SizedBox(height: 12),
          _buildContactRow(Icons.email, 'E-Mail', email),
          SizedBox(height: 12),
          _buildContactRow(Icons.language, 'Website', website),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryAccent,
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryText.withOpacity(0.6),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.primaryText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextParagraph(String text) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: AppTheme.primaryText.withOpacity(0.8),
        ),
      ),
    );
  }
}