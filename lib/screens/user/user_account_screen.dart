import 'package:flutter/material.dart';
import 'package:driving_guide/providers/user_profile.dart';

class UserAccountScreen extends StatefulWidget {
  @override
  _UserAccountScreenState createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  final UserProfile userProfile = UserProfile();
  String? _userId;
  String? _selectedDialect;
  bool _isLoading = false;
  final List<String> _dialects = ['TWI', 'FANTE', 'DAGBANI', 'GURENE', 'YORUBA', 'GA', 'HAUSA', 'EWE'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    String? userId = await userProfile.getUserId();
    String? dialect = await userProfile.getUserDialect();
    setState(() {
      _userId = userId;
      _selectedDialect = dialect;
      _isLoading = false;
    });
  }

  Future<void> _updateDialect(String newDialect) async {
    String? userId = await userProfile.getUserId();

    if (userId == null) {
      _showSnackBar('User ID not found in local storage');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await userProfile.updateLocalDialect(userId, newDialect);
      setState(() => _selectedDialect = newDialect);
      await userProfile.setUserDialect(newDialect);
      _showSnackBar('Local dialect updated successfully');
    } catch (e) {
      _showSnackBar('Failed to update local dialect');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('User Account'),
        backgroundColor: Colors.purple,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                backgroundColor: Colors.purple.shade100,
                radius: 60,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 30),
              _buildInfoCard('User ID', _userId ?? 'Not available'),
              const SizedBox(height: 20),
              _buildInfoCard('Current Dialect', _selectedDialect ?? 'Not set'),
              const SizedBox(height: 30),
              Text(
                'Select New Dialect',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              _buildDialectDropdown(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _selectedDialect == null ? null : () => _updateDialect(_selectedDialect!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Update Dialect', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            SizedBox(height: 5),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildDialectDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDialect,
          isExpanded: true,
          hint: Text('Select a dialect'),
          items: _dialects.map((String dialect) {
            return DropdownMenuItem<String>(
              value: dialect,
              child: Text(dialect),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() => _selectedDialect = newValue);
          },
        ),
      ),
    );
  }
}