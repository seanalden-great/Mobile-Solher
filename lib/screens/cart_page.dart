// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import '../blocs/cart/cart_bloc.dart';
// import '../blocs/cart/cart_event.dart';
// import '../blocs/cart/cart_state.dart';
// import '../models/cart_model.dart';
// import 'product_detail_page.dart';

// class CartPage extends StatefulWidget {
//   const CartPage({super.key});

//   @override
//   State<CartPage> createState() => _CartPageState();
// }

// class _CartPageState extends State<CartPage> {
//   // Simpan ID barang yang dicentang
//   List<int> _selectedIds = [];
//   bool _isAllSelected = false;

//   @override
//   void initState() {
//     super.initState();
//     context.read<CartBloc>().add(FetchCartEvent());
//   }

//   void _toggleSelectAll(bool? val, List<CartModel> items) {
//     setState(() {
//       _isAllSelected = val ?? false;
//       if (_isAllSelected) {
//         _selectedIds = items.map((e) => e.id).toList();
//       } else {
//         _selectedIds.clear();
//       }
//     });
//   }

//   void _toggleItem(bool? val, int id, List<CartModel> items) {
//     setState(() {
//       if (val == true) {
//         _selectedIds.add(id);
//       } else {
//         _selectedIds.remove(id);
//       }
//       _isAllSelected = _selectedIds.length == items.length;
//     });
//   }

//   num _calculateSubtotal(List<CartModel> items) {
//     num total = 0;
//     for (var item in items) {
//       if (_selectedIds.contains(item.id) && item.product != null) {
//         total += (item.product!.price * item.quantity);
//       }
//     }
//     return total;
//   }

//   num _calculateSaved(List<CartModel> items) {
//     num saved = 0;
//     for (var item in items) {
//       if (_selectedIds.contains(item.id) && item.product != null) {
//         if (item.product!.discountPrice != null &&
//             item.product!.discountPrice! > 0) {
//           saved += ((item.product!.price - item.product!.discountPrice!) *
//               item.quantity);
//         }
//       }
//     }
//     return saved; // Tambahkan bundleDiscount dari backend jika Anda mau di sini
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currencyFormat =
//         NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

//     return Scaffold(
//       backgroundColor: const Color(0xFFFAFAFA),
//       appBar: AppBar(
//         title: const Text('YOUR BAG',
//             style: TextStyle(
//                 fontWeight: FontWeight.w900,
//                 fontFamily: 'serif',
//                 letterSpacing: 1)),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//       ),
//       body: BlocConsumer<CartBloc, CartState>(
//         listener: (context, state) {
//           if (state is CartActionSuccess) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content: Text(state.message), backgroundColor: Colors.black));
//           } else if (state is CartError) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content: Text(state.message), backgroundColor: Colors.red));
//           }
//         },
//         builder: (context, state) {
//           if (state is CartLoading && state is! CartLoaded) {
//             return const Center(
//                 child: CircularProgressIndicator(color: Colors.black));
//           }

//           if (state is CartLoaded) {
//             final items = state.items;
//             if (items.isEmpty) {
//               return _buildEmptyCart(context);
//             }

//             final subtotal = _calculateSubtotal(items);
//             final saved = _calculateSaved(items) + state.summary.bundleDiscount;
//             final grandTotal = subtotal - saved;

//             return Column(
//               children: [
//                 Expanded(
//                   child: SingleChildScrollView(
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // CHECKBOX SELECT ALL & DELETE
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Checkbox(
//                                   value: _isAllSelected ||
//                                       (_selectedIds.length == items.length &&
//                                           items.isNotEmpty),
//                                   onChanged: (val) =>
//                                       _toggleSelectAll(val, items),
//                                   activeColor: Colors.black,
//                                 ),
//                                 const Text('PILIH SEMUA',
//                                     style: TextStyle(
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold,
//                                         letterSpacing: 1)),
//                               ],
//                             ),
//                             if (_selectedIds.isNotEmpty)
//                               TextButton(
//                                 onPressed: () {
//                                   // Hapus satu-satu (bisa diupgrade API bulk delete)
//                                   for (var id in _selectedIds) {
//                                     context
//                                         .read<CartBloc>()
//                                         .add(DeleteCartItemEvent(id));
//                                   }
//                                   setState(() {
//                                     _selectedIds.clear();
//                                     _isAllSelected = false;
//                                   });
//                                 },
//                                 child: const Text('HAPUS TERPILIH',
//                                     style: TextStyle(
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.red,
//                                         letterSpacing: 1)),
//                               )
//                           ],
//                         ),
//                         const Divider(color: Colors.black12),
//                         const SizedBox(height: 8),

//                         // DAFTAR ITEM KERANJANG
//                         ...items.map((item) {
//                           if (item.product == null)
//                             return const SizedBox.shrink();
//                           bool hasDiscount =
//                               item.product!.discountPrice != null &&
//                                   item.product!.discountPrice! > 0;
//                           num activePrice = hasDiscount
//                               ? item.product!.discountPrice!
//                               : item.product!.price;

//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 20),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Checkbox(
//                                   value: _selectedIds.contains(item.id),
//                                   onChanged: (val) =>
//                                       _toggleItem(val, item.id, items),
//                                   activeColor: Colors.black,
//                                 ),
//                                 GestureDetector(
//                                   onTap: () => Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (_) => ProductDetailPage(
//                                               initialProduct: item.product!))),
//                                   child: Container(
//                                     width: 100,
//                                     height: 120,
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey.shade100,
//                                       borderRadius: BorderRadius.circular(16),
//                                       image: item.product!.image != null
//                                           ? DecorationImage(
//                                               image: NetworkImage(
//                                                   item.product!.image!),
//                                               fit: BoxFit.cover)
//                                           : null,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(item.product!.name.toUpperCase(),
//                                           style: const TextStyle(
//                                               fontSize: 13,
//                                               fontWeight: FontWeight.bold,
//                                               letterSpacing: 0.5),
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis),
//                                       const SizedBox(height: 6),
//                                       if (item.color != null)
//                                         Text('Warna: ${item.color}',
//                                             style: const TextStyle(
//                                                 fontSize: 11,
//                                                 color: Colors.grey)),
//                                       const SizedBox(height: 6),
//                                       if (hasDiscount) ...[
//                                         Text(
//                                             currencyFormat.format(
//                                                 activePrice * item.quantity),
//                                             style: const TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w900,
//                                                 color: Colors.black)),
//                                         Text(
//                                             currencyFormat.format(
//                                                 item.product!.price *
//                                                     item.quantity),
//                                             style: const TextStyle(
//                                                 fontSize: 11,
//                                                 color: Colors.grey,
//                                                 decoration: TextDecoration
//                                                     .lineThrough)),
//                                       ] else ...[
//                                         Text(
//                                             currencyFormat.format(
//                                                 activePrice * item.quantity),
//                                             style: const TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w900,
//                                                 color: Colors.black)),
//                                       ],
//                                       const SizedBox(height: 12),
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Container(
//                                             decoration: BoxDecoration(
//                                                 border: Border.all(
//                                                     color:
//                                                         Colors.grey.shade300),
//                                                 borderRadius:
//                                                     BorderRadius.circular(8)),
//                                             child: Row(
//                                               children: [
//                                                 IconButton(
//                                                     icon: const Icon(
//                                                         Icons.remove,
//                                                         size: 14),
//                                                     padding: EdgeInsets.zero,
//                                                     constraints:
//                                                         const BoxConstraints(),
//                                                     onPressed: () {
//                                                       if (item.quantity > 1)
//                                                         context
//                                                             .read<CartBloc>()
//                                                             .add(UpdateCartQtyEvent(
//                                                                 item.id,
//                                                                 item.quantity -
//                                                                     1));
//                                                     }),
//                                                 Padding(
//                                                   padding: const EdgeInsets
//                                                       .symmetric(
//                                                       horizontal: 12),
//                                                   child: Text(
//                                                       '${item.quantity}',
//                                                       style: const TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.bold)),
//                                                 ),
//                                                 IconButton(
//                                                     icon: const Icon(Icons.add,
//                                                         size: 14),
//                                                     padding: EdgeInsets.zero,
//                                                     constraints:
//                                                         const BoxConstraints(),
//                                                     onPressed: () {
//                                                       if (item.quantity <
//                                                           item.product!.stock)
//                                                         context
//                                                             .read<CartBloc>()
//                                                             .add(UpdateCartQtyEvent(
//                                                                 item.id,
//                                                                 item.quantity +
//                                                                     1));
//                                                     }),
//                                               ],
//                                             ),
//                                           ),
//                                           IconButton(
//                                             icon: const Icon(
//                                                 Icons.delete_outline,
//                                                 color: Colors.red),
//                                             onPressed: () => context
//                                                 .read<CartBloc>()
//                                                 .add(DeleteCartItemEvent(
//                                                     item.id)),
//                                           )
//                                         ],
//                                       )
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // ORDER SUMMARY
//                 Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 20,
//                           offset: const Offset(0, -5))
//                     ],
//                     borderRadius:
//                         const BorderRadius.vertical(top: Radius.circular(30)),
//                   ),
//                   child: SafeArea(
//                     top: false,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text('ORDER SUMMARY',
//                             style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w900,
//                                 letterSpacing: 1.5)),
//                         const SizedBox(height: 16),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text('Subtotal (${_selectedIds.length} items)',
//                                 style: const TextStyle(
//                                     fontSize: 12, color: Colors.grey)),
//                             Text(currencyFormat.format(subtotal),
//                                 style: const TextStyle(
//                                     fontSize: 12, fontWeight: FontWeight.bold)),
//                           ],
//                         ),
//                         if (saved > 0) ...[
//                           const SizedBox(height: 8),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('Total Saved',
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.green,
//                                       fontWeight: FontWeight.bold)),
//                               Text('- ${currencyFormat.format(saved)}',
//                                   style: const TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.green)),
//                             ],
//                           ),
//                         ],
//                         const Padding(
//                             padding: EdgeInsets.symmetric(vertical: 12),
//                             child: Divider()),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text('ESTIMATED TOTAL',
//                                 style: TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 1.5)),
//                             Text(currencyFormat.format(grandTotal),
//                                 style: const TextStyle(
//                                     fontSize: 22, fontWeight: FontWeight.w900)),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.black,
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 16),
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(16))),
//                             onPressed: _selectedIds.isEmpty
//                                 ? null
//                                 : () {
//                                     // TODO: Navigasi ke Halaman Pembayaran Checkout
//                                   },
//                             child: const Text('CHECKOUT NOW',
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 2)),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             );
//           }

//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyCart(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.shopping_bag_outlined,
//               size: 80, color: Colors.grey.shade300),
//           const SizedBox(height: 24),
//           const Text('Tas Belanja Kosong',
//               style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'serif')),
//           const SizedBox(height: 8),
//           const Text('Temukan gaya baru untuk melengkapi penampilan Anda.',
//               style: TextStyle(color: Colors.grey, fontSize: 12)),
//           const SizedBox(height: 32),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30))),
//             onPressed: () => Navigator.pop(context),
//             child: const Text('LANJUTKAN BELANJA',
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1)),
//           )
//         ],
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import '../blocs/cart/cart_bloc.dart';
// import '../blocs/cart/cart_event.dart';
// import '../blocs/cart/cart_state.dart';
// import '../models/cart_model.dart';
// import 'product_detail_page.dart';

// class CartPage extends StatefulWidget {
//   const CartPage({super.key});

//   @override
//   State<CartPage> createState() => _CartPageState();
// }

// class _CartPageState extends State<CartPage> {
//   List<int> _selectedIds = [];
//   bool _isAllSelected = false;

//   // 👇 [BARU] STATE LOKAL UNTUK OPTIMISTIC UI 👇
//   List<CartModel> _currentItems = [];
//   CartSummaryModel? _currentSummary;
//   final Map<int, int> _optimisticQty = {};
//   final Map<int, Timer> _debounceTimers = {};

//   @override
//   void initState() {
//     super.initState();
//     context.read<CartBloc>().add(FetchCartEvent());
//   }

//   @override
//   void dispose() {
//     // Bersihkan semua timer di memori saat halaman ditutup
//     for (var timer in _debounceTimers.values) {
//       timer.cancel();
//     }
//     super.dispose();
//   }

//   // --- LOGIKA OPTIMISTIC UI & DEBOUNCE ---
//   void _dispatchUpdateQty(int cartId, int newQty) {
//     // Batalkan pengiriman sebelumnya jika user klik dengan cepat
//     _debounceTimers[cartId]?.cancel();

//     // Tunda 500ms. Jika tidak ada klik lagi, baru tembak ke backend!
//     _debounceTimers[cartId] = Timer(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         context.read<CartBloc>().add(UpdateCartQtyEvent(cartId, newQty));
//       }
//     });
//   }

//   void _toggleSelectAll(bool? val, List<CartModel> items) {
//     setState(() {
//       _isAllSelected = val ?? false;
//       if (_isAllSelected) {
//         _selectedIds = items.map((e) => e.id).toList();
//       } else {
//         _selectedIds.clear();
//       }
//     });
//   }

//   void _toggleItem(bool? val, int id, List<CartModel> items) {
//     setState(() {
//       if (val == true) {
//         _selectedIds.add(id);
//       } else {
//         _selectedIds.remove(id);
//       }
//       _isAllSelected = _selectedIds.length == items.length;
//     });
//   }

//   // 👇 Modifikasi kalkulasi menggunakan nilai Optimistic 👇
//   num _calculateSubtotal(List<CartModel> items) {
//     num total = 0;
//     for (var item in items) {
//       if (_selectedIds.contains(item.id) && item.product != null) {
//         int qty = _optimisticQty[item.id] ?? item.quantity;
//         total += (item.product!.price * qty);
//       }
//     }
//     return total;
//   }

//   num _calculateSaved(List<CartModel> items) {
//     num saved = 0;
//     for (var item in items) {
//       if (_selectedIds.contains(item.id) && item.product != null) {
//         int qty = _optimisticQty[item.id] ?? item.quantity;
//         if (item.product!.discountPrice != null &&
//             item.product!.discountPrice! > 0) {
//           saved += ((item.product!.price - item.product!.discountPrice!) * qty);
//         }
//       }
//     }
//     return saved;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currencyFormat =
//         NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

//     return Scaffold(
//       backgroundColor: const Color(0xFFFAFAFA),
//       appBar: AppBar(
//         title: const Text('YOUR BAG',
//             style: TextStyle(
//                 fontWeight: FontWeight.w900,
//                 fontFamily: 'serif',
//                 letterSpacing: 1)),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//       ),
//       body: BlocConsumer<CartBloc, CartState>(
//         listener: (context, state) {
//           if (state is CartActionSuccess) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content: Text(state.message), backgroundColor: Colors.black));
//           } else if (state is CartError) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content: Text(state.message), backgroundColor: Colors.red));
//           } else if (state is CartLoaded) {
//             // 👇 Sinkronkan data API dengan cache lokal 👇
//             setState(() {
//               _currentItems = state.items;
//               _currentSummary = state.summary;
//               // Reset nilai optimistic agar sama dengan server
//               for (var item in state.items) {
//                 _optimisticQty[item.id] = item.quantity;
//               }
//             });
//           }
//         },
//         builder: (context, state) {
//           // Hanya tampilkan putaran (spinner) penuh saat keranjang masih kosong
//           if (state is CartLoading && _currentItems.isEmpty) {
//             return const Center(
//                 child: CircularProgressIndicator(color: Colors.black));
//           }

//           if (_currentItems.isEmpty && state is CartLoaded) {
//             return _buildEmptyCart(context);
//           } else if (_currentItems.isEmpty) {
//             return const SizedBox.shrink(); // Menahan layar berkedip sesaat
//           }

//           // Gunakan _currentItems agar data tidak hilang sesaat ketika statusnya CartLoading
//           final items = _currentItems;
//           final subtotal = _calculateSubtotal(items);
//           final saved =
//               _calculateSaved(items) + (_currentSummary?.bundleDiscount ?? 0);
//           final grandTotal = subtotal - saved;

//           return Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // CHECKBOX SELECT ALL & DELETE
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Checkbox(
//                                 value: _isAllSelected ||
//                                     (_selectedIds.length == items.length &&
//                                         items.isNotEmpty),
//                                 onChanged: (val) =>
//                                     _toggleSelectAll(val, items),
//                                 activeColor: Colors.black,
//                               ),
//                               const Text('PILIH SEMUA',
//                                   style: TextStyle(
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 1)),
//                             ],
//                           ),
//                           if (_selectedIds.isNotEmpty)
//                             TextButton(
//                               onPressed: () {
//                                 for (var id in _selectedIds) {
//                                   context
//                                       .read<CartBloc>()
//                                       .add(DeleteCartItemEvent(id));
//                                 }
//                                 setState(() {
//                                   _selectedIds.clear();
//                                   _isAllSelected = false;
//                                 });
//                               },
//                               child: const Text('HAPUS TERPILIH',
//                                   style: TextStyle(
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.red,
//                                       letterSpacing: 1)),
//                             )
//                         ],
//                       ),
//                       const Divider(color: Colors.black12),
//                       const SizedBox(height: 8),

//                       // DAFTAR ITEM KERANJANG
//                       ...items.map((item) {
//                         if (item.product == null)
//                           return const SizedBox.shrink();

//                         bool hasDiscount =
//                             item.product!.discountPrice != null &&
//                                 item.product!.discountPrice! > 0;
//                         num activePrice = hasDiscount
//                             ? item.product!.discountPrice!
//                             : item.product!.price;

//                         // 👇 KUNCI OPTIMISTIC UI: Gunakan qty sementara jika sedang diubah 👇
//                         int currentQty =
//                             _optimisticQty[item.id] ?? item.quantity;

//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 20),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Checkbox(
//                                 value: _selectedIds.contains(item.id),
//                                 onChanged: (val) =>
//                                     _toggleItem(val, item.id, items),
//                                 activeColor: Colors.black,
//                               ),
//                               GestureDetector(
//                                 onTap: () => Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (_) => ProductDetailPage(
//                                             initialProduct: item.product!))),
//                                 child: Container(
//                                   width: 100,
//                                   height: 120,
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade100,
//                                     borderRadius: BorderRadius.circular(16),
//                                     image: item.product!.image != null
//                                         ? DecorationImage(
//                                             image: NetworkImage(
//                                                 item.product!.image!),
//                                             fit: BoxFit.cover)
//                                         : null,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(item.product!.name.toUpperCase(),
//                                         style: const TextStyle(
//                                             fontSize: 13,
//                                             fontWeight: FontWeight.bold,
//                                             letterSpacing: 0.5),
//                                         maxLines: 2,
//                                         overflow: TextOverflow.ellipsis),
//                                     const SizedBox(height: 6),
//                                     if (item.color != null)
//                                       Text('Warna: ${item.color}',
//                                           style: const TextStyle(
//                                               fontSize: 11,
//                                               color: Colors.grey)),
//                                     const SizedBox(height: 6),
//                                     if (hasDiscount) ...[
//                                       Text(
//                                           currencyFormat
//                                               .format(activePrice * currentQty),
//                                           style: const TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w900,
//                                               color: Colors.black)),
//                                       Text(
//                                           currencyFormat.format(
//                                               item.product!.price * currentQty),
//                                           style: const TextStyle(
//                                               fontSize: 11,
//                                               color: Colors.grey,
//                                               decoration:
//                                                   TextDecoration.lineThrough)),
//                                     ] else ...[
//                                       Text(
//                                           currencyFormat
//                                               .format(activePrice * currentQty),
//                                           style: const TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w900,
//                                               color: Colors.black)),
//                                     ],
//                                     const SizedBox(height: 12),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Container(
//                                           decoration: BoxDecoration(
//                                               border: Border.all(
//                                                   color: Colors.grey.shade300),
//                                               borderRadius:
//                                                   BorderRadius.circular(8)),
//                                           child: Row(
//                                             children: [
//                                               IconButton(
//                                                   icon: const Icon(Icons.remove,
//                                                       size: 14),
//                                                   padding: EdgeInsets.zero,
//                                                   constraints:
//                                                       const BoxConstraints(),
//                                                   onPressed: () {
//                                                     if (currentQty > 1) {
//                                                       setState(() =>
//                                                           _optimisticQty[
//                                                                   item.id] =
//                                                               currentQty - 1);
//                                                       _dispatchUpdateQty(
//                                                           item.id,
//                                                           currentQty - 1);
//                                                     }
//                                                   }),
//                                               Padding(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         horizontal: 12),
//                                                 child: Text('$currentQty',
//                                                     style: const TextStyle(
//                                                         fontWeight:
//                                                             FontWeight.bold)),
//                                               ),
//                                               IconButton(
//                                                   icon: const Icon(Icons.add,
//                                                       size: 14),
//                                                   padding: EdgeInsets.zero,
//                                                   constraints:
//                                                       const BoxConstraints(),
//                                                   onPressed: () {
//                                                     if (currentQty <
//                                                         item.product!.stock) {
//                                                       setState(() =>
//                                                           _optimisticQty[
//                                                                   item.id] =
//                                                               currentQty + 1);
//                                                       _dispatchUpdateQty(
//                                                           item.id,
//                                                           currentQty + 1);
//                                                     }
//                                                   }),
//                                             ],
//                                           ),
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(Icons.delete_outline,
//                                               color: Colors.red),
//                                           onPressed: () => context
//                                               .read<CartBloc>()
//                                               .add(
//                                                   DeleteCartItemEvent(item.id)),
//                                         )
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                               )
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                     ],
//                   ),
//                 ),
//               ),

//               // ORDER SUMMARY
//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 20,
//                         offset: const Offset(0, -5))
//                   ],
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(30)),
//                 ),
//                 child: SafeArea(
//                   top: false,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('ORDER SUMMARY',
//                           style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w900,
//                               letterSpacing: 1.5)),
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Subtotal (${_selectedIds.length} items)',
//                               style: const TextStyle(
//                                   fontSize: 12, color: Colors.grey)),
//                           Text(currencyFormat.format(subtotal),
//                               style: const TextStyle(
//                                   fontSize: 12, fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                       if (saved > 0) ...[
//                         const SizedBox(height: 8),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text('Total Saved',
//                                 style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.green,
//                                     fontWeight: FontWeight.bold)),
//                             Text('- ${currencyFormat.format(saved)}',
//                                 style: const TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green)),
//                           ],
//                         ),
//                       ],
//                       const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 12),
//                           child: Divider()),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text('ESTIMATED TOTAL',
//                               style: TextStyle(
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 1.5)),
//                           Text(currencyFormat.format(grandTotal),
//                               style: const TextStyle(
//                                   fontSize: 22, fontWeight: FontWeight.w900)),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.black,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16))),
//                           onPressed: _selectedIds.isEmpty
//                               ? null
//                               : () {
//                                   // TODO: Navigasi ke Halaman Pembayaran Checkout
//                                 },
//                           child: const Text('CHECKOUT NOW',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 2)),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyCart(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.shopping_bag_outlined,
//               size: 80, color: Colors.grey.shade300),
//           const SizedBox(height: 24),
//           const Text('Tas Belanja Kosong',
//               style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'serif')),
//           const SizedBox(height: 8),
//           const Text('Temukan gaya baru untuk melengkapi penampilan Anda.',
//               style: TextStyle(color: Colors.grey, fontSize: 12)),
//           const SizedBox(height: 32),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30))),
//             onPressed: () => Navigator.pop(context),
//             child: const Text('LANJUTKAN BELANJA',
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1)),
//           )
//         ],
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:solher_mobile/screens/payment_page.dart';
// import '../blocs/cart/cart_bloc.dart';
// import '../blocs/cart/cart_event.dart';
// import '../blocs/cart/cart_state.dart';
// import '../models/cart_model.dart';
// import 'product_detail_page.dart';

// class CartPage extends StatefulWidget {
//   const CartPage({super.key});

//   @override
//   State<CartPage> createState() => _CartPageState();
// }

// class _CartPageState extends State<CartPage> {
//   List<int> _selectedIds = [];
//   bool _isAllSelected = false;

//   // 👇 STATE LOKAL UNTUK OPTIMISTIC UI 👇
//   List<CartModel> _currentItems = [];
//   CartSummaryModel? _currentSummary;
//   final Map<int, int> _optimisticQty = {};
//   final Map<int, Timer> _debounceTimers = {};

//   @override
//   void initState() {
//     super.initState();
//     context.read<CartBloc>().add(FetchCartEvent());
//   }

//   @override
//   void dispose() {
//     // Bersihkan semua timer di memori saat halaman ditutup
//     for (var timer in _debounceTimers.values) {
//       timer.cancel();
//     }
//     super.dispose();
//   }

//   // --- LOGIKA OPTIMISTIC UI & DEBOUNCE YANG DISEMPURNAKAN ---
//   void _dispatchUpdateQty(int cartId, int newQty) {
//     // 1. Update UI secara instan tanpa menunggu API
//     setState(() {
//       _optimisticQty[cartId] = newQty;
//     });

//     // 2. Batalkan pengiriman sebelumnya jika user klik beruntun dengan cepat
//     _debounceTimers[cartId]?.cancel();

//     // 3. Tunda 1 Detik (1000ms). Jika tidak ada interaksi lagi, sinkronkan ke server!
//     _debounceTimers[cartId] = Timer(const Duration(milliseconds: 1000), () {
//       if (mounted) {
//         context.read<CartBloc>().add(UpdateCartQtyEvent(cartId, newQty));
//       }
//     });
//   }

//   void _toggleSelectAll(bool? val, List<CartModel> items) {
//     setState(() {
//       _isAllSelected = val ?? false;
//       if (_isAllSelected) {
//         _selectedIds = items.map((e) => e.id).toList();
//       } else {
//         _selectedIds.clear();
//       }
//     });
//   }

//   void _toggleItem(bool? val, int id, List<CartModel> items) {
//     setState(() {
//       if (val == true) {
//         _selectedIds.add(id);
//       } else {
//         _selectedIds.remove(id);
//       }
//       _isAllSelected = _selectedIds.length == items.length;
//     });
//   }

//   // Kalkulasi menggunakan nilai Optimistic agar Total Harga instan berubah
//   num _calculateSubtotal(List<CartModel> items) {
//     num total = 0;
//     for (var item in items) {
//       if (_selectedIds.contains(item.id) && item.product != null) {
//         int qty = _optimisticQty[item.id] ?? item.quantity;
//         total += (item.product!.price * qty);
//       }
//     }
//     return total;
//   }

//   num _calculateSaved(List<CartModel> items) {
//     num saved = 0;
//     for (var item in items) {
//       if (_selectedIds.contains(item.id) && item.product != null) {
//         int qty = _optimisticQty[item.id] ?? item.quantity;
//         if (item.product!.discountPrice != null &&
//             item.product!.discountPrice! > 0) {
//           saved += ((item.product!.price - item.product!.discountPrice!) * qty);
//         }
//       }
//     }
//     return saved;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currencyFormat =
//         NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

//     return Scaffold(
//       backgroundColor: const Color(0xFFFAFAFA),
//       appBar: AppBar(
//         title: const Text('YOUR BAG',
//             style: TextStyle(
//                 fontWeight: FontWeight.w900,
//                 fontFamily: 'serif',
//                 letterSpacing: 1)),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//       ),
//       body: BlocConsumer<CartBloc, CartState>(
//         listener: (context, state) {
//           if (state is CartActionSuccess) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content: Text(state.message), backgroundColor: Colors.black));
//           } else if (state is CartError) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content: Text(state.message), backgroundColor: Colors.red));
//             // Jika terjadi error dari server (misal stok habis), batalkan nilai optimistic
//             setState(() {
//               _optimisticQty.clear();
//             });
//           } else if (state is CartLoaded) {
//             setState(() {
//               _currentItems = state.items;
//               _currentSummary = state.summary;

//               // 👇 PERLINDUNGAN ANTI LOMPAT-LOMPAT (RACE CONDITION) 👇
//               final serverIds = state.items.map((e) => e.id).toSet();

//               _optimisticQty.removeWhere((id, optimisticValue) {
//                 // 1. Jika barang sudah dihapus dari server, hapus dari optimistic map
//                 if (!serverIds.contains(id)) return true;

//                 // 2. Cek angka dari server
//                 final serverItem = state.items.firstWhere((e) => e.id == id);

//                 // HAPUS pelindung optimistic HANYA JIKA server sudah merespon
//                 // dengan kuantitas yang SAMA PERSIS dengan interaksi terakhir user.
//                 return serverItem.quantity == optimisticValue;
//               });
//             });
//           }
//         },
//         builder: (context, state) {
//           // Hanya tampilkan putaran (spinner) penuh saat keranjang masih kosong
//           if (state is CartLoading && _currentItems.isEmpty) {
//             return const Center(
//                 child: CircularProgressIndicator(color: Colors.black));
//           }

//           if (_currentItems.isEmpty && state is CartLoaded) {
//             return _buildEmptyCart(context);
//           } else if (_currentItems.isEmpty) {
//             return const SizedBox.shrink(); // Menahan layar berkedip sesaat
//           }

//           final items = _currentItems;
//           final subtotal = _calculateSubtotal(items);
//           final saved =
//               _calculateSaved(items) + (_currentSummary?.bundleDiscount ?? 0);
//           final grandTotal = subtotal - saved;

//           return Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // CHECKBOX SELECT ALL & DELETE
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Checkbox(
//                                 value: _isAllSelected ||
//                                     (_selectedIds.length == items.length &&
//                                         items.isNotEmpty),
//                                 onChanged: (val) =>
//                                     _toggleSelectAll(val, items),
//                                 activeColor: Colors.black,
//                               ),
//                               const Text('PILIH SEMUA',
//                                   style: TextStyle(
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 1)),
//                             ],
//                           ),
//                           if (_selectedIds.isNotEmpty)
//                             TextButton(
//                               onPressed: () {
//                                 for (var id in _selectedIds) {
//                                   // Hapus pelindung optimistik karena barang dihapus
//                                   _optimisticQty.remove(id);
//                                   context
//                                       .read<CartBloc>()
//                                       .add(DeleteCartItemEvent(id));
//                                 }
//                                 setState(() {
//                                   _selectedIds.clear();
//                                   _isAllSelected = false;
//                                 });
//                               },
//                               child: const Text('HAPUS TERPILIH',
//                                   style: TextStyle(
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.red,
//                                       letterSpacing: 1)),
//                             )
//                         ],
//                       ),
//                       const Divider(color: Colors.black12),
//                       const SizedBox(height: 8),

//                       // DAFTAR ITEM KERANJANG
//                       ...items.map((item) {
//                         if (item.product == null)
//                           return const SizedBox.shrink();

//                         bool hasDiscount =
//                             item.product!.discountPrice != null &&
//                                 item.product!.discountPrice! > 0;
//                         num activePrice = hasDiscount
//                             ? item.product!.discountPrice!
//                             : item.product!.price;

//                         // 👇 KUNCI UI: Tampilkan nilai sementara (optimistic) jika ada 👇
//                         int currentQty =
//                             _optimisticQty[item.id] ?? item.quantity;

//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 20),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Checkbox(
//                                 value: _selectedIds.contains(item.id),
//                                 onChanged: (val) =>
//                                     _toggleItem(val, item.id, items),
//                                 activeColor: Colors.black,
//                               ),
//                               GestureDetector(
//                                 onTap: () => Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (_) => ProductDetailPage(
//                                             initialProduct: item.product!))),
//                                 child: Container(
//                                   width: 100,
//                                   height: 120,
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade100,
//                                     borderRadius: BorderRadius.circular(16),
//                                     image: item.product!.image != null
//                                         ? DecorationImage(
//                                             image: NetworkImage(
//                                                 item.product!.image!),
//                                             fit: BoxFit.cover)
//                                         : null,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(item.product!.name.toUpperCase(),
//                                         style: const TextStyle(
//                                             fontSize: 13,
//                                             fontWeight: FontWeight.bold,
//                                             letterSpacing: 0.5),
//                                         maxLines: 2,
//                                         overflow: TextOverflow.ellipsis),
//                                     const SizedBox(height: 6),
//                                     if (item.color != null)
//                                       Text('Warna: ${item.color}',
//                                           style: const TextStyle(
//                                               fontSize: 11,
//                                               color: Colors.grey)),
//                                     const SizedBox(height: 6),
//                                     if (hasDiscount) ...[
//                                       Text(
//                                           currencyFormat
//                                               .format(activePrice * currentQty),
//                                           style: const TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w900,
//                                               color: Colors.black)),
//                                       Text(
//                                           currencyFormat.format(
//                                               item.product!.price * currentQty),
//                                           style: const TextStyle(
//                                               fontSize: 11,
//                                               color: Colors.grey,
//                                               decoration:
//                                                   TextDecoration.lineThrough)),
//                                     ] else ...[
//                                       Text(
//                                           currencyFormat
//                                               .format(activePrice * currentQty),
//                                           style: const TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w900,
//                                               color: Colors.black)),
//                                     ],
//                                     const SizedBox(height: 12),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Container(
//                                           decoration: BoxDecoration(
//                                               border: Border.all(
//                                                   color: Colors.grey.shade300),
//                                               borderRadius:
//                                                   BorderRadius.circular(8)),
//                                           child: Row(
//                                             children: [
//                                               IconButton(
//                                                   icon: const Icon(Icons.remove,
//                                                       size: 14),
//                                                   padding: EdgeInsets.zero,
//                                                   constraints:
//                                                       const BoxConstraints(),
//                                                   onPressed: () {
//                                                     if (currentQty > 1) {
//                                                       _dispatchUpdateQty(
//                                                           item.id,
//                                                           currentQty - 1);
//                                                     }
//                                                   }),
//                                               Padding(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         horizontal: 12),
//                                                 child: Text('$currentQty',
//                                                     style: const TextStyle(
//                                                         fontWeight:
//                                                             FontWeight.bold)),
//                                               ),
//                                               IconButton(
//                                                   icon: const Icon(Icons.add,
//                                                       size: 14),
//                                                   padding: EdgeInsets.zero,
//                                                   constraints:
//                                                       const BoxConstraints(),
//                                                   onPressed: () {
//                                                     if (currentQty <
//                                                         item.product!.stock) {
//                                                       _dispatchUpdateQty(
//                                                           item.id,
//                                                           currentQty + 1);
//                                                     }
//                                                   }),
//                                             ],
//                                           ),
//                                         ),
//                                         IconButton(
//                                             icon: const Icon(
//                                                 Icons.delete_outline,
//                                                 color: Colors.red),
//                                             onPressed: () {
//                                               _optimisticQty.remove(item.id);
//                                               context.read<CartBloc>().add(
//                                                   DeleteCartItemEvent(item.id));
//                                             })
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                               )
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                     ],
//                   ),
//                 ),
//               ),

//               // ORDER SUMMARY
//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 20,
//                         offset: const Offset(0, -5))
//                   ],
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(30)),
//                 ),
//                 child: SafeArea(
//                   top: false,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('ORDER SUMMARY',
//                           style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w900,
//                               letterSpacing: 1.5)),
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Subtotal (${_selectedIds.length} items)',
//                               style: const TextStyle(
//                                   fontSize: 12, color: Colors.grey)),
//                           Text(currencyFormat.format(subtotal),
//                               style: const TextStyle(
//                                   fontSize: 12, fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                       if (saved > 0) ...[
//                         const SizedBox(height: 8),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text('Total Saved',
//                                 style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.green,
//                                     fontWeight: FontWeight.bold)),
//                             Text('- ${currencyFormat.format(saved)}',
//                                 style: const TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green)),
//                           ],
//                         ),
//                       ],
//                       const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 12),
//                           child: Divider()),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text('ESTIMATED TOTAL',
//                               style: TextStyle(
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 1.5)),
//                           Text(currencyFormat.format(grandTotal),
//                               style: const TextStyle(
//                                   fontSize: 22, fontWeight: FontWeight.w900)),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.black,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16))),
//                           // onPressed: _selectedIds.isEmpty
//                           //     ? null
//                           //     : () {
//                           //         // TODO: Navigasi ke Halaman Pembayaran Checkout
//                           //       },
//                           // Cari kode ini di cart_page.dart sekitar baris paling bawah
//                           onPressed: _selectedIds.isEmpty
//                               ? null
//                               : () {
//                                   // Navigasi ke Halaman Pembayaran Checkout dengan membawa ID barang
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => PaymentPage(
//                                           selectedCartIds: _selectedIds),
//                                     ),
//                                   );
//                                 },
//                           child: const Text('CHECKOUT NOW',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 2)),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyCart(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.shopping_bag_outlined,
//               size: 80, color: Colors.grey.shade300),
//           const SizedBox(height: 24),
//           const Text('Tas Belanja Kosong',
//               style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'serif')),
//           const SizedBox(height: 8),
//           const Text('Temukan gaya baru untuk melengkapi penampilan Anda.',
//               style: TextStyle(color: Colors.grey, fontSize: 12)),
//           const SizedBox(height: 32),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30))),
//             onPressed: () => Navigator.pop(context),
//             child: const Text('LANJUTKAN BELANJA',
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1)),
//           )
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:solher_mobile/blocs/address/address_bloc.dart';
import 'package:solher_mobile/blocs/checkout/checkout_bloc.dart';
import 'package:solher_mobile/repositories/address_repository.dart';
import 'package:solher_mobile/repositories/checkout_repository.dart';

import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_event.dart';
import '../blocs/cart/cart_state.dart';
import '../models/cart_model.dart';
import 'product_detail_page.dart';
import 'payment_page.dart'; // PENTING: Import Payment Page

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<int> _selectedIds = [];
  bool _isAllSelected = false;

  // 👇 STATE LOKAL UNTUK OPTIMISTIC UI 👇
  List<CartModel> _currentItems = [];
  CartSummaryModel? _currentSummary;
  final Map<int, int> _optimisticQty = {};
  final Map<int, Timer> _debounceTimers = {};

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(FetchCartEvent());
  }

  @override
  void dispose() {
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  void _dispatchUpdateQty(int cartId, int newQty) {
    setState(() {
      _optimisticQty[cartId] = newQty;
    });

    _debounceTimers[cartId]?.cancel();

    _debounceTimers[cartId] = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        context.read<CartBloc>().add(UpdateCartQtyEvent(cartId, newQty));
      }
    });
  }

  void _toggleSelectAll(bool? val, List<CartModel> items) {
    setState(() {
      _isAllSelected = val ?? false;
      if (_isAllSelected) {
        _selectedIds = items.map((e) => e.id).toList();
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _toggleItem(bool? val, int id, List<CartModel> items) {
    setState(() {
      if (val == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
      _isAllSelected = _selectedIds.length == items.length;
    });
  }

  num _calculateSubtotal(List<CartModel> items) {
    num total = 0;
    for (var item in items) {
      if (_selectedIds.contains(item.id) && item.product != null) {
        int qty = _optimisticQty[item.id] ?? item.quantity;
        total += (item.product!.price * qty);
      }
    }
    return total;
  }

  num _calculateSaved(List<CartModel> items) {
    num saved = 0;
    for (var item in items) {
      if (_selectedIds.contains(item.id) && item.product != null) {
        int qty = _optimisticQty[item.id] ?? item.quantity;
        if (item.product!.discountPrice != null &&
            item.product!.discountPrice! > 0) {
          saved += ((item.product!.price - item.product!.discountPrice!) * qty);
        }
      }
    }
    return saved;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Your Cart',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
                letterSpacing: 1)),
        backgroundColor: Colors.grey[500],
        foregroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message), backgroundColor: Colors.black));
          } else if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message), backgroundColor: Colors.red));
            setState(() {
              _optimisticQty.clear();
            });
          } else if (state is CartLoaded) {
            setState(() {
              _currentItems = state.items;
              _currentSummary = state.summary;

              final serverIds = state.items.map((e) => e.id).toSet();

              _optimisticQty.removeWhere((id, optimisticValue) {
                if (!serverIds.contains(id)) return true;
                final serverItem = state.items.firstWhere((e) => e.id == id);
                return serverItem.quantity == optimisticValue;
              });
            });
          }
        },
        builder: (context, state) {
          if (state is CartLoading && _currentItems.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          }

          if (_currentItems.isEmpty && state is CartLoaded) {
            return _buildEmptyCart(context);
          } else if (_currentItems.isEmpty) {
            return const SizedBox.shrink();
          }

          final items = _currentItems;
          final subtotal = _calculateSubtotal(items);
          final saved =
              _calculateSaved(items) + (_currentSummary?.bundleDiscount ?? 0);
          final grandTotal = subtotal - saved;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CHECKBOX SELECT ALL & DELETE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _isAllSelected ||
                                    (_selectedIds.length == items.length &&
                                        items.isNotEmpty),
                                onChanged: (val) =>
                                    _toggleSelectAll(val, items),
                                activeColor: Colors.black,
                              ),
                              const Text('PILIH SEMUA',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1)),
                            ],
                          ),
                          if (_selectedIds.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                for (var id in _selectedIds) {
                                  _optimisticQty.remove(id);
                                  context
                                      .read<CartBloc>()
                                      .add(DeleteCartItemEvent(id));
                                }
                                setState(() {
                                  _selectedIds.clear();
                                  _isAllSelected = false;
                                });
                              },
                              child: const Text('HAPUS TERPILIH',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      letterSpacing: 1)),
                            )
                        ],
                      ),
                      const Divider(color: Colors.black12),
                      const SizedBox(height: 8),

                      // DAFTAR ITEM KERANJANG
                      ...items.map((item) {
                        if (item.product == null)
                          return const SizedBox.shrink();

                        bool hasDiscount =
                            item.product!.discountPrice != null &&
                                item.product!.discountPrice! > 0;
                        num activePrice = hasDiscount
                            ? item.product!.discountPrice!
                            : item.product!.price;

                        int currentQty =
                            _optimisticQty[item.id] ?? item.quantity;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _selectedIds.contains(item.id),
                                onChanged: (val) =>
                                    _toggleItem(val, item.id, items),
                                activeColor: Colors.black,
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ProductDetailPage(
                                            initialProduct: item.product!))),
                                child: Container(
                                  width: 100,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                    image: item.product!.image != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                                item.product!.image!),
                                            fit: BoxFit.cover)
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product!.name.toUpperCase(),
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    if (item.color != null)
                                      Text('Warna: ${item.color}',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey)),
                                    const SizedBox(height: 6),
                                    if (hasDiscount) ...[
                                      Text(
                                          currencyFormat
                                              .format(activePrice * currentQty),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black)),
                                      Text(
                                          currencyFormat.format(
                                              item.product!.price * currentQty),
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough)),
                                    ] else ...[
                                      Text(
                                          currencyFormat
                                              .format(activePrice * currentQty),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black)),
                                    ],
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                  icon: const Icon(Icons.remove,
                                                      size: 14),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  onPressed: () {
                                                    if (currentQty > 1) {
                                                      _dispatchUpdateQty(
                                                          item.id,
                                                          currentQty - 1);
                                                    }
                                                  }),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12),
                                                child: Text('$currentQty',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              IconButton(
                                                  icon: const Icon(Icons.add,
                                                      size: 14),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  onPressed: () {
                                                    if (currentQty <
                                                        item.product!.stock) {
                                                      _dispatchUpdateQty(
                                                          item.id,
                                                          currentQty + 1);
                                                    }
                                                  }),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              color: Colors.red),
                                          onPressed: () {
                                            _optimisticQty.remove(item.id);
                                            context.read<CartBloc>().add(
                                                DeleteCartItemEvent(item.id));
                                          },
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              // ORDER SUMMARY
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5))
                  ],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ORDER SUMMARY',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal (${_selectedIds.length} items)',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          Text(currencyFormat.format(subtotal),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (saved > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Saved',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)),
                            Text('- ${currencyFormat.format(saved)}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                          ],
                        ),
                      ],
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ESTIMATED TOTAL',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5)),
                          Text(currencyFormat.format(grandTotal),
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          // onPressed: _selectedIds.isEmpty
                          //     ? null
                          //     : () {
                          //         // 👇 PENGAMANAN DELAY NAVIGASI 👇
                          //         Future.microtask(() {
                          //           if (mounted) {
                          //             Navigator.push(
                          //               context,
                          //               MaterialPageRoute(
                          //                 builder: (_) => PaymentPage(
                          //                     selectedCartIds: _selectedIds),
                          //               ),
                          //             );
                          //           }
                          //         });
                          //       },

                          // onPressed: _selectedIds.isEmpty
                          //     ? null
                          //     : () {
                          //         // 👇 PERBAIKAN: Suntikkan BLoC saat navigasi 👇
                          //         Future.microtask(() {
                          //           if (mounted) {
                          //             Navigator.push(
                          //               context,
                          //               MaterialPageRoute(
                          //                 builder: (_) => MultiBlocProvider(
                          //                   providers: [
                          //                     BlocProvider(
                          //                       create: (context) => AddressBloc(
                          //                           addressRepository:
                          //                               AddressRepository()),
                          //                     ),
                          //                     BlocProvider(
                          //                       create: (context) => CheckoutBloc(
                          //                           repository:
                          //                               CheckoutRepository()),
                          //                     ),
                          //                   ],
                          //                   child: PaymentPage(
                          //                       selectedCartIds: _selectedIds),
                          //                 ),
                          //               ),
                          //             );
                          //           }
                          //         });
                          //       },
                          onPressed: _selectedIds.isEmpty
                              ? null
                              : () {
                                  // 👇 PERBAIKAN MUTLAK: Bawa memori CartBloc yang sudah matang ke PaymentPage 👇
                                  Future.microtask(() {
                                    if (mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: context.read<CartBloc>(),
                                            child: PaymentPage(
                                                selectedCartIds: _selectedIds),
                                          ),
                                        ),
                                      );
                                    }
                                  });
                                },
                          child: const Text('CHECKOUT NOW',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2)),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          const Text('Tas Belanja Kosong',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif')),
          const SizedBox(height: 8),
          const Text('Temukan gaya baru untuk melengkapi penampilan Anda.',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            onPressed: () => Navigator.pop(context),
            child: const Text('LANJUTKAN BELANJA',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
          )
        ],
      ),
    );
  }
}
