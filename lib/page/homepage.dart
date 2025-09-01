import 'package:flutter/material.dart';
import 'package:login_register/page/notesdetail.dart';
import 'package:login_register/page/notespage.dart';
import '../models/note.dart';
import '../services/auth_service.dart';
import '../services/note_service.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    setState(() => _isLoading = true);

    try {
      final userNotes = await NoteService.getAllNotes();
      setState(() {
        notes = userNotes;
        _isLoading = false;
      });
    } catch (e) {
      print('Load notes error: $e');

      setState(() => _isLoading = false);

      // Check if session expired
      if (e.toString().contains('Session expired')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please login again.'),
            backgroundColor: Colors.orange,
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/login');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToNotesForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotesFormPage(),
      ),
    );

    if (result == true) {
      _loadNotes(); // Reload notes
    }
  }

  void _navigateToNoteDetail(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailPage(note: note),
      ),
    );

    if (result == true) {
      _loadNotes(); // Reload notes
    }
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Hi, ${widget.username}!',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'refresh') {
                _loadNotes();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                notes.isEmpty ? _buildEmptyState() : _buildNotesList(),
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A5568),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        onPressed: _navigateToNotesForm,
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/logo.png',
            width: 250,
            height: 250,
          ),
          const SizedBox(height: 12),
          const Text(
            'Start Your Journey',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Every big step start with small step.\nNotes your first idea and start\nyour journey!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomPaint(
            size: const Size(100, 80),
            painter: CurvedArrowPainter(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Notes',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return GestureDetector(
                  onTap: () => _navigateToNoteDetail(note),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.lightbulb,
                                color: Colors.orange,
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                note.title.isEmpty ? 'Untitled' : note.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Text(
                            note.content.isEmpty ? 'No content' : note.content,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              height: 1.4,
                            ),
                            maxLines: 8,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CurvedArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final startX = size.width * 0.5;
    final startY = size.height * 0.1;
    final controlPoint1X = size.width * 0.8;
    final controlPoint1Y = size.height * 0.3;
    final controlPoint2X = size.width * 0.7;
    final controlPoint2Y = size.height * 0.7;
    final endX = size.width * 0.6;
    final endY = size.height * 0.9;

    path.moveTo(startX, startY);
    path.cubicTo(controlPoint1X, controlPoint1Y, controlPoint2X, controlPoint2Y,
        endX, endY);
    canvas.drawPath(path, paint);

    // Arrow head
    const arrowHeadLength = 12.0;
    const arrowHeadAngle = 0.5;
    final dx = endX - controlPoint2X;
    final dy = endY - controlPoint2Y;
    final angle = math.atan2(dy, dx);

    final arrowPoint1X =
        endX - arrowHeadLength * math.cos(angle - arrowHeadAngle);
    final arrowPoint1Y =
        endY - arrowHeadLength * math.sin(angle - arrowHeadAngle);
    final arrowPoint2X =
        endX - arrowHeadLength * math.cos(angle + arrowHeadAngle);
    final arrowPoint2Y =
        endY - arrowHeadLength * math.sin(angle + arrowHeadAngle);

    final arrowPath = Path();
    arrowPath.moveTo(arrowPoint1X, arrowPoint1Y);
    arrowPath.lineTo(endX, endY);
    arrowPath.lineTo(arrowPoint2X, arrowPoint2Y);
    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
