import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/section_card.dart';
import '../cubit/weather_cubit.dart';
import 'weather_condition_ui.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key, required this.locationLabel});

  final String locationLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      title: 'Current weather',
      icon: Icons.thermostat,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.place_outlined,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  locationLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlocBuilder<WeatherCubit, WeatherState>(
            builder: (context, state) => _buildContent(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WeatherState state) {
    final theme = Theme.of(context);
    final isLoading = state.status == WeatherStatus.loading;
    final weather = state.weather;

    if (isLoading && weather == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == WeatherStatus.failure || weather == null) {
      return Row(
        children: [
          Icon(Icons.cloud_off, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(state.errorMessage ?? 'Could not load weather.'),
          ),
          TextButton(
            onPressed: context.read<WeatherCubit>().retry,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    final temperature = weather.temperature;
    final humidity = weather.humidity;
    final windSpeed = weather.windSpeed;
    final updatedAt = state.updatedAt;

    final content = Column(
      children: [
        Row(
          children: [
            Icon(
              weather.condition.icon,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  temperature == null ? '--' : '${temperature.round()}°C',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  weather.condition.label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _WeatherStat(
                icon: Icons.water_drop_outlined,
                label: 'Humidity',
                value: humidity == null ? '--' : '$humidity%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WeatherStat(
                icon: Icons.air,
                label: 'Wind',
                value: windSpeed == null ? '--' : '$windSpeed km/h',
              ),
            ),
          ],
        ),
        if (updatedAt != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                state.isOutdated ? Icons.cloud_off : Icons.schedule,
                size: 16,
                color: state.isOutdated
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  state.isOutdated
                      ? "Couldn't refresh · from ${timeAgo(updatedAt)}"
                      : 'Updated ${timeAgo(updatedAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: state.isOutdated
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (state.isOutdated)
                TextButton(
                  onPressed: context.read<WeatherCubit>().retry,
                  child: const Text('Retry'),
                ),
            ],
          ),
        ],
      ],
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: isLoading ? 0.3 : 1, child: content),
        if (isLoading) const CircularProgressIndicator(),
      ],
    );
  }
}

class _WeatherStat extends StatelessWidget {
  const _WeatherStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelMedium),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
