import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artillery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ArtilleryCalculator(),
    );
  }
}

class ArtilleryCalculator extends StatefulWidget {
  const ArtilleryCalculator({super.key});
  @override
  ArtilleryCalculatorState createState() => ArtilleryCalculatorState();
}

class ArtilleryCalculatorState extends State<ArtilleryCalculator> {
  final TextEditingController targetDistanceController =
      TextEditingController();
  final TextEditingController targetAngleController = TextEditingController();
  final TextEditingController artyDistanceController = TextEditingController();
  final TextEditingController artyAngleController = TextEditingController();

  double? artyTargetDistance;
  double? artyToTargetAzimuth;

  @override
  void initState() {
    super.initState();
    // Add listeners to update results in real-time
    targetDistanceController.addListener(updateResults);
    targetAngleController.addListener(updateResults);
    artyDistanceController.addListener(updateResults);
    artyAngleController.addListener(updateResults);
  }

  @override
  void dispose() {
    targetDistanceController.dispose();
    targetAngleController.dispose();
    artyDistanceController.dispose();
    artyAngleController.dispose();
    super.dispose();
  }

  void updateResults() {
    // Parse input values
    double? targetDistance = double.tryParse(targetDistanceController.text);
    double? targetAngle = double.tryParse(targetAngleController.text);
    double? artyDistance = double.tryParse(artyDistanceController.text);
    double? artyAngle = double.tryParse(artyAngleController.text);

    // Check if all inputs are valid
    if (targetDistance != null &&
        targetAngle != null &&
        artyDistance != null &&
        artyAngle != null) {
      // Call the spott function
      spott(targetDistance, targetAngle, artyDistance, artyAngle);
    } else {
      // Clear results if inputs are invalid
      setState(() {
        artyTargetDistance = null;
        artyToTargetAzimuth = null;
      });
    }
  }

  void spott(double targetDistance, double targetAngle, double artyDistance,
      double artyAngle) {
    double A = angleBetweenAzimuths(targetAngle, artyAngle);
    double distance = aDistance(targetDistance, artyDistance, A);
    double B = bAngle(distance, A, targetDistance);
    double artyAngleReciprocal = inverseAzimuth(artyAngle);
    double azimuth =
        calculateArtyToTargetAzimuth(artyAngleReciprocal, B, targetAngle);

    setState(() {
      artyTargetDistance = distance;
      artyToTargetAzimuth = azimuth;
    });
  }

  double aDistance(double b, double c, double A) {
    return sqrt(-2 * b * c * cos(radians(A)) + pow(b, 2) + pow(c, 2));
  }

  double angleBetweenAzimuths(double az1, double az2) {
    return min((az1 - az2).abs(), 360 - (az1 - az2).abs());
  }

  double bAngle(double artyTargetDistance, double A, double targetDistance) {
    return degrees(asin(targetDistance * sin(radians(A)) / artyTargetDistance));
  }

  double inverseAzimuth(double azimuth) {
    return (azimuth + 180) % 360;
  }

  double calculateArtyToTargetAzimuth(
      double artyAngleReciprocal, double B, double targetAngle) {
    if (isClockwise(artyAngleReciprocal, targetAngle)) {
      return (artyAngleReciprocal + B) % 360;
    } else {
      return (artyAngleReciprocal - B) % 360;
    }
  }

  bool isClockwise(double a, double b) {
    double clockwiseDiff = (b - a + 360) % 360;
    return clockwiseDiff < 180;
  }

  double radians(double degrees) {
    return degrees * pi / 180;
  }

  double degrees(double radians) {
    return radians * 180 / pi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artillery Calculator Spotter Used As Reference'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input fields
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text('Target'),
                        TextField(
                          controller: targetDistanceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Distance (m)',
                          ),
                        ),
                        TextField(
                          controller: targetAngleController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Angle (°)',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text('Artillery'),
                        TextField(
                          controller: artyDistanceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Distance (m)',
                          ),
                        ),
                        TextField(
                          controller: artyAngleController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Angle (°)',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Results
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Results',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Artillery to Target Distance: ${artyTargetDistance?.toStringAsFixed(2) ?? "N/A"}m',
                  ),
                  Text(
                    'Artillery to Target Azimuth: ${artyToTargetAzimuth?.toStringAsFixed(2) ?? "N/A"}°',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
