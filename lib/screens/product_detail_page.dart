import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../blocs/product/product_state.dart';
import '../repositories/product_repository.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel initialProduct;

  const ProductDetailPage({super.key, required this.initialProduct});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _activeImageIndex = 0;
  int _quantity = 1;
  String _selectedColor = '';

  @override
  void initState() {
    super.initState();
    // Jika produk memiliki warna, pilih warna pertama secara default
    if (widget.initialProduct.color.isNotEmpty) {
      _selectedColor = widget.initialProduct.color.first;
    }
  }

  // Helper untuk menentukan Hex Code warna secara dinamis
  Color _getColorHex(String colorName) {
    final map = {
      'black': Colors.black,
      'white': Colors.white,
      'brown': Colors.brown,
      'beige': const Color(0xFFF5F5DC),
      'red': Colors.red.shade800,
      'navy': Colors.indigo.shade900,
      'green': Colors.green.shade800,
      'grey': Colors.grey,
      'pink': Colors.pink.shade200,
      'blue': Colors.blue.shade600,
      'silver': const Color(0xFFC0C0C0),
      'gold': const Color(0xFFD4AF37),
    };
    return map[colorName.toLowerCase()] ?? Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    // KITA MEMBUAT BLOC BARU KHUSUS UNTUK HALAMAN INI AGAR TIDAK MERUSAK HOME
    return BlocProvider(
      create: (context) => ProductBloc(productRepository: ProductRepository())
        ..add(FetchProductDetailEvent(widget.initialProduct.slug.isNotEmpty
            ? widget.initialProduct.slug
            : widget.initialProduct.id.toString())),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.black),
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.black),
                onPressed: () {}),
          ],
        ),
        // BAGIAN BAWAH: Sticky Bottom Bar (Add to Cart / Buy)
        bottomNavigationBar: _buildBottomActions(),

        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            // Kita gunakan initialProduct sebagai patokan, namun jika state sukses, timpa dengan data API terbaru
            ProductModel displayProduct = widget.initialProduct;

            if (state is ProductDetailLoaded) {
              displayProduct = state.product;
              // Set warna default jika sebelumnya kosong tapi dari API ternyata ada
              if (_selectedColor.isEmpty && displayProduct.color.isNotEmpty) {
                _selectedColor = displayProduct.color.first;
              }
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageGallery(displayProduct),
                  _buildProductInfo(displayProduct),
                  _buildVariations(displayProduct),
                  _buildSpecifications(displayProduct),
                  _buildAccordions(displayProduct),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageGallery(ProductModel product) {
    List<String> images = [];
    if (product.image != null) images.add(product.image!);
    images.addAll(product.variantImages);

    if (images.isEmpty) {
      return Container(
          height: 350,
          color: Colors.grey.shade100,
          child: const Center(
              child: Icon(Icons.image_not_supported,
                  size: 50, color: Colors.grey)));
    }

    return Column(
      children: [
        SizedBox(
          height: 450,
          child: PageView.builder(
            physics: const BouncingScrollPhysics(),
            onPageChanged: (idx) => setState(() => _activeImageIndex = idx),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Image.network(images[index], fit: BoxFit.cover);
            },
          ),
        ),
        const SizedBox(height: 16),
        // Thumbnail Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _activeImageIndex == index ? 24 : 6,
              decoration: BoxDecoration(
                color: _activeImageIndex == index
                    ? Colors.black
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProductInfo(ProductModel product) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    bool hasDiscount =
        product.discountPrice != null && product.discountPrice! > 0;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const Icon(Icons.star_half, color: Colors.amber, size: 16),
              const SizedBox(width: 8),
              Text('(10+ Ulasan)',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      decoration: TextDecoration.underline)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.name.toUpperCase(),
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
                height: 1.2),
          ),
          const SizedBox(height: 16),
          if (hasDiscount) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(currencyFormat.format(product.discountPrice),
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.red)),
                const SizedBox(width: 8),
                Text(currencyFormat.format(product.price),
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                        height: 1.8)),
              ],
            ),
          ] else ...[
            Text(currencyFormat.format(product.price),
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black)),
          ],
          if (product.stock > 0 && product.stock <= 5) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200)),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SELLING FAST!',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                                letterSpacing: 1)),
                        Text(
                            'Hurry, only ${product.stock} items left in stock.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.orange.shade800)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVariations(ProductModel product) {
    if (product.color.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('COLORS',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.grey)),
              Text(_selectedColor.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: product.color.map((colorName) {
              bool isSelected = _selectedColor == colorName;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = colorName),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.grey.shade100 : Colors.white,
                    border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade300,
                        width: isSelected ? 2 : 1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                            color: _getColorHex(colorName),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300)),
                      ),
                      const SizedBox(width: 8),
                      Text(colorName.toUpperCase(),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.black : Colors.grey)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSpecifications(ProductModel product) {
    bool hasSpecs = product.material != null ||
        product.weight != null ||
        product.length != null ||
        product.strapLength.isNotEmpty;
    if (!hasSpecs) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100)),
        child: Column(
          children: [
            if (product.material != null)
              _buildSpecRow('MATERIAL', product.material!),
            if (product.weight != null)
              _buildSpecRow('WEIGHT', '${product.weight} gram'),
            if (product.length != null)
              _buildSpecRow('DIMENSIONS',
                  '${product.length} x ${product.width} x ${product.height} cm'),
            if (product.strapLength.isNotEmpty)
              _buildSpecRow('STRAP', product.strapLength.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.grey))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildAccordions(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, left: 12, right: 12),
      child: Column(
        children: [
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text('DESCRIPTION',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Text(product.description ?? 'Tidak ada deskripsi tersedia.',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.5)),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text('DESIGN DETAILS',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Text(product.design ?? 'Tidak ada detail desain.',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.5)),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24,
          32), // Padding bottom ekstra untuk area poni/home indicator iPhone
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        children: [
          // Quantity Selector
          Container(
            height: 50,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: () => setState(() {
                          if (_quantity > 1) _quantity--;
                        })),
                Text('$_quantity',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () => setState(() {
                          if (_quantity < widget.initialProduct.stock)
                            _quantity++;
                        })),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Action Buttons
          Expanded(
            child: widget.initialProduct.stock <= 0
                ? Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text('OUT OF STOCK',
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side:
                                const BorderSide(color: Colors.black, width: 2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            // TODO: Panggil CartBloc di sini
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Berhasil ditambahkan ke Tas!'),
                                    backgroundColor: Colors.green));
                          },
                          child: const Text('ADD TO BAG',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  letterSpacing: 1)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            // TODO: Langsung bawa ke halaman Checkout
                          },
                          child: const Text('BUY NOW',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1)),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
