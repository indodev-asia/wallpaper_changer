//wallpaper changer - developed by Antonius (indodev.asia)
import 'dart:async'; // Required for Timer
import 'dart:io';    // Required for Directory and File operations
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p; // Required for path manipulation (e.g., getting basename)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dart Wallpaper Changer', // Title for the application window
      theme: ThemeData(
        primarySwatch: Colors.blue, // Defines the primary color palette
        useMaterial3: true, // Opt-in for Material 3 design
        fontFamily: 'Inter', // Set the Inter font family
      ),
      home: const WallpaperChangerScreen(), // The main screen of the app
    );
  }
}

class WallpaperChangerScreen extends StatefulWidget {
  const WallpaperChangerScreen({super.key});

  @override
  State<WallpaperChangerScreen> createState() => _WallpaperChangerScreenState();
}

class _WallpaperChangerScreenState extends State<WallpaperChangerScreen> {
  final String wallpaperDirPath = '/home/robohax/Desktop/Wallpaper/Car/';
  List<String> wallpaperFiles = [];
  int currentWallpaperIndex = 0;
  String currentWallpaperName = 'Loading wallpapers...';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadWallpapers();
    _startWallpaperChanger();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  Future<void> _loadWallpapers() async {
    try {
      final Directory directory = Directory(wallpaperDirPath);

      if (!await directory.exists()) {
        setState(() {
          currentWallpaperName = 'Error: Wallpaper directory not found!';
        });
        print('Error: Wallpaper directory not found at $wallpaperDirPath');
        return; // Exit if directory doesn't exist
      }

      wallpaperFiles = directory
          .listSync()
          .where((entity) =>
              entity is File &&
              (entity.path.toLowerCase().endsWith('.png') ||
                  entity.path.toLowerCase().endsWith('.jpg') ||
                  entity.path.toLowerCase().endsWith('.jpeg')))
          .map((entity) => entity.path)
          .toList();

      if (wallpaperFiles.isEmpty) {
        setState(() {
          currentWallpaperName = 'No wallpaper files found!';
        });
        print('No wallpaper files found in $wallpaperDirPath');
      } else {
        print('Found ${wallpaperFiles.length} wallpaper files.');
        
        _changeWallpaper();
      }
    } catch (e) {
     
      setState(() {
        currentWallpaperName = 'Error loading wallpapers: $e';
      });
      print('Error loading wallpapers: $e');
    }
  }

  void _startWallpaperChanger() {
    // Timer.periodic creates a repeating timer.
    // Duration(minutes: 5) sets the interval to 5 minutes (300 seconds).
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _changeWallpaper(); // Call the wallpaper changing function
    });
    print('Wallpaper changer started. Changing every 5 minutes.');
  }

  
  Future<void> _changeWallpaper() async {
    if (wallpaperFiles.isEmpty) {
      print('No wallpaper files to change. Please add images to the directory.');
      return;
    }

   
    final String nextWallpaperPath =
        wallpaperFiles[currentWallpaperIndex % wallpaperFiles.length];
    currentWallpaperIndex++; // Increment index for the next cycle

   
    setState(() {
      currentWallpaperName = p.basename(nextWallpaperPath);
    });

    print('Attempting to set wallpaper: $nextWallpaperPath');

    
    try {
      final resultLight = await Process.run(
        'gsettings',
        [
          'set',
          'org.gnome.desktop.background',
          'picture-uri',
          'file://$nextWallpaperPath', // Use file:// URI
        ],
      );
      final resultDark = await Process.run(
        'gsettings',
        [
          'set',
          'org.gnome.desktop.background',
          'picture-uri-dark',
          'file://$nextWallpaperPath', // Use file:// URI
        ],
      );

     if (resultLight.exitCode == 0 && resultDark.exitCode == 0) {
        print('Wallpaper set successfully to: $currentWallpaperName');
      } else {
        print('Error setting wallpaper (light theme): ${resultLight.stderr}');
        print('Error setting wallpaper (dark theme): ${resultDark.stderr}');
        setState(() {
          currentWallpaperName = 'Failed to set: ${p.basename(nextWallpaperPath)}';
        });
      }
    } catch (e) {
      print('Exception while running gsettings command: $e');
      setState(() {
        currentWallpaperName = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dart Wallpaper Changer'),
        centerTitle: true, // Center the app bar title
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          children: <Widget>[
            const Spacer(), // Pushes content towards the center/top
            Text(
              'Current Wallpaper:',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.blueGrey[700], // A slightly darker grey for better contrast
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0), // More padding for the wallpaper name
              child: Text(
                currentWallpaperName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple, // A distinct color for the name
                ),
              ),
            ),
            const Spacer(), // Pushes content towards the center/bottom
            
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0), // Padding from the bottom edge
                child: Text(
                  'dart wallpaper changer - code by Antonius (indodev.asia)',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600], // Slightly darker grey for the signature
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
