import 'package:flutter/material.dart';
import 'package:libriflow/common/mysnackbar.dart';
import 'package:libriflow/screen/login.dart';
import 'package:libriflow/widget/mybutton.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to Dashboard!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            MyButtonWidgets(
              text: "Logout Now",
              onPressed: () {
                MySnackBar.show(
                  context,
                  message: "Logged out!",
                  background: Colors.blue,
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
