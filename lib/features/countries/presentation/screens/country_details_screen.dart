import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/entities/coordinates.dart';
import '../../../../core/widgets/flag_image.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../map/presentation/location_map.dart';
import '../../../weather/presentation/cubit/weather_cubit.dart';
import '../../../weather/presentation/widgets/weather_card.dart';
import '../../domain/entities/country.dart';
import '../cubit/country_details_cubit.dart';

class CountryDetailsScreen extends StatelessWidget {
  const CountryDetailsScreen({super.key, required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<CountryDetailsCubit>(param1: country)..load(),
        ),
        BlocProvider(
          create: (_) {
            final cubit = getIt<WeatherCubit>();
            final point = country.coordinates;
            if (point != null) cubit.load(point);
            return cubit;
          },
        ),
      ],
      child: _CountryDetailsView(country: country),
    );
  }
}

class _CountryDetailsView extends StatelessWidget {
  const _CountryDetailsView({required this.country});

  final Country country;

  String _formatPopulation(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  String _pinnedLabel(Coordinates pinned) {
    if (pinned == country.coordinates) {
      return country.capital.isEmpty ? country.name : country.capital;
    }
    return 'Pinned location · ${pinned.latitude.toStringAsFixed(2)}, '
        '${pinned.longitude.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CountryDetailsCubit, CountryDetailsState>(
          listenWhen: (previous, current) =>
              previous.pinnedPoint != current.pinnedPoint,
          listener: (context, state) {
            final point = state.pinnedPoint;
            if (point != null) context.read<WeatherCubit>().load(point);
          },
        ),
        BlocListener<CountryDetailsCubit, CountryDetailsState>(
          listenWhen: (previous, current) =>
              previous.isFavorite != current.isFavorite,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.isFavorite
                        ? 'Added to favorites'
                        : 'Removed from favorites',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(country.name),
          actions: [
            BlocBuilder<CountryDetailsCubit, CountryDetailsState>(
              buildWhen: (previous, current) =>
                  previous.isFavorite != current.isFavorite,
              builder: (context, state) => IconButton(
                tooltip: state.isFavorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
                onPressed: context.read<CountryDetailsCubit>().toggleFavorite,
                icon: Icon(
                  state.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: state.isFavorite ? Colors.red : null,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  _buildInfoCard(context),
                  const SizedBox(height: 16),
                  _buildLocation(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        FlagImage(code: country.code, width: 168, height: 112),
        const SizedBox(height: 16),
        Text(
          country.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Chip(
          avatar: const Icon(Icons.public, size: 18),
          label: Text(country.region),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final coordinates = country.coordinates;

    return BlocBuilder<CountryDetailsCubit, CountryDetailsState>(
      buildWhen: (previous, current) =>
          previous.infoStatus != current.infoStatus ||
          previous.details != current.details,
      builder: (context, state) {
        String infoValue(String? value) {
          if (state.infoStatus == InfoStatus.loading) return 'Loading...';
          if (state.infoStatus == InfoStatus.failure) return '-';
          return value ?? 'Not available';
        }

        final population = state.details?.population;

        return SectionCard(
          title: 'Overview',
          icon: Icons.info_outline,
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.location_city,
                label: 'Capital',
                value: country.capital.isEmpty
                    ? 'Not available'
                    : country.capital,
              ),
              _InfoRow(
                icon: Icons.public,
                label: 'Region',
                value: country.region,
              ),
              _InfoRow(
                icon: Icons.groups_outlined,
                label: 'Population',
                value: infoValue(
                  population == null ? null : _formatPopulation(population),
                ),
              ),
              _InfoRow(
                icon: Icons.payments_outlined,
                label: 'Currency',
                value: infoValue(state.details?.currency),
              ),
              _InfoRow(
                icon: Icons.north,
                label: 'Latitude',
                value:
                    coordinates?.latitude.toStringAsFixed(4) ?? 'Not available',
              ),
              _InfoRow(
                icon: Icons.east,
                label: 'Longitude',
                value:
                    coordinates?.longitude.toStringAsFixed(4) ??
                    'Not available',
              ),
              if (state.infoStatus == InfoStatus.failure) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.errorMessage ?? '')),
                    TextButton(
                      onPressed: context.read<CountryDetailsCubit>().load,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocation(BuildContext context) {
    final countryPoint = country.coordinates;

    if (countryPoint == null) {
      return const SectionCard(
        title: 'Weather & map',
        icon: Icons.location_off_outlined,
        child: Text('Location is not available for this country.'),
      );
    }

    return BlocBuilder<CountryDetailsCubit, CountryDetailsState>(
      buildWhen: (previous, current) =>
          previous.pinnedPoint != current.pinnedPoint,
      builder: (context, state) {
        final pinned = state.pinnedPoint ?? countryPoint;

        return Column(
          children: [
            LocationMap(
              countryPoint: countryPoint,
              pinnedPoint: pinned,
              onPinMoved: context.read<CountryDetailsCubit>().pinTo,
            ),
            const SizedBox(height: 16),
            WeatherCard(locationLabel: _pinnedLabel(pinned)),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
