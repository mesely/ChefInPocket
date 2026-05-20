import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/common_widgets.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final _addItemController = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _addItemController.dispose();
    super.dispose();
  }

  Future<void> _toggleItem(GroceryItem item) async {
    try {
      await ApiService.instance.updateGroceryItem(
        item.copyWith(isChecked: !item.isChecked),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _removeItem(GroceryItem item) async {
    try {
      await ApiService.instance.removeGroceryItem(item.id);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${item.title} removed.')));
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _addItem(String title, {BuildContext? sheetContext}) async {
    if (title.trim().isEmpty || _isAdding) {
      return;
    }

    setState(() {
      _isAdding = true;
    });

    try {
      await ApiService.instance.addGroceryItem(title.trim());
      _addItemController.clear();

      if (sheetContext != null && sheetContext.mounted) {
        Navigator.pop(sheetContext);
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  void _showAddBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return _AddGrocerySheet(
          controller: _addItemController,
          isAdding: _isAdding,
          onAdd: (title) => _addItem(title, sheetContext: sheetContext),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChefPage(
      currentRoute: AppRoutes.groceryList,
      showBottomNav: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.darkButton,
        onPressed: _showAddBottomSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: StreamBuilder<List<GroceryItem>>(
        stream: ApiService.instance.watchGroceryList(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <GroceryItem>[];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Grocery List', style: AppTextStyles.display),
                  ),
                  const InfoChip(label: 'Live', isActive: true),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Items you need before cooking.',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderColor(context)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addItemController,
                        decoration: InputDecoration(
                          hintText: 'Add milk, eggs, tomatoes...',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: AppColors.mutedText(context),
                          ),
                          filled: true,
                          fillColor: AppColors.softSurface(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: AppColors.borderColor(context),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: AppColors.borderColor(context),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primaryText(context),
                        ),
                        onSubmitted: _addItem,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isAdding
                          ? null
                          : () => _addItem(_addItemController.text),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(96, 48),
                      ),
                      child: Text(_isAdding ? 'Adding...' : 'Add'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Use the + button for quick suggestions.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.mutedText(context),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const AppSectionHeader(label: 'Missing Ingredients'),
              const SizedBox(height: AppSpacing.sm),
              if (snapshot.connectionState == ConnectionState.waiting &&
                  items.isEmpty)
                const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                Text(
                  'Grocery list could not be loaded.\n${snapshot.error}',
                  style: AppTextStyles.body.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                )
              else if (items.isEmpty)
                Card(
                  color: AppColors.surface(context),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: BorderSide(color: AppColors.borderColor(context)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 36),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Your grocery list is empty.\nTap + to add items.',
                            style: AppTextStyles.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      color: AppColors.surface(context),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: AppColors.borderColor(context),
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Checkbox(
                          value: item.isChecked,
                          onChanged: (_) => _toggleItem(item),
                        ),
                        title: Text(
                          item.title,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            decoration: item.isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          item.note,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mutedText(context),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                            IconButton(
                              onPressed: () => _removeItem(item),
                              icon: const Icon(Icons.delete_outline, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AddGrocerySheet extends StatelessWidget {
  const _AddGrocerySheet({
    required this.controller,
    required this.isAdding,
    required this.onAdd,
  });

  final TextEditingController controller;
  final bool isAdding;
  final void Function(String) onAdd;

  static const _suggestions = [
    ('🥚', 'Eggs'),
    ('🍅', 'Tomatoes'),
    ('🧅', 'Onion'),
    ('🧄', 'Garlic'),
    ('🥛', 'Milk'),
    ('🧀', 'Cheese'),
    ('🥩', 'Chicken'),
    ('🥦', 'Broccoli'),
    ('🫒', 'Olive Oil'),
    ('🌾', 'Flour'),
    ('🍋', 'Lemon'),
    ('🌿', 'Fresh Herbs'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Add to Grocery List', style: AppTextStyles.title),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Quick add', style: AppTextStyles.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((suggestion) {
              return GestureDetector(
                onTap: () => onAdd(suggestion.$2),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softSurface(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor(context)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(suggestion.$1, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        suggestion.$2,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryText(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Or type a custom item', style: AppTextStyles.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'e.g. Feta cheese...',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.mutedText(context),
                    ),
                    filled: true,
                    fillColor: AppColors.softSurface(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.borderColor(context),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.borderColor(context),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primaryText(context),
                  ),
                  onSubmitted: onAdd,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: isAdding ? null : () => onAdd(controller.text),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 48),
                ),
                child: Text(isAdding ? 'Adding...' : 'Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
