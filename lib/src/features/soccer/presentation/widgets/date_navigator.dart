import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubit/soccer_cubit.dart';
import '../cubit/soccer_state.dart';

class DateNavigator extends StatelessWidget {
  const DateNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SoccerCubit, SoccerStates>(
      buildWhen: (_, state) {
        return state is SoccerTodayFixturesLoading ||
            state is SoccerTodayFixturesLoaded ||
            state is SoccerTodayFixturesLoadFailure;
      },
      builder: (context, state) {
        final cubit = context.read<SoccerCubit>();
        final selectedDate = cubit.selectedDate;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left arrow
              _ArrowButton(
                icon: Icons.chevron_left_rounded,
                onTap: cubit.goToPreviousDay,
                theme: theme,
              ),
              const SizedBox(width: 12),
              // Date label
              _DateLabel(date: selectedDate, theme: theme),
              const SizedBox(width: 12),
              // Right arrow
              _ArrowButton(
                icon: Icons.chevron_right_rounded,
                onTap: cubit.goToNextDay,
                theme: theme,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ArrowButton({
    required this.icon,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _DateLabel extends StatelessWidget {
  final DateTime date;
  final ThemeData theme;

  const _DateLabel({required this.date, required this.theme});

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isYesterday(DateTime d) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return d.year == yesterday.year &&
        d.month == yesterday.month &&
        d.day == yesterday.day;
  }

  bool _isTomorrow(DateTime d) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return d.year == tomorrow.year &&
        d.month == tomorrow.month &&
        d.day == tomorrow.day;
  }

  String _formatDate(DateTime d) {
    if (_isToday(d)) {
      return 'Today, ${DateFormat('MMM d').format(d)}';
    } else if (_isYesterday(d)) {
      return 'Yesterday, ${DateFormat('MMM d').format(d)}';
    } else if (_isTomorrow(d)) {
      return 'Tomorrow, ${DateFormat('MMM d').format(d)}';
    }
    return DateFormat('EEE, MMM d').format(d);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(date),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(date),
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
