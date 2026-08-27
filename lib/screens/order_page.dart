// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:solher_mobile/models/transaction_models.dart';
// import '../blocs/order/order_bloc.dart';
// import '../blocs/order/order_event.dart';
// import '../blocs/order/order_state.dart';
// import '../repositories/order_repository.dart';
// import 'package:url_launcher/url_launcher.dart'; // Tambahkan ini di pubspec.yaml untuk Payment URL

// class OrderPage extends StatefulWidget {
//   const OrderPage({super.key});

//   @override
//   State<OrderPage> createState() => _OrderPageState();
// }

// class _OrderPageState extends State<OrderPage> {
//   String _activeTab = 'all';

//   final List<Map<String, String>> _tabs = [
//     {'label': 'All Orders', 'value': 'all'},
//     {'label': 'Unpaid', 'value': 'unpaid'},
//     {'label': 'To Ship', 'value': 'to_ship'},
//     {'label': 'In Transit', 'value': 'shipping'},
//     {'label': 'Completed', 'value': 'completed'},
//     {'label': 'Issues', 'value': 'issues'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//           OrderBloc(orderRepository: OrderRepository())..add(FetchOrders()),
//       child: Scaffold(
//         backgroundColor: const Color(0xFFFAFAFA),
//         appBar: AppBar(
//           title: const Text('TRACK MY ORDER',
//               style: TextStyle(
//                   fontWeight: FontWeight.w900,
//                   fontFamily: 'serif',
//                   letterSpacing: 1)),
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 1,
//         ),
//         body: Column(
//           children: [
//             _buildTabs(),
//             Expanded(
//               child: BlocConsumer<OrderBloc, OrderState>(
//                 listener: (context, state) {
//                   if (state is OrderActionSuccess) {
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                         content: Text(state.message),
//                         backgroundColor: Colors.black));
//                   } else if (state is OrderError) {
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                         content: Text(state.message),
//                         backgroundColor: Colors.red));
//                   }
//                 },
//                 builder: (context, state) {
//                   if (state is OrderLoading) {
//                     return const Center(
//                         child: CircularProgressIndicator(color: Colors.black));
//                   } else if (state is OrderLoaded) {
//                     return _buildOrderList(state.orders);
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTabs() {
//     return Container(
//       width: double.infinity,
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Row(
//           children: _tabs.map((tab) {
//             final isSelected = _activeTab == tab['value'];
//             return Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: ChoiceChip(
//                 label: Text(tab['label']!,
//                     style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1,
//                         color:
//                             isSelected ? Colors.white : Colors.grey.shade600)),
//                 selected: isSelected,
//                 onSelected: (_) => setState(() => _activeTab = tab['value']!),
//                 selectedColor: Colors.black,
//                 backgroundColor: Colors.grey.shade100,
//                 side: BorderSide.none,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20)),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   List<TransactionModel> _filterOrders(List<TransactionModel> orders) {
//     return orders.where((order) {
//       if (_activeTab == 'all') return true;
//       final status = order.status.toLowerCase();

//       if (_activeTab == 'unpaid') return status == 'pending';
//       if (_activeTab == 'to_ship') return status == 'processing';
//       if (_activeTab == 'completed') return status == 'completed';
//       if (_activeTab == 'issues')
//         return status.contains('refund') ||
//             status == 'cancelled' ||
//             status == 'returned';
//       return false; // Untuk tab In Transit butuh data dari Biteship
//     }).toList();
//   }

//   Widget _buildOrderList(List<TransactionModel> allOrders) {
//     final filtered = _filterOrders(allOrders);

//     if (filtered.isEmpty) {
//       return const Center(
//         child: Text('Tidak ada pesanan.',
//             style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
//       );
//     }

//     return ListView.separated(
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.all(16),
//       itemCount: filtered.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 16),
//       itemBuilder: (context, index) {
//         final order = filtered[index];
//         return _buildOrderCard(context, order);
//       },
//     );
//   }

//   Widget _buildOrderCard(BuildContext context, TransactionModel order) {
//     final currencyFormatter =
//         NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.02),
//               blurRadius: 10,
//               offset: const Offset(0, 4))
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // HEADER (Order ID & Status)
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//                 color: Colors.grey.shade50,
//                 borderRadius:
//                     const BorderRadius.vertical(top: Radius.circular(16))),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('ORDER ID',
//                         style: TextStyle(
//                             fontSize: 10,
//                             color: Colors.grey,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1)),
//                     Text(order.orderId,
//                         style: const TextStyle(
//                             fontFamily: 'monospace',
//                             fontWeight: FontWeight.w900,
//                             fontSize: 14)),
//                   ],
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                       color: _getStatusColor(order.status).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20)),
//                   child: Text(order.status.toUpperCase(),
//                       style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                           color: _getStatusColor(order.status))),
//                 ),
//               ],
//             ),
//           ),

//           // ITEM LIST
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: order.details.map((detail) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 12.0),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 60,
//                         height: 60,
//                         decoration: BoxDecoration(
//                             color: Colors.grey.shade100,
//                             borderRadius: BorderRadius.circular(8)),
//                         child: detail.product?.image != null
//                             ? ClipRRect(
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: Image.network(detail.product!.image!,
//                                     fit: BoxFit.cover))
//                             : const Icon(Icons.image_not_supported,
//                                 color: Colors.grey),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(detail.product?.name ?? 'Unknown Product',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 13),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis),
//                             if (detail.color != null)
//                               Text('Color: ${detail.color}',
//                                   style: const TextStyle(
//                                       fontSize: 10, color: Colors.grey)),
//                             const SizedBox(height: 4),
//                             Text(
//                                 '${detail.quantity} x ${currencyFormatter.format(detail.price)}',
//                                 style: const TextStyle(
//                                     fontSize: 12, color: Colors.black54)),
//                           ],
//                         ),
//                       ),
//                       Text(
//                           currencyFormatter
//                               .format(detail.quantity * detail.price),
//                           style: const TextStyle(
//                               fontWeight: FontWeight.w900, fontSize: 13)),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),

//           const Divider(height: 1, color: Color(0xFFF3F4F6)),

//           // FOOTER & ACTIONS
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('GRAND TOTAL',
//                         style: TextStyle(
//                             fontSize: 10,
//                             color: Colors.grey,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1)),
//                     Text(currencyFormatter.format(order.grandTotal),
//                         style: const TextStyle(
//                             fontWeight: FontWeight.w900, fontSize: 16)),
//                   ],
//                 ),
//                 _buildActionButtons(context, order),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons(BuildContext context, TransactionModel order) {
//     if (order.status == 'pending') {
//       return Row(
//         children: [
//           OutlinedButton(
//             style: OutlinedButton.styleFrom(
//                 foregroundColor: Colors.red,
//                 side: const BorderSide(color: Colors.red)),
//             onPressed: () {
//               // Dialog konfirmasi pembatalan
//               showDialog(
//                   context: context,
//                   builder: (ctx) => AlertDialog(
//                         title: const Text('Batalkan Pesanan?'),
//                         content:
//                             const Text('Tindakan ini tidak dapat diurungkan.'),
//                         actions: [
//                           TextButton(
//                               onPressed: () => Navigator.pop(ctx),
//                               child: const Text('KEMBALI')),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red),
//                             onPressed: () {
//                               Navigator.pop(ctx);
//                               context
//                                   .read<OrderBloc>()
//                                   .add(CancelOrderRequested(order.id));
//                             },
//                             child: const Text('YA, BATALKAN',
//                                 style: TextStyle(color: Colors.white)),
//                           )
//                         ],
//                       ));
//             },
//             child: const Text('CANCEL',
//                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//           ),
//           const SizedBox(width: 8),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black, foregroundColor: Colors.white),
//             onPressed: () async {
//               if (order.payment?.checkoutUrl != null) {
//                 final url = Uri.parse(order.payment!.checkoutUrl!);
//                 if (await canLaunchUrl(url))
//                   await launchUrl(url, mode: LaunchMode.externalApplication);
//               }
//             },
//             child: const Text('PAY NOW',
//                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       );
//     } else if (order.status == 'processing') {
//       return ElevatedButton(
//         style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.black, foregroundColor: Colors.white),
//         onPressed: () {
//           // Navigasi ke halaman lacak (Tracking) jika Anda sudah membuatnya
//         },
//         child: const Text('TRACK ORDER',
//             style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//       );
//     }
//     return const SizedBox.shrink();
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'pending':
//         return Colors.orange;
//       case 'processing':
//         return Colors.blue;
//       case 'completed':
//         return Colors.green;
//       case 'cancelled':
//         return Colors.red;
//       case 'refunded':
//         return Colors.teal;
//       default:
//         return Colors.grey;
//     }
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:solher_mobile/models/transaction_models.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../blocs/order/order_bloc.dart';
// import '../blocs/order/order_event.dart';
// import '../blocs/order/order_state.dart';
// import '../repositories/order_repository.dart';

// class OrderPage extends StatefulWidget {
//   const OrderPage({super.key});

//   @override
//   State<OrderPage> createState() => _OrderPageState();
// }

// class _OrderPageState extends State<OrderPage> {
//   String _activeTab = 'all';
//   String _searchQuery = '';
//   final TextEditingController _searchCtrl = TextEditingController();

//   final List<Map<String, String>> _tabs = [
//     {'label': 'All Orders', 'value': 'all'},
//     {'label': 'Unpaid', 'value': 'unpaid'},
//     {'label': 'To Ship', 'value': 'to_ship'},
//     {'label': 'In Transit', 'value': 'shipping'},
//     {'label': 'Completed', 'value': 'completed'},
//     {'label': 'Issues / Returns', 'value': 'issues'},
//   ];

//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//           OrderBloc(orderRepository: OrderRepository())..add(FetchOrders()),
//       child: Scaffold(
//         backgroundColor: const Color(0xFFFAFAFA),
//         appBar: AppBar(
//           title: const Text('TRACK MY ORDER',
//               style: TextStyle(
//                   fontWeight: FontWeight.w900,
//                   fontFamily: 'serif',
//                   letterSpacing: 1)),
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 1,
//         ),
//         body: Column(
//           children: [
//             _buildSearchBar(),
//             Expanded(
//               child: BlocConsumer<OrderBloc, OrderState>(
//                 listener: (context, state) {
//                   if (state is OrderActionSuccess) {
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                         content: Text(state.message),
//                         backgroundColor: Colors.green));
//                   } else if (state is OrderError) {
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                         content: Text(state.message),
//                         backgroundColor: Colors.red));
//                   }
//                 },
//                 builder: (context, state) {
//                   if (state is OrderLoading) {
//                     return const Center(
//                         child: CircularProgressIndicator(color: Colors.black));
//                   } else if (state is OrderLoaded) {
//                     return Column(
//                       children: [
//                         _buildTabs(state.orders),
//                         Expanded(child: _buildOrderList(state.orders)),
//                       ],
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//       child: TextField(
//         controller: _searchCtrl,
//         onChanged: (val) => setState(() => _searchQuery = val),
//         decoration: InputDecoration(
//           hintText: 'Search Order ID, Courier, Method...',
//           hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
//           prefixIcon: const Icon(Icons.search, color: Colors.grey),
//           filled: true,
//           fillColor: Colors.grey.shade50,
//           contentPadding: const EdgeInsets.symmetric(vertical: 0),
//           border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade200)),
//           enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade200)),
//           focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Colors.black)),
//         ),
//       ),
//     );
//   }

//   Widget _buildTabs(List<TransactionModel> orders) {
//     return Container(
//       width: double.infinity,
//       color: Colors.white,
//       padding: const EdgeInsets.only(bottom: 12),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Row(
//           children: _tabs.map((tab) {
//             final isSelected = _activeTab == tab['value'];
//             // Hitung jumlah order per tab
//             final count =
//                 _filterOrders(orders, overrideTab: tab['value']).length;

//             return Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: ChoiceChip(
//                 label: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(tab['label']!,
//                         style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1,
//                             color: isSelected
//                                 ? Colors.white
//                                 : Colors.grey.shade600)),
//                     if (count > 0) ...[
//                       const SizedBox(width: 6),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 6, vertical: 2),
//                         decoration: BoxDecoration(
//                             color: isSelected
//                                 ? Colors.white24
//                                 : Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(10)),
//                         child: Text('$count',
//                             style: TextStyle(
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.w900,
//                                 color:
//                                     isSelected ? Colors.white : Colors.black)),
//                       ),
//                     ]
//                   ],
//                 ),
//                 selected: isSelected,
//                 onSelected: (_) => setState(() => _activeTab = tab['value']!),
//                 selectedColor: Colors.black,
//                 backgroundColor: Colors.transparent,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                     side: BorderSide(
//                         color:
//                             isSelected ? Colors.black : Colors.grey.shade300)),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   List<TransactionModel> _filterOrders(List<TransactionModel> orders,
//       {String? overrideTab}) {
//     final tabToUse = overrideTab ?? _activeTab;
//     final query = _searchQuery.toLowerCase();

//     return orders.where((order) {
//       // 1. Filter Pencarian
//       bool matchSearch = true;
//       if (query.isNotEmpty) {
//         matchSearch = order.orderId.toLowerCase().contains(query) ||
//             order.paymentMethod?.toLowerCase().contains(query) == true ||
//             order.courierCompany?.toLowerCase().contains(query) == true ||
//             order.trackingNumber?.toLowerCase().contains(query) == true;
//       }

//       // 2. Filter Tab
//       bool matchTab = false;
//       final status = order.status.toLowerCase();
//       final shipStatus = order.shippingStatus?.toLowerCase() ?? 'pending';

//       if (tabToUse == 'all') {
//         matchTab = true;
//       } else if (tabToUse == 'unpaid') {
//         matchTab = status == 'pending';
//       } else if (tabToUse == 'to_ship') {
//         matchTab = status == 'processing' &&
//             [
//               'pending',
//               'placed',
//               'confirmed',
//               'allocated',
//               'picking_up',
//               'picked'
//             ].contains(shipStatus);
//       } else if (tabToUse == 'shipping') {
//         matchTab = shipStatus == 'dropping_off';
//       } else if (tabToUse == 'completed') {
//         matchTab = status == 'completed' || shipStatus == 'delivered';
//       } else if (tabToUse == 'cancelled') {
//         matchTab = status == 'cancelled';
//       } else if (tabToUse == 'issues') {
//         matchTab = status.contains('refund') ||
//             ['returned', 'shipping_failed'].contains(status) ||
//             [
//               'on_hold',
//               'return_in_transit',
//               'rejected',
//               'disposed',
//               'courier_not_found'
//             ].contains(shipStatus);
//       }

//       return matchSearch && matchTab;
//     }).toList();
//   }

//   Widget _buildOrderList(List<TransactionModel> allOrders) {
//     final filtered = _filterOrders(allOrders);

//     if (filtered.isEmpty) {
//       return const Center(
//           child: Text('Tidak ada pesanan ditemukan.',
//               style:
//                   TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)));
//     }

//     return ListView.separated(
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.all(16),
//       itemCount: filtered.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 16),
//       itemBuilder: (context, index) {
//         return _buildOrderCard(context, filtered[index]);
//       },
//     );
//   }

//   Widget _buildOrderCard(BuildContext context, TransactionModel order) {
//     final currencyFormatter =
//         NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
//     final dateFormatter = DateFormat('dd MMM yyyy, HH:mm');
//     final dateStr = order.createdAt.isNotEmpty
//         ? dateFormatter
//             .format(DateTime.tryParse(order.createdAt) ?? DateTime.now())
//         : '-';

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.02),
//               blurRadius: 10,
//               offset: const Offset(0, 4))
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // HEADER: ORDER ID & DATE & STATUS
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//                 color: Colors.grey.shade50,
//                 borderRadius:
//                     const BorderRadius.vertical(top: Radius.circular(16))),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('ORDER ID',
//                           style: TextStyle(
//                               fontSize: 9,
//                               color: Colors.grey,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 2)),
//                       Text(order.orderId,
//                           style: const TextStyle(
//                               fontFamily: 'monospace',
//                               fontWeight: FontWeight.w900,
//                               fontSize: 13)),
//                       const SizedBox(height: 8),
//                       const Text('DATE',
//                           style: TextStyle(
//                               fontSize: 9,
//                               color: Colors.grey,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 2)),
//                       Text(dateStr,
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 11)),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     _buildStatusBadge(order.status, isShipping: false),
//                     const SizedBox(height: 6),
//                     if (['biteship', 'dhl'].contains(order.shippingMethod))
//                       _buildStatusBadge(order.shippingStatus ?? 'Pending',
//                           isShipping: true)
//                     else if (order.shippingMethod == 'free')
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 4),
//                         decoration: BoxDecoration(
//                             color: Colors.grey.shade200,
//                             borderRadius: BorderRadius.circular(12)),
//                         child: const Text('IN STORE',
//                             style: TextStyle(
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black)),
//                       )
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // ITEMS
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: order.details.map((detail) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 12.0),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: 60,
//                         height: 60,
//                         decoration: BoxDecoration(
//                             color: Colors.grey.shade100,
//                             borderRadius: BorderRadius.circular(8)),
//                         child: detail.product?.image != null
//                             ? ClipRRect(
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: Image.network(detail.product!.image!,
//                                     fit: BoxFit.cover))
//                             : const Icon(Icons.image_not_supported,
//                                 color: Colors.grey),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(detail.product?.name ?? 'Unknown Product',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 12),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis),
//                             if (detail.color != null)
//                               Text('Color: ${detail.color}',
//                                   style: const TextStyle(
//                                       fontSize: 10, color: Colors.grey)),
//                             const SizedBox(height: 4),
//                             Text(
//                                 '${detail.quantity} x ${currencyFormatter.format(detail.price)}',
//                                 style: const TextStyle(
//                                     fontSize: 11, color: Colors.black54)),
//                           ],
//                         ),
//                       ),
//                       Text(
//                           currencyFormatter
//                               .format(detail.quantity * detail.price),
//                           style: const TextStyle(
//                               fontWeight: FontWeight.w900, fontSize: 12)),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),

//           // SUBTOTALS & INFO
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//                 color: Colors.grey.shade50,
//                 border: Border.symmetric(
//                     horizontal: BorderSide(color: Colors.grey.shade100))),
//             child: Column(
//               children: [
//                 _buildPriceRow(
//                     'Subtotal', currencyFormatter.format(order.totalAmount)),
//                 _buildPriceRow(
//                     'Shipping Cost',
//                     order.shippingCost > 0
//                         ? currencyFormatter.format(order.shippingCost)
//                         : 'Free'),
//                 if (order.promoDiscount > 0)
//                   _buildPriceRow('Promo (${order.promoCode ?? '-'})',
//                       '- ${currencyFormatter.format(order.promoDiscount)}',
//                       color: Colors.green),
//                 if (order.pointsUsed > 0)
//                   _buildPriceRow('Points Redeemed',
//                       '- ${currencyFormatter.format(order.pointsUsed * 1000)}',
//                       color: Colors.orange),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 8),
//                   child: Divider(height: 1, color: Colors.grey),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('FINAL AMOUNT',
//                         style: TextStyle(
//                             fontSize: 10,
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1)),
//                     Text(currencyFormatter.format(order.grandTotal),
//                         style: const TextStyle(
//                             fontWeight: FontWeight.w900, fontSize: 16)),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // PAYMENT & SHIPPING INFO
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('PAYMENT INFO',
//                               style: TextStyle(
//                                   fontSize: 9,
//                                   color: Colors.grey,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 1)),
//                           const SizedBox(height: 4),
//                           Text(
//                               (order.paymentMethod ?? 'Waiting Payment')
//                                   .replaceAll('_', ' ')
//                                   .toUpperCase(),
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 11)),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('SHIPPING INFO',
//                               style: TextStyle(
//                                   fontSize: 9,
//                                   color: Colors.grey,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 1)),
//                           const SizedBox(height: 4),
//                           if (order.shippingMethod == 'free')
//                             const Text('NO COURIER (IN STORE)',
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 11))
//                           else if (order.courierCompany != null) ...[
//                             Text(
//                                 '${order.courierCompany?.toUpperCase()} - ${order.courierType?.toUpperCase()}',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 11)),
//                             Text(
//                                 'Resi: ${order.trackingNumber ?? 'Waiting...'}',
//                                 style: const TextStyle(
//                                     fontSize: 10,
//                                     color: Colors.grey,
//                                     fontFamily: 'monospace')),
//                           ] else
//                             const Text('Setup Shipping...',
//                                 style: TextStyle(
//                                     fontSize: 11,
//                                     fontStyle: FontStyle.italic,
//                                     color: Colors.grey))
//                         ],
//                       ),
//                     )
//                   ],
//                 )
//               ],
//             ),
//           ),

//           // ACTIONS
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: _buildActionRow(context, order),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPriceRow(String label, String value,
//       {Color color = Colors.black54}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
//           Text(value,
//               style: TextStyle(
//                   fontSize: 11, fontWeight: FontWeight.bold, color: color)),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusBadge(String text, {required bool isShipping}) {
//     Color bg = Colors.grey.shade100;
//     Color fg = Colors.grey.shade600;
//     final str = text.toLowerCase();

//     if (isShipping) {
//       if (['delivered'].contains(str)) {
//         bg = Colors.green.shade50;
//         fg = Colors.green;
//       } else if ([
//         'picking_up',
//         'picked',
//         'dropping_off',
//         'allocated',
//         'confirmed'
//       ].contains(str)) {
//         bg = Colors.blue.shade50;
//         fg = Colors.blue;
//       } else if (['cancelled', 'rejected', 'disposed'].contains(str)) {
//         bg = Colors.red.shade50;
//         fg = Colors.red;
//       } else if (['on_hold', 'returned'].contains(str)) {
//         bg = Colors.orange.shade50;
//         fg = Colors.orange;
//       }
//     } else {
//       if (str == 'pending') {
//         bg = Colors.orange.shade50;
//         fg = Colors.orange;
//       } else if (str == 'processing') {
//         bg = Colors.blue.shade50;
//         fg = Colors.blue;
//       } else if (str == 'completed') {
//         bg = Colors.green.shade50;
//         fg = Colors.green;
//       } else if (str == 'cancelled') {
//         bg = Colors.red.shade50;
//         fg = Colors.red;
//       } else if (str == 'refunded') {
//         bg = Colors.teal.shade50;
//         fg = Colors.teal;
//       } else if (str.contains('refund')) {
//         bg = Colors.purple.shade50;
//         fg = Colors.purple;
//       }
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: fg.withOpacity(0.2))),
//       child: Text(text.replaceAll('_', ' ').toUpperCase(),
//           style:
//               TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: fg)),
//     );
//   }

//   Widget _buildActionRow(BuildContext context, TransactionModel order) {
//     final bloc = context.read<OrderBloc>();
//     List<Widget> actions = [];

//     // 1. CANCEL ORDER
//     if (['pending', 'processing'].contains(order.status)) {
//       actions.add(
//         Expanded(
//           child: OutlinedButton(
//             style: OutlinedButton.styleFrom(
//                 foregroundColor: Colors.red,
//                 side: BorderSide(color: Colors.red.shade200)),
//             onPressed: () => _confirmAction(
//                 context,
//                 'Batalkan Pesanan?',
//                 'Tindakan ini tidak dapat diurungkan.',
//                 () => bloc.add(CancelOrderRequested(order.id))),
//             child: const Text('CANCEL',
//                 style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
//           ),
//         ),
//       );
//       actions.add(const SizedBox(width: 8));
//     }

//     // 2. PAY NOW
//     if (order.status == 'pending') {
//       actions.add(
//         Expanded(
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black, foregroundColor: Colors.white),
//             onPressed: () async {
//               if (order.payment?.checkoutUrl != null) {
//                 final url = Uri.parse(order.payment!.checkoutUrl!);
//                 if (await canLaunchUrl(url))
//                   await launchUrl(url, mode: LaunchMode.externalApplication);
//               }
//             },
//             child: const Text('PAY NOW',
//                 style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
//           ),
//         ),
//       );
//     }

//     // 3. TRACK ORDER
//     if (['processing', 'completed', 'shipping_failed'].contains(order.status) &&
//         ['biteship', 'dhl'].contains(order.shippingMethod)) {
//       actions.add(
//         Expanded(
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black, foregroundColor: Colors.white),
//             onPressed: () {
//               // TODO: Navigasi ke halaman Tracking Detail
//               ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Membuka lacak resi...')));
//             },
//             child: const Text('TRACK ORDER',
//                 style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
//           ),
//         ),
//       );
//     }

//     // 4. REQUEST REFUND
//     bool canRefund =
//         ['completed', 'shipping_failed', 'returned'].contains(order.status);
//     if (canRefund && ['biteship', 'dhl'].contains(order.shippingMethod)) {
//       final shipStatus = order.shippingStatus?.toLowerCase() ?? '';
//       if (['picked', 'dropping_off', 'delivered', 'return_in_transit']
//           .contains(shipStatus)) {
//         canRefund = false;
//       }
//     }

//     if (canRefund) {
//       if (actions.isNotEmpty) actions.add(const SizedBox(width: 8));
//       actions.add(
//         Expanded(
//           child: OutlinedButton(
//             style: OutlinedButton.styleFrom(
//                 foregroundColor: Colors.grey.shade700,
//                 side: BorderSide(color: Colors.grey.shade300)),
//             onPressed: () => _showRefundDialog(context, order.id),
//             child: const Text('REQUEST REFUND',
//                 style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
//           ),
//         ),
//       );
//     }

//     // 5. REFUND MESSAGES & PROCESS
//     if (order.status == 'refund_requested') {
//       actions.add(const Expanded(
//           child: Text('Waiting for Admin Approval...',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                   fontSize: 11,
//                   fontStyle: FontStyle.italic,
//                   color: Colors.orange))));
//     } else if (order.status == 'refund_manual_required') {
//       actions.add(const Expanded(
//           child: Text('Manual Refund Required. Contact CS.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                   fontSize: 11,
//                   fontStyle: FontStyle.italic,
//                   color: Colors.pink))));
//     } else if (order.status == 'refund_rejected') {
//       actions.add(const Expanded(
//           child: Text('Refund Rejected.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                   fontSize: 11,
//                   fontStyle: FontStyle.italic,
//                   color: Colors.red))));
//     } else if (order.status == 'refund_approved') {
//       actions.add(
//         Expanded(
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue, foregroundColor: Colors.white),
//             onPressed: () => bloc.add(ProcessRefundRequested(order.id)),
//             child: const Text('REFUND NOW',
//                 style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
//           ),
//         ),
//       );
//     }

//     if (actions.isEmpty) return const SizedBox.shrink();
//     return Row(children: actions);
//   }

//   void _confirmAction(BuildContext context, String title, String content,
//       VoidCallback onConfirm) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text(title,
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         content: Text(content, style: const TextStyle(fontSize: 14)),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(ctx),
//               child: const Text('BATAL', style: TextStyle(color: Colors.grey))),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
//             onPressed: () {
//               Navigator.pop(ctx);
//               onConfirm();
//             },
//             child: const Text('YA, LANJUTKAN',
//                 style: TextStyle(color: Colors.white)),
//           )
//         ],
//       ),
//     );
//   }

//   void _showRefundDialog(BuildContext context, int transactionId) {
//     final reasonCtrl = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Request Refund',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Alasan Pengembalian:',
//                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             TextField(
//               controller: reasonCtrl,
//               maxLines: 3,
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.grey.shade100,
//                 hintText: 'Jelaskan alasan Anda...',
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide.none),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text('Bukti Foto/Video:',
//                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                   border: Border.all(
//                       color: Colors.grey.shade300, style: BorderStyle.solid),
//                   borderRadius: BorderRadius.circular(8)),
//               child: const Text(
//                   'Ketuk untuk memilih file (Butuh implementasi ImagePicker)',
//                   style: TextStyle(fontSize: 10, color: Colors.grey),
//                   textAlign: TextAlign.center),
//             )
//           ],
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(ctx),
//               child: const Text('BATAL', style: TextStyle(color: Colors.grey))),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
//             onPressed: () {
//               if (reasonCtrl.text.isEmpty) return;
//               Navigator.pop(ctx);
//               // PENTING: filePath ini hanya dummy. Anda wajib menggunakan package 'image_picker' untuk mengambil file path asli dari HP.
//               context.read<OrderBloc>().add(RequestRefundRequested(
//                   transactionId: transactionId,
//                   reason: reasonCtrl.text,
//                   filePath: '/dummy/path/file.jpg'));
//             },
//             child: const Text('KIRIM', style: TextStyle(color: Colors.white)),
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:solher_mobile/models/transaction_models.dart';
import 'package:url_launcher/url_launcher.dart';
import '../blocs/order/order_bloc.dart';
import '../blocs/order/order_event.dart';
import '../blocs/order/order_state.dart';
import '../repositories/order_repository.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String _activeTab = 'all';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  // 👇 PERBAIKAN: Menambahkan tab Cancelled ke dalam daftar 👇
  final List<Map<String, String>> _tabs = [
    {'label': 'All Orders', 'value': 'all'},
    {'label': 'Unpaid', 'value': 'unpaid'},
    {'label': 'To Ship', 'value': 'to_ship'},
    {'label': 'In Transit', 'value': 'shipping'},
    {'label': 'Completed', 'value': 'completed'},
    {'label': 'Cancelled', 'value': 'cancelled'}, // <--- TAB BARU DITAMBAHKAN
    {'label': 'Issues / Returns', 'value': 'issues'},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          OrderBloc(orderRepository: OrderRepository())..add(FetchOrders()),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: const Text('Orders',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'serif',
                  letterSpacing: 1)),
          backgroundColor: Colors.grey[500],
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: BlocConsumer<OrderBloc, OrderState>(
                listener: (context, state) {
                  if (state is OrderActionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green));
                  } else if (state is OrderError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red));
                  }
                },
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.black));
                  } else if (state is OrderLoaded) {
                    return Column(
                      children: [
                        _buildTabs(state.orders),
                        Expanded(child: _buildOrderList(state.orders)),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search Order ID, Courier, Method...',
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black)),
        ),
      ),
    );
  }

  Widget _buildTabs(List<TransactionModel> orders) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _tabs.map((tab) {
            final isSelected = _activeTab == tab['value'];
            // Hitung jumlah order per tab
            final count =
                _filterOrders(orders, overrideTab: tab['value']).length;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tab['label']!,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600)),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white24
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text('$count',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color:
                                    isSelected ? Colors.white : Colors.black)),
                      ),
                    ]
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => setState(() => _activeTab = tab['value']!),
                selectedColor: Colors.black,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                        color:
                            isSelected ? Colors.black : Colors.grey.shade300)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<TransactionModel> _filterOrders(List<TransactionModel> orders,
      {String? overrideTab}) {
    final tabToUse = overrideTab ?? _activeTab;
    final query = _searchQuery.toLowerCase();

    return orders.where((order) {
      // 1. Filter Pencarian
      bool matchSearch = true;
      if (query.isNotEmpty) {
        matchSearch = order.orderId.toLowerCase().contains(query) ||
            order.paymentMethod?.toLowerCase().contains(query) == true ||
            order.courierCompany?.toLowerCase().contains(query) == true ||
            order.trackingNumber?.toLowerCase().contains(query) == true;
      }

      // 2. Filter Tab
      bool matchTab = false;
      final status = order.status.toLowerCase();
      final shipStatus = order.shippingStatus?.toLowerCase() ?? 'pending';

      if (tabToUse == 'all') {
        matchTab = true;
      } else if (tabToUse == 'unpaid') {
        matchTab = status == 'pending';
      } else if (tabToUse == 'to_ship') {
        matchTab = status == 'processing' &&
            [
              'pending',
              'placed',
              'confirmed',
              'allocated',
              'picking_up',
              'picked'
            ].contains(shipStatus);
      } else if (tabToUse == 'shipping') {
        matchTab = shipStatus == 'dropping_off';
      } else if (tabToUse == 'completed') {
        matchTab = status == 'completed' || shipStatus == 'delivered';
      } else if (tabToUse == 'cancelled') {
        matchTab = status == 'cancelled';
      } else if (tabToUse == 'issues') {
        matchTab = status.contains('refund') ||
            ['returned', 'shipping_failed'].contains(status) ||
            [
              'on_hold',
              'return_in_transit',
              'rejected',
              'disposed',
              'courier_not_found'
            ].contains(shipStatus);
      }

      return matchSearch && matchTab;
    }).toList();
  }

  Widget _buildOrderList(List<TransactionModel> allOrders) {
    final filtered = _filterOrders(allOrders);

    if (filtered.isEmpty) {
      return const Center(
          child: Text('Tidak ada pesanan ditemukan.',
              style:
                  TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)));
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildOrderCard(context, filtered[index]);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, TransactionModel order) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm');
    final dateStr = order.createdAt.isNotEmpty
        ? dateFormatter
            .format(DateTime.tryParse(order.createdAt) ?? DateTime.now())
        : '-';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: ORDER ID & DATE & STATUS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ORDER ID',
                          style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
                      Text(order.orderId,
                          style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w900,
                              fontSize: 13)),
                      const SizedBox(height: 8),
                      const Text('DATE',
                          style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
                      Text(dateStr,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(order.status, isShipping: false),
                    const SizedBox(height: 6),
                    if (['biteship', 'dhl'].contains(order.shippingMethod))
                      _buildStatusBadge(order.shippingStatus ?? 'Pending',
                          isShipping: true)
                    else if (order.shippingMethod == 'free')
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Text('IN STORE',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      )
                  ],
                ),
              ],
            ),
          ),

          // ITEMS
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: order.details.map((detail) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8)),
                        child: detail.product?.image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(detail.product!.image!,
                                    fit: BoxFit.cover))
                            : const Icon(Icons.image_not_supported,
                                color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(detail.product?.name ?? 'Unknown Product',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            if (detail.color != null)
                              Text('Color: ${detail.color}',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                                '${detail.quantity} x ${currencyFormatter.format(detail.price)}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black54)),
                          ],
                        ),
                      ),
                      Text(
                          currencyFormatter
                              .format(detail.quantity * detail.price),
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // SUBTOTALS & INFO
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey.shade100))),
            child: Column(
              children: [
                _buildPriceRow(
                    'Subtotal', currencyFormatter.format(order.totalAmount)),
                _buildPriceRow(
                    'Shipping Cost',
                    order.shippingCost > 0
                        ? currencyFormatter.format(order.shippingCost)
                        : 'Free'),
                if (order.promoDiscount > 0)
                  _buildPriceRow('Promo (${order.promoCode ?? '-'})',
                      '- ${currencyFormatter.format(order.promoDiscount)}',
                      color: Colors.green),
                if (order.pointsUsed > 0)
                  _buildPriceRow('Points Redeemed',
                      '- ${currencyFormatter.format(order.pointsUsed * 1000)}',
                      color: Colors.orange),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Colors.grey),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('FINAL AMOUNT',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                    Text(currencyFormatter.format(order.grandTotal),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),

                // PAYMENT & SHIPPING INFO
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PAYMENT INFO',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(
                              (order.paymentMethod ?? 'Waiting Payment')
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SHIPPING INFO',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                          const SizedBox(height: 4),
                          if (order.shippingMethod == 'free')
                            const Text('NO COURIER (IN STORE)',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 11))
                          else if (order.courierCompany != null) ...[
                            Text(
                                '${order.courierCompany?.toUpperCase()} - ${order.courierType?.toUpperCase()}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 11)),
                            Text(
                                'Resi: ${order.trackingNumber ?? 'Waiting...'}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontFamily: 'monospace')),
                          ] else
                            const Text('Setup Shipping...',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey))
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),

          // ACTIONS
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildActionRow(context, order),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value,
      {Color color = Colors.black54}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, {required bool isShipping}) {
    Color bg = Colors.grey.shade100;
    Color fg = Colors.grey.shade600;
    final str = text.toLowerCase();

    if (isShipping) {
      if (['delivered'].contains(str)) {
        bg = Colors.green.shade50;
        fg = Colors.green;
      } else if ([
        'picking_up',
        'picked',
        'dropping_off',
        'allocated',
        'confirmed'
      ].contains(str)) {
        bg = Colors.blue.shade50;
        fg = Colors.blue;
      } else if (['cancelled', 'rejected', 'disposed'].contains(str)) {
        bg = Colors.red.shade50;
        fg = Colors.red;
      } else if (['on_hold', 'returned'].contains(str)) {
        bg = Colors.orange.shade50;
        fg = Colors.orange;
      }
    } else {
      if (str == 'pending') {
        bg = Colors.orange.shade50;
        fg = Colors.orange;
      } else if (str == 'processing') {
        bg = Colors.blue.shade50;
        fg = Colors.blue;
      } else if (str == 'completed') {
        bg = Colors.green.shade50;
        fg = Colors.green;
      } else if (str == 'cancelled') {
        bg = Colors.red.shade50;
        fg = Colors.red;
      } else if (str == 'refunded') {
        bg = Colors.teal.shade50;
        fg = Colors.teal;
      } else if (str.contains('refund')) {
        bg = Colors.purple.shade50;
        fg = Colors.purple;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: fg.withOpacity(0.2))),
      child: Text(text.replaceAll('_', ' ').toUpperCase(),
          style:
              TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  Widget _buildActionRow(BuildContext context, TransactionModel order) {
    final bloc = context.read<OrderBloc>();
    List<Widget> actions = [];

    // 1. CANCEL ORDER
    if (['pending', 'processing'].contains(order.status)) {
      actions.add(
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade200)),
            onPressed: () => _confirmAction(
                context,
                'Batalkan Pesanan?',
                'Tindakan ini tidak dapat diurungkan.',
                () => bloc.add(CancelOrderRequested(order.id))),
            child: const Text('CANCEL',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
      );
      actions.add(const SizedBox(width: 8));
    }

    // 2. PAY NOW
    if (order.status == 'pending') {
      actions.add(
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, foregroundColor: Colors.white),
            onPressed: () async {
              if (order.payment?.checkoutUrl != null) {
                final url = Uri.parse(order.payment!.checkoutUrl!);
                if (await canLaunchUrl(url))
                  await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('PAY NOW',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }

    // 3. TRACK ORDER
    if (['processing', 'completed', 'shipping_failed'].contains(order.status) &&
        ['biteship', 'dhl'].contains(order.shippingMethod)) {
      actions.add(
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, foregroundColor: Colors.white),
            onPressed: () {
              // TODO: Navigasi ke halaman Tracking Detail
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Membuka lacak resi...')));
            },
            child: const Text('TRACK ORDER',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }

    // 4. REQUEST REFUND
    bool canRefund =
        ['completed', 'shipping_failed', 'returned'].contains(order.status);
    if (canRefund && ['biteship', 'dhl'].contains(order.shippingMethod)) {
      final shipStatus = order.shippingStatus?.toLowerCase() ?? '';
      if (['picked', 'dropping_off', 'delivered', 'return_in_transit']
          .contains(shipStatus)) {
        canRefund = false;
      }
    }

    if (canRefund) {
      if (actions.isNotEmpty) actions.add(const SizedBox(width: 8));
      actions.add(
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300)),
            onPressed: () => _showRefundDialog(context, order.id),
            child: const Text('REQUEST REFUND',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }

    // 5. REFUND MESSAGES & PROCESS
    if (order.status == 'refund_requested') {
      actions.add(const Expanded(
          child: Text('Waiting for Admin Approval...',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.orange))));
    } else if (order.status == 'refund_manual_required') {
      actions.add(const Expanded(
          child: Text('Manual Refund Required. Contact CS.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.pink))));
    } else if (order.status == 'refund_rejected') {
      actions.add(const Expanded(
          child: Text('Refund Rejected.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.red))));
    } else if (order.status == 'refund_approved') {
      actions.add(
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, foregroundColor: Colors.white),
            onPressed: () => bloc.add(ProcessRefundRequested(order.id)),
            child: const Text('REFUND NOW',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();
    return Row(children: actions);
  }

  void _confirmAction(BuildContext context, String title, String content,
      VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(content, style: const TextStyle(fontSize: 14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('BATAL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('YA, LANJUTKAN',
                style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showRefundDialog(BuildContext context, int transactionId) {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Refund',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alasan Pengembalian:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                hintText: 'Jelaskan alasan Anda...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Bukti Foto/Video:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.grey.shade300, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8)),
              child: const Text(
                  'Ketuk untuk memilih file (Butuh implementasi ImagePicker)',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                  textAlign: TextAlign.center),
            )
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('BATAL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () {
              if (reasonCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              // PENTING: filePath ini hanya dummy. Anda wajib menggunakan package 'image_picker' untuk mengambil file path asli dari HP.
              context.read<OrderBloc>().add(RequestRefundRequested(
                  transactionId: transactionId,
                  reason: reasonCtrl.text,
                  filePath: '/dummy/path/file.jpg'));
            },
            child: const Text('KIRIM', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
