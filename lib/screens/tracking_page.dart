import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackingPage extends StatefulWidget {
  final int orderId;

  const TrackingPage({super.key, required this.orderId});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  Map<String, dynamic>? _orderData;
  Map<String, dynamic>? _trackingData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json'
      };

      // 1. Fetch Order Data
      final orderRes = await http.get(
        Uri.parse(
            'https://back.solher.co.id/api/transactions/${widget.orderId}'),
        headers: headers,
      );

      if (orderRes.statusCode == 200) {
        _orderData = json.decode(orderRes.body);
      } else {
        throw Exception('Gagal memuat detail pesanan.');
      }

      // 2. Fetch Tracking Data
      try {
        final trackRes = await http.get(
          Uri.parse(
              'https://back.solher.co.id/api/transactions/${widget.orderId}/tracking'),
          headers: headers,
        );

        if (trackRes.statusCode == 200) {
          _trackingData = json.decode(trackRes.body);
        }
      } catch (trackErr) {
        // Mockup fallback (seperti di Vue) jika tracking DHL belum masuk API Biteship
        if (_orderData?['courier_company']?.toString().toLowerCase() == 'dhl') {
          _trackingData = {
            'courier': {
              'company': 'DHL',
              'type': 'Express Worldwide',
              'history': [
                {
                  'status': 'processing',
                  'note': 'Order data received by DHL',
                  'updated_at': _orderData!['created_at'],
                }
              ]
            },
            'origin': {
              'contact_name': 'Solher Store',
              'address': 'Surabaya, ID'
            },
            'destination': {
              'contact_name': _orderData?['user']?['name'] ?? 'Customer',
              'address': 'International Route'
            }
          };
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 👇 Helper Formatters 👇
  String _formatCurrency(dynamic amount) {
    final val = double.tryParse(amount?.toString() ?? '0') ?? 0;
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(val);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  String _formatStatusTitle(String? status) {
    if (status == null) return 'Processing';
    return status.replaceAll('_', ' ').toUpperCase();
  }

  String? _getCourierLogo(String? courier) {
    if (courier == null) return null;
    final normalized = courier.toLowerCase().replaceAll(' ', '');

    if (normalized.contains('anteraja'))
      return 'assets/icons/courier_icons/anteraja.png';
    if (normalized.contains('gojek') || normalized.contains('gosend'))
      return 'assets/icons/courier_icons/gojek.png';
    if (normalized.contains('grab'))
      return 'assets/icons/courier_icons/grab.png';
    if (normalized.contains('jne')) return 'assets/icons/courier_icons/jne.png';
    if (normalized.contains('jnt') || normalized.contains('j&t'))
      return 'assets/icons/courier_icons/jnt.png';
    if (normalized.contains('ninja'))
      return 'assets/icons/courier_icons/ninja.png';
    if (normalized.contains('paxel'))
      return 'assets/icons/courier_icons/paxel.png';
    if (normalized.contains('sicepat'))
      return 'assets/icons/courier_icons/sicepat.png';
    if (normalized.contains('dhl'))
      return 'assets/icons/courier_icons/dhl.png'; // Tambahkan jika ada

    return null;
  }

  String? _getPaymentLogo(String? method) {
    if (method == null) return null;
    final normalized = method.toLowerCase().replaceAll(' ', '');

    if (normalized.contains('bca')) return 'assets/icons/payment_icons/bca.png';
    if (normalized.contains('bni')) return 'assets/icons/payment_icons/bni.png';
    if (normalized.contains('bri')) return 'assets/icons/payment_icons/bri.png';
    if (normalized.contains('mandiri'))
      return 'assets/icons/payment_icons/mandiri.png';
    if (normalized.contains('permata'))
      return 'assets/icons/payment_icons/permata.png';
    if (normalized.contains('bsi')) return 'assets/icons/payment_icons/bsi.png';
    if (normalized.contains('ovo')) return 'assets/icons/payment_icons/ovo.png';
    if (normalized.contains('shopeepay'))
      return 'assets/icons/payment_icons/shopeepay.png';
    if (normalized.contains('dana'))
      return 'assets/icons/payment_icons/dana.png';
    if (normalized.contains('linkaja'))
      return 'assets/icons/payment_icons/linkaja.png';
    if (normalized.contains('alfamart'))
      return 'assets/icons/payment_icons/alfamart.png';
    if (normalized.contains('indomaret'))
      return 'assets/icons/payment_icons/indomaret.png';
    if (normalized.contains('qris'))
      return 'assets/icons/payment_icons/qris.png';

    return null;
  }

  List<dynamic> _getTimelineHistory() {
    final apiHistory =
        _trackingData?['courier']?['history'] as List<dynamic>? ?? [];
    if (apiHistory.isNotEmpty) {
      return apiHistory.reversed.toList();
    }
    return [
      {
        'status':
            _trackingData?['status'] ?? _orderData?['status'] ?? 'Processing',
        'note': 'Pesanan sedang diproses oleh sistem.',
        'updated_at':
            _orderData?['created_at'] ?? DateTime.now().toIso8601String(),
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        title: const Text('PELACAKAN PENGIRIMAN',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
                letterSpacing: 1,
                fontSize: 18)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _error != null
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)))
              : _orderData == null
                  ? const Center(child: Text('Data tidak ditemukan'))
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderCard(),
                          const SizedBox(height: 20),
                          _buildAddressCard(),
                          const SizedBox(height: 20),
                          _buildOrderSummaryCard(),
                          const SizedBox(height: 20),
                          _buildTimelineCard(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildHeaderCard() {
    final waybill = _trackingData?['courier']?['waybill_id'] ??
        _orderData?['tracking_number'] ??
        'Menunggu Kurir...';
    final status = _trackingData?['status'] ?? _orderData?['status'];
    final paymentMethod = _orderData?['payment_method'] ?? '';
    final courierCompany = _trackingData?['courier']?['company'] ??
        _orderData?['courier_company'] ??
        'N/A';
    final courierType =
        _trackingData?['courier']?['type'] ?? _orderData?['courier_type'] ?? '';

    final paymentLogo = _getPaymentLogo(paymentMethod);
    final courierLogo = _getCourierLogo(courierCompany);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NOMOR RESI',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 2)),
                const SizedBox(height: 4),
                Text(waybill,
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(_formatStatusTitle(status),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PEMBAYARAN',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (paymentLogo != null) ...[
                            Image.asset(paymentLogo, height: 20),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                                paymentMethod
                                    .replaceAll('_', ' ')
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.green)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade200),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('KURIR',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (courierLogo != null) ...[
                            Image.asset(courierLogo, height: 20),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(courierCompany.toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                Text(courierType.toUpperCase(),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    final originName = _trackingData?['origin']?['contact_name'] ?? '-';
    final originPhone = _trackingData?['origin']?['contact_phone'] ?? '-';
    final originAddress = _trackingData?['origin']?['address'] ?? '-';

    final destName = _trackingData?['destination']?['contact_name'] ?? '-';
    final destPhone = _trackingData?['destination']?['contact_phone'] ?? '-';
    final destAddress = _trackingData?['destination']?['address'] ?? '-';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              const Text('DETAIL ASAL',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(originName, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(originPhone,
              style: const TextStyle(
                  fontFamily: 'monospace', fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(originAddress,
              style: const TextStyle(
                  fontSize: 12, color: Colors.black87, height: 1.5)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Colors.black12),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.black),
              const SizedBox(width: 8),
              const Text('DETAIL TUJUAN',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(destName, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(destPhone,
              style: const TextStyle(
                  fontFamily: 'monospace', fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(destAddress,
              style: const TextStyle(
                  fontSize: 12, color: Colors.black87, height: 1.5)),
        ],
      ),
    );
  }

  // Widget _buildOrderSummaryCard() {
  //   final details = _orderData?['details'] as List<dynamic>? ?? [];
  //   final subtotal = _orderData?['total_amount'] ?? 0;
  //   final shipping = _orderData?['shipping_cost'] ?? 0;
  //   final promo = _orderData?['promo_discount'] ?? 0;
  //   final pointsDiscount = (_orderData?['points_used'] ?? 0) * 1000;

  //   // Grand Total kalkulasi yang akurat
  //   final grandTotal = (double.tryParse(subtotal.toString()) ?? 0) +
  //       (double.tryParse(shipping.toString()) ?? 0) -
  //       (double.tryParse(promo.toString()) ?? 0) -
  //       (double.tryParse(pointsDiscount.toString()) ?? 0);

  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(color: Colors.grey.shade200),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //           decoration: BoxDecoration(
  //               color: Colors.grey.shade50,
  //               borderRadius:
  //                   const BorderRadius.vertical(top: Radius.circular(20)),
  //               border:
  //                   const Border(bottom: BorderSide(color: Colors.black12))),
  //           child: const Text('RINGKASAN PESANAN',
  //               style: TextStyle(
  //                   fontSize: 10,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.grey,
  //                   letterSpacing: 2)),
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Column(
  //             children: [
  //               ...details.map((item) {
  //                 return Padding(
  //                   padding: const EdgeInsets.only(bottom: 16),
  //                   child: Row(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Container(
  //                         width: 50,
  //                         height: 50,
  //                         decoration: BoxDecoration(
  //                             color: Colors.grey.shade100,
  //                             borderRadius: BorderRadius.circular(8)),
  //                         child: item['product']?['image'] != null
  //                             ? ClipRRect(
  //                                 borderRadius: BorderRadius.circular(8),
  //                                 child: Image.network(item['product']['image'],
  //                                     fit: BoxFit.cover))
  //                             : const Icon(Icons.image, color: Colors.grey),
  //                       ),
  //                       const SizedBox(width: 12),
  //                       Expanded(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Text(
  //                                 item['product']?['name']?.toUpperCase() ??
  //                                     'PRODUK',
  //                                 style: const TextStyle(
  //                                     fontWeight: FontWeight.bold,
  //                                     fontSize: 12)),
  //                             if (item['color'] != null)
  //                               Text('Warna: ${item['color']}',
  //                                   style: const TextStyle(
  //                                       fontSize: 10, color: Colors.grey)),
  //                             const SizedBox(height: 4),
  //                             Text(
  //                                 '${item['quantity']} x ${_formatCurrency(item['price'])}',
  //                                 style: const TextStyle(
  //                                     fontSize: 11, color: Colors.grey)),
  //                           ],
  //                         ),
  //                       ),
  //                       Text(
  //                           _formatCurrency(
  //                               (item['quantity'] ?? 1) * (item['price'] ?? 0)),
  //                           style: const TextStyle(
  //                               fontWeight: FontWeight.bold, fontSize: 12))
  //                     ],
  //                   ),
  //                 );
  //               }).toList(),
  //               const Divider(height: 32, color: Colors.black12),
  //               _buildSummaryRow('Subtotal Produk', _formatCurrency(subtotal)),
  //               _buildSummaryRow('Ongkos Kirim', _formatCurrency(shipping)),
  //               if (promo > 0)
  //                 _buildSummaryRow(
  //                     'Promo Digunakan', '- ${_formatCurrency(promo)}',
  //                     isDiscount: true),
  //               if (pointsDiscount > 0)
  //                 _buildSummaryRow(
  //                     'Poin Ditukarkan', '- ${_formatCurrency(pointsDiscount)}',
  //                     color: Colors.orange),
  //               const Padding(
  //                 padding: EdgeInsets.symmetric(vertical: 12),
  //                 child: Divider(
  //                     height: 1,
  //                     color: Colors.black12,
  //                     // style: BorderStyle.none
  //                     ),
  //               ),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   const Text('TOTAL KESELURUHAN',
  //                       style: TextStyle(
  //                           fontSize: 10,
  //                           fontWeight: FontWeight.bold,
  //                           letterSpacing: 1)),
  //                   Text(_formatCurrency(grandTotal),
  //                       style: const TextStyle(
  //                           fontSize: 18, fontWeight: FontWeight.w900)),
  //                 ],
  //               )
  //             ],
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget _buildOrderSummaryCard() {
    final details = _orderData?['details'] as List<dynamic>? ?? [];
    final subtotal = _orderData?['total_amount'] ?? 0;
    final shipping = _orderData?['shipping_cost'] ?? 0;
    final promo = _orderData?['promo_discount'] ?? 0;

    // 👇 PERBAIKAN: Parsing aman untuk points_used jika berbentuk String
    final pointsUsedRaw = _orderData?['points_used']?.toString() ?? '0';
    final pointsDiscount = (double.tryParse(pointsUsedRaw) ?? 0) * 1000;

    // Grand Total kalkulasi yang akurat
    final grandTotal = (double.tryParse(subtotal.toString()) ?? 0) +
        (double.tryParse(shipping.toString()) ?? 0) -
        (double.tryParse(promo.toString()) ?? 0) -
        pointsDiscount;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                border:
                    const Border(bottom: BorderSide(color: Colors.black12))),
            child: const Text('RINGKASAN PESANAN',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 2)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ...details.map((item) {
                  // 👇 PERBAIKAN: Konversi mutlak JSON String -> Angka sebelum dikali
                  final qty =
                      num.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
                  final price =
                      num.tryParse(item['price']?.toString() ?? '0') ?? 0;
                  final totalItemPrice = qty * price;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8)),
                          child: item['product']?['image'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(item['product']['image'],
                                      fit: BoxFit.cover))
                              : const Icon(Icons.image, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  item['product']?['name']?.toUpperCase() ??
                                      'PRODUK',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                              if (item['color'] != null)
                                Text('Warna: ${item['color']}',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text('$qty x ${_formatCurrency(price)}',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Text(_formatCurrency(totalItemPrice),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12))
                      ],
                    ),
                  );
                }).toList(),
                const Divider(height: 32, color: Colors.black12),
                _buildSummaryRow('Subtotal Produk', _formatCurrency(subtotal)),
                _buildSummaryRow('Ongkos Kirim', _formatCurrency(shipping)),
                if ((double.tryParse(promo.toString()) ?? 0) > 0)
                  _buildSummaryRow(
                      'Promo Digunakan', '- ${_formatCurrency(promo)}',
                      isDiscount: true),
                if (pointsDiscount > 0)
                  _buildSummaryRow(
                      'Poin Ditukarkan', '- ${_formatCurrency(pointsDiscount)}',
                      color: Colors.orange),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                      height: 1,
                      color: Colors.black12,
                      // style: BorderStyle.none
                      ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL KESELURUHAN',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                    Text(_formatCurrency(grandTotal),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isDiscount = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color:
                      color ?? (isDiscount ? Colors.green : Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    final history = _getTimelineHistory();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('LINIMASA PELACAKAN',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 2)),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              final isLatest = index == 0;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color:
                                isLatest ? Colors.black : Colors.grey.shade300,
                            shape: BoxShape.circle,
                            border: isLatest
                                ? Border.all(
                                    color: Colors.grey.shade200, width: 2)
                                : null,
                          ),
                        ),
                        if (index != history.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: Colors.grey.shade200,
                            ),
                          )
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formatStatusTitle(item['status']),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color:
                                        isLatest ? Colors.black : Colors.grey)),
                            const SizedBox(height: 4),
                            Text(item['note'] ?? '-',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                            const SizedBox(height: 4),
                            Text(_formatDate(item['updated_at']),
                                style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
