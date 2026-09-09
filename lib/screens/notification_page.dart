import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/notif/notif_bloc.dart';
import '../blocs/notif/notif_event.dart';
import '../blocs/notif/notif_state.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          TextButton(
            onPressed: () {
              context.read<NotifBloc>().add(MarkAllNotifsAsReadEvent());
            },
            child: const Text('Read All', style: TextStyle(color: Colors.black)),
          )
        ],
      ),
      body: BlocBuilder<NotifBloc, NotifState>(
        builder: (context, state) {
          if (state is NotifLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          } else if (state is NotifError) {
            return Center(child: Text(state.message));
          } else if (state is NotifLoaded) {
            final notifs = state.notifications;
            if (notifs.isEmpty) {
              return const Center(child: Text('Belum ada notifikasi.', style: TextStyle(color: Colors.grey)));
            }

            return ListView.separated(
              itemCount: notifs.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = notifs[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  tileColor: notif.isRead ? Colors.white : Colors.grey.shade50,
                  title: Text(
                    notif.title,
                    style: TextStyle(fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(notif.message, style: const TextStyle(height: 1.4)),
                  ),
                  trailing: notif.isRead
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                          onPressed: () {
                            context.read<NotifBloc>().add(MarkNotifAsReadEvent(notif.id));
                          },
                        ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}