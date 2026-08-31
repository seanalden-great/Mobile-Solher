import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/wishlist/wishlist_bloc.dart';
import '../blocs/wishlist/wishlist_event.dart';
import '../blocs/wishlist/wishlist_state.dart';
import '../models/product_model.dart';
import '../repositories/wishlist_repository.dart';
import 'product_detail_page.dart'; // Sesuaikan jika path berbeda

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          WishlistBloc(wishlistRepository: WishlistRepository())
            ..add(FetchWishlists()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('My Wishlist',
              style:
                  TextStyle(fontWeight: FontWeight.w900, fontFamily: 'serif')),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          centerTitle: true,
        ),
        body: BlocConsumer<WishlistBloc, WishlistState>(
          listener: (context, state) {
            if (state is WishlistToggleSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message), backgroundColor: Colors.black));
            } else if (state is WishlistError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            if (state is WishlistLoading || state is WishlistInitial) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.black));
            } else if (state is WishlistLoaded) {
              final items = state.wishlists;

              if (items.isEmpty) {
                return _buildEmptyState(context);
              }

              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final product = items[index].product;
                  if (product == null)
                    return const SizedBox
                        .shrink(); // Cegah error jika produk dihapus dari database

                  return _buildFavoriteCard(context, product);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          const Text('Wishlist Kosong',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif')),
          const SizedBox(height: 8),
          const Text('Koleksi favorit Anda akan muncul di sini.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('KEMBALI BELANJA',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
          )
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, ProductModel product) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    bool hasDiscount =
        // product.discountPrice != null && product.discountPrice! > 0;
        product.hasActiveDiscount;

    return GestureDetector(
      onTap: () {
        // Pindah ke Detail Produk saat di klik
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
                  // Tombol Hapus dari Favorit
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        // Memicu penghapusan dari Wishlist (Toggle)
                        context
                            .read<WishlistBloc>()
                            .add(ToggleWishlistEvent(product.id));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4)
                            ]),
                        child: const Icon(Icons.favorite,
                            color: Colors.red, size: 18),
                      ),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(
                            'SALE -${((product.price - product.discountPrice!) / product.price * 100).round()}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1)),
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
                letterSpacing: 1),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (hasDiscount) ...[
                Text(currencyFormatter.format(product.discountPrice),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.red)),
                const SizedBox(width: 6),
                Text(currencyFormatter.format(product.price),
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough)),
              ] else ...[
                Text(currencyFormatter.format(product.price),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.black)),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
