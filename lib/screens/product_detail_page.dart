// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import '../models/product_model.dart';
// import '../blocs/product/product_bloc.dart';
// import '../blocs/product/product_event.dart';
// import '../blocs/product/product_state.dart';
// import '../repositories/product_repository.dart';

// class ProductDetailPage extends StatefulWidget {
//   final ProductModel initialProduct;

//   const ProductDetailPage({super.key, required this.initialProduct});

//   @override
//   State<ProductDetailPage> createState() => _ProductDetailPageState();
// }

// class _ProductDetailPageState extends State<ProductDetailPage> {
//   int _activeImageIndex = 0;
//   int _quantity = 1;
//   String _selectedColor = '';

//   @override
//   void initState() {
//     super.initState();
//     // Jika produk memiliki warna, pilih warna pertama secara default
//     if (widget.initialProduct.color.isNotEmpty) {
//       _selectedColor = widget.initialProduct.color.first;
//     }
//   }

//   // Helper untuk menentukan Hex Code warna secara dinamis
//   Color _getColorHex(String colorName) {
//     final map = {
//       'black': Colors.black,
//       'white': Colors.white,
//       'brown': Colors.brown,
//       'beige': const Color(0xFFF5F5DC),
//       'red': Colors.red.shade800,
//       'navy': Colors.indigo.shade900,
//       'green': Colors.green.shade800,
//       'grey': Colors.grey,
//       'pink': Colors.pink.shade200,
//       'blue': Colors.blue.shade600,
//       'silver': const Color(0xFFC0C0C0),
//       'gold': const Color(0xFFD4AF37),
//     };
//     return map[colorName.toLowerCase()] ?? Colors.grey.shade300;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // KITA MEMBUAT BLOC BARU KHUSUS UNTUK HALAMAN INI AGAR TIDAK MERUSAK HOME
//     return BlocProvider(
//       create: (context) => ProductBloc(productRepository: ProductRepository())
//         ..add(FetchProductDetailEvent(widget.initialProduct.slug.isNotEmpty
//             ? widget.initialProduct.slug
//             : widget.initialProduct.id.toString())),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//             onPressed: () => Navigator.pop(context),
//           ),
//           actions: [
//             IconButton(
//                 icon: const Icon(Icons.share_outlined, color: Colors.black),
//                 onPressed: () {}),
//             IconButton(
//                 icon: const Icon(Icons.favorite_border, color: Colors.black),
//                 onPressed: () {}),
//           ],
//         ),
//         // BAGIAN BAWAH: Sticky Bottom Bar (Add to Cart / Buy)
//         bottomNavigationBar: _buildBottomActions(),

//         body: BlocBuilder<ProductBloc, ProductState>(
//           builder: (context, state) {
//             // Kita gunakan initialProduct sebagai patokan, namun jika state sukses, timpa dengan data API terbaru
//             ProductModel displayProduct = widget.initialProduct;

//             if (state is ProductDetailLoaded) {
//               displayProduct = state.product;
//               // Set warna default jika sebelumnya kosong tapi dari API ternyata ada
//               if (_selectedColor.isEmpty && displayProduct.color.isNotEmpty) {
//                 _selectedColor = displayProduct.color.first;
//               }
//             }

//             return SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildImageGallery(displayProduct),
//                   _buildProductInfo(displayProduct),
//                   _buildVariations(displayProduct),
//                   _buildSpecifications(displayProduct),
//                   _buildAccordions(displayProduct),
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildImageGallery(ProductModel product) {
//     List<String> images = [];
//     if (product.image != null) images.add(product.image!);
//     images.addAll(product.variantImages);

//     if (images.isEmpty) {
//       return Container(
//           height: 350,
//           color: Colors.grey.shade100,
//           child: const Center(
//               child: Icon(Icons.image_not_supported,
//                   size: 50, color: Colors.grey)));
//     }

//     return Column(
//       children: [
//         SizedBox(
//           height: 450,
//           child: PageView.builder(
//             physics: const BouncingScrollPhysics(),
//             onPageChanged: (idx) => setState(() => _activeImageIndex = idx),
//             itemCount: images.length,
//             itemBuilder: (context, index) {
//               return Image.network(images[index], fit: BoxFit.cover);
//             },
//           ),
//         ),
//         const SizedBox(height: 16),
//         // Thumbnail Indicators
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(images.length, (index) {
//             return AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               margin: const EdgeInsets.symmetric(horizontal: 4),
//               height: 6,
//               width: _activeImageIndex == index ? 24 : 6,
//               decoration: BoxDecoration(
//                 color: _activeImageIndex == index
//                     ? Colors.black
//                     : Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(3),
//               ),
//             );
//           }),
//         ),
//       ],
//     );
//   }

//   Widget _buildProductInfo(ProductModel product) {
//     final currencyFormat =
//         NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
//     bool hasDiscount =
//         product.discountPrice != null && product.discountPrice! > 0;

//     return Padding(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.star, color: Colors.amber, size: 16),
//               const Icon(Icons.star, color: Colors.amber, size: 16),
//               const Icon(Icons.star, color: Colors.amber, size: 16),
//               const Icon(Icons.star, color: Colors.amber, size: 16),
//               const Icon(Icons.star_half, color: Colors.amber, size: 16),
//               const SizedBox(width: 8),
//               Text('(10+ Ulasan)',
//                   style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey.shade600,
//                       decoration: TextDecoration.underline)),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             product.name.toUpperCase(),
//             style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w900,
//                 fontFamily: 'serif',
//                 height: 1.2),
//           ),
//           const SizedBox(height: 16),
//           if (hasDiscount) ...[
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(currencyFormat.format(product.discountPrice),
//                     style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w900,
//                         color: Colors.red)),
//                 const SizedBox(width: 8),
//                 Text(currencyFormat.format(product.price),
//                     style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                         decoration: TextDecoration.lineThrough,
//                         height: 1.8)),
//               ],
//             ),
//           ] else ...[
//             Text(currencyFormat.format(product.price),
//                 style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w900,
//                     color: Colors.black)),
//           ],
//           if (product.stock > 0 && product.stock <= 5) ...[
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                   color: Colors.orange.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.orange.shade200)),
//               child: Row(
//                 children: [
//                   const Text('🔥', style: TextStyle(fontSize: 18)),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('SELLING FAST!',
//                             style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.orange.shade900,
//                                 letterSpacing: 1)),
//                         Text(
//                             'Hurry, only ${product.stock} items left in stock.',
//                             style: TextStyle(
//                                 fontSize: 12, color: Colors.orange.shade800)),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildVariations(ProductModel product) {
//     if (product.color.isEmpty) return const SizedBox.shrink();

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('COLORS',
//                   style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 2,
//                       color: Colors.grey)),
//               Text(_selectedColor.toUpperCase(),
//                   style: const TextStyle(
//                       fontSize: 12, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Wrap(
//             spacing: 12,
//             runSpacing: 12,
//             children: product.color.map((colorName) {
//               bool isSelected = _selectedColor == colorName;
//               return GestureDetector(
//                 onTap: () => setState(() => _selectedColor = colorName),
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: isSelected ? Colors.grey.shade100 : Colors.white,
//                     border: Border.all(
//                         color: isSelected ? Colors.black : Colors.grey.shade300,
//                         width: isSelected ? 2 : 1),
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 16,
//                         height: 16,
//                         decoration: BoxDecoration(
//                             color: _getColorHex(colorName),
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.grey.shade300)),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(colorName.toUpperCase(),
//                           style: TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                               color: isSelected ? Colors.black : Colors.grey)),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }

//   Widget _buildSpecifications(ProductModel product) {
//     bool hasSpecs = product.material != null ||
//         product.weight != null ||
//         product.length != null ||
//         product.strapLength.isNotEmpty;
//     if (!hasSpecs) return const SizedBox.shrink();

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//             color: Colors.grey.shade50,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: Colors.grey.shade100)),
//         child: Column(
//           children: [
//             if (product.material != null)
//               _buildSpecRow('MATERIAL', product.material!),
//             if (product.weight != null)
//               _buildSpecRow('WEIGHT', '${product.weight} gram'),
//             if (product.length != null)
//               _buildSpecRow('DIMENSIONS',
//                   '${product.length} x ${product.width} x ${product.height} cm'),
//             if (product.strapLength.isNotEmpty)
//               _buildSpecRow('STRAP', product.strapLength.join(', ')),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSpecRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//               width: 100,
//               child: Text(label,
//                   style: const TextStyle(
//                       fontSize: 9,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 1.5,
//                       color: Colors.grey))),
//           Expanded(
//               child: Text(value,
//                   style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87))),
//         ],
//       ),
//     );
//   }

//   Widget _buildAccordions(ProductModel product) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 24.0, left: 12, right: 12),
//       child: Column(
//         children: [
//           Theme(
//             data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//             child: ExpansionTile(
//               title: const Text('DESCRIPTION',
//                   style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w900,
//                       letterSpacing: 1)),
//               childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//               children: [
//                 Text(product.description ?? 'Tidak ada deskripsi tersedia.',
//                     style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey.shade700,
//                         height: 1.5)),
//               ],
//             ),
//           ),
//           const Divider(height: 1, indent: 16, endIndent: 16),
//           Theme(
//             data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//             child: ExpansionTile(
//               title: const Text('DESIGN DETAILS',
//                   style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w900,
//                       letterSpacing: 1)),
//               childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//               children: [
//                 Text(product.design ?? 'Tidak ada detail desain.',
//                     style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey.shade700,
//                         height: 1.5)),
//               ],
//             ),
//           ),
//           const Divider(height: 1, indent: 16, endIndent: 16),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomActions() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(24, 16, 24,
//           32), // Padding bottom ekstra untuk area poni/home indicator iPhone
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, -5))
//         ],
//       ),
//       child: Row(
//         children: [
//           // Quantity Selector
//           Container(
//             height: 50,
//             decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//                 borderRadius: BorderRadius.circular(12)),
//             child: Row(
//               children: [
//                 IconButton(
//                     icon: const Icon(Icons.remove, size: 18),
//                     onPressed: () => setState(() {
//                           if (_quantity > 1) _quantity--;
//                         })),
//                 Text('$_quantity',
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.bold)),
//                 IconButton(
//                     icon: const Icon(Icons.add, size: 18),
//                     onPressed: () => setState(() {
//                           if (_quantity < widget.initialProduct.stock)
//                             _quantity++;
//                         })),
//               ],
//             ),
//           ),
//           const SizedBox(width: 16),

//           // Action Buttons
//           Expanded(
//             child: widget.initialProduct.stock <= 0
//                 ? Container(
//                     height: 50,
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                         color: Colors.grey.shade200,
//                         borderRadius: BorderRadius.circular(12)),
//                     child: const Text('OUT OF STOCK',
//                         style: TextStyle(
//                             color: Colors.grey,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1)),
//                   )
//                 : Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             side:
//                                 const BorderSide(color: Colors.black, width: 2),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12)),
//                           ),
//                           onPressed: () {
//                             // TODO: Panggil CartBloc di sini
//                             ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                     content:
//                                         Text('Berhasil ditambahkan ke Tas!'),
//                                     backgroundColor: Colors.green));
//                           },
//                           child: const Text('ADD TO BAG',
//                               style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                   letterSpacing: 1)),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             backgroundColor: Colors.black,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12)),
//                           ),
//                           onPressed: () {
//                             // TODO: Langsung bawa ke halaman Checkout
//                           },
//                           child: const Text('BUY NOW',
//                               style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                   letterSpacing: 1)),
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
  
  // State untuk Varian Warna
  List<ProductModel> _siblingColors = [];
  bool _isLoadingSiblings = false;
  int? _loadedSiblingFor; // Mencegah pemanggilan API berulang

  @override
  void initState() {
    super.initState();
    // Tarik warna saudara berdasarkan nama inisial
    _fetchSiblingColors(widget.initialProduct.name);
  }

  // --- LOGIKA VARIAN WARNA (Seperti di Vue) ---
  String _extractColorName(String fullName) {
    if (fullName.isEmpty) return "MAIN";
    final words = fullName.trim().split(" ");
    if (words.isEmpty) return "";
    final lastWord = words.last;
    return lastWord[0].toUpperCase() + lastWord.substring(1).toLowerCase();
  }

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
      'mocca': const Color(0xFF967969),
      'cream': const Color(0xFFFDF4E3),
      'sage': const Color(0xFF9DC183),
      'maroon': const Color(0xFF800000),
      'olive': const Color(0xFF808000),
      'taupe': const Color(0xFF483C32),
      'khaki': const Color(0xFFF0E68C),
    };
    return map[colorName.toLowerCase()] ?? Colors.grey.shade300;
  }

  Future<void> _fetchSiblingColors(String productName) async {
    if (productName.isEmpty) return;
    setState(() => _isLoadingSiblings = true);

    try {
      final words = productName.trim().split(" ");
      String rootName = productName;
      if (words.length > 1) {
        words.removeLast(); // Buang kata terakhir (warna)
        rootName = words.join(" ");
      }

      // Ambil seluruh produk aktif tanpa harus pakai BLoC agar tidak merusak state detail
      final repo = ProductRepository();
      final allProducts = await repo.fetchActiveProducts();
      
      // Filter produk yang mengandung Root Name
      final siblings = allProducts
          .where((p) => p.name.toLowerCase().contains(rootName.toLowerCase()))
          .toList();

      if (mounted) {
        setState(() {
          _siblingColors = siblings.length > 1 ? siblings : [];
          _isLoadingSiblings = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSiblings = false);
    }
  }

  void _goToColorVariant(ProductModel siblingProduct) {
    if (siblingProduct.id == widget.initialProduct.id) return;
    
    // Ganti halaman dengan varian baru agar pengguna merasa mulus berpindah warna
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => ProductDetailPage(initialProduct: siblingProduct),
        transitionDuration: Duration.zero, // Tanpa animasi transisi agar terasa instan seperti di Web
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black, size: 22), onPressed: () {}),
            IconButton(icon: const Icon(Icons.favorite_border, color: Colors.black, size: 22), onPressed: () {}),
            const SizedBox(width: 8),
          ],
        ),
        
        body: BlocConsumer<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductDetailLoaded) {
              // Jika nama produk berbeda drastis dengan inisial, tarik ulang siblingnya
              if (_loadedSiblingFor != state.product.id) {
                _loadedSiblingFor = state.product.id;
                _fetchSiblingColors(state.product.name);
              }
            }
          },
          builder: (context, state) {
            ProductModel displayProduct = widget.initialProduct;
            if (state is ProductDetailLoaded) {
              displayProduct = state.product;
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _buildBreadcrumb(displayProduct),
                        _buildImageGallery(displayProduct),
                        _buildProductInfo(displayProduct),
                        _buildUrgencyBanner(displayProduct),
                        _buildVariations(displayProduct),
                        _buildSpecifications(displayProduct),
                        _buildAccordions(displayProduct),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                _buildBottomActions(displayProduct), // Sticky di bawah
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget _buildBreadcrumb(ProductModel product) {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
  //     child: Row(
  //       children: [
  //         const Text('HOME / COLLECTIONS / ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
  //         if (product.category != null)
  //           Text('${product.category!['name'].toString().toUpperCase()} / ', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
  //         Expanded(
  //           child: Text(product.name.toUpperCase(), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 1.5)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildImageGallery(ProductModel product) {
    List<String> images = [];
    if (product.image != null) images.add(product.image!);
    images.addAll(product.variantImages);

    bool hasDiscount = product.discountPrice != null && product.discountPrice! > 0;
    
    // Asumsi: New Arrival jika ID produk cukup tinggi (karena tidak ada parameter created_at di Dart Model Anda)
    // Bisa disesuaikan jika API menambahkan createdAt
    bool isNewArrival = product.id > 50; 

    if (images.isEmpty) {
      return Container(height: 350, color: Colors.grey.shade100, child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            SizedBox(
              height: 400,
              child: PageView.builder(
                physics: const BouncingScrollPhysics(),
                onPageChanged: (idx) => setState(() => _activeImageIndex = idx),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Image.network(images[index], fit: BoxFit.cover);
                },
              ),
            ),
            
            // Badges Kiri Atas
            Positioned(
              top: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasDiscount)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      color: Colors.red.shade700,
                      child: Text(
                        'SALE -${((product.price - product.discountPrice!) / product.price * 100).round()}%',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                    ),
                  if (isNewArrival)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      color: Colors.black,
                      child: const Text(
                        'NEW ARRIVAL',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                    ),
                ],
              ),
            ),

            // Indikator Titik
            if (images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: _activeImageIndex == index ? 24 : 6,
                      decoration: BoxDecoration(
                        color: _activeImageIndex == index ? Colors.black : Colors.white70,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(ProductModel product) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    bool hasDiscount = product.discountPrice != null && product.discountPrice! > 0;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👇 DATA ASLI: Jika total terjual ada, tampilkan. Jika 0, sembunyikan (Tanpa Dummy!) 👇
          if (product.totalSold > 0) ...[
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Text('Terjual ${product.totalSold}+', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 12),
          ],

          Text(
            product.name.toUpperCase(),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, fontFamily: 'serif', height: 1.1, letterSpacing: -0.5),
          ),
          const SizedBox(height: 16),
          
          if (hasDiscount) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(currencyFormat.format(product.discountPrice), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.red)),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: Text(currencyFormat.format(product.price), style: const TextStyle(fontSize: 14, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                ),
              ],
            ),
          ] else ...[
            Text(currencyFormat.format(product.price), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black)),
          ],
        ],
      ),
    );
  }

  Widget _buildUrgencyBanner(ProductModel product) {
    if (product.stock <= 0 || product.stock > 5) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.circle),
              child: const Text('🔥', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SELLING FAST!', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.orange.shade900, letterSpacing: 1.5)),
                  const SizedBox(height: 2),
                  Text('Hurry, only ${product.stock} items left in stock.', style: TextStyle(fontSize: 12, color: Colors.orange.shade800, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariations(ProductModel product) {
    if (_isLoadingSiblings) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
      );
    }

    if (_siblingColors.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('COLORS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey)),
              Text(_extractColorName(product.name).toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _siblingColors.map((sibling) {
              final colorName = _extractColorName(sibling.name);
              bool isSelected = product.id == sibling.id;
              
              return GestureDetector(
                onTap: () => _goToColorVariant(sibling),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.grey.shade100 : Colors.white,
                    border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300, width: isSelected ? 2 : 1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          color: _getColorHex(colorName), 
                          shape: BoxShape.circle, 
                          border: Border.all(color: Colors.black12)
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(colorName.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.grey.shade600)),
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
    bool hasSpecs = product.material != null || product.weight != null || product.length != null || product.strapLength.isNotEmpty;
    if (!hasSpecs) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
        child: Column(
          children: [
            if (product.material != null) _buildSpecRow('MATERIAL', product.material!),
            if (product.weight != null) _buildSpecRow('WEIGHT', '${product.weight} gram'),
            if (product.length != null) _buildSpecRow('DIMENSIONS', '${product.length} x ${product.width} x ${product.height} cm'),
            if (product.strapLength.isNotEmpty) _buildSpecRow('STRAP', product.strapLength.join(', ')),
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
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87))),
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
              title: const Text('DESCRIPTION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Text(product.description ?? 'Tidak ada deskripsi tersedia.', style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5)),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text('DESIGN DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Text(product.design ?? 'Tidak ada detail desain.', style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5)),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: const ExpansionTile(
              title: Text('SHIPPING & RETURNS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
              childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Text('Free shipping on all orders over Rp 500.000. Returns are accepted within 7 days of receiving the item. The product must be in its original, unworn condition.', style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5)),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
        ],
      ),
    );
  }

  Widget _buildBottomActions(ProductModel product) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), 
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Quantity Selector
            Container(
              height: 50,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: () => setState(() { if (_quantity > 1) _quantity--; })),
                  SizedBox(width: 20, child: Text('$_quantity', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () => setState(() { if (_quantity < product.stock) _quantity++; })),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Action Buttons
            Expanded(
              child: product.stock <= 0
                ? Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                    child: const Text('OUT OF STOCK', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(color: Colors.black, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil ditambahkan ke Tas!'), backgroundColor: Colors.green));
                          },
                          child: const Text('ADD TO BAG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 1)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            // TODO: Pindah ke halaman cart/checkout
                          },
                          child: const Text('BUY NOW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                        ),
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}