import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_event.dart';
import '../blocs/category/category_state.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../blocs/product/product_state.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../repositories/category_repository.dart';
import '../repositories/product_repository.dart';
import 'product_detail_page.dart';
import 'product_search_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              CategoryBloc(categoryRepository: CategoryRepository())
                ..add(FetchCategories()),
        ),
        BlocProvider(
          create: (context) =>
              ProductBloc(productRepository: ProductRepository())
                ..add(FetchActiveProductsEvent()),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Explore',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'serif',
                  letterSpacing: 1)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.search, color: Colors.black87),
          //     onPressed: () {
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //               builder: (_) => const ProductSearchPage()));
          //     },
          //   ),
          // ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchTeaser(context),
            _buildCategoryPills(),
            Expanded(
              child: _buildProductGrid(),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Kotak Pencarian Palsu (Teaser) yang mengarahkan ke halaman Search
  Widget _buildSearchTeaser(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ProductSearchPage()));
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey.shade500, size: 20),
            const SizedBox(width: 12),
            Text(
              'Cari tas, warna, atau model...',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Filter Kategori Mendatar
  Widget _buildCategoryPills() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading || state is CategoryInitial) {
          return const SizedBox(
              height: 40,
              child: Center(
                  child: CircularProgressIndicator(
                      color: Colors.black, strokeWidth: 2)));
        } else if (state is CategoryLoaded) {
          final List<Category> filterCategories = [
            Category(id: 0, code: 'ALL', name: 'Semua Koleksi'),
            ...state.categories
          ];

          return SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              itemCount: filterCategories.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedCategoryIndex == index;
                final category = filterCategories[index];

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategoryIndex = index);
                    if (category.id == 0) {
                      context
                          .read<ProductBloc>()
                          .add(FetchActiveProductsEvent());
                    } else {
                      context
                          .read<ProductBloc>()
                          .add(FetchProductsByCategoryEvent(category.id!));
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      border: Border.all(
                          color:
                              isSelected ? Colors.black : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category.name.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // 3. Grid Produk (Majalah Style)
  Widget _buildProductGrid() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.black));
        } else if (state is ProductError) {
          return Center(
              child: Text(state.message,
                  style: const TextStyle(color: Colors.red)));
        } else if (state is ProductListLoaded) {
          final products = state.products;

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text("Koleksi belum tersedia.",
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 Kolom
              childAspectRatio:
                  0.55, // Rasio vertikal yang panjang ala Instagram
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildGridCard(context, products[index]);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildGridCard(BuildContext context, ProductModel product) {
    bool hasDiscount = product.hasActiveDiscount;
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailPage(initialProduct: product)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                image: product.image != null
                    ? DecorationImage(
                        image: NetworkImage(product.image!), fit: BoxFit.cover)
                    : null,
              ),
              child: Stack(
                children: [
                  if (hasDiscount)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('SALE',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                      ),
                    ),
                  if (product.isFinalSale == 1)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('FINAL SALE',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.name.toUpperCase(),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          if (hasDiscount) ...[
            Text(
              currencyFormat.format(product.discountPrice),
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w900, color: Colors.red),
            ),
            const SizedBox(height: 2),
            Text(
              currencyFormat.format(product.price),
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough),
            ),
          ] else ...[
            Text(
              currencyFormat.format(product.price),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87),
            ),
          ]
        ],
      ),
    );
  }
}
