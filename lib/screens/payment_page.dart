// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart';

// // Repositories & Models
// import '../repositories/checkout_repository.dart';
// import '../models/checkout_model.dart';
// import '../models/cart_model.dart';
// import '../models/address_model.dart';
// import '../models/user_model.dart';

// // BLoCs
// import '../blocs/auth/auth_bloc.dart';
// import '../blocs/auth/auth_state.dart';
// import '../blocs/cart/cart_bloc.dart';
// import '../blocs/cart/cart_state.dart';
// import '../blocs/address/address_bloc.dart';
// import '../blocs/address/address_state.dart';
// import '../blocs/checkout/checkout_bloc.dart';
// import '../blocs/checkout/checkout_event.dart';
// import '../blocs/checkout/checkout_state.dart';

// class PaymentPage extends StatefulWidget {
//   final List<int> selectedCartIds;

//   const PaymentPage({super.key, required this.selectedCartIds});

//   @override
//   State<PaymentPage> createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   final CheckoutRepository _checkoutRepo = CheckoutRepository();

//   // State Formulir
//   int? _selectedAddressId;
//   String _shippingMethod = 'free'; // 'free' atau 'biteship'
//   ShippingRateModel? _selectedRate;
//   String _deliveryType = 'now'; // 'now' atau 'scheduled'

//   // State Promo & Points
//   int _pointsToUse = 0;
//   String _promoInput = '';
//   String? _appliedPromoCode;
//   num _promoDiscountAmount = 0;
//   bool _isVerifyingPromo = false;
//   bool _useMemberVoucher = false;

//   // State API Kurir
//   List<ShippingRateModel> _shippingRates = [];
//   bool _isLoadingRates = false;

//   @override
//   void initState() {
//     super.initState();
//     // Default Address Logic dijalankan di builder saat alamat dimuat
//   }

//   // --- LOGIKA ONGKIR ---
//   Future<void> _fetchRates(int addressId) async {
//     setState(() {
//       _isLoadingRates = true;
//       _shippingRates = [];
//       _selectedRate = null;
//     });

//     try {
//       final rates = await _checkoutRepo.fetchShippingRates(
//           addressId, widget.selectedCartIds);
//       setState(() {
//         _shippingRates = rates;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text(e.toString())));
//     } finally {
//       setState(() {
//         _isLoadingRates = false;
//       });
//     }
//   }

//   // --- LOGIKA PROMO ---
//   Future<void> _applyPromo(List<CartModel> checkoutItems) async {
//     if (_promoInput.isEmpty) return;
//     setState(() => _isVerifyingPromo = true);

//     try {
//       final code = _promoInput.toUpperCase();

//       // Siapkan payload cart sesuai kebutuhan backend
//       final cartPayload = checkoutItems
//           .map((item) => {
//                 'product_id': item.productId,
//                 'quantity': item.quantity,
//               })
//           .toList();

//       final res = await _checkoutRepo.verifyPromo(code, cartPayload);

//       setState(() {
//         _appliedPromoCode = code;
//         _promoDiscountAmount = res['discount_value'] ?? 0;
//         _pointsToUse = 0; // Kunci poin jika promo aktif
//       });

//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('✅ ${res['message']}'), backgroundColor: Colors.green));
//     } catch (e) {
//       setState(() {
//         _appliedPromoCode = null;
//         _promoDiscountAmount = 0;
//         _useMemberVoucher = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
//     } finally {
//       setState(() => _isVerifyingPromo = false);
//     }
//   }

//   void _removePromo() {
//     setState(() {
//       _promoInput = '';
//       _appliedPromoCode = null;
//       _promoDiscountAmount = 0;
//       _useMemberVoucher = false;
//     });
//   }

//   // --- KALKULASI HARGA ---
//   num _getSubtotal(List<CartModel> items) {
//     num total = 0;
//     for (var item in items) {
//       num price = item.product?.discountPrice != null &&
//               item.product!.discountPrice! > 0
//           ? item.product!.discountPrice!
//           : item.product?.price ?? 0;
//       total += (price * item.quantity);
//     }
//     return total;
//   }

//   // --- BUILDER UI ---
//   @override
//   Widget build(BuildContext context) {
//     final currencyFormat =
//         NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

//     return Scaffold(
//       backgroundColor: const Color(0xFFFAFAFA),
//       appBar: AppBar(
//         title: const Text('CHECKOUT',
//             style: TextStyle(
//                 fontWeight: FontWeight.w900,
//                 fontFamily: 'serif',
//                 letterSpacing: 1)),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//       ),
//       body: MultiBlocListener(
//         listeners: [
//           BlocListener<CheckoutBloc, CheckoutState>(
//             listener: (context, state) async {
//               if (state is CheckoutSuccess) {
//                 // Buka Link Pembayaran Xendit
//                 final url = Uri.parse(state.checkoutUrl);
//                 if (await canLaunchUrl(url)) {
//                   await launchUrl(url, mode: LaunchMode.externalApplication);
//                   // Optional: Arahkan ke halaman sukses/menunggu
//                   Navigator.pop(context);
//                 }
//               } else if (state is CheckoutError) {
//                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text(state.message), backgroundColor: Colors.red));
//               }
//             },
//           ),
//         ],
//         child: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
//           UserModel? user;
//           if (authState is AuthAuthenticated) user = authState.user;

//           return BlocBuilder<CartBloc, CartState>(
//               builder: (context, cartState) {
//             if (cartState is! CartLoaded)
//               return const Center(
//                   child: CircularProgressIndicator(color: Colors.black));

//             // Saring item yang dicheckout
//             final checkoutItems = cartState.items
//                 .where((e) => widget.selectedCartIds.contains(e.id))
//                 .toList();
//             if (checkoutItems.isEmpty)
//               return const Center(child: Text("Tas Belanja Kosong"));

//             final subtotal = _getSubtotal(checkoutItems);
//             num bundleDiscount = cartState.summary
//                 .bundleDiscount; // Jika ada perhitungan bundle dari API cart
//             num shippingCost =
//                 _shippingMethod == 'biteship' && _selectedRate != null
//                     ? _selectedRate!.price
//                     : 0;
//             num pointDiscount = _pointsToUse * 1000;

//             // Cegah minus
//             num grandTotal = (subtotal -
//                     bundleDiscount -
//                     _promoDiscountAmount -
//                     pointDiscount) +
//                 shippingCost;
//             if (grandTotal < 0) grandTotal = 0;

//             // Max Poin yang diizinkan
//             int maxPointsAllowed = user != null ? user.point : 0;
//             int maxUsableByPrice =
//                 ((subtotal - bundleDiscount - _promoDiscountAmount) / 1000)
//                     .floor();
//             if (maxPointsAllowed > maxUsableByPrice)
//               maxPointsAllowed = maxUsableByPrice;
//             if (maxPointsAllowed < 0) maxPointsAllowed = 0;

//             return Column(
//               children: [
//                 Expanded(
//                   child: SingleChildScrollView(
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // 1. ALAMAT PENGIRIMAN
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(6),
//                               decoration: const BoxDecoration(
//                                   color: Colors.black, shape: BoxShape.circle),
//                               child: const Text('1',
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold)),
//                             ),
//                             const SizedBox(width: 8),
//                             const Text('SHIPPING ADDRESS',
//                                 style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 1)),
//                           ],
//                         ),
//                         const SizedBox(height: 16),

//                         BlocBuilder<AddressBloc, AddressState>(
//                           builder: (context, addressState) {
//                             if (addressState is AddressLoaded) {
//                               if (addressState.addresses.isEmpty) {
//                                 return const Text(
//                                     'Tidak ada alamat. Silakan tambah di profil.');
//                               }

//                               // Set default
//                               if (_selectedAddressId == null) {
//                                 final defaultAddr = addressState.addresses
//                                     .firstWhere((a) => a.isDefault,
//                                         orElse: () =>
//                                             addressState.addresses.first);
//                                 _selectedAddressId = defaultAddr.id;
//                                 // Panggil ongkir awal jika metode biteship
//                                 if (_shippingMethod == 'biteship')
//                                   _fetchRates(_selectedAddressId!);
//                               }

//                               return Column(
//                                 children: addressState.addresses.map((addr) {
//                                   bool isSelected =
//                                       _selectedAddressId == addr.id;
//                                   return GestureDetector(
//                                     onTap: () {
//                                       setState(
//                                           () => _selectedAddressId = addr.id);
//                                       if (_shippingMethod == 'biteship')
//                                         _fetchRates(addr.id!);
//                                     },
//                                     child: Container(
//                                       margin: const EdgeInsets.only(bottom: 12),
//                                       padding: const EdgeInsets.all(16),
//                                       decoration: BoxDecoration(
//                                         color: isSelected
//                                             ? Colors.white
//                                             : Colors.grey.shade50,
//                                         border: Border.all(
//                                             color: isSelected
//                                                 ? Colors.black
//                                                 : Colors.grey.shade200),
//                                         borderRadius: BorderRadius.circular(16),
//                                         boxShadow: isSelected
//                                             ? const [
//                                                 BoxShadow(
//                                                     color: Colors.black12,
//                                                     blurRadius: 4)
//                                               ]
//                                             : [],
//                                       ),
//                                       child: Row(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Radio<int>(
//                                             value: addr.id!,
//                                             groupValue: _selectedAddressId,
//                                             activeColor: Colors.black,
//                                             onChanged: (val) {
//                                               setState(() =>
//                                                   _selectedAddressId = val);
//                                               if (_shippingMethod == 'biteship')
//                                                 _fetchRates(val!);
//                                             },
//                                           ),
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   children: [
//                                                     Text(
//                                                         '${addr.firstName} ${addr.lastName}'
//                                                             .toUpperCase(),
//                                                         style: const TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize: 13)),
//                                                     if (addr.isDefault)
//                                                       Container(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .symmetric(
//                                                                   horizontal: 6,
//                                                                   vertical: 2),
//                                                           decoration: BoxDecoration(
//                                                               color: Colors.grey
//                                                                   .shade200,
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           4)),
//                                                           child: const Text(
//                                                               'DEFAULT',
//                                                               style: TextStyle(
//                                                                   fontSize: 8,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold)))
//                                                   ],
//                                                 ),
//                                                 const SizedBox(height: 4),
//                                                 Text(
//                                                     '${addr.location}, ${addr.city}, ${addr.province} - ${addr.postalCode}',
//                                                     style: const TextStyle(
//                                                         fontSize: 12,
//                                                         color: Colors.grey,
//                                                         height: 1.5)),
//                                               ],
//                                             ),
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 }).toList(),
//                               );
//                             }
//                             return const CircularProgressIndicator();
//                           },
//                         ),
//                         const SizedBox(height: 24),

//                         // 2. METODE PENGIRIMAN
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(6),
//                               decoration: const BoxDecoration(
//                                   color: Colors.black, shape: BoxShape.circle),
//                               child: const Text('2',
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold)),
//                             ),
//                             const SizedBox(width: 8),
//                             const Text('SHIPPING METHOD',
//                                 style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 1)),
//                           ],
//                         ),
//                         const SizedBox(height: 16),

//                         // Opsi FREE
//                         GestureDetector(
//                           onTap: () => setState(() => _shippingMethod = 'free'),
//                           child: Container(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                                 border: Border.all(
//                                     color: _shippingMethod == 'free'
//                                         ? Colors.black
//                                         : Colors.grey.shade200),
//                                 borderRadius: BorderRadius.circular(16),
//                                 color: _shippingMethod == 'free'
//                                     ? Colors.white
//                                     : Colors.grey.shade50),
//                             child: Row(
//                               children: [
//                                 Radio<String>(
//                                     value: 'free',
//                                     groupValue: _shippingMethod,
//                                     activeColor: Colors.black,
//                                     onChanged: (val) =>
//                                         setState(() => _shippingMethod = val!)),
//                                 Expanded(
//                                   child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const Text('FREE SHIPPING (IN STORE)',
//                                             style: TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 12)),
//                                         Text('Ambil langsung di toko Solher',
//                                             style: TextStyle(
//                                                 fontSize: 10,
//                                                 color: Colors.green.shade600,
//                                                 fontWeight: FontWeight.bold)),
//                                       ]),
//                                 ),
//                                 const Text('Rp 0',
//                                     style:
//                                         TextStyle(fontWeight: FontWeight.w900)),
//                               ],
//                             ),
//                           ),
//                         ),

//                         // Opsi BITESHIP
//                         GestureDetector(
//                           onTap: () {
//                             setState(() => _shippingMethod = 'biteship');
//                             if (_selectedAddressId != null &&
//                                 _shippingRates.isEmpty)
//                               _fetchRates(_selectedAddressId!);
//                           },
//                           child: Container(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                                 border: Border.all(
//                                     color: _shippingMethod == 'biteship'
//                                         ? Colors.black
//                                         : Colors.grey.shade200),
//                                 borderRadius: BorderRadius.circular(16),
//                                 color: _shippingMethod == 'biteship'
//                                     ? Colors.white
//                                     : Colors.grey.shade50),
//                             child: Row(
//                               children: [
//                                 Radio<String>(
//                                     value: 'biteship',
//                                     groupValue: _shippingMethod,
//                                     activeColor: Colors.black,
//                                     onChanged: (val) {
//                                       setState(() => _shippingMethod = val!);
//                                       if (_selectedAddressId != null)
//                                         _fetchRates(_selectedAddressId!);
//                                     }),
//                                 const Expanded(
//                                   child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text('STANDARD COURIER',
//                                             style: TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 12)),
//                                         Text('Powered by Biteship',
//                                             style: TextStyle(
//                                                 fontSize: 10,
//                                                 color: Colors.grey)),
//                                       ]),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),

//                         // Daftar Kurir Biteship (Jika Dipilih)
//                         if (_shippingMethod == 'biteship') ...[
//                           const SizedBox(height: 8),
//                           if (_isLoadingRates)
//                             const Center(child: CircularProgressIndicator())
//                           else if (_shippingRates.isEmpty)
//                             const Text(
//                                 'Tidak ada kurir yang tersedia untuk wilayah ini.',
//                                 style:
//                                     TextStyle(color: Colors.red, fontSize: 12))
//                           else
//                             ..._shippingRates.map((rate) {
//                               bool isSelected =
//                                   _selectedRate?.company == rate.company &&
//                                       _selectedRate?.type == rate.type;
//                               return GestureDetector(
//                                 onTap: () =>
//                                     setState(() => _selectedRate = rate),
//                                 child: Container(
//                                   margin: const EdgeInsets.only(
//                                       bottom: 8, left: 32),
//                                   padding: const EdgeInsets.all(12),
//                                   decoration: BoxDecoration(
//                                       border: Border.all(
//                                           color: isSelected
//                                               ? Colors.blue
//                                               : Colors.grey.shade200),
//                                       borderRadius: BorderRadius.circular(12),
//                                       color: isSelected
//                                           ? Colors.blue.shade50
//                                           : Colors.white),
//                                   child: Row(
//                                     children: [
//                                       Expanded(
//                                         child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                   '${rate.company.toUpperCase()} - ${rate.type.replaceAll('_', ' ')}',
//                                                   style: const TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize: 11)),
//                                               Text('Estimasi: ${rate.duration}',
//                                                   style: const TextStyle(
//                                                       fontSize: 10,
//                                                       color: Colors.grey)),
//                                             ]),
//                                       ),
//                                       Text(currencyFormat.format(rate.price),
//                                           style: const TextStyle(
//                                               fontWeight: FontWeight.w900,
//                                               fontSize: 12)),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }).toList()
//                         ],
//                         const SizedBox(height: 32),

//                         // 3. KODE PROMO & POIN
//                         const Text('PROMO CODE',
//                             style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 letterSpacing: 1.5,
//                                 color: Colors.grey)),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 onChanged: (val) => _promoInput = val,
//                                 enabled: _appliedPromoCode == null,
//                                 decoration: InputDecoration(
//                                     hintText: 'Enter code here',
//                                     filled: true,
//                                     fillColor: Colors.grey.shade50,
//                                     border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                         borderSide: BorderSide(
//                                             color: Colors.grey.shade300)),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         horizontal: 16)),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             if (_appliedPromoCode == null)
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.black,
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 20, vertical: 14),
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(12))),
//                                 onPressed: _isVerifyingPromo
//                                     ? null
//                                     : () => _applyPromo(checkoutItems),
//                                 child: _isVerifyingPromo
//                                     ? const SizedBox(
//                                         width: 16,
//                                         height: 16,
//                                         child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2))
//                                     : const Text('APPLY',
//                                         style: TextStyle(color: Colors.white)),
//                               )
//                             else
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.red.shade50,
//                                     foregroundColor: Colors.red,
//                                     elevation: 0,
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 20, vertical: 14),
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                         side: BorderSide(
//                                             color: Colors.red.shade200))),
//                                 onPressed: _removePromo,
//                                 child: const Text('REMOVE'),
//                               )
//                           ],
//                         ),

//                         if (user != null && user.isMembership) ...[
//                           const SizedBox(height: 24),
//                           const Text('SOLHER CLUB POINTS',
//                               style: TextStyle(
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 1.5,
//                                   color: Colors.grey)),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: TextField(
//                                   keyboardType: TextInputType.number,
//                                   onChanged: (val) {
//                                     setState(() {
//                                       _pointsToUse = int.tryParse(val) ?? 0;
//                                       if (_pointsToUse > maxPointsAllowed)
//                                         _pointsToUse = maxPointsAllowed;
//                                     });
//                                   },
//                                   enabled: _appliedPromoCode != 'SOLHOST34' &&
//                                       _appliedPromoCode != 'MERDEKA17',
//                                   decoration: InputDecoration(
//                                       hintText: 'Max: $maxPointsAllowed pts',
//                                       filled: true,
//                                       fillColor: Colors.grey.shade50,
//                                       border: OutlineInputBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                           borderSide: BorderSide(
//                                               color: Colors.yellow.shade600)),
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                               horizontal: 16)),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.yellow.shade100,
//                                     foregroundColor: Colors.yellow.shade900,
//                                     elevation: 0,
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 20, vertical: 14),
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(12))),
//                                 onPressed: _appliedPromoCode == 'SOLHOST34'
//                                     ? null
//                                     : () {
//                                         setState(() {
//                                           _pointsToUse = maxPointsAllowed;
//                                         });
//                                       },
//                                 child: const Text('USE ALL'),
//                               )
//                             ],
//                           ),
//                         ]
//                       ],
//                     ),
//                   ),
//                 ),

//                 // AREA SUMMARY BOTTOM
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
//                         Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('Subtotal (${checkoutItems.length} items)',
//                                   style: const TextStyle(
//                                       fontSize: 12, color: Colors.grey)),
//                               Text(currencyFormat.format(subtotal),
//                                   style: const TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold)),
//                             ]),
//                         const SizedBox(height: 8),
//                         if (shippingCost > 0) ...[
//                           Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text('Shipping Cost',
//                                     style: TextStyle(
//                                         fontSize: 12, color: Colors.grey)),
//                                 Text(currencyFormat.format(shippingCost),
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold)),
//                               ]),
//                           const SizedBox(height: 8),
//                         ],
//                         if (_promoDiscountAmount > 0) ...[
//                           Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('Promo (${_appliedPromoCode})',
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.green,
//                                         fontWeight: FontWeight.bold)),
//                                 Text(
//                                     '- ${currencyFormat.format(_promoDiscountAmount)}',
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.green)),
//                               ]),
//                           const SizedBox(height: 8),
//                         ],
//                         if (pointDiscount > 0) ...[
//                           Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text('Points Applied',
//                                     style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.orange,
//                                         fontWeight: FontWeight.bold)),
//                                 Text(
//                                     '- ${currencyFormat.format(pointDiscount)}',
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.orange)),
//                               ]),
//                           const SizedBox(height: 8),
//                         ],
//                         const Padding(
//                             padding: EdgeInsets.symmetric(vertical: 8),
//                             child: Divider()),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text('GRAND TOTAL',
//                                 style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 1.5)),
//                             Text(currencyFormat.format(grandTotal),
//                                 style: const TextStyle(
//                                     fontSize: 22, fontWeight: FontWeight.w900)),
//                           ],
//                         ),
//                         const SizedBox(height: 16),

//                         // TOMBOL CHECKOUT
//                         BlocBuilder<CheckoutBloc, CheckoutState>(
//                             builder: (context, checkoutState) {
//                           bool isButtonDisabled = _selectedAddressId == null ||
//                               (_shippingMethod == 'biteship' &&
//                                   _selectedRate == null) ||
//                               checkoutState is CheckoutLoading;

//                           return SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.black,
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 16),
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(16))),
//                               onPressed: isButtonDisabled
//                                   ? null
//                                   : () {
//                                       // BUAT PAYLOAD SESUAI BACKEND LARAVEL
//                                       final payload = {
//                                         'address_id': _selectedAddressId,
//                                         'shipping_method': _shippingMethod,
//                                         'use_points': _pointsToUse,
//                                         'cart_ids': widget.selectedCartIds,
//                                         'courier_company':
//                                             _shippingMethod == 'biteship'
//                                                 ? _selectedRate?.company
//                                                 : null,
//                                         'courier_type':
//                                             _shippingMethod == 'biteship'
//                                                 ? _selectedRate?.type
//                                                 : null,
//                                         'shipping_cost': shippingCost,
//                                         'delivery_type': _deliveryType,
//                                         'promo_code': _appliedPromoCode,
//                                         'currency': 'IDR',
//                                       };

//                                       context
//                                           .read<CheckoutBloc>()
//                                           .add(SubmitCheckoutEvent(payload));
//                                     },
//                               child: checkoutState is CheckoutLoading
//                                   ? const SizedBox(
//                                       height: 20,
//                                       width: 20,
//                                       child: CircularProgressIndicator(
//                                           color: Colors.white, strokeWidth: 2))
//                                   : const Text('PAY SECURELY',
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           letterSpacing: 2)),
//                             ),
//                           );
//                         })
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             );
//           });
//         }),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart';

// // Repositories & Models
// import '../repositories/checkout_repository.dart';
// import '../models/checkout_model.dart';
// import '../models/cart_model.dart';
// import '../models/user_model.dart';

// // BLoCs
// import '../blocs/auth/auth_bloc.dart';
// import '../blocs/auth/auth_state.dart';
// import '../blocs/cart/cart_bloc.dart';
// import '../blocs/cart/cart_state.dart';
// import '../blocs/address/address_bloc.dart';
// import '../blocs/address/address_event.dart'; // 👇 Pastikan ini diimport
// import '../blocs/address/address_state.dart';
// import '../blocs/checkout/checkout_bloc.dart';
// import '../blocs/checkout/checkout_event.dart';
// import '../blocs/checkout/checkout_state.dart';

// class PaymentPage extends StatefulWidget {
//   final List<int> selectedCartIds;

//   const PaymentPage({super.key, required this.selectedCartIds});

//   @override
//   State<PaymentPage> createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   final CheckoutRepository _checkoutRepo = CheckoutRepository();

//   // State Formulir
//   int? _selectedAddressId;
//   String _shippingMethod = 'free'; // 'free' atau 'biteship'
//   ShippingRateModel? _selectedRate;
//   String _deliveryType = 'now'; // 'now' atau 'scheduled'

//   // State Promo & Points
//   int _pointsToUse = 0;
//   String _promoInput = '';
//   String? _appliedPromoCode;
//   num _promoDiscountAmount = 0;
//   bool _isVerifyingPromo = false;
//   bool _useMemberVoucher = false;

//   // State API Kurir
//   List<ShippingRateModel> _shippingRates = [];
//   bool _isLoadingRates = false;

//   @override
//   void initState() {
//     super.initState();
//     // Tarik data alamat setiap kali masuk halaman checkout
//     context.read<AddressBloc>().add(FetchAddresses());
//   }

//   // --- LOGIKA ONGKIR ---
//   Future<void> _fetchRates(int addressId) async {
//     setState(() {
//       _isLoadingRates = true;
//       _shippingRates = [];
//       _selectedRate = null;
//     });

//     try {
//       final rates = await _checkoutRepo.fetchShippingRates(
//           addressId, widget.selectedCartIds);
//       if (mounted) {
//         setState(() {
//           _shippingRates = rates;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(e.toString())));
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingRates = false;
//         });
//       }
//     }
//   }

//   // --- LOGIKA PROMO ---
//   Future<void> _applyPromo(List<CartModel> checkoutItems) async {
//     if (_promoInput.isEmpty) return;
//     setState(() => _isVerifyingPromo = true);

//     try {
//       final code = _promoInput.toUpperCase();

//       // Siapkan payload cart sesuai kebutuhan backend
//       final cartPayload = checkoutItems
//           .map((item) => {
//                 'product_id': item.productId,
//                 'quantity': item.quantity,
//               })
//           .toList();

//       final res = await _checkoutRepo.verifyPromo(code, cartPayload);

//       setState(() {
//         _appliedPromoCode = code;
//         _promoDiscountAmount = res['discount_value'] ?? 0;
//         _pointsToUse = 0; // Kunci poin jika promo aktif
//       });

//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('✅ ${res['message']}'), backgroundColor: Colors.green));
//     } catch (e) {
//       setState(() {
//         _appliedPromoCode = null;
//         _promoDiscountAmount = 0;
//         _useMemberVoucher = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
//     } finally {
//       setState(() => _isVerifyingPromo = false);
//     }
//   }

//   void _removePromo() {
//     setState(() {
//       _promoInput = '';
//       _appliedPromoCode = null;
//       _promoDiscountAmount = 0;
//       _useMemberVoucher = false;
//     });
//   }

//   // --- KALKULASI HARGA ---
//   num _getSubtotal(List<CartModel> items) {
//     num total = 0;
//     for (var item in items) {
//       num price = item.product?.discountPrice != null &&
//               item.product!.discountPrice! > 0
//           ? item.product!.discountPrice!
//           : item.product?.price ?? 0;
//       total += (price * item.quantity);
//     }
//     return total;
//   }

//   // --- BUILDER UI ---
//   @override
//   Widget build(BuildContext context) {
//     final currencyFormat =
//         NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

//     return Scaffold(
//       backgroundColor: const Color(0xFFFAFAFA),
//       appBar: AppBar(
//         title: const Text('CHECKOUT',
//             style: TextStyle(
//                 fontWeight: FontWeight.w900,
//                 fontFamily: 'serif',
//                 letterSpacing: 1)),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//       ),
//       body: MultiBlocListener(
//         listeners: [
//           // 👇 KUNCI PERBAIKAN: Pindahkan logika penentuan alamat awal ke Listener! 👇
//           BlocListener<AddressBloc, AddressState>(
//             listener: (context, state) {
//               if (state is AddressLoaded && state.addresses.isNotEmpty) {
//                 if (_selectedAddressId == null) {
//                   final defaultAddr = state.addresses.firstWhere(
//                       (a) => a.isDefault,
//                       orElse: () => state.addresses.first);

//                   setState(() {
//                     _selectedAddressId = defaultAddr.id;
//                   });

//                   if (_shippingMethod == 'biteship') {
//                     _fetchRates(defaultAddr.id!);
//                   }
//                 }
//               }
//             },
//           ),
//           BlocListener<CheckoutBloc, CheckoutState>(
//             listener: (context, state) async {
//               if (state is CheckoutSuccess) {
//                 // Buka Link Pembayaran Xendit
//                 final url = Uri.parse(state.checkoutUrl);
//                 if (await canLaunchUrl(url)) {
//                   await launchUrl(url, mode: LaunchMode.externalApplication);
//                   Navigator.pop(
//                       context); // Kembali ke cart setelah membuka link
//                 }
//               } else if (state is CheckoutError) {
//                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text(state.message), backgroundColor: Colors.red));
//               }
//             },
//           ),
//         ],
//         child: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
//           UserModel? user;
//           if (authState is AuthAuthenticated) user = authState.user;

//           return BlocBuilder<CartBloc, CartState>(
//               builder: (context, cartState) {
//             if (cartState is! CartLoaded) {
//               return const Center(
//                   child: CircularProgressIndicator(color: Colors.black));
//             }

//             // Saring item yang dicheckout
//             final checkoutItems = cartState.items
//                 .where((e) => widget.selectedCartIds.contains(e.id))
//                 .toList();
//             if (checkoutItems.isEmpty) {
//               return const Center(child: Text("Tas Belanja Kosong"));
//             }

//             final subtotal = _getSubtotal(checkoutItems);
//             num bundleDiscount = cartState.summary.bundleDiscount;
//             num shippingCost =
//                 _shippingMethod == 'biteship' && _selectedRate != null
//                     ? _selectedRate!.price
//                     : 0;
//             num pointDiscount = _pointsToUse * 1000;

//             // Cegah minus
//             num grandTotal = (subtotal -
//                     bundleDiscount -
//                     _promoDiscountAmount -
//                     pointDiscount) +
//                 shippingCost;
//             if (grandTotal < 0) grandTotal = 0;

//             // Max Poin yang diizinkan
//             int maxPointsAllowed = user != null ? user.point : 0;
//             int maxUsableByPrice =
//                 ((subtotal - bundleDiscount - _promoDiscountAmount) / 1000)
//                     .floor();
//             if (maxPointsAllowed > maxUsableByPrice) {
//               maxPointsAllowed = maxUsableByPrice;
//             }
//             if (maxPointsAllowed < 0) maxPointsAllowed = 0;

//             return Column(
//               children: [
//                 Expanded(
//                   child: SingleChildScrollView(
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // 1. ALAMAT PENGIRIMAN
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(6),
//                               decoration: const BoxDecoration(
//                                   color: Colors.black, shape: BoxShape.circle),
//                               child: const Text('1',
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold)),
//                             ),
//                             const SizedBox(width: 8),
//                             const Text('SHIPPING ADDRESS',
//                                 style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 1)),
//                           ],
//                         ),
//                         const SizedBox(height: 16),

//                         BlocBuilder<AddressBloc, AddressState>(
//                           builder: (context, addressState) {
//                             if (addressState is AddressLoaded) {
//                               if (addressState.addresses.isEmpty) {
//                                 return const Text(
//                                     'Tidak ada alamat. Silakan tambah di profil.');
//                               }

//                               return Column(
//                                 children: addressState.addresses.map((addr) {
//                                   bool isSelected =
//                                       _selectedAddressId == addr.id;
//                                   return GestureDetector(
//                                     onTap: () {
//                                       setState(
//                                           () => _selectedAddressId = addr.id);
//                                       if (_shippingMethod == 'biteship') {
//                                         _fetchRates(addr.id!);
//                                       }
//                                     },
//                                     child: Container(
//                                       margin: const EdgeInsets.only(bottom: 12),
//                                       padding: const EdgeInsets.all(16),
//                                       decoration: BoxDecoration(
//                                         color: isSelected
//                                             ? Colors.white
//                                             : Colors.grey.shade50,
//                                         border: Border.all(
//                                             color: isSelected
//                                                 ? Colors.black
//                                                 : Colors.grey.shade200),
//                                         borderRadius: BorderRadius.circular(16),
//                                         boxShadow: isSelected
//                                             ? const [
//                                                 BoxShadow(
//                                                     color: Colors.black12,
//                                                     blurRadius: 4)
//                                               ]
//                                             : [],
//                                       ),
//                                       child: Row(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Radio<int>(
//                                             value: addr.id!,
//                                             groupValue: _selectedAddressId,
//                                             activeColor: Colors.black,
//                                             onChanged: (val) {
//                                               setState(() =>
//                                                   _selectedAddressId = val);
//                                               if (_shippingMethod ==
//                                                   'biteship') {
//                                                 _fetchRates(val!);
//                                               }
//                                             },
//                                           ),
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   children: [
//                                                     Text(
//                                                         '${addr.firstName} ${addr.lastName}'
//                                                             .toUpperCase(),
//                                                         style: const TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize: 13)),
//                                                     if (addr.isDefault)
//                                                       Container(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .symmetric(
//                                                                   horizontal: 6,
//                                                                   vertical: 2),
//                                                           decoration: BoxDecoration(
//                                                               color: Colors.grey
//                                                                   .shade200,
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           4)),
//                                                           child: const Text(
//                                                               'DEFAULT',
//                                                               style: TextStyle(
//                                                                   fontSize: 8,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold)))
//                                                   ],
//                                                 ),
//                                                 const SizedBox(height: 4),
//                                                 Text(
//                                                     '${addr.location}, ${addr.city}, ${addr.province} - ${addr.postalCode}',
//                                                     style: const TextStyle(
//                                                         fontSize: 12,
//                                                         color: Colors.grey,
//                                                         height: 1.5)),
//                                               ],
//                                             ),
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 }).toList(),
//                               );
//                             }
//                             return const Center(
//                                 child: CircularProgressIndicator());
//                           },
//                         ),
//                         const SizedBox(height: 24),

//                         // 2. METODE PENGIRIMAN
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(6),
//                               decoration: const BoxDecoration(
//                                   color: Colors.black, shape: BoxShape.circle),
//                               child: const Text('2',
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold)),
//                             ),
//                             const SizedBox(width: 8),
//                             const Text('SHIPPING METHOD',
//                                 style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 1)),
//                           ],
//                         ),
//                         const SizedBox(height: 16),

//                         // Opsi FREE
//                         GestureDetector(
//                           onTap: () => setState(() => _shippingMethod = 'free'),
//                           child: Container(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                                 border: Border.all(
//                                     color: _shippingMethod == 'free'
//                                         ? Colors.black
//                                         : Colors.grey.shade200),
//                                 borderRadius: BorderRadius.circular(16),
//                                 color: _shippingMethod == 'free'
//                                     ? Colors.white
//                                     : Colors.grey.shade50),
//                             child: Row(
//                               children: [
//                                 Radio<String>(
//                                     value: 'free',
//                                     groupValue: _shippingMethod,
//                                     activeColor: Colors.black,
//                                     onChanged: (val) =>
//                                         setState(() => _shippingMethod = val!)),
//                                 Expanded(
//                                   child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const Text('FREE SHIPPING (IN STORE)',
//                                             style: TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 12)),
//                                         Text('Ambil langsung di toko Solher',
//                                             style: TextStyle(
//                                                 fontSize: 10,
//                                                 color: Colors.green.shade600,
//                                                 fontWeight: FontWeight.bold)),
//                                       ]),
//                                 ),
//                                 const Text('Rp 0',
//                                     style:
//                                         TextStyle(fontWeight: FontWeight.w900)),
//                               ],
//                             ),
//                           ),
//                         ),

//                         // Opsi BITESHIP
//                         GestureDetector(
//                           onTap: () {
//                             setState(() => _shippingMethod = 'biteship');
//                             if (_selectedAddressId != null &&
//                                 _shippingRates.isEmpty) {
//                               _fetchRates(_selectedAddressId!);
//                             }
//                           },
//                           child: Container(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                                 border: Border.all(
//                                     color: _shippingMethod == 'biteship'
//                                         ? Colors.black
//                                         : Colors.grey.shade200),
//                                 borderRadius: BorderRadius.circular(16),
//                                 color: _shippingMethod == 'biteship'
//                                     ? Colors.white
//                                     : Colors.grey.shade50),
//                             child: Row(
//                               children: [
//                                 Radio<String>(
//                                     value: 'biteship',
//                                     groupValue: _shippingMethod,
//                                     activeColor: Colors.black,
//                                     onChanged: (val) {
//                                       setState(() => _shippingMethod = val!);
//                                       if (_selectedAddressId != null) {
//                                         _fetchRates(_selectedAddressId!);
//                                       }
//                                     }),
//                                 const Expanded(
//                                   child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text('STANDARD COURIER',
//                                             style: TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 12)),
//                                         Text('Powered by Biteship',
//                                             style: TextStyle(
//                                                 fontSize: 10,
//                                                 color: Colors.grey)),
//                                       ]),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),

//                         // Daftar Kurir Biteship (Jika Dipilih)
//                         if (_shippingMethod == 'biteship') ...[
//                           const SizedBox(height: 8),
//                           if (_isLoadingRates)
//                             const Center(child: CircularProgressIndicator())
//                           else if (_shippingRates.isEmpty)
//                             const Text(
//                                 'Tidak ada kurir yang tersedia untuk wilayah ini.',
//                                 style:
//                                     TextStyle(color: Colors.red, fontSize: 12))
//                           else
//                             ..._shippingRates.map((rate) {
//                               bool isSelected =
//                                   _selectedRate?.company == rate.company &&
//                                       _selectedRate?.type == rate.type;
//                               return GestureDetector(
//                                 onTap: () =>
//                                     setState(() => _selectedRate = rate),
//                                 child: Container(
//                                   margin: const EdgeInsets.only(
//                                       bottom: 8, left: 32),
//                                   padding: const EdgeInsets.all(12),
//                                   decoration: BoxDecoration(
//                                       border: Border.all(
//                                           color: isSelected
//                                               ? Colors.blue
//                                               : Colors.grey.shade200),
//                                       borderRadius: BorderRadius.circular(12),
//                                       color: isSelected
//                                           ? Colors.blue.shade50
//                                           : Colors.white),
//                                   child: Row(
//                                     children: [
//                                       Expanded(
//                                         child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                   '${rate.company.toUpperCase()} - ${rate.type.replaceAll('_', ' ')}',
//                                                   style: const TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize: 11)),
//                                               Text('Estimasi: ${rate.duration}',
//                                                   style: const TextStyle(
//                                                       fontSize: 10,
//                                                       color: Colors.grey)),
//                                             ]),
//                                       ),
//                                       Text(currencyFormat.format(rate.price),
//                                           style: const TextStyle(
//                                               fontWeight: FontWeight.w900,
//                                               fontSize: 12)),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }).toList()
//                         ],
//                         const SizedBox(height: 32),

//                         // 3. KODE PROMO & POIN
//                         const Text('PROMO CODE',
//                             style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 letterSpacing: 1.5,
//                                 color: Colors.grey)),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 onChanged: (val) => _promoInput = val,
//                                 enabled: _appliedPromoCode == null,
//                                 decoration: InputDecoration(
//                                     hintText: 'Enter code here',
//                                     filled: true,
//                                     fillColor: Colors.grey.shade50,
//                                     border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                         borderSide: BorderSide(
//                                             color: Colors.grey.shade300)),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         horizontal: 16)),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             if (_appliedPromoCode == null)
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.black,
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 20, vertical: 14),
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(12))),
//                                 onPressed: _isVerifyingPromo
//                                     ? null
//                                     : () => _applyPromo(checkoutItems),
//                                 child: _isVerifyingPromo
//                                     ? const SizedBox(
//                                         width: 16,
//                                         height: 16,
//                                         child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2))
//                                     : const Text('APPLY',
//                                         style: TextStyle(color: Colors.white)),
//                               )
//                             else
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.red.shade50,
//                                     foregroundColor: Colors.red,
//                                     elevation: 0,
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 20, vertical: 14),
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                         side: BorderSide(
//                                             color: Colors.red.shade200))),
//                                 onPressed: _removePromo,
//                                 child: const Text('REMOVE'),
//                               )
//                           ],
//                         ),

//                         if (user != null && user.isMembership) ...[
//                           const SizedBox(height: 24),
//                           const Text('SOLHER CLUB POINTS',
//                               style: TextStyle(
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 1.5,
//                                   color: Colors.grey)),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: TextField(
//                                   keyboardType: TextInputType.number,
//                                   onChanged: (val) {
//                                     setState(() {
//                                       _pointsToUse = int.tryParse(val) ?? 0;
//                                       if (_pointsToUse > maxPointsAllowed) {
//                                         _pointsToUse = maxPointsAllowed;
//                                       }
//                                     });
//                                   },
//                                   decoration: InputDecoration(
//                                       hintText: 'Max: $maxPointsAllowed pts',
//                                       filled: true,
//                                       fillColor: Colors.grey.shade50,
//                                       border: OutlineInputBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                           borderSide: BorderSide(
//                                               color: Colors.yellow.shade600)),
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                               horizontal: 16)),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.yellow.shade100,
//                                     foregroundColor: Colors.yellow.shade900,
//                                     elevation: 0,
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 20, vertical: 14),
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(12))),
//                                 onPressed: () {
//                                   setState(() {
//                                     _pointsToUse = maxPointsAllowed;
//                                   });
//                                 },
//                                 child: const Text('USE ALL'),
//                               )
//                             ],
//                           ),
//                         ]
//                       ],
//                     ),
//                   ),
//                 ),

//                 // AREA SUMMARY BOTTOM
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
//                         Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('Subtotal (${checkoutItems.length} items)',
//                                   style: const TextStyle(
//                                       fontSize: 12, color: Colors.grey)),
//                               Text(currencyFormat.format(subtotal),
//                                   style: const TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold)),
//                             ]),
//                         const SizedBox(height: 8),
//                         if (shippingCost > 0) ...[
//                           Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text('Shipping Cost',
//                                     style: TextStyle(
//                                         fontSize: 12, color: Colors.grey)),
//                                 Text(currencyFormat.format(shippingCost),
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold)),
//                               ]),
//                           const SizedBox(height: 8),
//                         ],
//                         if (_promoDiscountAmount > 0) ...[
//                           Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('Promo ($_appliedPromoCode)',
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.green,
//                                         fontWeight: FontWeight.bold)),
//                                 Text(
//                                     '- ${currencyFormat.format(_promoDiscountAmount)}',
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.green)),
//                               ]),
//                           const SizedBox(height: 8),
//                         ],
//                         if (pointDiscount > 0) ...[
//                           Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text('Points Applied',
//                                     style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.orange,
//                                         fontWeight: FontWeight.bold)),
//                                 Text(
//                                     '- ${currencyFormat.format(pointDiscount)}',
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.orange)),
//                               ]),
//                           const SizedBox(height: 8),
//                         ],
//                         const Padding(
//                             padding: EdgeInsets.symmetric(vertical: 8),
//                             child: Divider()),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text('GRAND TOTAL',
//                                 style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 1.5)),
//                             Text(currencyFormat.format(grandTotal),
//                                 style: const TextStyle(
//                                     fontSize: 22, fontWeight: FontWeight.w900)),
//                           ],
//                         ),
//                         const SizedBox(height: 16),

//                         // TOMBOL CHECKOUT
//                         BlocBuilder<CheckoutBloc, CheckoutState>(
//                             builder: (context, checkoutState) {
//                           bool isButtonDisabled = _selectedAddressId == null ||
//                               (_shippingMethod == 'biteship' &&
//                                   _selectedRate == null) ||
//                               checkoutState is CheckoutLoading;

//                           return SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.black,
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 16),
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(16))),
//                               onPressed: isButtonDisabled
//                                   ? null
//                                   : () {
//                                       // BUAT PAYLOAD SESUAI BACKEND LARAVEL
//                                       final payload = {
//                                         'address_id': _selectedAddressId,
//                                         'shipping_method': _shippingMethod,
//                                         'use_points': _pointsToUse,
//                                         'cart_ids': widget.selectedCartIds,
//                                         'courier_company':
//                                             _shippingMethod == 'biteship'
//                                                 ? _selectedRate?.company
//                                                 : null,
//                                         'courier_type':
//                                             _shippingMethod == 'biteship'
//                                                 ? _selectedRate?.type
//                                                 : null,
//                                         'shipping_cost': shippingCost,
//                                         'delivery_type': _deliveryType,
//                                         'promo_code': _appliedPromoCode,
//                                         'currency': 'IDR',
//                                       };

//                                       context
//                                           .read<CheckoutBloc>()
//                                           .add(SubmitCheckoutEvent(payload));
//                                     },
//                               child: checkoutState is CheckoutLoading
//                                   ? const SizedBox(
//                                       height: 20,
//                                       width: 20,
//                                       child: CircularProgressIndicator(
//                                           color: Colors.white, strokeWidth: 2))
//                                   : const Text('PAY SECURELY',
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           letterSpacing: 2)),
//                             ),
//                           );
//                         })
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             );
//           });
//         }),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart';

// // Repositories & Models
// import '../repositories/checkout_repository.dart';
// import '../repositories/address_repository.dart'; // 👇 PENTING: Import ini ditambahkan
// import '../models/checkout_model.dart';
// import '../models/cart_model.dart';
// import '../models/user_model.dart';

// // BLoCs
// import '../blocs/auth/auth_bloc.dart';
// import '../blocs/auth/auth_state.dart';
// import '../blocs/cart/cart_bloc.dart';
// import '../blocs/cart/cart_state.dart';
// import '../blocs/address/address_bloc.dart';
// import '../blocs/address/address_event.dart';
// import '../blocs/address/address_state.dart';
// import '../blocs/checkout/checkout_bloc.dart';
// import '../blocs/checkout/checkout_event.dart';
// import '../blocs/checkout/checkout_state.dart';

// class PaymentPage extends StatefulWidget {
//   final List<int> selectedCartIds;

//   const PaymentPage({super.key, required this.selectedCartIds});

//   @override
//   State<PaymentPage> createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   final CheckoutRepository _checkoutRepo = CheckoutRepository();

//   // State Formulir
//   int? _selectedAddressId;
//   String _shippingMethod = 'free'; // 'free' atau 'biteship'
//   ShippingRateModel? _selectedRate;
//   String _deliveryType = 'now'; // 'now' atau 'scheduled'

//   // State Promo & Points
//   int _pointsToUse = 0;
//   String _promoInput = '';
//   String? _appliedPromoCode;
//   num _promoDiscountAmount = 0;
//   bool _isVerifyingPromo = false;
//   bool _useMemberVoucher = false;

//   // State API Kurir
//   List<ShippingRateModel> _shippingRates = [];
//   bool _isLoadingRates = false;

//   @override
//   void initState() {
//     super.initState();
//     // PERBAIKAN: Hapus pemanggilan context.read() di sini untuk mencegah ProviderNotFoundException.
//     // Pemanggilan FetchAddresses dipindahkan langsung ke dalam BlocProvider di fungsi build()
//   }

//   // --- LOGIKA ONGKIR ---
//   Future<void> _fetchRates(int addressId) async {
//     setState(() {
//       _isLoadingRates = true;
//       _shippingRates = [];
//       _selectedRate = null;
//     });

//     try {
//       final rates = await _checkoutRepo.fetchShippingRates(
//           addressId, widget.selectedCartIds);
//       if (mounted) {
//         setState(() {
//           _shippingRates = rates;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(e.toString())));
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingRates = false;
//         });
//       }
//     }
//   }

//   // --- LOGIKA PROMO ---
//   Future<void> _applyPromo(List<CartModel> checkoutItems) async {
//     if (_promoInput.isEmpty) return;
//     setState(() => _isVerifyingPromo = true);

//     try {
//       final code = _promoInput.toUpperCase();

//       // Siapkan payload cart sesuai kebutuhan backend
//       final cartPayload = checkoutItems
//           .map((item) => {
//                 'product_id': item.productId,
//                 'quantity': item.quantity,
//               })
//           .toList();

//       final res = await _checkoutRepo.verifyPromo(code, cartPayload);

//       setState(() {
//         _appliedPromoCode = code;
//         _promoDiscountAmount = res['discount_value'] ?? 0;
//         _pointsToUse = 0; // Kunci poin jika promo aktif
//       });

//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('✅ ${res['message']}'), backgroundColor: Colors.green));
//     } catch (e) {
//       setState(() {
//         _appliedPromoCode = null;
//         _promoDiscountAmount = 0;
//         _useMemberVoucher = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
//     } finally {
//       setState(() => _isVerifyingPromo = false);
//     }
//   }

//   void _removePromo() {
//     setState(() {
//       _promoInput = '';
//       _appliedPromoCode = null;
//       _promoDiscountAmount = 0;
//       _useMemberVoucher = false;
//     });
//   }

//   // --- KALKULASI HARGA ---
//   num _getSubtotal(List<CartModel> items) {
//     num total = 0;
//     for (var item in items) {
//       num price = item.product?.discountPrice != null &&
//               item.product!.discountPrice! > 0
//           ? item.product!.discountPrice!
//           : item.product?.price ?? 0;
//       total += (price * item.quantity);
//     }
//     return total;
//   }

//   // --- BUILDER UI ---
//   @override
//   Widget build(BuildContext context) {
//     final currencyFormat =
//         NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

//     // 👇 SOLUSI MUTLAK: Bungkus Scaffold dengan MultiBlocProvider di sini 👇
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<AddressBloc>(
//           create: (context) => AddressBloc(
//               addressRepository: AddressRepository())
//             ..add(
//                 FetchAddresses()), // Fetch dipanggil secara aman saat BLoC diciptakan
//         ),
//         BlocProvider<CheckoutBloc>(
//           create: (context) => CheckoutBloc(repository: _checkoutRepo),
//         ),
//       ],
//       child: Scaffold(
//         backgroundColor: const Color(0xFFFAFAFA),
//         appBar: AppBar(
//           title: const Text('CHECKOUT',
//               style: TextStyle(
//                   fontWeight: FontWeight.w900,
//                   fontFamily: 'serif',
//                   letterSpacing: 1)),
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 0.5,
//         ),
//         body: MultiBlocListener(
//           listeners: [
//             BlocListener<AddressBloc, AddressState>(
//               listener: (context, state) {
//                 if (state is AddressLoaded && state.addresses.isNotEmpty) {
//                   if (_selectedAddressId == null) {
//                     final defaultAddr = state.addresses.firstWhere(
//                         (a) => a.isDefault,
//                         orElse: () => state.addresses.first);

//                     setState(() {
//                       _selectedAddressId = defaultAddr.id;
//                     });

//                     if (_shippingMethod == 'biteship') {
//                       _fetchRates(defaultAddr.id!);
//                     }
//                   }
//                 }
//               },
//             ),
//             // BlocListener<CheckoutBloc, CheckoutState>(
//             //   listener: (context, state) async {
//             //     if (state is CheckoutSuccess) {
//             //       // Buka Link Pembayaran Xendit
//             //       final url = Uri.parse(state.checkoutUrl);
//             //       if (await canLaunchUrl(url)) {
//             //         await launchUrl(url, mode: LaunchMode.externalApplication);
//             //         Navigator.pop(
//             //             context); // Kembali ke cart setelah membuka link
//             //       }
//             //     } else if (state is CheckoutError) {
//             //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             //           content: Text(state.message),
//             //           backgroundColor: Colors.red));
//             //     }
//             //   },
//             // ),

//             BlocListener<CheckoutBloc, CheckoutState>(
//               listener: (context, state) async {
//                 if (state is CheckoutSuccess) {
//                   final url = Uri.parse(state.checkoutUrl);

//                   // Gunakan try-catch dan mode inAppBrowserView agar lebih elegan
//                   try {
//                     await launchUrl(
//                       url,
//                       mode: LaunchMode
//                           .inAppBrowserView, // 👇 Terbuka di dalam aplikasi
//                     );
//                     if (context.mounted) {
//                       Navigator.pop(
//                           context); // Kembali ke cart setelah checkout ditekan
//                     }
//                   } catch (e) {
//                     if (context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                             content: Text('Gagal membuka halaman pembayaran'),
//                             backgroundColor: Colors.red),
//                       );
//                     }
//                   }
//                 } else if (state is CheckoutError) {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                       content: Text(state.message),
//                       backgroundColor: Colors.red));
//                 }
//               },
//             ),
//           ],
//           child:
//               BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
//             UserModel? user;
//             if (authState is AuthAuthenticated) user = authState.user;

//             return BlocBuilder<CartBloc, CartState>(
//                 builder: (context, cartState) {
//               if (cartState is! CartLoaded) {
//                 return const Center(
//                     child: CircularProgressIndicator(color: Colors.black));
//               }

//               // Saring item yang dicheckout
//               final checkoutItems = cartState.items
//                   .where((e) => widget.selectedCartIds.contains(e.id))
//                   .toList();
//               if (checkoutItems.isEmpty) {
//                 return const Center(child: Text("Tas Belanja Kosong"));
//               }

//               final subtotal = _getSubtotal(checkoutItems);
//               num bundleDiscount = cartState.summary.bundleDiscount;
//               num shippingCost =
//                   _shippingMethod == 'biteship' && _selectedRate != null
//                       ? _selectedRate!.price
//                       : 0;
//               num pointDiscount = _pointsToUse * 1000;

//               // Cegah minus
//               num grandTotal = (subtotal -
//                       bundleDiscount -
//                       _promoDiscountAmount -
//                       pointDiscount) +
//                   shippingCost;
//               if (grandTotal < 0) grandTotal = 0;

//               // Max Poin yang diizinkan
//               int maxPointsAllowed = user != null ? user.point : 0;
//               int maxUsableByPrice =
//                   ((subtotal - bundleDiscount - _promoDiscountAmount) / 1000)
//                       .floor();
//               if (maxPointsAllowed > maxUsableByPrice) {
//                 maxPointsAllowed = maxUsableByPrice;
//               }
//               if (maxPointsAllowed < 0) maxPointsAllowed = 0;

//               return Column(
//                 children: [
//                   Expanded(
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // 1. ALAMAT PENGIRIMAN
//                           Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(6),
//                                 decoration: const BoxDecoration(
//                                     color: Colors.black,
//                                     shape: BoxShape.circle),
//                                 child: const Text('1',
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold)),
//                               ),
//                               const SizedBox(width: 8),
//                               const Text('SHIPPING ADDRESS',
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 1)),
//                             ],
//                           ),
//                           const SizedBox(height: 16),

//                           BlocBuilder<AddressBloc, AddressState>(
//                             builder: (context, addressState) {
//                               if (addressState is AddressLoaded) {
//                                 if (addressState.addresses.isEmpty) {
//                                   return const Text(
//                                       'Tidak ada alamat. Silakan tambah di profil.');
//                                 }

//                                 return Column(
//                                   children: addressState.addresses.map((addr) {
//                                     bool isSelected =
//                                         _selectedAddressId == addr.id;
//                                     return GestureDetector(
//                                       onTap: () {
//                                         setState(
//                                             () => _selectedAddressId = addr.id);
//                                         if (_shippingMethod == 'biteship') {
//                                           _fetchRates(addr.id!);
//                                         }
//                                       },
//                                       child: Container(
//                                         margin:
//                                             const EdgeInsets.only(bottom: 12),
//                                         padding: const EdgeInsets.all(16),
//                                         decoration: BoxDecoration(
//                                           color: isSelected
//                                               ? Colors.white
//                                               : Colors.grey.shade50,
//                                           border: Border.all(
//                                               color: isSelected
//                                                   ? Colors.black
//                                                   : Colors.grey.shade200),
//                                           borderRadius:
//                                               BorderRadius.circular(16),
//                                           boxShadow: isSelected
//                                               ? const [
//                                                   BoxShadow(
//                                                       color: Colors.black12,
//                                                       blurRadius: 4)
//                                                 ]
//                                               : [],
//                                         ),
//                                         child: Row(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Radio<int>(
//                                               value: addr.id!,
//                                               groupValue: _selectedAddressId,
//                                               activeColor: Colors.black,
//                                               onChanged: (val) {
//                                                 setState(() =>
//                                                     _selectedAddressId = val);
//                                                 if (_shippingMethod ==
//                                                     'biteship') {
//                                                   _fetchRates(val!);
//                                                 }
//                                               },
//                                             ),
//                                             Expanded(
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceBetween,
//                                                     children: [
//                                                       Text(
//                                                           '${addr.firstName} ${addr.lastName}'
//                                                               .toUpperCase(),
//                                                           style:
//                                                               const TextStyle(
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                   fontSize:
//                                                                       13)),
//                                                       if (addr.isDefault)
//                                                         Container(
//                                                             padding: const EdgeInsets
//                                                                 .symmetric(
//                                                                 horizontal: 6,
//                                                                 vertical: 2),
//                                                             decoration: BoxDecoration(
//                                                                 color: Colors
//                                                                     .grey
//                                                                     .shade200,
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .circular(
//                                                                             4)),
//                                                             child: const Text(
//                                                                 'DEFAULT',
//                                                                 style: TextStyle(
//                                                                     fontSize: 8,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .bold)))
//                                                     ],
//                                                   ),
//                                                   const SizedBox(height: 4),
//                                                   Text(
//                                                       '${addr.location}, ${addr.city}, ${addr.province} - ${addr.postalCode}',
//                                                       style: const TextStyle(
//                                                           fontSize: 12,
//                                                           color: Colors.grey,
//                                                           height: 1.5)),
//                                                 ],
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),
//                                 );
//                               }
//                               return const Center(
//                                   child: CircularProgressIndicator());
//                             },
//                           ),
//                           const SizedBox(height: 24),

//                           // 2. METODE PENGIRIMAN
//                           Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(6),
//                                 decoration: const BoxDecoration(
//                                     color: Colors.black,
//                                     shape: BoxShape.circle),
//                                 child: const Text('2',
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold)),
//                               ),
//                               const SizedBox(width: 8),
//                               const Text('SHIPPING METHOD',
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 1)),
//                             ],
//                           ),
//                           const SizedBox(height: 16),

//                           // Opsi FREE
//                           GestureDetector(
//                             onTap: () =>
//                                 setState(() => _shippingMethod = 'free'),
//                             child: Container(
//                               margin: const EdgeInsets.only(bottom: 12),
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: _shippingMethod == 'free'
//                                           ? Colors.black
//                                           : Colors.grey.shade200),
//                                   borderRadius: BorderRadius.circular(16),
//                                   color: _shippingMethod == 'free'
//                                       ? Colors.white
//                                       : Colors.grey.shade50),
//                               child: Row(
//                                 children: [
//                                   Radio<String>(
//                                       value: 'free',
//                                       groupValue: _shippingMethod,
//                                       activeColor: Colors.black,
//                                       onChanged: (val) => setState(
//                                           () => _shippingMethod = val!)),
//                                   Expanded(
//                                     child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           const Text('FREE SHIPPING (IN STORE)',
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 12)),
//                                           Text('Ambil langsung di toko Solher',
//                                               style: TextStyle(
//                                                   fontSize: 10,
//                                                   color: Colors.green.shade600,
//                                                   fontWeight: FontWeight.bold)),
//                                         ]),
//                                   ),
//                                   const Text('Rp 0',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.w900)),
//                                 ],
//                               ),
//                             ),
//                           ),

//                           // Opsi BITESHIP
//                           GestureDetector(
//                             onTap: () {
//                               setState(() => _shippingMethod = 'biteship');
//                               if (_selectedAddressId != null &&
//                                   _shippingRates.isEmpty) {
//                                 _fetchRates(_selectedAddressId!);
//                               }
//                             },
//                             child: Container(
//                               margin: const EdgeInsets.only(bottom: 12),
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: _shippingMethod == 'biteship'
//                                           ? Colors.black
//                                           : Colors.grey.shade200),
//                                   borderRadius: BorderRadius.circular(16),
//                                   color: _shippingMethod == 'biteship'
//                                       ? Colors.white
//                                       : Colors.grey.shade50),
//                               child: Row(
//                                 children: [
//                                   Radio<String>(
//                                       value: 'biteship',
//                                       groupValue: _shippingMethod,
//                                       activeColor: Colors.black,
//                                       onChanged: (val) {
//                                         setState(() => _shippingMethod = val!);
//                                         if (_selectedAddressId != null) {
//                                           _fetchRates(_selectedAddressId!);
//                                         }
//                                       }),
//                                   const Expanded(
//                                     child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text('STANDARD COURIER',
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 12)),
//                                           Text('Powered by Biteship',
//                                               style: TextStyle(
//                                                   fontSize: 10,
//                                                   color: Colors.grey)),
//                                         ]),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),

//                           // Daftar Kurir Biteship (Jika Dipilih)
//                           if (_shippingMethod == 'biteship') ...[
//                             const SizedBox(height: 8),
//                             if (_isLoadingRates)
//                               const Center(
//                                   child: CircularProgressIndicator(
//                                       color: Colors.black))
//                             else if (_shippingRates.isEmpty)
//                               const Text(
//                                   'Tidak ada kurir yang tersedia untuk wilayah ini.',
//                                   style: TextStyle(
//                                       color: Colors.red, fontSize: 12))
//                             else
//                               ..._shippingRates.map((rate) {
//                                 bool isSelected =
//                                     _selectedRate?.company == rate.company &&
//                                         _selectedRate?.type == rate.type;
//                                 return GestureDetector(
//                                   onTap: () =>
//                                       setState(() => _selectedRate = rate),
//                                   child: Container(
//                                     margin: const EdgeInsets.only(
//                                         bottom: 8, left: 32),
//                                     padding: const EdgeInsets.all(12),
//                                     decoration: BoxDecoration(
//                                         border: Border.all(
//                                             color: isSelected
//                                                 ? Colors.blue
//                                                 : Colors.grey.shade200),
//                                         borderRadius: BorderRadius.circular(12),
//                                         color: isSelected
//                                             ? Colors.blue.shade50
//                                             : Colors.white),
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                     '${rate.company.toUpperCase()} - ${rate.type.replaceAll('_', ' ')}',
//                                                     style: const TextStyle(
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         fontSize: 11)),
//                                                 Text(
//                                                     'Estimasi: ${rate.duration}',
//                                                     style: const TextStyle(
//                                                         fontSize: 10,
//                                                         color: Colors.grey)),
//                                               ]),
//                                         ),
//                                         Text(currencyFormat.format(rate.price),
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.w900,
//                                                 fontSize: 12)),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               }).toList()
//                           ],
//                           const SizedBox(height: 32),

//                           // 3. KODE PROMO & POIN
//                           const Text('PROMO CODE',
//                               style: TextStyle(
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 1.5,
//                                   color: Colors.grey)),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: TextField(
//                                   onChanged: (val) => _promoInput = val,
//                                   enabled: _appliedPromoCode == null,
//                                   decoration: InputDecoration(
//                                       hintText: 'Enter code here',
//                                       filled: true,
//                                       fillColor: Colors.grey.shade50,
//                                       border: OutlineInputBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                           borderSide: BorderSide(
//                                               color: Colors.grey.shade300)),
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                               horizontal: 16)),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               if (_appliedPromoCode == null)
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.black,
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 20, vertical: 14),
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(12))),
//                                   onPressed: _isVerifyingPromo
//                                       ? null
//                                       : () => _applyPromo(checkoutItems),
//                                   child: _isVerifyingPromo
//                                       ? const SizedBox(
//                                           width: 16,
//                                           height: 16,
//                                           child: CircularProgressIndicator(
//                                               color: Colors.white,
//                                               strokeWidth: 2))
//                                       : const Text('APPLY',
//                                           style:
//                                               TextStyle(color: Colors.white)),
//                                 )
//                               else
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.red.shade50,
//                                       foregroundColor: Colors.red,
//                                       elevation: 0,
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 20, vertical: 14),
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                           side: BorderSide(
//                                               color: Colors.red.shade200))),
//                                   onPressed: _removePromo,
//                                   child: const Text('REMOVE'),
//                                 )
//                             ],
//                           ),

//                           if (user != null && user.isMembership) ...[
//                             const SizedBox(height: 24),
//                             const Text('SOLHER CLUB POINTS',
//                                 style: TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 1.5,
//                                     color: Colors.grey)),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: TextField(
//                                     keyboardType: TextInputType.number,
//                                     onChanged: (val) {
//                                       setState(() {
//                                         _pointsToUse = int.tryParse(val) ?? 0;
//                                         if (_pointsToUse > maxPointsAllowed) {
//                                           _pointsToUse = maxPointsAllowed;
//                                         }
//                                       });
//                                     },
//                                     decoration: InputDecoration(
//                                         hintText: 'Max: $maxPointsAllowed pts',
//                                         filled: true,
//                                         fillColor: Colors.grey.shade50,
//                                         border: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                             borderSide: BorderSide(
//                                                 color: Colors.yellow.shade600)),
//                                         contentPadding:
//                                             const EdgeInsets.symmetric(
//                                                 horizontal: 16)),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.yellow.shade100,
//                                       foregroundColor: Colors.yellow.shade900,
//                                       elevation: 0,
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 20, vertical: 14),
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(12))),
//                                   onPressed: () {
//                                     setState(() {
//                                       _pointsToUse = maxPointsAllowed;
//                                     });
//                                   },
//                                   child: const Text('USE ALL'),
//                                 )
//                               ],
//                             ),
//                           ]
//                         ],
//                       ),
//                     ),
//                   ),

//                   // AREA SUMMARY BOTTOM
//                   Container(
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 20,
//                             offset: const Offset(0, -5))
//                       ],
//                       borderRadius:
//                           const BorderRadius.vertical(top: Radius.circular(30)),
//                     ),
//                     child: SafeArea(
//                       top: false,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('Subtotal (${checkoutItems.length} items)',
//                                     style: const TextStyle(
//                                         fontSize: 12, color: Colors.grey)),
//                                 Text(currencyFormat.format(subtotal),
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold)),
//                               ]),
//                           const SizedBox(height: 8),
//                           if (shippingCost > 0) ...[
//                             Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text('Shipping Cost',
//                                       style: TextStyle(
//                                           fontSize: 12, color: Colors.grey)),
//                                   Text(currencyFormat.format(shippingCost),
//                                       style: const TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold)),
//                                 ]),
//                             const SizedBox(height: 8),
//                           ],
//                           if (_promoDiscountAmount > 0) ...[
//                             Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text('Promo ($_appliedPromoCode)',
//                                       style: const TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.green,
//                                           fontWeight: FontWeight.bold)),
//                                   Text(
//                                       '- ${currencyFormat.format(_promoDiscountAmount)}',
//                                       style: const TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.green)),
//                                 ]),
//                             const SizedBox(height: 8),
//                           ],
//                           if (pointDiscount > 0) ...[
//                             Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text('Points Applied',
//                                       style: TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.orange,
//                                           fontWeight: FontWeight.bold)),
//                                   Text(
//                                       '- ${currencyFormat.format(pointDiscount)}',
//                                       style: const TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.orange)),
//                                 ]),
//                             const SizedBox(height: 8),
//                           ],
//                           const Padding(
//                               padding: EdgeInsets.symmetric(vertical: 8),
//                               child: Divider()),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('GRAND TOTAL',
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 1.5)),
//                               Text(currencyFormat.format(grandTotal),
//                                   style: const TextStyle(
//                                       fontSize: 22,
//                                       fontWeight: FontWeight.w900)),
//                             ],
//                           ),
//                           const SizedBox(height: 16),

//                           // TOMBOL CHECKOUT
//                           BlocBuilder<CheckoutBloc, CheckoutState>(
//                               builder: (context, checkoutState) {
//                             bool isButtonDisabled =
//                                 _selectedAddressId == null ||
//                                     (_shippingMethod == 'biteship' &&
//                                         _selectedRate == null) ||
//                                     checkoutState is CheckoutLoading;

//                             return SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.black,
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 16),
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(16))),
//                                 onPressed: isButtonDisabled
//                                     ? null
//                                     : () {
//                                         final payload = {
//                                           'address_id': _selectedAddressId,
//                                           'shipping_method': _shippingMethod,
//                                           'use_points': _pointsToUse,
//                                           'cart_ids': widget.selectedCartIds,
//                                           'courier_company':
//                                               _shippingMethod == 'biteship'
//                                                   ? _selectedRate?.company
//                                                   : null,
//                                           'courier_type':
//                                               _shippingMethod == 'biteship'
//                                                   ? _selectedRate?.type
//                                                   : null,
//                                           'shipping_cost': shippingCost,
//                                           'delivery_type': _deliveryType,
//                                           'promo_code': _appliedPromoCode,
//                                           'currency': 'IDR',
//                                         };

//                                         context
//                                             .read<CheckoutBloc>()
//                                             .add(SubmitCheckoutEvent(payload));
//                                       },
//                                 child: checkoutState is CheckoutLoading
//                                     ? const SizedBox(
//                                         height: 20,
//                                         width: 20,
//                                         child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2))
//                                     : const Text('PAY SECURELY',
//                                         style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                             letterSpacing: 2)),
//                               ),
//                             );
//                           })
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               );
//             });
//           }),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';

// // Repositories & Models
// import '../repositories/checkout_repository.dart';
// import '../repositories/address_repository.dart';
// import '../models/checkout_model.dart';
// import '../models/cart_model.dart';
// import '../models/user_model.dart';

// // BLoCs
// import '../blocs/auth/auth_bloc.dart';
// import '../blocs/auth/auth_state.dart';
// import '../blocs/cart/cart_bloc.dart';
// import '../blocs/cart/cart_state.dart';
// import '../blocs/address/address_bloc.dart';
// import '../blocs/address/address_event.dart';
// import '../blocs/address/address_state.dart';
// import '../blocs/checkout/checkout_bloc.dart';
// import '../blocs/checkout/checkout_event.dart';
// import '../blocs/checkout/checkout_state.dart';

// // 👇 IMPORT HALAMAN XENDIT 👇
// import 'xendit_page.dart';

// class PaymentPage extends StatefulWidget {
//   final List<int> selectedCartIds;

//   const PaymentPage({super.key, required this.selectedCartIds});

//   @override
//   State<PaymentPage> createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   final CheckoutRepository _checkoutRepo = CheckoutRepository();

//   int? _selectedAddressId;
//   String _shippingMethod = 'free';
//   ShippingRateModel? _selectedRate;
//   String _deliveryType = 'now';

//   int _pointsToUse = 0;
//   String _promoInput = '';
//   String? _appliedPromoCode;
//   num _promoDiscountAmount = 0;
//   bool _isVerifyingPromo = false;
//   bool _useMemberVoucher = false;

//   List<ShippingRateModel> _shippingRates = [];
//   bool _isLoadingRates = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   Future<void> _fetchRates(int addressId) async {
//     setState(() {
//       _isLoadingRates = true;
//       _shippingRates = [];
//       _selectedRate = null;
//     });

//     try {
//       final rates = await _checkoutRepo.fetchShippingRates(
//           addressId, widget.selectedCartIds);
//       if (mounted) setState(() => _shippingRates = rates);
//     } catch (e) {
//       if (mounted)
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(e.toString())));
//     } finally {
//       if (mounted) setState(() => _isLoadingRates = false);
//     }
//   }

//   Future<void> _applyPromo(List<CartModel> checkoutItems) async {
//     if (_promoInput.isEmpty) return;
//     setState(() => _isVerifyingPromo = true);

//     try {
//       final code = _promoInput.toUpperCase();
//       final cartPayload = checkoutItems
//           .map((item) => {
//                 'product_id': item.productId,
//                 'quantity': item.quantity,
//               })
//           .toList();

//       final res = await _checkoutRepo.verifyPromo(code, cartPayload);

//       setState(() {
//         _appliedPromoCode = code;
//         _promoDiscountAmount = res['discount_value'] ?? 0;
//         _pointsToUse = 0;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('✅ ${res['message']}'), backgroundColor: Colors.green));
//     } catch (e) {
//       setState(() {
//         _appliedPromoCode = null;
//         _promoDiscountAmount = 0;
//         _useMemberVoucher = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
//     } finally {
//       setState(() => _isVerifyingPromo = false);
//     }
//   }

//   void _removePromo() {
//     setState(() {
//       _promoInput = '';
//       _appliedPromoCode = null;
//       _promoDiscountAmount = 0;
//       _useMemberVoucher = false;
//     });
//   }

//   num _getSubtotal(List<CartModel> items) {
//     num total = 0;
//     for (var item in items) {
//       num price = item.product?.discountPrice != null &&
//               item.product!.discountPrice! > 0
//           ? item.product!.discountPrice!
//           : item.product?.price ?? 0;
//       total += (price * item.quantity);
//     }
//     return total;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currencyFormat =
//         NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<AddressBloc>(
//           create: (context) =>
//               AddressBloc(addressRepository: AddressRepository())
//                 ..add(FetchAddresses()),
//         ),
//         BlocProvider<CheckoutBloc>(
//           create: (context) => CheckoutBloc(repository: _checkoutRepo),
//         ),
//       ],
//       child: Scaffold(
//         backgroundColor: const Color(0xFFFAFAFA),
//         appBar: AppBar(
//           title: const Text('CHECKOUT',
//               style: TextStyle(
//                   fontWeight: FontWeight.w900,
//                   fontFamily: 'serif',
//                   letterSpacing: 1)),
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 0.5,
//         ),
//         body: MultiBlocListener(
//           listeners: [
//             BlocListener<AddressBloc, AddressState>(
//               listener: (context, state) {
//                 if (state is AddressLoaded && state.addresses.isNotEmpty) {
//                   if (_selectedAddressId == null) {
//                     final defaultAddr = state.addresses.firstWhere(
//                         (a) => a.isDefault,
//                         orElse: () => state.addresses.first);
//                     setState(() => _selectedAddressId = defaultAddr.id);
//                     if (_shippingMethod == 'biteship')
//                       _fetchRates(defaultAddr.id!);
//                   }
//                 }
//               },
//             ),
//             BlocListener<CheckoutBloc, CheckoutState>(
//               listener: (context, state) {
//                 if (state is CheckoutSuccess) {
//                   // 👇 PERBAIKAN: Arahkan ke Halaman XenditPage Flutter Kita 👇
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) =>
//                           XenditPage(checkoutUrl: state.checkoutUrl),
//                     ),
//                   );
//                 } else if (state is CheckoutError) {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                       content: Text(state.message),
//                       backgroundColor: Colors.red));
//                 }
//               },
//             ),
//           ],
//           child:
//               BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
//             UserModel? user;
//             if (authState is AuthAuthenticated) user = authState.user;

//             return BlocBuilder<CartBloc, CartState>(
//                 builder: (context, cartState) {
//               if (cartState is! CartLoaded)
//                 return const Center(
//                     child: CircularProgressIndicator(color: Colors.black));

//               final checkoutItems = cartState.items
//                   .where((e) => widget.selectedCartIds.contains(e.id))
//                   .toList();
//               if (checkoutItems.isEmpty)
//                 return const Center(child: Text("Tas Belanja Kosong"));

//               final subtotal = _getSubtotal(checkoutItems);
//               num bundleDiscount = cartState.summary.bundleDiscount;
//               num shippingCost =
//                   _shippingMethod == 'biteship' && _selectedRate != null
//                       ? _selectedRate!.price
//                       : 0;
//               num pointDiscount = _pointsToUse * 1000;

//               num grandTotal = (subtotal -
//                       bundleDiscount -
//                       _promoDiscountAmount -
//                       pointDiscount) +
//                   shippingCost;
//               if (grandTotal < 0) grandTotal = 0;

//               int maxPointsAllowed = user != null ? user.point : 0;
//               int maxUsableByPrice =
//                   ((subtotal - bundleDiscount - _promoDiscountAmount) / 1000)
//                       .floor();
//               if (maxPointsAllowed > maxUsableByPrice)
//                 maxPointsAllowed = maxUsableByPrice;
//               if (maxPointsAllowed < 0) maxPointsAllowed = 0;

//               return Column(
//                 children: [
//                   Expanded(
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // 1. ALAMAT PENGIRIMAN
//                           Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(6),
//                                 decoration: const BoxDecoration(
//                                     color: Colors.black,
//                                     shape: BoxShape.circle),
//                                 child: const Text('1',
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold)),
//                               ),
//                               const SizedBox(width: 8),
//                               const Text('SHIPPING ADDRESS',
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 1)),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           BlocBuilder<AddressBloc, AddressState>(
//                             builder: (context, addressState) {
//                               if (addressState is AddressLoaded) {
//                                 if (addressState.addresses.isEmpty)
//                                   return const Text(
//                                       'Tidak ada alamat. Silakan tambah di profil.');
//                                 return Column(
//                                   children: addressState.addresses.map((addr) {
//                                     bool isSelected =
//                                         _selectedAddressId == addr.id;
//                                     return GestureDetector(
//                                       onTap: () {
//                                         setState(
//                                             () => _selectedAddressId = addr.id);
//                                         if (_shippingMethod == 'biteship')
//                                           _fetchRates(addr.id!);
//                                       },
//                                       child: Container(
//                                         margin:
//                                             const EdgeInsets.only(bottom: 12),
//                                         padding: const EdgeInsets.all(16),
//                                         decoration: BoxDecoration(
//                                           color: isSelected
//                                               ? Colors.white
//                                               : Colors.grey.shade50,
//                                           border: Border.all(
//                                               color: isSelected
//                                                   ? Colors.black
//                                                   : Colors.grey.shade200),
//                                           borderRadius:
//                                               BorderRadius.circular(16),
//                                           boxShadow: isSelected
//                                               ? const [
//                                                   BoxShadow(
//                                                       color: Colors.black12,
//                                                       blurRadius: 4)
//                                                 ]
//                                               : [],
//                                         ),
//                                         child: Row(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Radio<int>(
//                                                 value: addr.id!,
//                                                 groupValue: _selectedAddressId,
//                                                 activeColor: Colors.black,
//                                                 onChanged: (val) {
//                                                   setState(() =>
//                                                       _selectedAddressId = val);
//                                                   if (_shippingMethod ==
//                                                       'biteship')
//                                                     _fetchRates(val!);
//                                                 }),
//                                             Expanded(
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceBetween,
//                                                     children: [
//                                                       Text(
//                                                           '${addr.firstName} ${addr.lastName}'
//                                                               .toUpperCase(),
//                                                           style:
//                                                               const TextStyle(
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                   fontSize:
//                                                                       13)),
//                                                       if (addr.isDefault)
//                                                         Container(
//                                                             padding: const EdgeInsets
//                                                                 .symmetric(
//                                                                 horizontal: 6,
//                                                                 vertical: 2),
//                                                             decoration: BoxDecoration(
//                                                                 color: Colors
//                                                                     .grey
//                                                                     .shade200,
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .circular(
//                                                                             4)),
//                                                             child: const Text(
//                                                                 'DEFAULT',
//                                                                 style: TextStyle(
//                                                                     fontSize: 8,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .bold)))
//                                                     ],
//                                                   ),
//                                                   const SizedBox(height: 4),
//                                                   Text(
//                                                       '${addr.location}, ${addr.city}, ${addr.province} - ${addr.postalCode}',
//                                                       style: const TextStyle(
//                                                           fontSize: 12,
//                                                           color: Colors.grey,
//                                                           height: 1.5)),
//                                                 ],
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),
//                                 );
//                               }
//                               return const Center(
//                                   child: CircularProgressIndicator());
//                             },
//                           ),
//                           const SizedBox(height: 24),

//                           // 2. METODE PENGIRIMAN
//                           Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(6),
//                                 decoration: const BoxDecoration(
//                                     color: Colors.black,
//                                     shape: BoxShape.circle),
//                                 child: const Text('2',
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold)),
//                               ),
//                               const SizedBox(width: 8),
//                               const Text('SHIPPING METHOD',
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 1)),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           GestureDetector(
//                             onTap: () =>
//                                 setState(() => _shippingMethod = 'free'),
//                             child: Container(
//                               margin: const EdgeInsets.only(bottom: 12),
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: _shippingMethod == 'free'
//                                           ? Colors.black
//                                           : Colors.grey.shade200),
//                                   borderRadius: BorderRadius.circular(16),
//                                   color: _shippingMethod == 'free'
//                                       ? Colors.white
//                                       : Colors.grey.shade50),
//                               child: Row(
//                                 children: [
//                                   Radio<String>(
//                                       value: 'free',
//                                       groupValue: _shippingMethod,
//                                       activeColor: Colors.black,
//                                       onChanged: (val) => setState(
//                                           () => _shippingMethod = val!)),
//                                   Expanded(
//                                     child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           const Text('FREE SHIPPING (IN STORE)',
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 12)),
//                                           Text('Ambil langsung di toko Solher',
//                                               style: TextStyle(
//                                                   fontSize: 10,
//                                                   color: Colors.green.shade600,
//                                                   fontWeight: FontWeight.bold)),
//                                         ]),
//                                   ),
//                                   const Text('Rp 0',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.w900)),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               setState(() => _shippingMethod = 'biteship');
//                               if (_selectedAddressId != null &&
//                                   _shippingRates.isEmpty)
//                                 _fetchRates(_selectedAddressId!);
//                             },
//                             child: Container(
//                               margin: const EdgeInsets.only(bottom: 12),
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: _shippingMethod == 'biteship'
//                                           ? Colors.black
//                                           : Colors.grey.shade200),
//                                   borderRadius: BorderRadius.circular(16),
//                                   color: _shippingMethod == 'biteship'
//                                       ? Colors.white
//                                       : Colors.grey.shade50),
//                               child: Row(
//                                 children: [
//                                   Radio<String>(
//                                       value: 'biteship',
//                                       groupValue: _shippingMethod,
//                                       activeColor: Colors.black,
//                                       onChanged: (val) {
//                                         setState(() => _shippingMethod = val!);
//                                         if (_selectedAddressId != null)
//                                           _fetchRates(_selectedAddressId!);
//                                       }),
//                                   const Expanded(
//                                     child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text('STANDARD COURIER',
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 12)),
//                                           Text('Powered by Biteship',
//                                               style: TextStyle(
//                                                   fontSize: 10,
//                                                   color: Colors.grey)),
//                                         ]),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           if (_shippingMethod == 'biteship') ...[
//                             const SizedBox(height: 8),
//                             if (_isLoadingRates)
//                               const Center(
//                                   child: CircularProgressIndicator(
//                                       color: Colors.black))
//                             else if (_shippingRates.isEmpty)
//                               const Text('Tidak ada kurir yang tersedia.',
//                                   style: TextStyle(
//                                       color: Colors.red, fontSize: 12))
//                             else
//                               ..._shippingRates.map((rate) {
//                                 bool isSelected =
//                                     _selectedRate?.company == rate.company &&
//                                         _selectedRate?.type == rate.type;
//                                 return GestureDetector(
//                                   onTap: () =>
//                                       setState(() => _selectedRate = rate),
//                                   child: Container(
//                                     margin: const EdgeInsets.only(
//                                         bottom: 8, left: 32),
//                                     padding: const EdgeInsets.all(12),
//                                     decoration: BoxDecoration(
//                                         border: Border.all(
//                                             color: isSelected
//                                                 ? Colors.blue
//                                                 : Colors.grey.shade200),
//                                         borderRadius: BorderRadius.circular(12),
//                                         color: isSelected
//                                             ? Colors.blue.shade50
//                                             : Colors.white),
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                     '${rate.company.toUpperCase()} - ${rate.type.replaceAll('_', ' ')}',
//                                                     style: const TextStyle(
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         fontSize: 11)),
//                                                 Text(
//                                                     'Estimasi: ${rate.duration}',
//                                                     style: const TextStyle(
//                                                         fontSize: 10,
//                                                         color: Colors.grey)),
//                                               ]),
//                                         ),
//                                         Text(currencyFormat.format(rate.price),
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.w900,
//                                                 fontSize: 12)),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               }).toList()
//                           ],
//                           const SizedBox(height: 32),

//                           // 3. KODE PROMO & POIN
//                           const Text('PROMO CODE',
//                               style: TextStyle(
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 1.5,
//                                   color: Colors.grey)),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: TextField(
//                                   onChanged: (val) => _promoInput = val,
//                                   enabled: _appliedPromoCode == null,
//                                   decoration: InputDecoration(
//                                       hintText: 'Enter code here',
//                                       filled: true,
//                                       fillColor: Colors.grey.shade50,
//                                       border: OutlineInputBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                           borderSide: BorderSide(
//                                               color: Colors.grey.shade300)),
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                               horizontal: 16)),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               if (_appliedPromoCode == null)
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.black,
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 20, vertical: 14),
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(12))),
//                                   onPressed: _isVerifyingPromo
//                                       ? null
//                                       : () => _applyPromo(checkoutItems),
//                                   child: _isVerifyingPromo
//                                       ? const SizedBox(
//                                           width: 16,
//                                           height: 16,
//                                           child: CircularProgressIndicator(
//                                               color: Colors.white,
//                                               strokeWidth: 2))
//                                       : const Text('APPLY',
//                                           style:
//                                               TextStyle(color: Colors.white)),
//                                 )
//                               else
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.red.shade50,
//                                       foregroundColor: Colors.red,
//                                       elevation: 0,
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 20, vertical: 14),
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                           side: BorderSide(
//                                               color: Colors.red.shade200))),
//                                   onPressed: _removePromo,
//                                   child: const Text('REMOVE'),
//                                 )
//                             ],
//                           ),

//                           if (user != null && user.isMembership) ...[
//                             const SizedBox(height: 24),
//                             const Text('SOLHER CLUB POINTS',
//                                 style: TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 1.5,
//                                     color: Colors.grey)),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: TextField(
//                                     keyboardType: TextInputType.number,
//                                     onChanged: (val) {
//                                       setState(() {
//                                         _pointsToUse = int.tryParse(val) ?? 0;
//                                         if (_pointsToUse > maxPointsAllowed)
//                                           _pointsToUse = maxPointsAllowed;
//                                       });
//                                     },
//                                     decoration: InputDecoration(
//                                         hintText: 'Max: $maxPointsAllowed pts',
//                                         filled: true,
//                                         fillColor: Colors.grey.shade50,
//                                         border: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                             borderSide: BorderSide(
//                                                 color: Colors.yellow.shade600)),
//                                         contentPadding:
//                                             const EdgeInsets.symmetric(
//                                                 horizontal: 16)),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.yellow.shade100,
//                                       foregroundColor: Colors.yellow.shade900,
//                                       elevation: 0,
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 20, vertical: 14),
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(12))),
//                                   onPressed: () => setState(
//                                       () => _pointsToUse = maxPointsAllowed),
//                                   child: const Text('USE ALL'),
//                                 )
//                               ],
//                             ),
//                           ]
//                         ],
//                       ),
//                     ),
//                   ),

//                   // AREA SUMMARY BOTTOM
//                   Container(
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 20,
//                             offset: const Offset(0, -5))
//                       ],
//                       borderRadius:
//                           const BorderRadius.vertical(top: Radius.circular(30)),
//                     ),
//                     child: SafeArea(
//                       top: false,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('ORDER SUMMARY',
//                               style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w900,
//                                   letterSpacing: 1.5)),
//                           const SizedBox(height: 16),

//                           // 👇 PERBAIKAN: MENAMPILKAN DAFTAR ITEM BESERTA GAMBAR 👇
//                           Container(
//                             constraints: const BoxConstraints(maxHeight: 180),
//                             child: ListView.builder(
//                               shrinkWrap: true,
//                               itemCount: checkoutItems.length,
//                               itemBuilder: (context, index) {
//                                 final item = checkoutItems[index];
//                                 num price =
//                                     item.product?.discountPrice != null &&
//                                             item.product!.discountPrice! > 0
//                                         ? item.product!.discountPrice!
//                                         : item.product?.price ?? 0;

//                                 return Padding(
//                                   padding: const EdgeInsets.only(bottom: 12),
//                                   child: Row(
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.circular(8),
//                                         child: item.product?.image != null
//                                             ? Image.network(
//                                                 item.product!.image!,
//                                                 width: 50,
//                                                 height: 50,
//                                                 fit: BoxFit.cover)
//                                             : Container(
//                                                 width: 50,
//                                                 height: 50,
//                                                 color: Colors.grey.shade200,
//                                                 child: const Icon(Icons.image,
//                                                     color: Colors.grey)),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                                 item.product?.name
//                                                         .toUpperCase() ??
//                                                     '',
//                                                 style: const TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     fontSize: 11),
//                                                 maxLines: 1,
//                                                 overflow:
//                                                     TextOverflow.ellipsis),
//                                             const SizedBox(height: 2),
//                                             Text(
//                                                 'Warna: ${item.color ?? '-'} | Qty: ${item.quantity}',
//                                                 style: const TextStyle(
//                                                     fontSize: 10,
//                                                     color: Colors.grey)),
//                                           ],
//                                         ),
//                                       ),
//                                       Text(
//                                           currencyFormat
//                                               .format(price * item.quantity),
//                                           style: const TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 11)),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                           const Divider(),
//                           // 👆 ================================================== 👆

//                           Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('Subtotal (${checkoutItems.length} items)',
//                                     style: const TextStyle(
//                                         fontSize: 12, color: Colors.grey)),
//                                 Text(currencyFormat.format(subtotal),
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold)),
//                               ]),
//                           const SizedBox(height: 8),
//                           if (shippingCost > 0) ...[
//                             Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text('Shipping Cost',
//                                       style: TextStyle(
//                                           fontSize: 12, color: Colors.grey)),
//                                   Text(currencyFormat.format(shippingCost),
//                                       style: const TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold)),
//                                 ]),
//                             const SizedBox(height: 8),
//                           ],
//                           if (_promoDiscountAmount > 0) ...[
//                             Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text('Promo ($_appliedPromoCode)',
//                                       style: const TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.green,
//                                           fontWeight: FontWeight.bold)),
//                                   Text(
//                                       '- ${currencyFormat.format(_promoDiscountAmount)}',
//                                       style: const TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.green)),
//                                 ]),
//                             const SizedBox(height: 8),
//                           ],
//                           if (pointDiscount > 0) ...[
//                             Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text('Points Applied',
//                                       style: TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.orange,
//                                           fontWeight: FontWeight.bold)),
//                                   Text(
//                                       '- ${currencyFormat.format(pointDiscount)}',
//                                       style: const TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.orange)),
//                                 ]),
//                             const SizedBox(height: 8),
//                           ],
//                           const Padding(
//                               padding: EdgeInsets.symmetric(vertical: 8),
//                               child: Divider()),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('GRAND TOTAL',
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 1.5)),
//                               Text(currencyFormat.format(grandTotal),
//                                   style: const TextStyle(
//                                       fontSize: 22,
//                                       fontWeight: FontWeight.w900)),
//                             ],
//                           ),
//                           const SizedBox(height: 16),

//                           // TOMBOL CHECKOUT
//                           BlocBuilder<CheckoutBloc, CheckoutState>(
//                               builder: (context, checkoutState) {
//                             bool isButtonDisabled =
//                                 _selectedAddressId == null ||
//                                     (_shippingMethod == 'biteship' &&
//                                         _selectedRate == null) ||
//                                     checkoutState is CheckoutLoading;

//                             return SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.black,
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 16),
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(16))),
//                                 onPressed: isButtonDisabled
//                                     ? null
//                                     : () {
//                                         final payload = {
//                                           'address_id': _selectedAddressId,
//                                           'shipping_method': _shippingMethod,
//                                           'use_points': _pointsToUse,
//                                           'cart_ids': widget.selectedCartIds,
//                                           'courier_company':
//                                               _shippingMethod == 'biteship'
//                                                   ? _selectedRate?.company
//                                                   : null,
//                                           'courier_type':
//                                               _shippingMethod == 'biteship'
//                                                   ? _selectedRate?.type
//                                                   : null,
//                                           'shipping_cost': shippingCost,
//                                           'delivery_type': _deliveryType,
//                                           'promo_code': _appliedPromoCode,
//                                           'currency': 'IDR',
//                                         };
//                                         context
//                                             .read<CheckoutBloc>()
//                                             .add(SubmitCheckoutEvent(payload));
//                                       },
//                                 child: checkoutState is CheckoutLoading
//                                     ? const SizedBox(
//                                         height: 20,
//                                         width: 20,
//                                         child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2))
//                                     : const Text('PAY SECURELY',
//                                         style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                             letterSpacing: 2)),
//                               ),
//                             );
//                           })
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               );
//             });
//           }),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart';

// // Repositories & Models
// import '../repositories/checkout_repository.dart';
// import '../repositories/address_repository.dart';
// import '../models/checkout_model.dart';
// import '../models/cart_model.dart';
// import '../models/user_model.dart';

// // BLoCs
// import '../blocs/auth/auth_bloc.dart';
// import '../blocs/auth/auth_state.dart';
// import '../blocs/cart/cart_bloc.dart';
// import '../blocs/cart/cart_state.dart';
// import '../blocs/address/address_bloc.dart';
// import '../blocs/address/address_event.dart';
// import '../blocs/address/address_state.dart';
// import '../blocs/checkout/checkout_bloc.dart';
// import '../blocs/checkout/checkout_event.dart';
// import '../blocs/checkout/checkout_state.dart';

// // 👇 IMPORT HALAMAN XENDIT 👇
// import 'xendit_page.dart';

// class PaymentPage extends StatefulWidget {
//   final List<int> selectedCartIds;

//   const PaymentPage({super.key, required this.selectedCartIds});

//   @override
//   State<PaymentPage> createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   final CheckoutRepository _checkoutRepo = CheckoutRepository();

//   int? _selectedAddressId;
//   String _shippingMethod = 'free';
//   ShippingRateModel? _selectedRate;
//   String _deliveryType = 'now';

//   int _pointsToUse = 0;
//   String _promoInput = '';
//   String? _appliedPromoCode;
//   num _promoDiscountAmount = 0;
//   bool _isVerifyingPromo = false;
//   bool _useMemberVoucher = false;

//   List<ShippingRateModel> _shippingRates = [];
//   bool _isLoadingRates = false;

//   // 👇 PERBAIKAN: Tambahkan TextEditingController untuk TextField Points 👇
//   final TextEditingController _pointsController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//   }

//   // 👇 Pastikan memori dilepas saat halaman ditutup 👇
//   @override
//   void dispose() {
//     _pointsController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchRates(int addressId) async {
//     setState(() {
//       _isLoadingRates = true;
//       _shippingRates = [];
//       _selectedRate = null;
//     });

//     try {
//       final rates = await _checkoutRepo.fetchShippingRates(
//           addressId, widget.selectedCartIds);
//       if (mounted) setState(() => _shippingRates = rates);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(e.toString())));
//       }
//     } finally {
//       if (mounted) setState(() => _isLoadingRates = false);
//     }
//   }

//   Future<void> _applyPromo(List<CartModel> checkoutItems) async {
//     if (_promoInput.isEmpty) return;
//     setState(() => _isVerifyingPromo = true);

//     try {
//       final code = _promoInput.toUpperCase();
//       final cartPayload = checkoutItems
//           .map((item) => {
//                 'product_id': item.productId,
//                 'quantity': item.quantity,
//               })
//           .toList();

//       final res = await _checkoutRepo.verifyPromo(code, cartPayload);

//       setState(() {
//         _appliedPromoCode = code;
//         _promoDiscountAmount = res['discount_value'] ?? 0;

//         // Kosongkan poin jika promo dipakai (mencegah poin double disc)
//         _pointsToUse = 0;
//         _pointsController.clear();
//       });

//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('✅ ${res['message']}'), backgroundColor: Colors.green));
//     } catch (e) {
//       setState(() {
//         _appliedPromoCode = null;
//         _promoDiscountAmount = 0;
//         _useMemberVoucher = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
//     } finally {
//       setState(() => _isVerifyingPromo = false);
//     }
//   }

//   void _removePromo() {
//     setState(() {
//       _promoInput = '';
//       _appliedPromoCode = null;
//       _promoDiscountAmount = 0;
//       _useMemberVoucher = false;
//     });
//   }

//   num _getSubtotal(List<CartModel> items) {
//     num total = 0;
//     for (var item in items) {
//       num price = item.product?.discountPrice != null &&
//               item.product!.discountPrice! > 0
//           ? item.product!.discountPrice!
//           : item.product?.price ?? 0;
//       total += (price * item.quantity);
//     }
//     return total;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currencyFormat =
//         NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<AddressBloc>(
//           create: (context) =>
//               AddressBloc(addressRepository: AddressRepository())
//                 ..add(FetchAddresses()),
//         ),
//         BlocProvider<CheckoutBloc>(
//           create: (context) => CheckoutBloc(repository: _checkoutRepo),
//         ),
//       ],
//       child: Scaffold(
//         backgroundColor: const Color(0xFFFAFAFA),
//         appBar: AppBar(
//           title: const Text('CHECKOUT',
//               style: TextStyle(
//                   fontWeight: FontWeight.w900,
//                   fontFamily: 'serif',
//                   letterSpacing: 1)),
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 0.5,
//         ),
//         body: MultiBlocListener(
//           listeners: [
//             BlocListener<AddressBloc, AddressState>(
//               listener: (context, state) {
//                 if (state is AddressLoaded && state.addresses.isNotEmpty) {
//                   if (_selectedAddressId == null) {
//                     final defaultAddr = state.addresses.firstWhere(
//                         (a) => a.isDefault,
//                         orElse: () => state.addresses.first);
//                     setState(() => _selectedAddressId = defaultAddr.id);
//                     if (_shippingMethod == 'biteship') {
//                       _fetchRates(defaultAddr.id!);
//                     }
//                   }
//                 }
//               },
//             ),
//             BlocListener<CheckoutBloc, CheckoutState>(
//               listener: (context, state) {
//                 if (state is CheckoutSuccess) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) =>
//                           XenditPage(checkoutUrl: state.checkoutUrl),
//                     ),
//                   );
//                 } else if (state is CheckoutError) {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                       content: Text(state.message),
//                       backgroundColor: Colors.red));
//                 }
//               },
//             ),
//           ],
//           child:
//               BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
//             UserModel? user;
//             if (authState is AuthAuthenticated) user = authState.user;

//             return BlocBuilder<CartBloc, CartState>(
//                 builder: (context, cartState) {
//               if (cartState is! CartLoaded) {
//                 return const Center(
//                     child: CircularProgressIndicator(color: Colors.black));
//               }

//               final checkoutItems = cartState.items
//                   .where((e) => widget.selectedCartIds.contains(e.id))
//                   .toList();
//               if (checkoutItems.isEmpty) {
//                 return const Center(child: Text("Tas Belanja Kosong"));
//               }

//               final subtotal = _getSubtotal(checkoutItems);
//               num bundleDiscount = cartState.summary.bundleDiscount;
//               num shippingCost =
//                   _shippingMethod == 'biteship' && _selectedRate != null
//                       ? _selectedRate!.price
//                       : 0;

//               // Max Poin yang diizinkan (Kalkulasi duluan)
//               int maxPointsAllowed = user != null ? user.point : 0;
//               int maxUsableByPrice =
//                   ((subtotal - bundleDiscount - _promoDiscountAmount) / 1000)
//                       .floor();
//               if (maxPointsAllowed > maxUsableByPrice) {
//                 maxPointsAllowed = maxUsableByPrice;
//               }
//               if (maxPointsAllowed < 0) maxPointsAllowed = 0;

//               // Pastikan nilai _pointsToUse tidak bocor kelebihan
//               if (_pointsToUse > maxPointsAllowed) {
//                 _pointsToUse = maxPointsAllowed;
//               }

//               num pointDiscount = _pointsToUse * 1000;

//               num grandTotal = (subtotal -
//                       bundleDiscount -
//                       _promoDiscountAmount -
//                       pointDiscount) +
//                   shippingCost;
//               if (grandTotal < 0) grandTotal = 0;

//               return Column(
//                 children: [
//                   Expanded(
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // 1. ALAMAT PENGIRIMAN
//                           Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(6),
//                                 decoration: const BoxDecoration(
//                                     color: Colors.black,
//                                     shape: BoxShape.circle),
//                                 child: const Text('1',
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold)),
//                               ),
//                               const SizedBox(width: 8),
//                               const Text('SHIPPING ADDRESS',
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 1)),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           BlocBuilder<AddressBloc, AddressState>(
//                             builder: (context, addressState) {
//                               if (addressState is AddressLoaded) {
//                                 if (addressState.addresses.isEmpty) {
//                                   return const Text(
//                                       'Tidak ada alamat. Silakan tambah di profil.');
//                                 }
//                                 return Column(
//                                   children: addressState.addresses.map((addr) {
//                                     bool isSelected =
//                                         _selectedAddressId == addr.id;
//                                     return GestureDetector(
//                                       onTap: () {
//                                         setState(
//                                             () => _selectedAddressId = addr.id);
//                                         if (_shippingMethod == 'biteship') {
//                                           _fetchRates(addr.id!);
//                                         }
//                                       },
//                                       child: Container(
//                                         margin:
//                                             const EdgeInsets.only(bottom: 12),
//                                         padding: const EdgeInsets.all(16),
//                                         decoration: BoxDecoration(
//                                           color: isSelected
//                                               ? Colors.white
//                                               : Colors.grey.shade50,
//                                           border: Border.all(
//                                               color: isSelected
//                                                   ? Colors.black
//                                                   : Colors.grey.shade200),
//                                           borderRadius:
//                                               BorderRadius.circular(16),
//                                           boxShadow: isSelected
//                                               ? const [
//                                                   BoxShadow(
//                                                       color: Colors.black12,
//                                                       blurRadius: 4)
//                                                 ]
//                                               : [],
//                                         ),
//                                         child: Row(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Radio<int>(
//                                               value: addr.id!,
//                                               groupValue: _selectedAddressId,
//                                               activeColor: Colors.black,
//                                               onChanged: (val) {
//                                                 setState(() =>
//                                                     _selectedAddressId = val);
//                                                 if (_shippingMethod ==
//                                                     'biteship') {
//                                                   _fetchRates(val!);
//                                                 }
//                                               },
//                                             ),
//                                             Expanded(
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceBetween,
//                                                     children: [
//                                                       Text(
//                                                           '${addr.firstName} ${addr.lastName}'
//                                                               .toUpperCase(),
//                                                           style:
//                                                               const TextStyle(
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                   fontSize:
//                                                                       13)),
//                                                       if (addr.isDefault)
//                                                         Container(
//                                                             padding: const EdgeInsets
//                                                                 .symmetric(
//                                                                 horizontal: 6,
//                                                                 vertical: 2),
//                                                             decoration: BoxDecoration(
//                                                                 color: Colors
//                                                                     .grey
//                                                                     .shade200,
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .circular(
//                                                                             4)),
//                                                             child: const Text(
//                                                                 'DEFAULT',
//                                                                 style: TextStyle(
//                                                                     fontSize: 8,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .bold)))
//                                                     ],
//                                                   ),
//                                                   const SizedBox(height: 4),
//                                                   Text(
//                                                       '${addr.location}, ${addr.city}, ${addr.province} - ${addr.postalCode}',
//                                                       style: const TextStyle(
//                                                           fontSize: 12,
//                                                           color: Colors.grey,
//                                                           height: 1.5)),
//                                                 ],
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),
//                                 );
//                               }
//                               return const Center(
//                                   child: CircularProgressIndicator());
//                             },
//                           ),
//                           const SizedBox(height: 24),

//                           // 2. METODE PENGIRIMAN
//                           Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(6),
//                                 decoration: const BoxDecoration(
//                                     color: Colors.black,
//                                     shape: BoxShape.circle),
//                                 child: const Text('2',
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold)),
//                               ),
//                               const SizedBox(width: 8),
//                               const Text('SHIPPING METHOD',
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 1)),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           GestureDetector(
//                             onTap: () =>
//                                 setState(() => _shippingMethod = 'free'),
//                             child: Container(
//                               margin: const EdgeInsets.only(bottom: 12),
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: _shippingMethod == 'free'
//                                           ? Colors.black
//                                           : Colors.grey.shade200),
//                                   borderRadius: BorderRadius.circular(16),
//                                   color: _shippingMethod == 'free'
//                                       ? Colors.white
//                                       : Colors.grey.shade50),
//                               child: Row(
//                                 children: [
//                                   Radio<String>(
//                                       value: 'free',
//                                       groupValue: _shippingMethod,
//                                       activeColor: Colors.black,
//                                       onChanged: (val) => setState(
//                                           () => _shippingMethod = val!)),
//                                   Expanded(
//                                     child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           const Text('FREE SHIPPING (IN STORE)',
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 12)),
//                                           Text('Ambil langsung di toko Solher',
//                                               style: TextStyle(
//                                                   fontSize: 10,
//                                                   color: Colors.green.shade600,
//                                                   fontWeight: FontWeight.bold)),
//                                         ]),
//                                   ),
//                                   const Text('Rp 0',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.w900)),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               setState(() => _shippingMethod = 'biteship');
//                               if (_selectedAddressId != null &&
//                                   _shippingRates.isEmpty) {
//                                 _fetchRates(_selectedAddressId!);
//                               }
//                             },
//                             child: Container(
//                               margin: const EdgeInsets.only(bottom: 12),
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: _shippingMethod == 'biteship'
//                                           ? Colors.black
//                                           : Colors.grey.shade200),
//                                   borderRadius: BorderRadius.circular(16),
//                                   color: _shippingMethod == 'biteship'
//                                       ? Colors.white
//                                       : Colors.grey.shade50),
//                               child: Row(
//                                 children: [
//                                   Radio<String>(
//                                       value: 'biteship',
//                                       groupValue: _shippingMethod,
//                                       activeColor: Colors.black,
//                                       onChanged: (val) {
//                                         setState(() => _shippingMethod = val!);
//                                         if (_selectedAddressId != null) {
//                                           _fetchRates(_selectedAddressId!);
//                                         }
//                                       }),
//                                   const Expanded(
//                                     child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text('STANDARD COURIER',
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 12)),
//                                           Text('Powered by Biteship',
//                                               style: TextStyle(
//                                                   fontSize: 10,
//                                                   color: Colors.grey)),
//                                         ]),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           if (_shippingMethod == 'biteship') ...[
//                             const SizedBox(height: 8),
//                             if (_isLoadingRates)
//                               const Center(
//                                   child: CircularProgressIndicator(
//                                       color: Colors.black))
//                             else if (_shippingRates.isEmpty)
//                               const Text('Tidak ada kurir yang tersedia.',
//                                   style: TextStyle(
//                                       color: Colors.red, fontSize: 12))
//                             else
//                               ..._shippingRates.map((rate) {
//                                 bool isSelected =
//                                     _selectedRate?.company == rate.company &&
//                                         _selectedRate?.type == rate.type;
//                                 return GestureDetector(
//                                   onTap: () =>
//                                       setState(() => _selectedRate = rate),
//                                   child: Container(
//                                     margin: const EdgeInsets.only(
//                                         bottom: 8, left: 32),
//                                     padding: const EdgeInsets.all(12),
//                                     decoration: BoxDecoration(
//                                         border: Border.all(
//                                             color: isSelected
//                                                 ? Colors.blue
//                                                 : Colors.grey.shade200),
//                                         borderRadius: BorderRadius.circular(12),
//                                         color: isSelected
//                                             ? Colors.blue.shade50
//                                             : Colors.white),
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                     '${rate.company.toUpperCase()} - ${rate.type.replaceAll('_', ' ')}',
//                                                     style: const TextStyle(
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         fontSize: 11)),
//                                                 Text(
//                                                     'Estimasi: ${rate.duration}',
//                                                     style: const TextStyle(
//                                                         fontSize: 10,
//                                                         color: Colors.grey)),
//                                               ]),
//                                         ),
//                                         Text(currencyFormat.format(rate.price),
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.w900,
//                                                 fontSize: 12)),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               }).toList()
//                           ],
//                           const SizedBox(height: 32),

//                           // 3. KODE PROMO & POIN
//                           const Text('PROMO CODE',
//                               style: TextStyle(
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 1.5,
//                                   color: Colors.grey)),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: TextField(
//                                   onChanged: (val) => _promoInput = val,
//                                   enabled: _appliedPromoCode == null,
//                                   decoration: InputDecoration(
//                                       hintText: 'Enter code here',
//                                       filled: true,
//                                       fillColor: Colors.grey.shade50,
//                                       border: OutlineInputBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                           borderSide: BorderSide(
//                                               color: Colors.grey.shade300)),
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                               horizontal: 16)),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               if (_appliedPromoCode == null)
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.black,
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 20, vertical: 14),
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(12))),
//                                   onPressed: _isVerifyingPromo
//                                       ? null
//                                       : () => _applyPromo(checkoutItems),
//                                   child: _isVerifyingPromo
//                                       ? const SizedBox(
//                                           width: 16,
//                                           height: 16,
//                                           child: CircularProgressIndicator(
//                                               color: Colors.white,
//                                               strokeWidth: 2))
//                                       : const Text('APPLY',
//                                           style:
//                                               TextStyle(color: Colors.white)),
//                                 )
//                               else
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.red.shade50,
//                                       foregroundColor: Colors.red,
//                                       elevation: 0,
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 20, vertical: 14),
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                           side: BorderSide(
//                                               color: Colors.red.shade200))),
//                                   onPressed: _removePromo,
//                                   child: const Text('REMOVE'),
//                                 )
//                             ],
//                           ),

//                           // AREA SOLHER CLUB POINTS
//                           if (user != null && user.isMembership) ...[
//                             const SizedBox(height: 24),
//                             const Text('SOLHER CLUB POINTS',
//                                 style: TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 1.5,
//                                     color: Colors.grey)),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: TextField(
//                                     controller:
//                                         _pointsController, // 👇 Pasang Controller
//                                     keyboardType: TextInputType.number,
//                                     onChanged: (val) {
//                                       setState(() {
//                                         _pointsToUse = int.tryParse(val) ?? 0;
//                                         if (_pointsToUse > maxPointsAllowed) {
//                                           _pointsToUse = maxPointsAllowed;
//                                           _pointsController.text =
//                                               maxPointsAllowed.toString();

//                                           // Pindahkan kursor ke ujung teks
//                                           _pointsController.selection =
//                                               TextSelection.fromPosition(
//                                                   TextPosition(
//                                                       offset: _pointsController
//                                                           .text.length));
//                                         }
//                                       });
//                                     },
//                                     decoration: InputDecoration(
//                                         hintText: 'Max: $maxPointsAllowed pts',
//                                         filled: true,
//                                         fillColor: Colors.grey.shade50,
//                                         border: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                             borderSide: BorderSide(
//                                                 color: Colors.yellow.shade600)),
//                                         contentPadding:
//                                             const EdgeInsets.symmetric(
//                                                 horizontal: 16)),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),

//                                 // 👇 LOGIKA PERGANTIAN TOMBOL USE ALL / REMOVE 👇
//                                 if (_pointsToUse > 0)
//                                   ElevatedButton(
//                                     style: ElevatedButton.styleFrom(
//                                         backgroundColor: Colors.red.shade50,
//                                         foregroundColor: Colors.red,
//                                         elevation: 0,
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 20, vertical: 14),
//                                         shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                             side: BorderSide(
//                                                 color: Colors.red.shade200))),
//                                     onPressed: () {
//                                       setState(() {
//                                         _pointsToUse = 0;
//                                         _pointsController.clear();
//                                       });
//                                     },
//                                     child: const Text('REMOVE'),
//                                   )
//                                 else
//                                   ElevatedButton(
//                                     style: ElevatedButton.styleFrom(
//                                         backgroundColor: Colors.yellow.shade100,
//                                         foregroundColor: Colors.yellow.shade900,
//                                         elevation: 0,
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 20, vertical: 14),
//                                         shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(12))),
//                                     onPressed: () {
//                                       setState(() {
//                                         _pointsToUse = maxPointsAllowed;
//                                         _pointsController.text =
//                                             maxPointsAllowed.toString();
//                                       });
//                                     },
//                                     child: const Text('USE ALL'),
//                                   )
//                               ],
//                             ),
//                           ]
//                         ],
//                       ),
//                     ),
//                   ),

//                   // AREA SUMMARY BOTTOM
//                   Container(
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 20,
//                             offset: const Offset(0, -5))
//                       ],
//                       borderRadius:
//                           const BorderRadius.vertical(top: Radius.circular(30)),
//                     ),
//                     child: SafeArea(
//                       top: false,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('ORDER SUMMARY',
//                               style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w900,
//                                   letterSpacing: 1.5)),
//                           const SizedBox(height: 16),

//                           Container(
//                             constraints: const BoxConstraints(maxHeight: 180),
//                             child: ListView.builder(
//                               shrinkWrap: true,
//                               itemCount: checkoutItems.length,
//                               itemBuilder: (context, index) {
//                                 final item = checkoutItems[index];
//                                 num price =
//                                     item.product?.discountPrice != null &&
//                                             item.product!.discountPrice! > 0
//                                         ? item.product!.discountPrice!
//                                         : item.product?.price ?? 0;

//                                 return Padding(
//                                   padding: const EdgeInsets.only(bottom: 12),
//                                   child: Row(
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.circular(8),
//                                         child: item.product?.image != null
//                                             ? Image.network(
//                                                 item.product!.image!,
//                                                 width: 50,
//                                                 height: 50,
//                                                 fit: BoxFit.cover)
//                                             : Container(
//                                                 width: 50,
//                                                 height: 50,
//                                                 color: Colors.grey.shade200,
//                                                 child: const Icon(Icons.image,
//                                                     color: Colors.grey)),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                                 item.product?.name
//                                                         .toUpperCase() ??
//                                                     '',
//                                                 style: const TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     fontSize: 11),
//                                                 maxLines: 1,
//                                                 overflow:
//                                                     TextOverflow.ellipsis),
//                                             const SizedBox(height: 2),
//                                             Text(
//                                                 'Warna: ${item.color ?? '-'} | Qty: ${item.quantity}',
//                                                 style: const TextStyle(
//                                                     fontSize: 10,
//                                                     color: Colors.grey)),
//                                           ],
//                                         ),
//                                       ),
//                                       Text(
//                                           currencyFormat
//                                               .format(price * item.quantity),
//                                           style: const TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 11)),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                           const Divider(),

//                           Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('Subtotal (${checkoutItems.length} items)',
//                                     style: const TextStyle(
//                                         fontSize: 12, color: Colors.grey)),
//                                 Text(currencyFormat.format(subtotal),
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold)),
//                               ]),
//                           const SizedBox(height: 8),
//                           if (shippingCost > 0) ...[
//                             Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text('Shipping Cost',
//                                       style: TextStyle(
//                                           fontSize: 12, color: Colors.grey)),
//                                   Text(currencyFormat.format(shippingCost),
//                                       style: const TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold)),
//                                 ]),
//                             const SizedBox(height: 8),
//                           ],
//                           if (_promoDiscountAmount > 0) ...[
//                             Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text('Promo ($_appliedPromoCode)',
//                                       style: const TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.green,
//                                           fontWeight: FontWeight.bold)),
//                                   Text(
//                                       '- ${currencyFormat.format(_promoDiscountAmount)}',
//                                       style: const TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.green)),
//                                 ]),
//                             const SizedBox(height: 8),
//                           ],
//                           if (pointDiscount > 0) ...[
//                             Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text('Points Applied',
//                                       style: TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.orange,
//                                           fontWeight: FontWeight.bold)),
//                                   Text(
//                                       '- ${currencyFormat.format(pointDiscount)}',
//                                       style: const TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.orange)),
//                                 ]),
//                             const SizedBox(height: 8),
//                           ],
//                           const Padding(
//                               padding: EdgeInsets.symmetric(vertical: 8),
//                               child: Divider()),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('GRAND TOTAL',
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 1.5)),
//                               Text(currencyFormat.format(grandTotal),
//                                   style: const TextStyle(
//                                       fontSize: 22,
//                                       fontWeight: FontWeight.w900)),
//                             ],
//                           ),
//                           const SizedBox(height: 16),

//                           // TOMBOL CHECKOUT
//                           BlocBuilder<CheckoutBloc, CheckoutState>(
//                               builder: (context, checkoutState) {
//                             bool isButtonDisabled =
//                                 _selectedAddressId == null ||
//                                     (_shippingMethod == 'biteship' &&
//                                         _selectedRate == null) ||
//                                     checkoutState is CheckoutLoading;

//                             return SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.black,
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 16),
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(16))),
//                                 onPressed: isButtonDisabled
//                                     ? null
//                                     : () {
//                                         final payload = {
//                                           'address_id': _selectedAddressId,
//                                           'shipping_method': _shippingMethod,
//                                           'use_points': _pointsToUse,
//                                           'cart_ids': widget.selectedCartIds,
//                                           'courier_company':
//                                               _shippingMethod == 'biteship'
//                                                   ? _selectedRate?.company
//                                                   : null,
//                                           'courier_type':
//                                               _shippingMethod == 'biteship'
//                                                   ? _selectedRate?.type
//                                                   : null,
//                                           'shipping_cost': shippingCost,
//                                           'delivery_type': _deliveryType,
//                                           'promo_code': _appliedPromoCode,
//                                           'currency': 'IDR',
//                                         };

//                                         context
//                                             .read<CheckoutBloc>()
//                                             .add(SubmitCheckoutEvent(payload));
//                                       },
//                                 child: checkoutState is CheckoutLoading
//                                     ? const SizedBox(
//                                         height: 20,
//                                         width: 20,
//                                         child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2))
//                                     : const Text('PAY SECURELY',
//                                         style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                             letterSpacing: 2)),
//                               ),
//                             );
//                           })
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               );
//             });
//           }),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Repositories & Models
import '../repositories/checkout_repository.dart';
import '../repositories/address_repository.dart';
import '../models/checkout_model.dart';
import '../models/cart_model.dart';
import '../models/user_model.dart';

// BLoCs
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_state.dart';
import '../blocs/address/address_bloc.dart';
import '../blocs/address/address_event.dart';
import '../blocs/address/address_state.dart';
import '../blocs/checkout/checkout_bloc.dart';
import '../blocs/checkout/checkout_event.dart';
import '../blocs/checkout/checkout_state.dart';

// 👇 IMPORT HALAMAN XENDIT 👇
import 'xendit_page.dart';

class PaymentPage extends StatefulWidget {
  final List<int> selectedCartIds;

  const PaymentPage({super.key, required this.selectedCartIds});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final CheckoutRepository _checkoutRepo = CheckoutRepository();

  int? _selectedAddressId;
  String _shippingMethod = 'free';
  ShippingRateModel? _selectedRate;
  String _deliveryType = 'now';

  int _pointsToUse = 0;
  String _promoInput = '';
  String? _appliedPromoCode;
  num _promoDiscountAmount = 0;
  bool _isVerifyingPromo = false;
  bool _useMemberVoucher = false;

  List<ShippingRateModel> _shippingRates = [];
  bool _isLoadingRates = false;

  final TextEditingController _pointsController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  // 👇 FUNGSI PINTAR UNTUK MENDETEKSI LOGO KURIR 👇
  String? _getCourierLogo(String company) {
    // Normalisasi string: ubah ke huruf kecil dan hapus spasi
    final normalized = company.toLowerCase().replaceAll(' ', '');

    if (normalized.contains('anteraja')) return 'assets/courier_icons/anteraja.png';
    if (normalized.contains('gojek') || normalized.contains('gosend'))
      return 'assets/courier_icons/gojek.png';
    if (normalized.contains('grab')) return 'assets/courier_icons/grab.png';
    if (normalized.contains('jne')) return 'assets/courier_icons/jne.png';
    if (normalized.contains('jnt') || normalized.contains('j&t'))
      return 'assets/courier_icons/jnt.png';
    if (normalized.contains('ninja')) return 'assets/courier_icons/ninja.png';
    if (normalized.contains('paxel')) return 'assets/courier_icons/paxel.png';
    if (normalized.contains('sicepat')) return 'assets/courier_icons/sicepat.png';

    return null; // Mengembalikan null jika kurir tidak dikenali
  }

  Future<void> _fetchRates(int addressId) async {
    setState(() {
      _isLoadingRates = true;
      _shippingRates = [];
      _selectedRate = null;
    });

    try {
      final rates = await _checkoutRepo.fetchShippingRates(
          addressId, widget.selectedCartIds);
      if (mounted) setState(() => _shippingRates = rates);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoadingRates = false);
    }
  }

  Future<void> _applyPromo(List<CartModel> checkoutItems) async {
    if (_promoInput.isEmpty) return;
    setState(() => _isVerifyingPromo = true);

    try {
      final code = _promoInput.toUpperCase();
      final cartPayload = checkoutItems
          .map((item) => {
                'product_id': item.productId,
                'quantity': item.quantity,
              })
          .toList();

      final res = await _checkoutRepo.verifyPromo(code, cartPayload);

      setState(() {
        _appliedPromoCode = code;
        _promoDiscountAmount = res['discount_value'] ?? 0;

        _pointsToUse = 0;
        _pointsController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✅ ${res['message']}'), backgroundColor: Colors.green));
    } catch (e) {
      setState(() {
        _appliedPromoCode = null;
        _promoDiscountAmount = 0;
        _useMemberVoucher = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isVerifyingPromo = false);
    }
  }

  void _removePromo() {
    setState(() {
      _promoInput = '';
      _appliedPromoCode = null;
      _promoDiscountAmount = 0;
      _useMemberVoucher = false;
    });
  }

  num _getSubtotal(List<CartModel> items) {
    num total = 0;
    for (var item in items) {
      num price = item.product?.discountPrice != null &&
              item.product!.discountPrice! > 0
          ? item.product!.discountPrice!
          : item.product?.price ?? 0;
      total += (price * item.quantity);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AddressBloc>(
          create: (context) =>
              AddressBloc(addressRepository: AddressRepository())
                ..add(FetchAddresses()),
        ),
        BlocProvider<CheckoutBloc>(
          create: (context) => CheckoutBloc(repository: _checkoutRepo),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: const Text('CHECKOUT',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'serif',
                  letterSpacing: 1)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<AddressBloc, AddressState>(
              listener: (context, state) {
                if (state is AddressLoaded && state.addresses.isNotEmpty) {
                  if (_selectedAddressId == null) {
                    final defaultAddr = state.addresses.firstWhere(
                        (a) => a.isDefault,
                        orElse: () => state.addresses.first);
                    setState(() => _selectedAddressId = defaultAddr.id);
                    if (_shippingMethod == 'biteship') {
                      _fetchRates(defaultAddr.id!);
                    }
                  }
                }
              },
            ),
            BlocListener<CheckoutBloc, CheckoutState>(
              listener: (context, state) {
                if (state is CheckoutSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          XenditPage(checkoutUrl: state.checkoutUrl),
                    ),
                  );
                } else if (state is CheckoutError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red));
                }
              },
            ),
          ],
          child:
              BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
            UserModel? user;
            if (authState is AuthAuthenticated) user = authState.user;

            return BlocBuilder<CartBloc, CartState>(
                builder: (context, cartState) {
              if (cartState is! CartLoaded) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.black));
              }

              final checkoutItems = cartState.items
                  .where((e) => widget.selectedCartIds.contains(e.id))
                  .toList();
              if (checkoutItems.isEmpty) {
                return const Center(child: Text("Tas Belanja Kosong"));
              }

              final subtotal = _getSubtotal(checkoutItems);
              num bundleDiscount = cartState.summary.bundleDiscount;
              num shippingCost =
                  _shippingMethod == 'biteship' && _selectedRate != null
                      ? _selectedRate!.price
                      : 0;

              int maxPointsAllowed = user != null ? user.point : 0;
              int maxUsableByPrice =
                  ((subtotal - bundleDiscount - _promoDiscountAmount) / 1000)
                      .floor();
              if (maxPointsAllowed > maxUsableByPrice) {
                maxPointsAllowed = maxUsableByPrice;
              }
              if (maxPointsAllowed < 0) maxPointsAllowed = 0;

              if (_pointsToUse > maxPointsAllowed) {
                _pointsToUse = maxPointsAllowed;
              }

              num pointDiscount = _pointsToUse * 1000;

              num grandTotal = (subtotal -
                      bundleDiscount -
                      _promoDiscountAmount -
                      pointDiscount) +
                  shippingCost;
              if (grandTotal < 0) grandTotal = 0;

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. ALAMAT PENGIRIMAN
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle),
                                child: const Text('1',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              const Text('SHIPPING ADDRESS',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<AddressBloc, AddressState>(
                            builder: (context, addressState) {
                              if (addressState is AddressLoaded) {
                                if (addressState.addresses.isEmpty) {
                                  return const Text(
                                      'Tidak ada alamat. Silakan tambah di profil.');
                                }
                                return Column(
                                  children: addressState.addresses.map((addr) {
                                    bool isSelected =
                                        _selectedAddressId == addr.id;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(
                                            () => _selectedAddressId = addr.id);
                                        if (_shippingMethod == 'biteship') {
                                          _fetchRates(addr.id!);
                                        }
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey.shade50,
                                          border: Border.all(
                                              color: isSelected
                                                  ? Colors.black
                                                  : Colors.grey.shade200),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: isSelected
                                              ? const [
                                                  BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 4)
                                                ]
                                              : [],
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Radio<int>(
                                              value: addr.id!,
                                              groupValue: _selectedAddressId,
                                              activeColor: Colors.black,
                                              onChanged: (val) {
                                                setState(() =>
                                                    _selectedAddressId = val);
                                                if (_shippingMethod ==
                                                    'biteship') {
                                                  _fetchRates(val!);
                                                }
                                              },
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                          '${addr.firstName} ${addr.lastName}'
                                                              .toUpperCase(),
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      13)),
                                                      if (addr.isDefault)
                                                        Container(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 6,
                                                                vertical: 2),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey
                                                                    .shade200,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4)),
                                                            child: const Text(
                                                                'DEFAULT',
                                                                style: TextStyle(
                                                                    fontSize: 8,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)))
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                      '${addr.location}, ${addr.city}, ${addr.province} - ${addr.postalCode}',
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                          height: 1.5)),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          ),
                          const SizedBox(height: 24),

                          // 2. METODE PENGIRIMAN
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle),
                                child: const Text('2',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              const Text('SHIPPING METHOD',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _shippingMethod = 'free'),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: _shippingMethod == 'free'
                                          ? Colors.black
                                          : Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(16),
                                  color: _shippingMethod == 'free'
                                      ? Colors.white
                                      : Colors.grey.shade50),
                              child: Row(
                                children: [
                                  Radio<String>(
                                      value: 'free',
                                      groupValue: _shippingMethod,
                                      activeColor: Colors.black,
                                      onChanged: (val) => setState(
                                          () => _shippingMethod = val!)),
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('FREE SHIPPING (IN STORE)',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12)),
                                          Text('Ambil langsung di toko Solher',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.green.shade600,
                                                  fontWeight: FontWeight.bold)),
                                        ]),
                                  ),
                                  const Text('Rp 0',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => _shippingMethod = 'biteship');
                              if (_selectedAddressId != null &&
                                  _shippingRates.isEmpty) {
                                _fetchRates(_selectedAddressId!);
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: _shippingMethod == 'biteship'
                                          ? Colors.black
                                          : Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(16),
                                  color: _shippingMethod == 'biteship'
                                      ? Colors.white
                                      : Colors.grey.shade50),
                              child: Row(
                                children: [
                                  Radio<String>(
                                      value: 'biteship',
                                      groupValue: _shippingMethod,
                                      activeColor: Colors.black,
                                      onChanged: (val) {
                                        setState(() => _shippingMethod = val!);
                                        if (_selectedAddressId != null) {
                                          _fetchRates(_selectedAddressId!);
                                        }
                                      }),
                                  const Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('STANDARD COURIER',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12)),
                                          Text('Powered by Biteship',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey)),
                                        ]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_shippingMethod == 'biteship') ...[
                            const SizedBox(height: 8),
                            if (_isLoadingRates)
                              const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.black))
                            else if (_shippingRates.isEmpty)
                              const Text('Tidak ada kurir yang tersedia.',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12))
                            else
                              ..._shippingRates.map((rate) {
                                bool isSelected =
                                    _selectedRate?.company == rate.company &&
                                        _selectedRate?.type == rate.type;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedRate = rate),
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 8, left: 32),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: isSelected
                                                ? Colors.blue
                                                : Colors.grey.shade200),
                                        borderRadius: BorderRadius.circular(12),
                                        color: isSelected
                                            ? Colors.blue.shade50
                                            : Colors.white),
                                    child: Row(
                                      children: [
                                        // 👇 TAMPILAN LOGO KURIR 👇
                                        Builder(builder: (context) {
                                          final logo =
                                              _getCourierLogo(rate.company);
                                          if (logo != null) {
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  right: 12),
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Image.asset(logo,
                                                  fit: BoxFit.contain),
                                            );
                                          }
                                          // Fallback jika logo tidak ditemukan
                                          return Container(
                                            margin: const EdgeInsets.only(
                                                right: 12),
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Icon(
                                                Icons.local_shipping,
                                                size: 20,
                                                color: Colors.grey),
                                          );
                                        }),
                                        Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    '${rate.company.toUpperCase()} - ${rate.type.replaceAll('_', ' ')}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 11)),
                                                Text(
                                                    'Estimasi: ${rate.duration}',
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey)),
                                              ]),
                                        ),
                                        Text(currencyFormat.format(rate.price),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList()
                          ],
                          const SizedBox(height: 32),

                          // 3. KODE PROMO & POIN
                          const Text('PROMO CODE',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: Colors.grey)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (val) => _promoInput = val,
                                  enabled: _appliedPromoCode == null,
                                  decoration: InputDecoration(
                                      hintText: 'Enter code here',
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (_appliedPromoCode == null)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12))),
                                  onPressed: _isVerifyingPromo
                                      ? null
                                      : () => _applyPromo(checkoutItems),
                                  child: _isVerifyingPromo
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2))
                                      : const Text('APPLY',
                                          style:
                                              TextStyle(color: Colors.white)),
                                )
                              else
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade50,
                                      foregroundColor: Colors.red,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          side: BorderSide(
                                              color: Colors.red.shade200))),
                                  onPressed: _removePromo,
                                  child: const Text('REMOVE'),
                                )
                            ],
                          ),

                          // AREA SOLHER CLUB POINTS
                          if (user != null && user.isMembership) ...[
                            const SizedBox(height: 24),
                            const Text('SOLHER CLUB POINTS',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: Colors.grey)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _pointsController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      setState(() {
                                        _pointsToUse = int.tryParse(val) ?? 0;
                                        if (_pointsToUse > maxPointsAllowed) {
                                          _pointsToUse = maxPointsAllowed;
                                          _pointsController.text =
                                              maxPointsAllowed.toString();

                                          _pointsController.selection =
                                              TextSelection.fromPosition(
                                                  TextPosition(
                                                      offset: _pointsController
                                                          .text.length));
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                        hintText: 'Max: $maxPointsAllowed pts',
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Colors.yellow.shade600)),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (_pointsToUse > 0)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade50,
                                        foregroundColor: Colors.red,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            side: BorderSide(
                                                color: Colors.red.shade200))),
                                    onPressed: () {
                                      setState(() {
                                        _pointsToUse = 0;
                                        _pointsController.clear();
                                      });
                                    },
                                    child: const Text('REMOVE'),
                                  )
                                else
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.yellow.shade100,
                                        foregroundColor: Colors.yellow.shade900,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12))),
                                    onPressed: () {
                                      setState(() {
                                        _pointsToUse = maxPointsAllowed;
                                        _pointsController.text =
                                            maxPointsAllowed.toString();
                                      });
                                    },
                                    child: const Text('USE ALL'),
                                  )
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),

                  // AREA SUMMARY BOTTOM
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

                          Container(
                            constraints: const BoxConstraints(maxHeight: 180),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: checkoutItems.length,
                              itemBuilder: (context, index) {
                                final item = checkoutItems[index];
                                num price =
                                    item.product?.discountPrice != null &&
                                            item.product!.discountPrice! > 0
                                        ? item.product!.discountPrice!
                                        : item.product?.price ?? 0;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: item.product?.image != null
                                            ? Image.network(
                                                item.product!.image!,
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover)
                                            : Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.grey.shade200,
                                                child: const Icon(Icons.image,
                                                    color: Colors.grey)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                item.product?.name
                                                        .toUpperCase() ??
                                                    '',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            const SizedBox(height: 2),
                                            Text(
                                                'Warna: ${item.color ?? '-'} | Qty: ${item.quantity}',
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      Text(
                                          currencyFormat
                                              .format(price * item.quantity),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(),

                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Subtotal (${checkoutItems.length} items)',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                Text(currencyFormat.format(subtotal),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ]),
                          const SizedBox(height: 8),
                          if (shippingCost > 0) ...[
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Shipping Cost',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  Text(currencyFormat.format(shippingCost),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ]),
                            const SizedBox(height: 8),
                          ],
                          if (_promoDiscountAmount > 0) ...[
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Promo ($_appliedPromoCode)',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      '- ${currencyFormat.format(_promoDiscountAmount)}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
                                ]),
                            const SizedBox(height: 8),
                          ],
                          if (pointDiscount > 0) ...[
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Points Applied',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      '- ${currencyFormat.format(pointDiscount)}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange)),
                                ]),
                            const SizedBox(height: 8),
                          ],
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider()),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('GRAND TOTAL',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5)),
                              Text(currencyFormat.format(grandTotal),
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900)),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // TOMBOL CHECKOUT
                          BlocBuilder<CheckoutBloc, CheckoutState>(
                              builder: (context, checkoutState) {
                            bool isButtonDisabled =
                                _selectedAddressId == null ||
                                    (_shippingMethod == 'biteship' &&
                                        _selectedRate == null) ||
                                    checkoutState is CheckoutLoading;

                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16))),
                                onPressed: isButtonDisabled
                                    ? null
                                    : () {
                                        final payload = {
                                          'address_id': _selectedAddressId,
                                          'shipping_method': _shippingMethod,
                                          'use_points': _pointsToUse,
                                          'cart_ids': widget.selectedCartIds,
                                          'courier_company':
                                              _shippingMethod == 'biteship'
                                                  ? _selectedRate?.company
                                                  : null,
                                          'courier_type':
                                              _shippingMethod == 'biteship'
                                                  ? _selectedRate?.type
                                                  : null,
                                          'shipping_cost': shippingCost,
                                          'delivery_type': _deliveryType,
                                          'promo_code': _appliedPromoCode,
                                          'currency': 'IDR',
                                        };

                                        context
                                            .read<CheckoutBloc>()
                                            .add(SubmitCheckoutEvent(payload));
                                      },
                                child: checkoutState is CheckoutLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2))
                                    : const Text('PAY SECURELY',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2)),
                              ),
                            );
                          })
                        ],
                      ),
                    ),
                  )
                ],
              );
            });
          }),
        ),
      ),
    );
  }
}
