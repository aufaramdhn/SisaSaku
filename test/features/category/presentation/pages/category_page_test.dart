import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/theme/app_theme.dart';
import 'package:sisasaku/features/category/domain/entities/category_entity.dart';
import 'package:sisasaku/features/category/presentation/pages/category_page.dart';
import 'package:sisasaku/features/category/presentation/providers/category_provider.dart';

void main() {
  late List<CategoryEntity> mockCategories;

  setUp(() {
    mockCategories = [
      CategoryEntity(
        id: 'cat-1',
        nama: 'Makanan',
        ikon: 'restaurant',
        warna: '#FF5722',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        syncStatus: true,
      ),
      CategoryEntity(
        id: 'cat-2',
        nama: 'Transportasi',
        ikon: 'directions_car',
        warna: '#2196F3',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        syncStatus: true,
      ),
    ];
  });

  group('CategoryPage - Edit/Delete Flows', () {
    testWidgets('onEdit navigates to edit page', (tester) async {
      bool navigatedToEdit = false;

      final router = GoRouter(
        initialLocation: '/category',
        routes: [
          GoRoute(
            path: '/category',
            builder: (context, state) => const CategoryPage(),
          ),
          GoRoute(
            path: '/category/:id/edit',
            builder: (context, state) {
              navigatedToEdit = true;
              return const Scaffold(body: Text('Edit Page'));
            },
          ),
          GoRoute(
            path: '/add-category',
            builder: (context, state) =>
                const Scaffold(body: Text('Add Category')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesProvider.overrideWith(
              (ref) => Stream.value(mockCategories),
            ),
            deleteCategoryProvider.overrideWith((ref, id) async {}),
          ],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify categories are displayed
      expect(find.text('Makanan'), findsOneWidget);

      // Find the edit button (Icons.edit) for the first category
      final editButtons = find.byIcon(Icons.edit);
      expect(editButtons, findsWidgets);

      // Tap the first edit button
      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      // Verify navigation occurred to the edit page
      expect(navigatedToEdit, isTrue);
      expect(find.text('Edit Page'), findsOneWidget);
    });

    testWidgets('delete shows confirmation dialog', (tester) async {
      final router = GoRouter(
        initialLocation: '/category',
        routes: [
          GoRoute(
            path: '/category',
            builder: (context, state) => const CategoryPage(),
          ),
          GoRoute(
            path: '/category/:id/edit',
            builder: (context, state) =>
                const Scaffold(body: Text('Edit Page')),
          ),
          GoRoute(
            path: '/add-category',
            builder: (context, state) =>
                const Scaffold(body: Text('Add Category')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesProvider.overrideWith(
              (ref) => Stream.value(mockCategories),
            ),
            deleteCategoryProvider.overrideWith((ref, id) async {}),
          ],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify categories are displayed
      expect(find.text('Makanan'), findsOneWidget);

      // Find the delete button (Icons.delete_outline)
      final deleteButtons = find.byIcon(Icons.delete_outline);
      expect(deleteButtons, findsWidgets);

      // Tap the first delete button
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Hapus Kategori'), findsOneWidget);
      expect(
        find.textContaining('Apakah Anda yakin ingin menghapus kategori'),
        findsOneWidget,
      );
      expect(find.text('Hapus'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
    });

    testWidgets('delete calls deleteCategoryProvider on confirm',
        (tester) async {
      String? deletedCategoryId;

      final router = GoRouter(
        initialLocation: '/category',
        routes: [
          GoRoute(
            path: '/category',
            builder: (context, state) => const CategoryPage(),
          ),
          GoRoute(
            path: '/category/:id/edit',
            builder: (context, state) =>
                const Scaffold(body: Text('Edit Page')),
          ),
          GoRoute(
            path: '/add-category',
            builder: (context, state) =>
                const Scaffold(body: Text('Add Category')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesProvider.overrideWith(
              (ref) => Stream.value(mockCategories),
            ),
            deleteCategoryProvider.overrideWith((ref, categoryId) async {
              deletedCategoryId = categoryId;
            }),
          ],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the first delete button
      final deleteButtons = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Confirm deletion by tapping "Hapus" button in the dialog
      final hapusButton = find.text('Hapus');
      expect(hapusButton, findsOneWidget);
      await tester.tap(hapusButton);
      await tester.pumpAndSettle();

      // Verify the provider was called with the correct category ID
      expect(deletedCategoryId, 'cat-1');
    });

    testWidgets('delete cancel does not call deleteCategoryProvider',
        (tester) async {
      String? deletedCategoryId;

      final router = GoRouter(
        initialLocation: '/category',
        routes: [
          GoRoute(
            path: '/category',
            builder: (context, state) => const CategoryPage(),
          ),
          GoRoute(
            path: '/category/:id/edit',
            builder: (context, state) =>
                const Scaffold(body: Text('Edit Page')),
          ),
          GoRoute(
            path: '/add-category',
            builder: (context, state) =>
                const Scaffold(body: Text('Add Category')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesProvider.overrideWith(
              (ref) => Stream.value(mockCategories),
            ),
            deleteCategoryProvider.overrideWith((ref, categoryId) async {
              deletedCategoryId = categoryId;
            }),
          ],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the first delete button
      final deleteButtons = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Cancel deletion by tapping "Batal" button
      final batalButton = find.text('Batal');
      expect(batalButton, findsOneWidget);
      await tester.tap(batalButton);
      await tester.pumpAndSettle();

      // Verify the provider was NOT called
      expect(deletedCategoryId, isNull);
    });
  });
}
