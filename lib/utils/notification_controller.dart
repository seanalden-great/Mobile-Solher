// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class NotificationController {
//   /// Inisialisasi Channel Notifikasi
//   static Future<void> initializeLocalNotifications() async {
//     await AwesomeNotifications().initialize(
//       null, // Gunakan ikon default aplikasi
//       [
//         NotificationChannel(
//           channelKey: 'chat_channel',
//           channelName: 'Chat Notifications',
//           channelDescription: 'Notifikasi pesan baru dari Admin Solher',
//           defaultColor: const Color(0xFF000000),
//           ledColor: const Color(0xFFFFFFFF),
//           importance: NotificationImportance.High,
//           channelShowBadge: true,
//           locked: false,
//         )
//       ],
//     );

//     // Minta Izin Notifikasi (Jika belum)
//     await AwesomeNotifications()
//         .isNotificationAllowed()
//         .then((isAllowed) async {
//       if (!isAllowed) {
//         await AwesomeNotifications().requestPermissionToSendNotifications();
//       }
//     });
//   }

//   /// Pasang Listener untuk Menangkap Action "Balas"
//   static Future<void> startListeningNotificationEvents() async {
//     AwesomeNotifications().setListeners(
//       onActionReceivedMethod: onActionReceivedMethod,
//     );
//   }

//   /// Memicu Notifikasi Pesan Baru dengan Gambar dan Tombol Balas
//   static Future<void> showNewMessageNotification({
//     required int adminId,
//     required String adminName,
//     required String message,
//     String? imageUrl,
//   }) async {
//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: DateTime.now().millisecond,
//         channelKey: 'chat_channel',
//         title: 'Pesan Baru dari $adminName',
//         body: message,
//         // Jika ada link gambar, ubah layout jadi BigPicture
//         notificationLayout: imageUrl != null
//             ? NotificationLayout.BigPicture
//             : NotificationLayout.Messaging,
//         bigPicture: imageUrl,
//         payload: {'admin_id': adminId.toString()},
//         category: NotificationCategory.Message,
//       ),
//       actionButtons: [
//         NotificationActionButton(
//           key: 'REPLY',
//           label: 'Balas',
//           autoDismissible: true,
//           requireInputText: true, // Memunculkan kolom ketikan di layar kunci
//           actionType: ActionType
//               .SilentBackgroundAction, // Mengeksekusi tanpa membuka aplikasi
//         ),
//       ],
//     );
//   }

//   /// 👇 FUNGSI LATAR BELAKANG: Dipanggil saat User menekan "Send" di notifikasi 👇
//   @pragma("vm:entry-point")
//   static Future<void> onActionReceivedMethod(
//       ReceivedAction receivedAction) async {
//     // Mengecek apakah tombol yang ditekan adalah tombol 'REPLY'
//     if (receivedAction.buttonKeyPressed == 'REPLY') {
//       final String replyText = receivedAction.buttonKeyInput;
//       final int adminId = int.parse(receivedAction.payload?['admin_id'] ?? '0');

//       if (replyText.isNotEmpty && adminId != 0) {
//         // Tembak API secara rahasia di latar belakang (Background HTTP Request)
//         try {
//           final prefs = await SharedPreferences.getInstance();
//           final token = prefs.getString('token');
//           final dio = Dio();

//           await dio.post(
//             'https://back.solher.co.id/api/chat/send',
//             data: {
//               'receiver_id': adminId,
//               'message': replyText,
//             },
//             options: Options(headers: {
//               'Authorization': 'Bearer $token',
//               'Accept': 'application/json',
//             }),
//           );
//         } catch (e) {
//           // Gagal mengirim bisa ditangani dengan menyimpan ke antrean SQLite
//         }
//       }
//     }
//   }
// }

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart'; // 👇 IMPORT WORKMANAGER

// 👇 FUNGSI LATAR BELAKANG WORKMANAGER (WAJIB DI LUAR KELAS & STATIC) 👇
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Mengecek apakah task yang dibangunkan OS adalah task keranjang
    if (task == 'cart_reminder_task') {
      try {
        final productName = inputData?['product_name'] ?? 'Barang di keranjang';

        // Memunculkan Notifikasi
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 999, // ID statis agar notifikasi lama tergantikan jika ada yang baru
            channelKey: 'promo_channel',
            title: 'Keranjang Anda Menunggu! 🛍️',
            body:
                '$productName hampir kehabisan stok. Checkout sekarang sebelum terlambat!',
            notificationLayout: NotificationLayout.Default,
            category: NotificationCategory.Promo,
          ),
        );
      } catch (e) {
        // Abaikan error di background
      }
    }
    return Future.value(true);
  });
}

class NotificationController {
  /// Inisialisasi Channel Notifikasi & Workmanager
  static Future<void> initializeLocalNotifications() async {
    // 1. Inisialisasi Awesome Notifications
    await AwesomeNotifications().initialize(
      null, // Gunakan ikon default aplikasi
      [
        NotificationChannel(
          channelKey: 'chat_channel',
          channelName: 'Chat Notifications',
          channelDescription: 'Notifikasi pesan baru dari Admin Solher',
          defaultColor: const Color(0xFF000000),
          ledColor: const Color(0xFFFFFFFF),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          locked: false,
        ),
        // 👇 CHANNEL BARU UNTUK PROMO / KERANJANG 👇
        NotificationChannel(
          channelKey: 'promo_channel',
          channelName: 'Promo & Reminders',
          channelDescription: 'Pengingat keranjang dan promo',
          defaultColor: const Color(0xFF000000),
          ledColor: const Color(0xFFFFFFFF),
          importance: NotificationImportance.Default,
        )
      ],
    );

    // Minta Izin Notifikasi (Jika belum)
    await AwesomeNotifications()
        .isNotificationAllowed()
        .then((isAllowed) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // 👇 2. INISIALISASI WORKMANAGER 👇
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode:
          false, // Ubah ke true jika ingin melihat log di konsol saat testing
    );
  }

  /// Pasang Listener untuk Menangkap Action "Balas"
  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  /// Membatalkan Alarm Keranjang (Dipanggil saat user checkout)
  static void cancelCartReminder() {
    Workmanager().cancelByUniqueName('cart_reminder_task');
  }

  /// Menjadwalkan Alarm Keranjang (Dipanggil saat Add to Cart)
  static void scheduleCartReminder(String productName) {
    // Batalkan pengingat lama (jika ada) agar tidak terjadi tumpang tindih
    cancelCartReminder();

    // Jadwalkan pengingat baru 1 jam dari sekarang
    Workmanager().registerOneOffTask(
      'cart_reminder_task', // Nama unik task
      'cart_reminder_task',
      initialDelay: const Duration(hours: 1), // Waktu tunggu
      inputData: <String, dynamic>{
        'product_name': productName,
      },
    );
  }

  /// Memicu Notifikasi Pesan Baru dengan Gambar dan Tombol Balas
  static Future<void> showNewMessageNotification({
    required int adminId,
    required String adminName,
    required String message,
    String? imageUrl,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecond,
        channelKey: 'chat_channel',
        title: 'Pesan Baru dari $adminName',
        body: message,
        notificationLayout: imageUrl != null
            ? NotificationLayout.BigPicture
            : NotificationLayout.Messaging,
        bigPicture: imageUrl,
        payload: {'admin_id': adminId.toString()},
        category: NotificationCategory.Message,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'REPLY',
          label: 'Balas',
          autoDismissible: true,
          requireInputText: true,
          actionType: ActionType.SilentBackgroundAction,
        ),
      ],
    );
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyPressed == 'REPLY') {
      final String replyText = receivedAction.buttonKeyInput;
      final int adminId = int.parse(receivedAction.payload?['admin_id'] ?? '0');

      if (replyText.isNotEmpty && adminId != 0) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          final dio = Dio();

          await dio.post(
            'https://back.solher.co.id/api/chat/send',
            data: {
              'receiver_id': adminId,
              'message': replyText,
            },
            options: Options(headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            }),
          );
        } catch (e) {
          // Gagal
        }
      }
    }
  }
}
