import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/affiliate/affiliate_bloc.dart';
import '../blocs/affiliate/affiliate_event.dart';
import '../blocs/affiliate/affiliate_state.dart';

class AffiliateDashboardPage extends StatefulWidget {
  const AffiliateDashboardPage({super.key});

  @override
  State<AffiliateDashboardPage> createState() => _AffiliateDashboardPageState();
}

class _AffiliateDashboardPageState extends State<AffiliateDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<AffiliateBloc>().add(FetchAffiliateDashboard());
  }

  String _formatPrice(num value) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return "-";
    DateTime dt = DateTime.parse(dateStr).toLocal();
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }

  void _copyToClipboard(String code) {
    final link = 'https://solher.co.id/?ref=$code';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Tautan berhasil disalin!'),
          backgroundColor: Colors.green),
    );
  }

  // --- MODAL WITHDRAWAL (SAMA SEPERTI WEB) ---
  void _showWithdrawalModal(num activeBalance) {
    if (activeBalance < 50000) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Saldo belum mencapai minimum penarikan (Rp 50.000)'),
          backgroundColor: Colors.orange));
      return;
    }

    String selectedMethod = 'bank';
    final bankCtrl = TextEditingController();
    final accNameCtrl = TextEditingController();
    final accNumCtrl = TextEditingController();
    final amountCtrl = TextEditingController(
        text: (activeBalance > 1000000 ? 1000000 : activeBalance)
            .toInt()
            .toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tarik Saldo',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'serif')),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    Text('Dana tersedia: ${_formatPrice(activeBalance)}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 16),

                    // Dropdown Metode
                    const Text('METODE PENARIKAN',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedMethod,
                          isExpanded: true,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w600),
                          items: const [
                            DropdownMenuItem(
                                value: 'bank',
                                child: Text('Transfer Bank (Proses 1-2 Hari)')),
                            DropdownMenuItem(
                                value: 'crypto',
                                child: Text('Web3 Auto-Payout (Instan)')),
                          ],
                          onChanged: (val) => setModalState(() {
                            selectedMethod = val!;
                            accNumCtrl.clear();
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (selectedMethod == 'crypto')
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            border: Border.all(color: Colors.indigo.shade200),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text(
                            '🚀 SMART CONTRACT AUTO-PAYOUT\nSaldo Anda akan dikonversi ke USDT dan ditransfer instan tanpa biaya admin.',
                            style:
                                TextStyle(fontSize: 10, color: Colors.indigo)),
                      ),

                    if (selectedMethod == 'bank') ...[
                      _buildInput('Nama Bank', bankCtrl),
                      _buildInput('Nama Pemilik Rekening', accNameCtrl),
                    ],

                    _buildInput(
                        selectedMethod == 'bank'
                            ? 'Nomor Rekening'
                            : 'Wallet Address (Polygon)',
                        accNumCtrl,
                        isNumber: selectedMethod == 'bank'),
                    _buildInput('Nominal Penarikan', amountCtrl,
                        isNumber: true),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (accNumCtrl.text.isEmpty ||
                              amountCtrl.text.isEmpty ||
                              (selectedMethod == 'bank' &&
                                  (bankCtrl.text.isEmpty ||
                                      accNameCtrl.text.isEmpty))) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Harap lengkapi semua data')));
                            return;
                          }
                          Navigator.pop(ctx);
                          context
                              .read<AffiliateBloc>()
                              .add(WithdrawAffiliateEvent(
                                method: selectedMethod,
                                bankName: bankCtrl.text,
                                accountName: accNameCtrl.text,
                                accountNumber: accNumCtrl.text,
                                amount: num.tryParse(amountCtrl.text) ?? 0,
                              ));
                        },
                        child: const Text('PROSES PENARIKAN',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- FORM PENDAFTARAN AFILIATOR ---
  void _showApplyModal() {
    final socialCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Daftar Afiliasi',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif')),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInput('Link Sosial Media Utama Anda', socialCtrl),
                _buildInput('Mengapa Anda ingin bergabung?', reasonCtrl,
                    maxLines: 3),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      if (socialCtrl.text.isEmpty || reasonCtrl.text.isEmpty)
                        return;
                      Navigator.pop(ctx);
                      context.read<AffiliateBloc>().add(ApplyAffiliateEvent(
                          socialMediaUrl: socialCtrl.text,
                          reason: reasonCtrl.text));
                    },
                    child: const Text('KIRIM PENDAFTARAN',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInput(String label, TextEditingController controller,
      {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('AFFILIATE',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
                letterSpacing: 1)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: BlocConsumer<AffiliateBloc, AffiliateState>(
        listener: (context, state) {
          if (state is AffiliateActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message), backgroundColor: Colors.green));
            if (state.refreshDashboard) {
              context.read<AffiliateBloc>().add(FetchAffiliateDashboard());
            }
          } else if (state is AffiliateError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is AffiliateLoading || state is AffiliateInitial) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          }

          // 👇 JIKA USER BELUM TERDAFTAR SEBAGAI AFILIATOR 👇
          if (state is NotAnAffiliateState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.campaign_outlined,
                        size: 80, color: Colors.amber.shade600),
                    const SizedBox(height: 24),
                    const Text('Gabung Solher Affiliate',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif')),
                    const SizedBox(height: 12),
                    const Text(
                        'Dapatkan komisi untuk setiap pembelian yang berhasil melalui tautan rujukan Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, height: 1.5)),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        onPressed: _showApplyModal,
                        child: const Text('DAFTAR SEKARANG',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5)),
                      ),
                    )
                  ],
                ),
              ),
            );
          }

          // 👇 JIKA USER ADALAH AFILIATOR (DASHBOARD) 👇
          if (state is AffiliateDashboardLoaded) {
            final data = state.data;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DASHBOARD',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'serif')),
                  const Text('Ringkasan komisi & tautan rujukan',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 24),

                  // CARDS STATISTIK
                  _buildStatCard('TOTAL EARNED', _formatPrice(data.totalEarned),
                      Colors.grey.shade50, Colors.black),
                  const SizedBox(height: 12),
                  _buildStatCard(
                      'PENDING COMMISSION',
                      _formatPrice(data.pendingBalance),
                      Colors.white,
                      Colors.orange.shade800,
                      borderColor: Colors.orange.shade100),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.green.shade100),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ACTIVE BALANCE',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: Colors.green)),
                        const SizedBox(height: 8),
                        Text(_formatPrice(data.activeBalance),
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: data.activeBalance > 0
                                    ? Colors.black
                                    : Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            onPressed: data.activeBalance > 0
                                ? () => _showWithdrawalModal(data.activeBalance)
                                : null,
                            child: const Text('WITHDRAW FUNDS',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1)),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // KOTAK TAUTAN
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('YOUR REFERRAL LINK',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5)),
                        const SizedBox(height: 4),
                        const Text('Bagikan tautan ini ke audiens Anda.',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                    'https://solher.co.id/?ref=${data.referralCode}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade800),
                                    overflow: TextOverflow.ellipsis),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    _copyToClipboard(data.referralCode ?? ''),
                                child: const Icon(Icons.copy, size: 18),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text('HISTORY',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'serif')),
                  const SizedBox(height: 16),

                  // TRANSAKSI LIST
                  data.transactions.isEmpty
                      ? const Center(
                          child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Text('Belum ada riwayat komisi.',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic))))
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.transactions.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final tx = data.transactions[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Order #${tx.id}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)),
                                      const SizedBox(height: 4),
                                      Text(_formatDate(tx.createdAt),
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                          '+ ${_formatPrice(tx.commissionEarned)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 13,
                                              color: Colors.green)),
                                      const SizedBox(height: 4),
                                      Text(tx.commissionStatus.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                              color: tx.commissionStatus ==
                                                      'pending'
                                                  ? Colors.orange
                                                  : Colors.grey)),
                                    ],
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

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color bgColor, Color textColor,
      {Color? borderColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor ?? Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: textColor.withOpacity(0.6))),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w900, color: textColor)),
        ],
      ),
    );
  }
}
