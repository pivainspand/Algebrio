import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';



void main() async {
  /*WidgetsFlutterBinding.ensureInitialized();
  await deleteDatabaseIfExists(); */
  runApp(MyApp());
}

Future<void> deleteDatabaseIfExists() async {
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'app.db');
  await deleteDatabase(path);
} // - baza


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue[50],
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100.0),
            borderSide: BorderSide(color: Colors.blue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100.0),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueAccent,
            textStyle: TextStyle(fontSize: 30),
          ),
        ),
      ),
      home: LoginPage(),
    );
  }
} // myApp

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Lūdzu, ievadiet e-pastu un paroli.');
      return;
    }

    DatabaseHelper dbHelper = DatabaseHelper();
    bool isValid = await dbHelper.checkUserCredentials(email, password);

    if (isValid) {
      Navigator.pushReplacement(
        this.context,
        MaterialPageRoute(builder: (BuildContext context) => MainScreen(email: email)),
      );
    } else {
      _showErrorDialog('Nepareizs E-pasts vai parole');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ошибка'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _goToRegister() {
    Navigator.push(
      this.context,
      MaterialPageRoute(builder: (BuildContext context) => RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Vai tu esi lietotājs?',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'E-mail'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lūdzu, ievadiet e-pastu';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Parole' , ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lūdzu, ievadiet paroli';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: Center(child: Text('Pieteikties', style: TextStyle(fontSize: 20 ))),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: _goToRegister,
                  child: Text('Reģistrācija'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} // login end


class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      _showErrorDialog('Paroles nesakrīt');
      return;
    }

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showErrorDialog('Lūdzu, aizpildiet visus laukus');
      return;
    }

    DatabaseHelper dbHelper = DatabaseHelper();
    bool isUserExists = await dbHelper.checkIfUserExists(email);

    if (isUserExists) {
      _showErrorDialog('Šis E-pasts jau tiek izmantots');
    } else {
      bool isRegistered = await dbHelper.registerUser(email, password);
      if (isRegistered) {
        _showSuccessDialog('Jūs esat veiksmīgi reģistrējies!');
      } else {
        _showErrorDialog('Kļūda reģistrējoties');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Kļūda'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Panākums'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(this.context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _goToLogin() {
    Navigator.pop(this.context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Reģistrēties',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'E-mail'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lūdzu, ievadiet e-pastu';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Parole'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lūdzu, ievadiet paroli';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(labelText: 'Apstipriniet paroli'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lūdzu, apstipriniet paroli';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _register,
                  child: Center(child: Text('Reģistrēties')),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: _goToLogin,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                  ),
                  child: Text('Ienākt', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} //reg  end

class MainScreen extends StatefulWidget {
  final String email;

  MainScreen({required this.email});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      ProfilePage(email: widget.email),
      LevelSelectionScreen(email: widget.email),
      SettingsPage(),
    ];

    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profils',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Sākumlapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Iestatījums',
          ),
        ],
      ),
    );
  }
}








class LevelSelectionScreen extends StatefulWidget {
  final String email;

  LevelSelectionScreen({required this.email});

  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  int activeLevel = 1;
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() async {
    int progress = await dbHelper.getUserProgress(widget.email);
    setState(() {
      activeLevel = progress;
    });
  }

  void _updateProgress(int level) async {
    await dbHelper.updateUserProgress(widget.email, level);
    setState(() {
      activeLevel = level;
    });
  }

  void openLevel1(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Level1Screen(onComplete: () {
          if (activeLevel == 1) {
            _updateProgress(2);
          }
        }),
      ),
    );
  }



  void openLevel2(BuildContext context) {
    if (activeLevel >= 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Level2Screen(onComplete: () {
            setState(() {
              if (activeLevel == 2) {
                _updateProgress(3);
              }
            });
          }),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lai atvērtu 2 līmeni jums jāpabeidz iepriekšējie līmeņi"), duration: Duration(seconds: 2),),
      );
    }
  }

  void openLevel3(BuildContext context) {
    if (activeLevel >= 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Level3Screen(onComplete: () {
            setState(() {
              if (activeLevel == 3) {
                _updateProgress(4);
              }
            });
          }),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lai atvērtu 3 līmeni jums jāpabeidz iepriekšējie līmeņi"), duration: Duration(seconds: 2),),
      );
    }
  }

  void openLevel4(BuildContext context) {
    if (activeLevel >= 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Level4Screen(onComplete: () {
            setState(() {
              if (activeLevel == 4) {
                _updateProgress(5);
              }
            });
          }),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lai atvērtu 4 līmeni jums jāpabeidz iepriekšējie līmeņi"), duration: Duration(seconds: 2),),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Līmeņa izvēle'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: 1000,
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(5, (index) {
                int level = index + 1;
                double topOffset = index * 120.0 + 100.0;
                double horizontalOffset = (index % 2 == 0) ? 80.0 : -140.0;

                return Positioned(
                  top: topOffset,
                  left: MediaQuery.of(context).size.width / 2 +
                      horizontalOffset - 40,
                  child: GestureDetector(
                    onTap: level == 1
                        ? () => openLevel1(context)
                        : (level == 2
                        ? () => openLevel2(context)
                        : (level == 3
                        ? () => openLevel3(context)
                        : (level == 4
                        ? () => openLevel4(context)
                        : null))),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: level <= activeLevel
                              ? Colors.blueAccent
                              : Colors.grey,
                          child: Icon(
                            level <= activeLevel ? Icons.star : Icons.lock,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Līmenis $level',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}




class Level1Screen extends StatefulWidget {
  final VoidCallback onComplete;

  Level1Screen({required this.onComplete});

  @override
  _Level1ScreenState createState() => _Level1ScreenState();
}

class _Level1ScreenState extends State<Level1Screen> {
  final Random random = Random();
  int questionCount = 0;
  int correctAnswers = 0;
  int num1 = 0;
  int num2 = 0;
  String userAnswer = '';
  String feedback = '';
  final TextEditingController _controller = TextEditingController();

  void generateQuestion() {
    do {
      num1 = random.nextInt(10) + 1;
      num2 = random.nextInt(10) + 1;
    } while (num1 + num2 > 10);
  }

  @override
  void initState() {
    super.initState();
    generateQuestion();
  }

  void checkAnswer() {
    int? answer = int.tryParse(userAnswer);
    if (answer != null && answer == num1 + num2) {
      correctAnswers++;
      feedback = 'Pareizi!';
    } else {
      feedback = 'Nepareizi. Pareizā atbilde: ${num1 + num2}';
    }
    userAnswer = '';
    _controller.clear();
    questionCount++;

    if (questionCount < 10) {
      generateQuestion();
    } else if (correctAnswers >= 6) {
      widget.onComplete();
      Navigator.pop(this.context);
    } else {
      feedback = 'Jūs neesat ierakstījis pietiekami daudz pareizo atbilžu. Mēģiniet vēlreiz.';
      questionCount = 0;
      correctAnswers = 0;
      generateQuestion();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Līmenis 1'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Jautājums ${questionCount + 1} no 10',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              '$num1 + $num2 = ?',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Jūsu atbilde',
              ),
              onChanged: (value) {
                userAnswer = value;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: checkAnswer,
              child: Text('Pārbaudīt'),
            ),
            SizedBox(height: 16),
            Text(
              feedback,
              style: TextStyle(fontSize: 18, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
class Level2Screen extends StatefulWidget {
  final VoidCallback onComplete;

  Level2Screen({required this.onComplete});

  @override
  _Level2ScreenState createState() => _Level2ScreenState();
}

class _Level2ScreenState extends State<Level2Screen> {
  final Random random = Random();
  int questionCount = 0;
  int correctAnswers = 0;
  int num1 = 0;
  int num2 = 0;
  String userAnswer = '';
  String feedback = '';
  final TextEditingController _controller1 = TextEditingController();

  void generateQuestion() {
    do {
      num1 = random.nextInt(10) + 1;
      num2 = random.nextInt(10) + 1;
    } while (num1 - num2 > 10 || num1 - num2 < 0 );
  }

  @override
  void initState() {
    super.initState();
    generateQuestion();
  }

  void checkAnswer() {
    int? answer = int.tryParse(userAnswer);
    if (answer != null && answer == num1 - num2) {
      correctAnswers++;
      feedback = 'Pareizi!';
    } else {
      feedback = 'Nepareizi. Pareizā atbilde: ${num1 - num2}';
    }


    _controller1.clear();
    userAnswer = '';

    questionCount++;

    if (questionCount < 10) {
      generateQuestion();
    } else if (correctAnswers >= 6) {
      widget.onComplete();
      Navigator.pop(this.context);
    } else {
      feedback = 'Jūs neesat ierakstījis pietiekami daudz pareizo atbilžu. Mēģiniet vēlreiz.';
      questionCount = 0;
      correctAnswers = 0;
      generateQuestion();
    }


    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Līmenis 2'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Jautājums ${questionCount + 1} no 10',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              '$num1 - $num2 = ?',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _controller1,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Jūsu atbilde',
              ),
              onChanged: (value) {
                userAnswer = value;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: checkAnswer,
              child: Text('Pārbaudīt'),
            ),
            SizedBox(height: 16),
            Text(
              feedback,
              style: TextStyle(fontSize: 18, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class Level3Screen extends StatefulWidget {
  final VoidCallback onComplete;

  Level3Screen({required this.onComplete});

  @override
  _Level3ScreenState createState() => _Level3ScreenState();
}

class _Level3ScreenState extends State<Level3Screen> {
  final Random random = Random();
  int questionCount = 0;
  int correctAnswers = 0;
  int num1 = 0;
  int num2 = 0;
  String userAnswer = '';
  String feedback = '';
  final TextEditingController _controller = TextEditingController();

  void generateQuestion() {
    do {
      num1 = random.nextInt(10) + 1;
      num2 = random.nextInt(10) + 1;
    } while (num1 * num2 > 100);
  }

  @override
  void initState() {
    super.initState();
    generateQuestion();
  }

  void checkAnswer() {
    int? answer = int.tryParse(userAnswer);
    if (answer != null && answer == num1 * num2) {
      correctAnswers++;
      feedback = 'Pareizi!';
    } else {
      feedback = 'Nepareizi. Pareizā atbilde: ${num1 * num2}';
    }

    _controller.clear();
    userAnswer = '';
    questionCount++;

    if (questionCount < 10) {
      generateQuestion();
    } else if (correctAnswers >= 6) {
      widget.onComplete();
      Navigator.pop(this.context);
    } else {
      feedback = 'Jūs neesat ierakstījis pietiekami daudz pareizo atbilžu. Mēģiniet vēlreiz.';
      questionCount = 0;
      correctAnswers = 0;
      generateQuestion();
    }


    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Līmenis 3'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Jautājums ${questionCount + 1} no 10',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              '$num1 * $num2 = ?',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Jūsu atbilde',
              ),
              onChanged: (value) {
                userAnswer = value;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: checkAnswer,
              child: Text('Pārbaudīt'),
            ),
            SizedBox(height: 16),
            Text(
              feedback,
              style: TextStyle(fontSize: 18, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class Level4Screen extends StatefulWidget {
  final VoidCallback onComplete;

  Level4Screen({required this.onComplete});

  @override
  _Level4ScreenState createState() => _Level4ScreenState();
}

class _Level4ScreenState extends State<Level4Screen> {
  final Random random = Random();
  int questionCount = 0;
  int correctAnswers = 0;
  int num1 = 0;
  int num2 = 0;
  String userAnswer = '';
  String feedback = '';
  final TextEditingController _controller = TextEditingController();

  void generateQuestion() {
    do {
      num1 = random.nextInt(10) + 1;
      num2 = random.nextInt(10) + 1;
    } while (num1 % num2 != 0 || num1 / num2 > 10);
  }

  @override
  void initState() {
    super.initState();
    generateQuestion();
  }

  void checkAnswer() {
    int? answer = int.tryParse(userAnswer);
    if (answer != null && answer == num1 ~/ num2) {
      correctAnswers++;
      feedback = 'Pareizi!';
    } else {
      feedback = 'Nepareizi. Pareizā atbilde: ${num1 ~/ num2}';
    }
    _controller.clear();
    userAnswer = '';

    questionCount++;

    if (questionCount < 10) {
      generateQuestion();
    } else if (correctAnswers >= 6) {
      widget.onComplete();
      Navigator.pop(this.context);
    } else {
      feedback = 'Jūs neesat ierakstījis pietiekami daudz pareizo atbilžu. Mēģiniet vēlreiz.';
      questionCount = 0;
      correctAnswers = 0;
      generateQuestion();
    }


    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Līmenis 4'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Jautājums ${questionCount + 1} no 10',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              '$num1 / $num2 = ?',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Jūsu atbilde',
              ),
              onChanged: (value) {
                userAnswer = value;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: checkAnswer,
              child: Text('Pārbaudīt'),
            ),
            SizedBox(height: 16),
            Text(
              feedback,
              style: TextStyle(fontSize: 18, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}






class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iestatījums')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SettingButton(
              text: 'Par lietotni',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Drīz tiks pievienots!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            SettingButton(
              text: 'Paziņojums',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Drīz tiks pievienots!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            SettingButton(
              text: 'Valoda',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Drīz tiks pievienots!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            SettingButton(
              text: 'Konfidencialitāte',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Drīz tiks pievienots!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            SettingButton(
              text: 'Tēma',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Drīz tiks pievienots!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            SettingButton(
              text: 'Izziņa',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Drīz tiks pievienots!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            SettingButton(
              text: 'Izeja',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const SettingButton({required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      ),
    );
  }
}



class ProfilePage extends StatefulWidget {
  final String email;

  ProfilePage({required this.email});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _avatar;
  late String nickname;

  @override
  void initState() {
    super.initState();
    nickname = widget.email.split('@')[0];
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _avatar = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profils')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                _avatar != null ? FileImage(_avatar!) : AssetImage('assets/default_avatar.png') as ImageProvider,
                child: _avatar == null
                    ? Icon(Icons.add_a_photo, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            Text(
              nickname,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Text(
              'Jūsu atlīdzības:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: 6,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Balva ${index + 1}',
                        style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
String hashPassword(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);
  return digest.toString();
} // kriptograf


// db
class DatabaseHelper {
  Future<Database> getDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'app.db');

    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE users(email TEXT PRIMARY KEY, password TEXT)'
        );
        await db.execute(
            'CREATE TABLE progress(email TEXT PRIMARY KEY, level INTEGER, FOREIGN KEY(email) REFERENCES users(email))'
        );
      },
      version: 1,
    );
  }

  Future<bool> checkIfUserExists(String email) async {
    final db = await getDatabase();
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  Future<bool> registerUser(String email, String password) async {
    final db = await getDatabase();
    String hashedPassword = hashPassword(password);
    try {
      await db.insert('users', {'email': email, 'password': hashedPassword});
      await db.insert('progress', {'email': email, 'level': 1});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkUserCredentials(String email, String password) async {
    final db = await getDatabase();
    String hashedPassword = hashPassword(password);
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
    );
    return result.isNotEmpty;
  }

  Future<int> getUserProgress(String email) async {
    final db = await getDatabase();
    final result = await db.query(
      'progress',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return result.first['level'] as int;
    }
    return 1;
  }

  Future<void> updateUserProgress(String email, int level) async {
    final db = await getDatabase();
    await db.update(
      'progress',
      {'level': level},
      where: 'email = ?',
      whereArgs: [email],
    );
  }
}

