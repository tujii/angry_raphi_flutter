import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../services/admin_config_service.dart';
import '../../../../services/registered_users_service.dart';

/// Admin Settings Page - Manage admins and promote users
class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  List<AdminInfo> _csvAdmins = [];
  List<Map<String, dynamic>> _firebaseAdmins = [];
  List<Map<String, dynamic>> _registeredUsers = [];
  bool _loading = true;
  late RegisteredUsersService _registeredUsersService;

  @override
  void initState() {
    super.initState();
    _registeredUsersService = RegisteredUsersService(FirebaseFirestore.instance);
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _loading = true);
    
    try {
      // Load CSV admins
      final csvAdmins = await AdminConfigService.loadAdminConfig();
      
      // Load Firebase admins
      final firebaseAdmins = await _loadFirebaseAdmins();
      
      // Load registered users from RegisteredUsersService
      final registeredUsers = await _registeredUsersService.getRegisteredUsers();
      
      setState(() {
        _csvAdmins = csvAdmins;
        _firebaseAdmins = firebaseAdmins;
        _registeredUsers = registeredUsers;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Laden der Admin-Daten: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _loadFirebaseAdmins() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('admins')
          .get();
          
      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'email': doc.data()['email'] ?? '',
                'displayName': doc.data()['displayName'] ?? '',
                'createdAt': doc.data()['createdAt']?.toDate(),
              })
          .toList();
    } catch (e) {
      return [];
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.adminSettings ?? 'Admin Einstellungen'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAdminData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCSVAdminsSection(),
                    const SizedBox(height: 24),
                    _buildFirebaseAdminsSection(),
                    const SizedBox(height: 24),
                    _buildRegisteredUsersSection(),
                    const SizedBox(height: 24),
                    _buildPromoteUserSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCSVAdminsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Konfigurierte Admins (CSV)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Diese Admins sind in der CSV-Konfiguration definiert:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (_csvAdmins.isEmpty)
              const Text('Keine konfigurierten Admins gefunden.')
            else
              ..._csvAdmins.map((admin) => _buildAdminTile(
                email: admin.email,
                displayName: admin.displayName,
                role: admin.role,
                isCSVAdmin: true,
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildFirebaseAdminsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Aktive Admins (Firebase)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Diese Admins sind aktuell in Firebase registriert:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (_firebaseAdmins.isEmpty)
              const Text('Keine aktiven Admins in Firebase gefunden.')
            else
              ..._firebaseAdmins.map((admin) => _buildAdminTile(
                email: admin['email'],
                displayName: admin['displayName'],
                role: 'admin',
                isCSVAdmin: false,
                canRemove: true,
                adminId: admin['id'],
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisteredUsersSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Registrierte Benutzer',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Diese Benutzer haben sich bereits mit Google angemeldet:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (_registeredUsers.isEmpty)
              const Text('Keine registrierten Benutzer gefunden.')
            else
              ..._registeredUsers.map((user) => _buildRegisteredUserTile(
                email: user['email'],
                displayName: user['displayName'],
                lastLoginAt: user['lastLoginAt'],
                onPromote: () => _showPromoteUserDialog(prefilledEmail: user['email']),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisteredUserTile({
    required String email,
    required String displayName,
    DateTime? lastLoginAt,
    required VoidCallback onPromote,
  }) {
    // Check if user is already an admin
    final isAlreadyAdmin = _firebaseAdmins.any((admin) => admin['email'] == email) ||
        _csvAdmins.any((admin) => admin.email == email);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAlreadyAdmin ? Colors.orange.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAlreadyAdmin ? Colors.orange.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isAlreadyAdmin ? Colors.orange : AppConstants.primaryColor,
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : email[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.isNotEmpty ? displayName : email.split('@')[0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  email,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (lastLoginAt != null)
                  Text(
                    'Letzter Login: ${_formatDate(lastLoginAt)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                if (isAlreadyAdmin)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Bereits Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!isAlreadyAdmin)
            IconButton(
              onPressed: onPromote,
              icon: const Icon(Icons.arrow_upward, color: Colors.green),
              tooltip: 'Zu Admin befördern',
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return 'vor ${difference.inDays} Tag${difference.inDays == 1 ? '' : 'en'}';
    } else if (difference.inHours > 0) {
      return 'vor ${difference.inHours} Stunde${difference.inHours == 1 ? '' : 'n'}';
    } else if (difference.inMinutes > 0) {
      return 'vor ${difference.inMinutes} Minute${difference.inMinutes == 1 ? '' : 'n'}';
    } else {
      return 'gerade eben';
    }
  }

  Widget _buildPromoteUserSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_add, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'User zu Admin befördern',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Manuell einen neuen Admin hinzufügen:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showPromoteUserDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Manuell Admin hinzufügen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminTile({
    required String email,
    required String displayName,
    required String role,
    required bool isCSVAdmin,
    bool canRemove = false,
    String? adminId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCSVAdmin ? Colors.blue.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCSVAdmin ? Colors.blue.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppConstants.primaryColor,
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : email[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.isNotEmpty ? displayName : email.split('@')[0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  email,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: role == 'super_admin' ? Colors.red : Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role == 'super_admin' ? 'Super Admin' : 'Admin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (canRemove && adminId != null)
            IconButton(
              onPressed: () => _showRemoveAdminDialog(adminId, email),
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              tooltip: 'Admin entfernen',
            ),
        ],
      ),
    );
  }

  void _showPromoteUserDialog({String? prefilledEmail}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return PromoteUserDialog(prefilledEmail: prefilledEmail);
      },
    ).then((_) => _loadAdminData()); // Refresh data after dialog closes
  }

  void _showRemoveAdminDialog(String adminId, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin entfernen'),
        content: Text('Möchten Sie $email wirklich als Admin entfernen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _removeAdmin(adminId, email);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Entfernen', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _removeAdmin(String adminId, String email) async {
    try {
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$email wurde als Admin entfernt')),
        );
        _loadAdminData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Entfernen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Dialog to promote a user to admin
class PromoteUserDialog extends StatefulWidget {
  final String? prefilledEmail;
  
  const PromoteUserDialog({super.key, this.prefilledEmail});

  @override
  State<PromoteUserDialog> createState() => _PromoteUserDialogState();
}

class _PromoteUserDialogState extends State<PromoteUserDialog> {
  String _email = '';
  String _displayName = '';
  bool _isLoading = false;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _email = widget.prefilledEmail ?? '';
    _emailController = TextEditingController(text: _email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('User zu Admin befördern'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Geben Sie die Daten des Benutzers ein, der zu Admin befördert werden soll:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-Mail-Adresse',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
                hintText: 'beispiel@email.com',
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => setState(() => _email = value.trim()),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Anzeigename (optional)',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                hintText: 'Max Mustermann',
              ),
              onChanged: (value) => setState(() => _displayName = value.trim()),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Der Benutzer muss bereits ein Google-Konto haben und sich mindestens einmal in der App angemeldet haben.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: _isLoading || !_isValidEmail(_email) ? null : () => _promoteUser(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Zu Admin befördern', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  bool _isValidEmail(String email) {
    return email.isNotEmpty && email.contains('@') && email.contains('.');
  }

  void _promoteUser() async {
    if (!_isValidEmail(_email)) return;

    setState(() => _isLoading = true);

    try {
      final displayNameToUse = _displayName.isNotEmpty ? _displayName : _email.split('@')[0];

      // Add user as admin in Firebase
      await FirebaseFirestore.instance.collection('admins').add({
        'email': _email,
        'displayName': displayNameToUse,
        'createdAt': FieldValue.serverTimestamp(),
        'promotedBy': 'admin', // Could be current admin's email
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_email wurde zu Admin befördert')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Befördern: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}