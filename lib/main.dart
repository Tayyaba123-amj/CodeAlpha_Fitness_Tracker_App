
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const PulseFitApp());
}

class AppColors {
  static const bg = Color(0xFF0B0B12);
  static const surface = Color(0xFF171722);
  static const card = Color(0xFF20202D);
  static const purple = Color(0xFF9B7BFF);
  static const pink = Color(0xFFFF6FAE);
  static const blue = Color(0xFF62B8FF);
  static const green = Color(0xFF55D6A5);
  static const muted = Color(0xFF9292A5);
  static const white = Colors.white;
}

class PulseFitApp extends StatelessWidget {
  const PulseFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PULSEFIT',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.purple,
          secondary: AppColors.pink,
          surface: AppColors.surface,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  int steps = 6842;
  int calories = 420;
  int water = 4;
  int activeMinutes = 35;

  bool workoutRunning = false;
  bool workoutPaused = false;
  String activeWorkout = 'Morning Walk';

  Uint8List? profileImageBytes;

  final int stepGoal = 10000;
  final int waterGoal = 8;

  final List<Map<String, dynamic>> workouts = [
    {
      'name': 'Morning Walk',
      'subtitle': 'Easy outdoor walking',
      'duration': '20 min',
      'calories': '120 kcal',
      'icon': Icons.directions_walk_rounded,
      'color': AppColors.green,
    },
    {
      'name': 'Running',
      'subtitle': 'Improve your stamina',
      'duration': '30 min',
      'calories': '250 kcal',
      'icon': Icons.directions_run_rounded,
      'color': AppColors.pink,
    },
    {
      'name': 'Cycling',
      'subtitle': 'Build your endurance',
      'duration': '25 min',
      'calories': '180 kcal',
      'icon': Icons.directions_bike_rounded,
      'color': AppColors.blue,
    },
    {
      'name': 'Yoga',
      'subtitle': 'Relax your mind and body',
      'duration': '15 min',
      'calories': '90 kcal',
      'icon': Icons.self_improvement_rounded,
      'color': AppColors.purple,
    },
    {
      'name': 'Strength Training',
      'subtitle': 'Build your strength',
      'duration': '35 min',
      'calories': '220 kcal',
      'icon': Icons.fitness_center_rounded,
      'color': Colors.orangeAccent,
    },
  ];

  final List<double> weeklyData = [
    0.35, 0.65, 0.45, 0.85, 0.55, 0.95, 0.70
  ];

  final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  bool get isDesktop => MediaQuery.of(context).size.width > 900;

  double get pageWidth =>
      MediaQuery.of(context).size.width > 1100 ? 1100 : double.infinity;

  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 600,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        profileImageBytes = bytes;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated successfully!'),
          backgroundColor: AppColors.purple,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to select image: $e')),
      );
    }
  }

  void startWorkout(String name) {
    setState(() {
      activeWorkout = name;
      workoutRunning = true;
      workoutPaused = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name started! Keep going!'),
        backgroundColor: AppColors.purple,
      ),
    );
  }

  void toggleWorkout() {
    setState(() {
      workoutPaused = !workoutPaused;
    });
  }

  void finishWorkout() {
    setState(() {
      workoutRunning = false;
      workoutPaused = false;
      calories += 100;
      activeMinutes += 20;
      steps += 500;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Workout completed! Great job!'),
        backgroundColor: AppColors.green,
      ),
    );
  }

  Widget pageContainer(Widget child) {
    return Center(
      child: SizedBox(
        width: pageWidth,
        child: child,
      ),
    );
  }

  Widget buildHeader(String greeting, String subtitle) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.card,
          backgroundImage: profileImageBytes != null
              ? MemoryImage(profileImageBytes!)
              : null,
          child: profileImageBytes == null
              ? const Icon(Icons.person, color: AppColors.purple)
              : null,
        ),
      ],
    );
  }

  Widget sectionTitle(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              selectedIndex = 1;
            });
          },
          child: Text(
            action,
            style: const TextStyle(color: AppColors.purple),
          ),
        ),
      ],
    );
  }

  Widget dashboardCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const Spacer(),
              Icon(
                Icons.trending_up_rounded,
                color: color,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget homePage() {
    final stepProgress = (steps / stepGoal).clamp(0.0, 1.0);

    return pageContainer(
      SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader('WELCOME BACK 👋', 'Let’s get moving!'),
            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7655D9), Color(0xFFB15CBA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOUR DAILY ACTIVITY',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.5,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$steps',
                              style: const TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Steps today',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              '${(stepProgress * 100).round()}% of daily goal',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 105,
                        width: 105,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 100,
                              width: 100,
                              child: CircularProgressIndicator(
                                value: stepProgress,
                                strokeWidth: 9,
                                backgroundColor: Colors.white24,
                                valueColor:
                                    const AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                            const Icon(
                              Icons.directions_walk_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Every step takes you closer to your goal!',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            sectionTitle('Today’s Overview', 'Workouts'),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isDesktop ? 2.2 : 1.28,
              children: [
                dashboardCard(
                  title: 'Calories Burned',
                  value: '$calories',
                  unit: 'kcal',
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.pink,
                  progress: calories / 600,
                ),
                dashboardCard(
                  title: 'Distance',
                  value: (steps * 0.00075).toStringAsFixed(2),
                  unit: 'km',
                  icon: Icons.location_on_rounded,
                  color: AppColors.blue,
                  progress: steps / stepGoal,
                ),
                dashboardCard(
                  title: 'Active Time',
                  value: '$activeMinutes',
                  unit: 'minutes',
                  icon: Icons.timer_rounded,
                  color: AppColors.green,
                  progress: activeMinutes / 60,
                ),
                dashboardCard(
                  title: 'Water Intake',
                  value: '$water',
                  unit: 'glasses',
                  icon: Icons.water_drop_rounded,
                  color: AppColors.purple,
                  progress: water / waterGoal,
                ),
              ],
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.water_drop_rounded, color: AppColors.blue),
                      SizedBox(width: 10),
                      Text(
                        'Water Tracker',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Daily goal: 8',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: List.generate(8, (index) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Icon(
                            Icons.water_drop_rounded,
                            size: 27,
                            color: index < water
                                ? AppColors.blue
                                : Colors.white12,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '$water / 8 glasses',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (water > 0) water--;
                          });
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (water < waterGoal) water++;
                          });
                        },
                        color: AppColors.blue,
                        icon: const Icon(Icons.add_circle),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            sectionTitle('Quick Start', 'Explore'),

            Row(
              children: [
                Expanded(
                  child: quickButton(
                    'Walking',
                    Icons.directions_walk_rounded,
                    AppColors.green,
                    () => startWorkout('Walking'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: quickButton(
                    'Running',
                    Icons.directions_run_rounded,
                    AppColors.pink,
                    () => startWorkout('Running'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [
                    AppColors.purple.withOpacity(0.20),
                    AppColors.pink.withOpacity(0.08),
                  ],
                ),
                border: Border.all(
                  color: AppColors.purple.withOpacity(0.2),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    color: AppColors.purple,
                    size: 30,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your only limit is the one you set yourself.',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Stay consistent. Stay strong. Keep going.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget quickButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget workoutsPage() {
    return pageContainer(
      SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader('YOUR FITNESS PLAN', 'Choose your workout'),
            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4C3A88), Color(0xFF8B4C9D)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'READY TO CHALLENGE YOURSELF?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    workoutRunning
                        ? '$activeWorkout is ${workoutPaused ? "paused" : "in progress"}'
                        : 'Start a new workout and make today count!',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if (workoutRunning) ...[
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: toggleWorkout,
                            icon: Icon(
                              workoutPaused
                                  ? Icons.play_arrow
                                  : Icons.pause,
                            ),
                            label: Text(
                              workoutPaused ? 'Resume' : 'Pause',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: finishWorkout,
                            icon: const Icon(Icons.check),
                            label: const Text('Finish'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 25),
            const Text(
              'Available Workouts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            ...workouts.map((item) {
              final Color color = item['color'] as Color;

              return Container(
                margin: const EdgeInsets.only(bottom: 13),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: color,
                        size: 29,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item['subtitle'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            '${item['duration']}  •  ${item['calories']}',
                            style: TextStyle(color: color, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        startWorkout(item['name'] as String);
                      },
                      icon: const Icon(
                        Icons.play_circle_fill_rounded,
                        color: AppColors.purple,
                        size: 35,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget progressPage() {
    return pageContainer(
      SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader('YOUR JOURNEY', 'Track your progress'),
            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Your activity level this week',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 190,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: WeeklyChartPainter(weeklyData, days),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            const Text(
              'Your Achievements',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isDesktop ? 2.2 : 1.35,
              children: [
                achievementCard(
                  Icons.directions_walk,
                  'Step Starter',
                  'Start your journey',
                  AppColors.green,
                ),
                achievementCard(
                  Icons.local_fire_department,
                  'Burn Master',
                  'Burn calories daily',
                  AppColors.pink,
                ),
                achievementCard(
                  Icons.water_drop,
                  'Hydration Hero',
                  'Stay hydrated',
                  AppColors.blue,
                ),
                achievementCard(
                  Icons.emoji_events,
                  'Consistency',
                  'Keep showing up',
                  AppColors.purple,
                ),
              ],
            ),

            const SizedBox(height: 22),
            const Text(
              'Activity Summary',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            summaryRow(
              'Total Steps',
              '$steps steps',
              Icons.directions_walk,
            ),
            summaryRow(
              'Calories Burned',
              '$calories kcal',
              Icons.local_fire_department,
            ),
            summaryRow(
              'Active Minutes',
              '$activeMinutes min',
              Icons.timer,
            ),
            summaryRow(
              'Water Intake',
              '$water glasses',
              Icons.water_drop,
            ),
          ],
        ),
      ),
    );
  }

  Widget achievementCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget summaryRow(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.purple),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget profilePage() {
    return pageContainer(
      SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          children: [
            buildHeader('YOUR ACCOUNT', 'Personal profile'),
            const SizedBox(height: 30),

            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  height: 125,
                  width: 125,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.purple, AppColors.pink],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withOpacity(0.35),
                        blurRadius: 25,
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.purple,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: profileImageBytes != null
                        ? Image.memory(
                            profileImageBytes!,
                            fit: BoxFit.cover,
                            width: 125,
                            height: 125,
                          )
                        : const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 70,
                          ),
                  ),
                ),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.pink,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.bg,
                      width: 3,
                    ),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: pickProfileImage,
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
            const Text(
              'Fitness Lover',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Your fitness journey starts here',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: pickProfileImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Change Profile Picture'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.purple,
                side: const BorderSide(color: AppColors.purple),
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ProfileStat(value: '7', label: 'Day Streak'),
                  ProfileStat(value: '12', label: 'Workouts'),
                  ProfileStat(value: '85%', label: 'Consistency'),
                ],
              ),
            ),

            const SizedBox(height: 25),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            settingsTile(
              Icons.person_outline,
              'Personal Information',
              'Manage your profile',
              () => showInfo('Personal Information'),
            ),
            settingsTile(
              Icons.notifications_none_rounded,
              'Notifications',
              'Activity reminders',
              () => showInfo('Notifications'),
            ),
            settingsTile(
              Icons.flag_outlined,
              'Daily Goals',
              'Your fitness targets',
              () => showInfo('Daily Goals'),
            ),
            settingsTile(
              Icons.palette_outlined,
              'App Appearance',
              'Dark theme',
              () => showInfo('App Appearance'),
            ),
            settingsTile(
              Icons.help_outline_rounded,
              'Help & Support',
              'Get assistance',
              () => showInfo('Help & Support'),
            ),
            settingsTile(
              Icons.info_outline_rounded,
              'About PULSEFIT',
              'Version 1.0.0',
              () => showInfo(
                'PULSEFIT - Your personal fitness companion.',
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'STAY STRONG. STAY CONSISTENT. 💜',
              style: TextStyle(
                color: AppColors.purple,
                letterSpacing: 1.2,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget settingsTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.purple),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 11,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
          color: AppColors.muted,
        ),
      ),
    );
  }

  void showInfo(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('PULSEFIT'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.purple),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      homePage(),
      workoutsPage(),
      progressPage(),
      profilePage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          backgroundColor: AppColors.surface,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.purple,
          unselectedItemColor: AppColors.muted,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_rounded),
              label: 'Workouts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const ProfileStat({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.purple,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class WeeklyChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;

  WeeklyChartPainter(this.values, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    final chartHeight = size.height - 30;
    final chartWidth = size.width;

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = chartHeight * i / 3;
      canvas.drawLine(
        Offset(0, y),
        Offset(chartWidth, y),
        gridPaint,
      );
    }

    final barWidth = chartWidth / (values.length * 1.8);

    for (int i = 0; i < values.length; i++) {
      final x = (i * chartWidth / values.length) +
          (chartWidth / values.length - barWidth) / 2;

      final barHeight = values[i] * (chartHeight - 10);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          chartHeight - barHeight,
          barWidth,
          barHeight,
        ),
        const Radius.circular(8),
      );

      final barPaint = Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.purple, AppColors.pink],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).createShader(
          Rect.fromLTWH(
            x,
            chartHeight - barHeight,
            barWidth,
            barHeight,
          ),
        );

      canvas.drawRRect(rect, barPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 11,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x + barWidth / 2 - textPainter.width / 2,
          chartHeight + 10,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WeeklyChartPainter oldDelegate) {
    return !listEquals(values, oldDelegate.values) ||
        !listEquals(labels, oldDelegate.labels);
  }
}
