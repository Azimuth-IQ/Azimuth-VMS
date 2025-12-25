import 'package:flutter/material.dart';
import '../AdminScreens/PresenceCheckScreen.dart';

// Team Leader Presence Check Screen
// This extends the admin screen but filters to only show events
// where the current user is a team leader
class TeamLeaderPresenceCheckScreen extends StatelessWidget {
  const TeamLeaderPresenceCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reuses the same PresenceCheckScreen component
    // The filtering logic is already built into the screen
    // based on presence check permissions from the Event model
    return const PresenceCheckScreen();
  }
}
