
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

// APPLICATION COLOURS
const Color navy = Color(0xFF142D52);
const Color pink = Color(0xFFFF4F99);
const Color softPink = Color(0xFFFFE8F1);
const Color darkPink = Color(0xFFE63E82);

// MAIN APPLICATION
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SKYFARE Baggage Fee Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: navy),
        scaffoldBackgroundColor: const Color(0xFFF5F8FD),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

// NAVIGATION DRAWER
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void navigateTo(BuildContext context, Widget page) {
    Navigator.pop(context);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: navy),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.flight_takeoff,
                  color: Colors.white,
                  size: 42,
                ),
                SizedBox(height: 14),
                Text(
                  'SKYFARE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Baggage Fee Calculator',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              navigateTo(context, const WelcomePage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('Calculator'),
            onTap: () {
              navigateTo(context, const CalculatorPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              navigateTo(context, const AboutPage());
            },
          ),
        ],
      ),
    );
  }
}

// WELCOME PAGE
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Welcome to SKYFARE'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.flight_takeoff,
                    color: navy,
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'SKYFARE',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Travel lighter, worry less.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  Image.asset(
                    'assets/images/luggage.png',
                    height: 275,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) {
                      return const Icon(
                        Icons.luggage,
                        size: 180,
                        color: pink,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Estimate your excess baggage fee before you fly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CalculatorPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Get Started'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AboutPage(),
                        ),
                      );
                    },
                    child: const Text('About this app'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// CALCULATOR PAGE
class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() =>
      _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController weightController =
      TextEditingController();

  final TextEditingController rateController =
      TextEditingController();

  String ticketClass = 'Economy';

  double? excessWeight;
  double? excessCharge;
  double? serviceTax;
  double? totalPayable;

  // NOTIFICATION MANAGEMENT
  OverlayEntry? _notificationEntry;
  Timer? _notificationTimer;

  @override
  void dispose() {
    _removeNotification();
    weightController.dispose();
    rateController.dispose();
    super.dispose();
  }

  // REMOVE PREVIOUS NOTIFICATION
  void _removeNotification() {
    _notificationTimer?.cancel();
    _notificationTimer = null;

    _notificationEntry?.remove();
    _notificationEntry?.dispose();
    _notificationEntry = null;
  }

  // VALIDATE NUMERIC INPUT
  String? validateNumber(String input, String fieldName) {
    final value = input.trim();

    if (value.isEmpty) {
      return 'Please complete all required fields.';
    }

    // Only digits with one optional decimal point.
    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
      if (fieldName == 'baggage weight') {
        return 'Please enter a valid baggage weight.';
      }

      return 'Please enter a valid baggage rate.';
    }

    final number = double.tryParse(value);

    if (number == null || !number.isFinite) {
      return 'Please enter a smaller value.';
    }

    return null;
  }

  // FLOATING TOP NOTIFICATION
  void showTopNotification(String message) {
    FocusScope.of(context).unfocus();

    // Remove old notification before displaying a new one.
    _removeNotification();

    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder: (overlayContext) {
        final topPadding =
            MediaQuery.of(overlayContext).padding.top;

        return Positioned(
          top: topPadding + 12,
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: softPink,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFC7DC),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.12,
                        ),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: darkPink,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: navy,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    _notificationEntry = entry;
    overlay.insert(entry);

    // Automatically disappear after 3 seconds.
    _notificationTimer = Timer(
      const Duration(seconds: 3),
      () {
        _removeNotification();
      },
    );
  }

  // CLEAR PREVIOUS CALCULATION
  void clearResult() {
    excessWeight = null;
    excessCharge = null;
    serviceTax = null;
    totalPayable = null;
  }

  // CALCULATE BAGGAGE FEE
  void calculateFee() {
    FocusScope.of(context).unfocus();

    // CHECK EMPTY FIELDS
    if (weightController.text.trim().isEmpty ||
        rateController.text.trim().isEmpty) {
      setState(() {
        clearResult();
      });

      showTopNotification(
        'Please complete all required fields.',
      );
      return;
    }

    // VALIDATE BAGGAGE WEIGHT
    final weightError = validateNumber(
      weightController.text,
      'baggage weight',
    );

    if (weightError != null) {
      setState(() {
        clearResult();
      });

      showTopNotification(weightError);
      return;
    }

    // VALIDATE BAGGAGE RATE
    final rateError = validateNumber(
      rateController.text,
      'excess baggage rate',
    );

    if (rateError != null) {
      setState(() {
        clearResult();
      });

      showTopNotification(rateError);
      return;
    }

    final double weight =
        double.parse(weightController.text.trim());

    final double rate =
        double.parse(rateController.text.trim());

    // BAGGAGE ALLOWANCE
    double allowance;

    if (ticketClass == 'Economy') {
      allowance = 20.0;
    } else {
      allowance = 40.0;
    }

    // EXCESS BAGGAGE
    double excess = weight - allowance;

    if (excess < 0) {
      excess = 0;
    }

    // CHARGES AND TAX
    final double charge = excess * rate;
    final double tax = charge * 0.08;
    final double total = charge + tax;

    if (!excess.isFinite ||
        !charge.isFinite ||
        !tax.isFinite ||
        !total.isFinite) {
      setState(() {
        clearResult();
      });

      showTopNotification(
        'Please enter smaller values.',
      );
      return;
    }

    // Remove error notification after successful calculation.
    _removeNotification();

    setState(() {
      excessWeight = excess;
      excessCharge = charge;
      serviceTax = tax;
      totalPayable = total;
    });
  }

  // RESET FORM
  void resetForm() {
    FocusScope.of(context).unfocus();

    _removeNotification();

    weightController.clear();
    rateController.clear();

    setState(() {
      ticketClass = 'Economy';
      clearResult();
    });
  }

  // RESULT ROW
  Widget resultRow(
    String label,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight:
                    bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: bold ? navy : Colors.black87,
              fontSize: bold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  // RADIO BUTTON TICKET CLASS
  Widget ticketClassSelector() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                left: 8,
                top: 6,
                bottom: 8,
              ),
              child: Text(
                'Ticket Class',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
            ),
            RadioGroup<String>(
              groupValue: ticketClass,
              onChanged: (value) {
                if (value != null) {
                  _removeNotification();

                  setState(() {
                    ticketClass = value;
                    clearResult();
                  });
                }
              },
              child: const Column(
                children: [
                  RadioListTile<String>(
                    title: Text('Economy Class'),
                    subtitle: Text(
                      'Free baggage allowance: 20 kg',
                    ),
                    value: 'Economy',
                    activeColor: navy,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    title: Text('Business Class'),
                    subtitle: Text(
                      'Free baggage allowance: 40 kg',
                    ),
                    value: 'Business',
                    activeColor: navy,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Baggage Fee Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HEADER
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: navy,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/luggage.png',
                          width: 90,
                          height: 90,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stack) {
                            return const Icon(
                              Icons.luggage,
                              color: pink,
                              size: 70,
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Travel lighter, worry less.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Estimate your baggage charges instantly.',
                                style: TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Your baggage details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Enter your details and tap Calculate Fee.',
                  ),

                  const SizedBox(height: 20),

                  // BAGGAGE WEIGHT
                  TextField(
                    controller: weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Checked baggage weight (kg)',
                      hintText: 'e.g. 25.5',
                      helperText: 'Enter a non-negative number.',
                      prefixIcon: Icon(Icons.luggage),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // RADIO BUTTONS FOR TICKET CLASS
                  ticketClassSelector(),

                  const SizedBox(height: 16),

                  // EXCESS BAGGAGE RATE
                  TextField(
                    controller: rateController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Excess baggage rate (RM/kg)',
                      hintText: 'e.g. 12.50',
                      helperText: 'Enter a non-negative rate.',
                      prefixIcon:
                          Icon(Icons.payments_outlined),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // CALCULATE BUTTON
                  SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: calculateFee,
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text('Calculate Fee'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // RESET BUTTON
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: resetForm,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CALCULATION RESULT
                  if (totalPayable != null &&
                      excessWeight != null &&
                      excessCharge != null &&
                      serviceTax != null)
                    Card(
                      color: const Color(0xFFF0F2F9),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Calculation Result',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: navy,
                              ),
                            ),
                            const SizedBox(height: 16),
                            resultRow(
                              'Excess baggage weight',
                              '${excessWeight?.toStringAsFixed(2)} kg',
                            ),
                            resultRow(
                              'Excess baggage charge',
                              'RM ${excessCharge?.toStringAsFixed(2)}',
                            ),
                            resultRow(
                              'Service tax (8%)',
                              'RM ${serviceTax?.toStringAsFixed(2)}',
                            ),
                            const Divider(height: 28),
                            resultRow(
                              'Total payable',
                              'RM ${totalPayable?.toStringAsFixed(2)}',
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 35),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ABOUT PAGE
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static final Uri repo = Uri.parse(
    'https://github.com/naleyaah/baggage-fee-calculator',
  );

  Future<void> openRepo(BuildContext context) async {
    try {
      final opened = await launchUrl(
        repo,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open GitHub URL.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open GitHub. Check your connection.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('About SKYFARE'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/luggage.png',
                      height: 130,
                      errorBuilder: (context, error, stack) {
                        return const Icon(
                          Icons.luggage,
                          size: 100,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'SKYFARE',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Baggage Fee Calculator',
                      textAlign: TextAlign.center,
                    ),
                    const Divider(height: 35),
                    const ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text('Author'),
                      subtitle: Text('Nur Aleeya Hanis'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.badge_outlined),
                      title: Text('Matric Number'),
                      subtitle: Text('2025237172'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.school_outlined),
                      title: Text('Course'),
                      subtitle: Text(
                        'ICT602 - Mobile Technology Development',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextButton.icon(
                      onPressed: () => openRepo(context),
                      icon: const Icon(Icons.link),
                      label:
                          const Text('Open GitHub Repository'),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '© 2026 Nur Aleeya Hanis. All rights reserved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
