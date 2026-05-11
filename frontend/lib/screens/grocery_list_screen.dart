import 'package:flutter/material.dart';

import '../models/firestore_models.dart';
import '../routes/app_routes.dart';
import '../services/firestore_service.dart';
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

  @override
  void dispose() {
    _addItemController.dispose();
    super.dispose();
  }

  Future<void> _addItem(String title, {BuildContext? sheetContext}) async {
    if (title.trim().isEmpty) return;
    if (sheetContext != null && sheetContext.mounted) {
      Navigator.pop(sheetContext);
    }
    await FirestoreService.instance.addGroceryItem(
      title: title.trim(),
      emoji: _emojiForTitle(title),
    );
    _addItemController.clear();
  }

  Future<void> _toggleItem(GroceryItemDoc item) async {
    await FirestoreService.instance.toggleGroceryItem(item.id, !item.checked);
  }

  Future<void> _removeItem(GroceryItemDoc item) async {
    await FirestoreService.instance.deleteGroceryItem(item.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.title} removed.')),
    );
  }

  String _emojiForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('egg')) return '🥚';
    if (t.contains('tomato')) return '🍅';
    if (t.contains('onion')) return '🧅';
    if (t.contains('garlic')) return '🧄';
    if (t.contains('milk')) return '🥛';
    if (t.contains('cheese')) return '🧀';
    if (t.contains('chicken')) return '🥩';
    if (t.contains('broccoli')) return '🥦';
    if (t.contains('oil')) return '🫒';
    if (t.contains('flour')) return '🌾';
    if (t.contains('lemon')) return '🍋';
    return '🛒';
  }

  void _showAddBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => _AddGrocerySheet(
        controller: _addItemController,
        onAdd: (title) => _addItem(title, sheetContext: sheetContext),
      ),
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
      child: StreamBuilder<List<GroceryItemDoc>>(
        stream: FirestoreService.instance.streamGroceryItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Text('Error loading list.', style: AppTextStyles.body);
          }

          final items = snapshot.data ?? [];
          final pending = items.where((i) => !i.checked).toList();
          final done = items.where((i) => i.checked).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Grocery List', style: AppTextStyles.display),
                  ),
                  InfoChip(label: '${items.length} items', isActive: true),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Items you need before cooking.',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (items.isEmpty)
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
              else ...[
                if (pending.isNotEmpty) ...[
                  AppSectionHeader(label: 'To buy (${pending.length})'),
                  const SizedBox(height: AppSpacing.sm),
                  ...pending.map((item) => _GroceryTile(
                        item: item,
                        onToggle: () => _toggleItem(item),
                        onDelete: () => _removeItem(item),
                      )),
                ],
                if (done.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppSectionHeader(label: 'Done (${done.length})'),
                  const SizedBox(height: AppSpacing.sm),
                  ...done.map((item) => _GroceryTile(
                        item: item,
                        onToggle: () => _toggleItem(item),
                        onDelete: () => _removeItem(item),
                      )),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _GroceryTile extends StatelessWidget {
  const _GroceryTile({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  final GroceryItemDoc item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          leading: GestureDetector(
            onTap: onToggle,
            child: item.checked
                ? const Icon(Icons.check_circle, color: AppColors.success)
                : Text(item.emoji, style: const TextStyle(fontSize: 24)),
          ),
          title: Text(
            item.title,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              decoration:
                  item.checked ? TextDecoration.lineThrough : null,
              color: item.checked
                  ? AppColors.textMuted
                  : AppColors.textPrimary,
            ),
          ),
          trailing: IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 20),
          ),
        ),
      ),
    );
  }
}

class _AddGrocerySheet extends StatefulWidget {
  const _AddGrocerySheet({required this.controller, required this.onAdd});

  final TextEditingController controller;
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
                child:
                    Text('Add to Grocery List', style: AppTextStyles.title),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
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
                        style: AppTextStyles.caption
                            .copyWith(fontWeight: FontWeight.w600),
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
                    hintStyle: AppTextStyles.body
                        .copyWith(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  style: AppTextStyles.body,
                  onSubmitted: widget.onAdd,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => widget.onAdd(widget.controller.text),
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
