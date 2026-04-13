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
  late Future<List<GroceryItem>> _itemsFuture;
  List<GroceryItem> _items = const [];
  final _addItemController = TextEditingController();
  bool _isAdding = false;
  bool _loadedItems = false;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems();
  }

  @override
  void dispose() {
    _addItemController.dispose();
    super.dispose();
  }

  Future<List<GroceryItem>> _loadItems() async {
    final items = await ApiService.instance.fetchGroceryList();
    _items = items;
    _loadedItems = true;
    return items;
  }

  Future<void> _removeItem(GroceryItem item) async {
    try {
      await ApiService.instance.removeGroceryItem(item.id);
      if (!mounted) return;
      setState(() {
        _items = _items.where((entry) => entry.id != item.id).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.title} removed.')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  Future<void> _addItem(String title, {BuildContext? sheetContext}) async {
    if (title.trim().isEmpty || _isAdding) return;

    setState(() {
      _isAdding = true;
    });

    try {
      final item = await ApiService.instance.addGroceryItem(title.trim());
      if (!mounted) return;

      setState(() {
        _items = [..._items, item];
        _addItemController.clear();
      });

      if (sheetContext != null && sheetContext.mounted) {
        Navigator.pop(sheetContext);
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
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
      backgroundColor: Colors.white,
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
      child: FutureBuilder<List<GroceryItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          final items = _loadedItems ? _items : snapshot.data ?? const [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Grocery List', style: AppTextStyles.display)),
                  const InfoChip(label: 'List', isActive: true),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Items you need before cooking.',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: AppSpacing.lg),
              const AppSectionHeader(label: 'Missing Ingredients'),
              const SizedBox(height: AppSpacing.sm),
              if (snapshot.connectionState == ConnectionState.waiting && items.isEmpty)
                const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                Text('Grocery list could not be loaded.', style: AppTextStyles.body)
              else if (items.isEmpty)
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: const BorderSide(color: AppColors.border),
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
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Text(item.emoji, style: const TextStyle(fontSize: 24)),
                        title: Text(
                          item.title,
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(item.note, style: AppTextStyles.caption),
                        trailing: IconButton(
                          onPressed: () => _removeItem(item),
                          icon: const Icon(Icons.delete_outline, size: 20),
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

class _AddGrocerySheet extends StatefulWidget {
  const _AddGrocerySheet({
    required this.controller,
    required this.isAdding,
    required this.onAdd,
  });

  final TextEditingController controller;
  final bool isAdding;
  final void Function(String) onAdd;

  @override
  State<_AddGrocerySheet> createState() => _AddGrocerySheetState();
}

class _AddGrocerySheetState extends State<_AddGrocerySheet> {
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
            children: _suggestions.map((s) {
              return GestureDetector(
                onTap: () => widget.onAdd(s.$2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s.$1, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        s.$2,
                        style: AppTextStyles.caption.copyWith(
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
                  controller: widget.controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'e.g. Feta cheese...',
                    hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: AppTextStyles.body,
                  onSubmitted: widget.onAdd,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: widget.isAdding
                    ? null
                    : () => widget.onAdd(widget.controller.text),
                child: Text(widget.isAdding ? '...' : 'Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
