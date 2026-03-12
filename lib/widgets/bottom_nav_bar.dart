import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: Semantics(label: 'Home Tab', child: const Icon(Icons.home)),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.book_outlined),
          activeIcon: Semantics(label: 'Courses Tab', child: const Icon(Icons.book)),
          label: 'Courses',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.quiz_outlined),
          activeIcon: Semantics(label: 'Quizzes Tab', child: const Icon(Icons.quiz)),
          label: 'Quizzes',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat_outlined),
          activeIcon: Semantics(label: 'Chat Tab', child: const Icon(Icons.chat)),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outlined),
          activeIcon: Semantics(label: 'Profile Tab', child: const Icon(Icons.person)),
          label: 'Profile',
        ),
      ],
    );
  }
}
