import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../auth/presentation/screens/account_screen.dart';
import '../../domain/entities/country.dart';
import '../cubit/countries_cubit.dart';
import '../cubit/countries_state.dart';
import '../widgets/country_tile.dart';
import 'country_details_screen.dart';

class CountriesScreen extends StatelessWidget {
  const CountriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CountriesCubit>()..load(),
      child: const _CountriesView(),
    );
  }
}

class _CountriesView extends StatefulWidget {
  const _CountriesView();

  @override
  State<_CountriesView> createState() => _CountriesViewState();
}

class _CountriesViewState extends State<_CountriesView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String value) {
    _searchController.text = value;
    context.read<CountriesCubit>().search(value);
  }

  void _openCountry(Country country) {
    final cubit = context.read<CountriesCubit>();
    cubit.openCountry(country);
    FocusScope.of(context).unfocus();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CountryDetailsScreen(country: country)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries'),
        actions: [
          BlocBuilder<CountriesCubit, CountriesState>(
            builder: (context, state) {
              final isOn = state is CountriesLoaded && state.showFavoritesOnly;

              return IconButton(
                tooltip: isOn ? 'Show all' : 'Show favorites',
                onPressed: context.read<CountriesCubit>().toggleFavoritesOnly,
                icon: Icon(
                  isOn ? Icons.favorite : Icons.favorite_border,
                  color: isOn ? Colors.red : null,
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Account',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AccountScreen())),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: BlocBuilder<CountriesCubit, CountriesState>(
              builder: (context, state) {
                final loaded = state is CountriesLoaded ? state : null;

                return Column(
                  children: [
                    _buildSearchBar(loaded),
                    if (loaded != null &&
                        loaded.query.isEmpty &&
                        loaded.recentSearches.isNotEmpty)
                      _buildRecentSearches(loaded.recentSearches),
                    if (loaded?.offlineSavedAt != null)
                      _buildOfflineBanner(loaded!.offlineSavedAt!),
                    Expanded(child: _buildBody(state)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(CountriesLoaded? state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: context.read<CountriesCubit>().search,
        decoration: InputDecoration(
          hintText: 'Search countries',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: state == null || state.query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear',
                  onPressed: () => _search(''),
                  icon: const Icon(Icons.close),
                ),
        ),
      ),
    );
  }

  Widget _buildRecentSearches(List<String> searches) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent searches',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Spacer(),
              TextButton(
                onPressed: context.read<CountriesCubit>().clearRecentSearches,
                child: const Text('Clear'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final name in searches)
                ActionChip(
                  avatar: const Icon(Icons.history, size: 18),
                  label: Text(name),
                  onPressed: () => _search(name),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(DateTime savedAt) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            size: 20,
            color: theme.colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Couldn't refresh. Showing countries saved ${timeAgo(savedAt)}.",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: context.read<CountriesCubit>().load,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(CountriesState state) {
    switch (state) {
      case CountriesLoading():
        return const Center(child: CircularProgressIndicator());

      case CountriesFailure(:final message):
        return MessageView(
          icon: Icons.cloud_off,
          title: 'Could not load countries',
          message: message,
          onRetry: context.read<CountriesCubit>().load,
        );

      case CountriesLoaded():
        if (state.countries.isEmpty) {
          return MessageView(
            icon: Icons.public_off,
            title: 'No countries found',
            message: 'The server returned an empty list.',
            onRetry: context.read<CountriesCubit>().load,
          );
        }

        final countries = state.visible;
        if (countries.isEmpty) {
          if (state.showFavoritesOnly && state.query.trim().isEmpty) {
            return const MessageView(
              icon: Icons.favorite_border,
              title: 'No favorites yet',
              message: 'Tap the heart on a country to save it here.',
            );
          }
          return MessageView(
            icon: Icons.search_off,
            title: 'No results',
            message: 'No country matches "${state.query.trim()}".',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: countries.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final country = countries[index];
            return CountryTile(
              country: country,
              isFavorite: state.favoriteCodes.contains(country.code),
              onTap: () => _openCountry(country),
            );
          },
        );
    }
  }
}
