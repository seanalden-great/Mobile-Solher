import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';
import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_event.dart';
import '../blocs/category/category_state.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../blocs/product/product_state.dart';
import '../repositories/category_repository.dart';
import '../repositories/product_repository.dart';
import 'product_detail_page.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilterIndex = 0;
  int _selectedCategoryId = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          create: (context) => ProductBloc(
              productRepository: ProductRepository())
            ..add(
                FetchActiveProductsEvent()), // Tarik semua produk aktif untuk difilter lokal
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari koleksi kami...',
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: Colors.grey, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            _buildCategoryFilters(),
            Expanded(
              child: _buildProductGrid(),
            ),
          ],
        ),
      ),
    );
  }

  // 👇 FILTER KATEGORI 👇
  Widget _buildCategoryFilters() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoaded) {
          final List<Category> filterCategories = [
            Category(id: 0, code: 'ALL', name: 'All Products'),
            ...state.categories
          ];

          return Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SizedBox(
              height: 35,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: filterCategories.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedFilterIndex == index;
                  final category = filterCategories[index];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilterIndex = index;
                        _selectedCategoryId = category.id ?? 0;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            category.name.toUpperCase(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade400,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 1.5,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              height: 4,
                              width: 4,
                              decoration: const BoxDecoration(
                                  color: Colors.black, shape: BoxShape.circle),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // 👇 GRID PRODUK 👇
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
          // --- LOGIKA PENYARINGAN LOKAL ---
          // final filteredProducts = state.products.where((product) {
          //   // Filter 1: Kategori
          //   bool matchesCategory = _selectedCategoryId == 0 ||
          //       (product.category != null &&
          //           product.category!.id == _selectedCategoryId);

          //   // Filter 2: Teks Pencarian
          //   bool matchesSearch =
          //       product.name.toLowerCase().contains(_searchQuery);

          //   return matchesCategory && matchesSearch;
          // }).toList();

          // --- LOGIKA PENYARINGAN LOKAL ---
          final filteredProducts = state.products.where((product) {
            // 👇 PERBAIKAN: Gunakan kurung siku ['id'] karena bentuknya Map
            bool matchesCategory = _selectedCategoryId == 0 ||
                (product.category != null &&
                    product.category!['id'] == _selectedCategoryId);

            // Filter 2: Teks Pencarian
            bool matchesSearch =
                product.name.toLowerCase().contains(_searchQuery);

            return matchesCategory && matchesSearch;
          }).toList();

          if (filteredProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text("Produk tidak ditemukan.",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 24,
              crossAxisSpacing: 16,
              childAspectRatio: 0.55, // Rasio vertikal kartu produk
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              return _buildProductCard(context, filteredProducts[index]);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    bool hasDiscount =
        // product.discountPrice != null && product.discountPrice! > 0;
        product.hasActiveDiscount;
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
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                image: product.image != null
                    ? DecorationImage(
                        image: NetworkImage(product.image!), fit: BoxFit.cover)
                    : null,
              ),
              child: Stack(
                children: [
                  if (hasDiscount) // Menampilkan badge diskon
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'SALE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.name.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: 1.2),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasDiscount) ...[
                Text(
                  currencyFormat.format(product.discountPrice),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.red),
                ),
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
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.black),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
