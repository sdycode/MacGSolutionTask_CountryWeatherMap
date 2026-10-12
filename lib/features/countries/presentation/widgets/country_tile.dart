import 'package:flutter/material.dart';

import '../../../../core/widgets/flag_image.dart';
import '../../domain/entities/country.dart';

class CountryTile extends StatelessWidget {
  const CountryTile({
    super.key,
    required this.country,
    required this.isFavorite,
    required this.onTap,
  });

  final Country country;
  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              FlagImage(code: country.code, width: 56, height: 38),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      country.capital.isEmpty
                          ? country.region
                          : '${country.capital} · ${country.region}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isFavorite)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.favorite, size: 20, color: Colors.red),
                ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
