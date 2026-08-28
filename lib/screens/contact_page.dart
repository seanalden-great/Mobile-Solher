import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/contact/contact_bloc.dart';
import '../blocs/contact/contact_event.dart';
import '../blocs/contact/contact_state.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // Otomatis isi form jika user sudah login
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _isLoggedIn = true;
      _nameCtrl.text = '${authState.user.firstName} ${authState.user.lastName}';
      _emailCtrl.text = authState.user.email;
      _phoneCtrl.text = authState.user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_nameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Harap isi nama, email, dan deskripsi.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    context.read<ContactBloc>().add(SubmitContactFormEvent(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          phone: _phoneCtrl.text,
          description: _descCtrl.text,
        ));
  }

  void _showHistoryModal() {
    context.read<ContactBloc>().add(FetchContactHistoryEvent());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<ContactBloc>(),
          child: Padding(
            padding: EdgeInsets.only(
                top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.85,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('PERTANYAAN SAYA',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'serif')),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: BlocBuilder<ContactBloc, ContactState>(
                      builder: (context, state) {
                        if (state is ContactHistoryLoading) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.black));
                        } else if (state is ContactHistoryError) {
                          return Center(
                              child: Text(state.message,
                                  style: const TextStyle(color: Colors.red)));
                        } else if (state is ContactHistoryLoaded) {
                          if (state.histories.isEmpty) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.mail_outline,
                                      size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text('Anda belum mengirim pesan apa pun.',
                                      style: TextStyle(
                                          fontFamily: 'serif',
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                          fontSize: 16)),
                                ],
                              ),
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.all(24),
                            physics: const BouncingScrollPhysics(),
                            itemCount: state.histories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final item = state.histories[index];
                              final dateStr = DateFormat('dd MMMM yyyy, HH:mm')
                                  .format(
                                      DateTime.parse(item.createdAt).toLocal());
                              final hasReply = item.response != null &&
                                  item.response!.isNotEmpty;

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 10)
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(dateStr,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                                letterSpacing: 1)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: hasReply
                                                ? Colors.green.shade50
                                                : Colors.orange.shade50,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: hasReply
                                                    ? Colors.green.shade200
                                                    : Colors.orange.shade200),
                                          ),
                                          child: Text(
                                            hasReply
                                                ? 'TERJAWAB'
                                                : 'MENUNGGU BALASAN',
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900,
                                                color: hasReply
                                                    ? Colors.green.shade700
                                                    : Colors.orange.shade700,
                                                letterSpacing: 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Text('"${item.description}"',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                              height: 1.5)),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          border: Border.all(
                                              color: Colors.blue.shade100),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.reply,
                                                  size: 16,
                                                  color: Colors.blue.shade700),
                                              const SizedBox(width: 8),
                                              const Text('BALASAN DARI SOLHER',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 1)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            hasReply
                                                ? item.response!
                                                : 'Tim kami belum membalas. Silakan cek kembali nanti.',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: hasReply
                                                    ? Colors.black87
                                                    : Colors.grey,
                                                fontStyle: hasReply
                                                    ? FontStyle.normal
                                                    : FontStyle.italic,
                                                height: 1.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      appBar: AppBar(
        title: const Text('KONTTAK KAMI',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
                letterSpacing: 1)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            if (_isLoggedIn)
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('RIWAYAT PERTANYAAN SAYA',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  onPressed: _showHistoryModal,
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Contact Us',
              style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ]),
              child: BlocConsumer<ContactBloc, ContactState>(
                listener: (context, state) {
                  if (state is ContactSubmitSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green));
                    _descCtrl.clear(); // Bersihkan isi pesan setelah sukses
                    if (!_isLoggedIn) {
                      _nameCtrl.clear();
                      _emailCtrl.clear();
                      _phoneCtrl.clear();
                    }
                  } else if (state is ContactSubmitError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red));
                  }
                },
                builder: (context, state) {
                  bool isLoading = state is ContactSubmitLoading;

                  return Column(
                    children: [
                      _buildInput('NAMA', _nameCtrl, readOnly: _isLoggedIn),
                      _buildInput('EMAIL', _emailCtrl,
                          readOnly: _isLoggedIn, isEmail: true),
                      _buildInput('TELEPON (OPSIONAL)', _phoneCtrl,
                          readOnly: _isLoggedIn, isPhone: true),
                      _buildInput('DESKRIPSI', _descCtrl, maxLines: 5),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: isLoading ? null : _submitForm,
                          child: isLoading
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('KIRIM PESAN',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2)),
                        ),
                      )
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller,
      {bool readOnly = false,
      bool isEmail = false,
      bool isPhone = false,
      int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.5)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            keyboardType: isEmail
                ? TextInputType.emailAddress
                : isPhone
                    ? TextInputType.phone
                    : TextInputType.text,
            style: TextStyle(
                fontSize: 14,
                color: readOnly ? Colors.grey.shade600 : Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: readOnly
                          ? Colors.transparent
                          : Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Colors.black, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}
