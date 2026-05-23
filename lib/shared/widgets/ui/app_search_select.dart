import 'package:flutter/material.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';

class SearchSelectItem<T> {
  final T value;
  final String label;
  final String? description;

  const SearchSelectItem({
    required this.value,
    required this.label,
    this.description,
  });
}

class AppSearchSelect<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<SearchSelectItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String Function(T value)? displayLabel;
  final String? helperText;

  const AppSearchSelect({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.displayLabel,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    final selectedItem = value == null
        ? null
        : items.where((item) => item.value == value).cast<SearchSelectItem<T>?>().firstWhere(
              (item) => item != null,
              orElse: () => null,
            );
    final selectedLabel = value == null
        ? hint
        : selectedItem?.label ??
            (displayLabel != null ? displayLabel!(value as T) : value.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondaryOf(context),
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final selected = await showModalBottomSheet<T>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => _SearchSelectSheet<T>(
                title: hint,
                items: items,
                displayLabel: displayLabel,
              ),
            );
            if (selected != null) {
              onChanged(selected);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              helperText: helperText,
              suffixIcon: const Icon(Icons.search_rounded),
            ),
            child: Text(
              selectedLabel,
              style: TextStyle(
                color: value == null
                    ? AppColors.textSecondaryOf(context)
                    : AppColors.textPrimaryOf(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchSelectSheet<T> extends StatefulWidget {
  final String title;
  final List<SearchSelectItem<T>> items;
  final String Function(T value)? displayLabel;

  const _SearchSelectSheet({
    required this.title,
    required this.items,
    this.displayLabel,
  });

  @override
  State<_SearchSelectSheet<T>> createState() => _SearchSelectSheetState<T>();
}

class _SearchSelectSheetState<T> extends State<_SearchSelectSheet<T>> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((item) {
      final text = '${item.label} ${item.description ?? ''}'.toLowerCase();
      return text.contains(_query.toLowerCase());
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgPrimaryOf(context),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColorOf(context),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryOf(context),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _controller,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: const InputDecoration(
                        hintText: 'Cari...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return ListTile(
                      title: Text(item.label),
                      subtitle: item.description == null ? null : Text(item.description!),
                      onTap: () => Navigator.pop(context, item.value),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
