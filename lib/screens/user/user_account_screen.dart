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
    String? userId = await userProfile.getUserId();
    String? dialect = await userProfile.getUserDialect();
    setState(() {
      _userId = userId;
      _selectedDialect = dialect;
    });
  }

  Future<void> _updateDialect(String newDialect) async {
    String? userId = await userProfile.getUserId();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID not found in local storage')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await userProfile.updateLocalDialect(userId, newDialect);
      setState(() {
        _selectedDialect = newDialect;
      });
      await userProfile.setUserDialect(newDialect);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Local dialect updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update local dialect')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Account'),
        backgroundColor: Colors.purple,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple,
              radius: 50,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'User ID: $_userId',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Current Dialect: $_selectedDialect',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Select New Dialect:',
              style: TextStyle(fontSize: 18, color: Colors.purple),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedDialect,
              items: _dialects.map((String dialect) {
                return DropdownMenuItem<String>(
                  value: dialect,
                  child: Text(dialect),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDialect = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedDialect == null
                  ? null
                  : () => _updateDialect(_selectedDialect!),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: Text('Update Dialect'),
            ),
          ],
        ),
      ),
    );
  }
}
