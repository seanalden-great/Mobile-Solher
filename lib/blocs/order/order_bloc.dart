// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../repositories/order_repository.dart';
// import 'order_event.dart';
// import 'order_state.dart';

// class OrderBloc extends Bloc<OrderEvent, OrderState> {
//   final OrderRepository orderRepository;

//   OrderBloc({required this.orderRepository}) : super(OrderInitial()) {
//     on<FetchOrders>((event, emit) async {
//       emit(OrderLoading());
//       try {
//         final orders = await orderRepository.fetchOrders();
//         emit(OrderLoaded(orders));
//       } catch (e) {
//         emit(OrderError(e.toString().replaceAll('Exception: ', '')));
//       }
//     });

//     on<FetchOrderDetailRequested>((event, emit) async {
//       emit(OrderLoading());
//       try {
//         final order =
//             await orderRepository.fetchOrderDetail(event.transactionId);
//         emit(OrderDetailLoaded(order));
//       } catch (e) {
//         emit(OrderError(e.toString().replaceAll('Exception: ', '')));
//       }
//     });

//     on<CheckoutRequested>((event, emit) async {
//       emit(OrderLoading());
//       try {
//         final response = await orderRepository.checkout(event.checkoutData);
//         emit(OrderCheckoutSuccess(response));
//         // Opsional: Tarik data terbaru setelah checkout selesai
//         add(FetchOrders());
//       } catch (e) {
//         emit(OrderError(e.toString().replaceAll('Exception: ', '')));
//       }
//     });

//     on<CancelOrderRequested>((event, emit) async {
//       emit(OrderLoading());
//       try {
//         await orderRepository.cancelOrder(event.transactionId);
//         emit(OrderActionSuccess('Pesanan berhasil dibatalkan.'));
//         add(FetchOrders()); // Refresh data
//       } catch (e) {
//         emit(OrderError(e.toString().replaceAll('Exception: ', '')));
//         add(FetchOrders());
//       }
//     });

//     on<ConfirmCompleteRequested>((event, emit) async {
//       emit(OrderLoading());
//       try {
//         await orderRepository.confirmComplete(event.transactionId);
//         emit(OrderActionSuccess(
//             'Terima kasih telah menyelesaikan pesanan ini!'));
//         add(FetchOrders()); // Refresh data
//       } catch (e) {
//         emit(OrderError(e.toString().replaceAll('Exception: ', '')));
//         add(FetchOrders());
//       }
//     });

//     on<RequestRefundRequested>((event, emit) async {
//       emit(OrderLoading());
//       try {
//         await orderRepository.requestRefund(
//             event.transactionId, event.reason, event.filePath);
//         emit(OrderActionSuccess('Pengajuan refund berhasil dikirim ke Admin.'));
//         add(FetchOrders()); // Refresh data
//       } catch (e) {
//         emit(OrderError(e.toString().replaceAll('Exception: ', '')));
//         add(FetchOrders());
//       }
//     });

//     on<ProcessRefundRequested>((event, emit) async {
//       emit(OrderLoading());
//       try {
//         await orderRepository.processRefundUser(event.transactionId);
//         emit(OrderActionSuccess(
//             'Pengembalian dana sedang diproses secara otomatis.'));
//         add(FetchOrders()); // Refresh data
//       } catch (e) {
//         emit(OrderError(e.toString().replaceAll('Exception: ', '')));
//         add(FetchOrders());
//       }
//     });

//     on<TrackOrderRequested>((event, emit) async {
//       emit(OrderLoading());
//       try {
//         final trackingData =
//             await orderRepository.trackOrder(event.transactionId);
//         emit(OrderTrackingLoaded(trackingData));
//       } catch (e) {
//         emit(OrderError(e.toString().replaceAll('Exception: ', '')));
//       }
//     });

//     on<BulkTrackOrdersRequested>((event, emit) async {
//       emit(OrderLoading());
//       try {
//         final bulkData =
//             await orderRepository.bulkTrackOrders(event.transactionIds);
//         emit(BulkOrderTrackingLoaded(bulkData));
//       } catch (e) {
//         emit(OrderError(e.toString().replaceAll('Exception: ', '')));
//       }
//     });
//   }
// }

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  // Menyimpan parameter aktif
  String currentTab = 'all';
  String currentSearch = '';

  OrderBloc({required this.orderRepository}) : super(OrderInitial()) {
    // 👇 FUNGSI INFINITE SCROLLING & FILTERING 👇
    on<FetchOrders>((event, emit) async {
      try {
        if (event.isRefresh) {
          emit(OrderLoading());
          currentTab = event.tab ?? currentTab;
          currentSearch = event.search ?? currentSearch;

          final orders = await orderRepository.fetchOrders(
            page: 1,
            tab: currentTab,
            search: currentSearch,
          );

          emit(OrderLoaded(
            orders: orders,
            hasReachedMax: orders.length < 20,
            currentPage: 1,
          ));
        } else {
          final currentState = state;
          if (currentState is OrderLoaded && !currentState.hasReachedMax) {
            final nextPage = currentState.currentPage + 1;
            final newOrders = await orderRepository.fetchOrders(
              page: nextPage,
              tab: currentTab,
              search: currentSearch,
            );

            emit(newOrders.isEmpty
                ? currentState.copyWith(hasReachedMax: true)
                : OrderLoaded(
                    orders: currentState.orders + newOrders,
                    hasReachedMax: newOrders.length < 20,
                    currentPage: nextPage,
                  ));
          }
        }
      } catch (e) {
        emit(OrderError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<FetchOrderDetailRequested>((event, emit) async {
      emit(OrderLoading());
      try {
        final order =
            await orderRepository.fetchOrderDetail(event.transactionId);
        emit(OrderDetailLoaded(order));
      } catch (e) {
        emit(OrderError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<CheckoutRequested>((event, emit) async {
      emit(OrderLoading());
      try {
        final response = await orderRepository.checkout(event.checkoutData);
        emit( OrderCheckoutSuccess(response));
        add(FetchOrders(isRefresh: true));
      } catch (e) {
        emit(OrderError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<CancelOrderRequested>((event, emit) async {
      emit(OrderLoading());
      try {
        await orderRepository.cancelOrder(event.transactionId);
        emit(OrderActionSuccess('Pesanan berhasil dibatalkan.'));
        add(FetchOrders(isRefresh: true));
      } catch (e) {
        emit(OrderError(e.toString().replaceAll('Exception: ', '')));
        add(FetchOrders(isRefresh: true));
      }
    });

    on<ConfirmCompleteRequested>((event, emit) async {
      emit(OrderLoading());
      try {
        await orderRepository.confirmComplete(event.transactionId);
        emit(OrderActionSuccess(
            'Terima kasih telah menyelesaikan pesanan ini!'));
        add(FetchOrders(isRefresh: true));
      } catch (e) {
        emit(OrderError(e.toString().replaceAll('Exception: ', '')));
        add(FetchOrders(isRefresh: true));
      }
    });

    on<RequestRefundRequested>((event, emit) async {
      emit(OrderLoading());
      try {
        await orderRepository.requestRefund(
            event.transactionId, event.reason, event.filePath);
        emit(OrderActionSuccess(
            'Pengajuan refund berhasil dikirim ke Admin.'));
        add(FetchOrders(isRefresh: true));
      } catch (e) {
        emit(OrderError(e.toString().replaceAll('Exception: ', '')));
        add(FetchOrders(isRefresh: true));
      }
    });

    on<ProcessRefundRequested>((event, emit) async {
      emit(OrderLoading());
      try {
        await orderRepository.processRefundUser(event.transactionId);
        emit(OrderActionSuccess(
            'Pengembalian dana sedang diproses secara otomatis.'));
        add(  FetchOrders(isRefresh: true));
      } catch (e) {
        emit(OrderError(e.toString().replaceAll('Exception: ', '')));
        add(FetchOrders(isRefresh: true));
      }
    });

    on<TrackOrderRequested>((event, emit) async {
      emit(OrderLoading());
      try {
        final trackingData =
            await orderRepository.trackOrder(event.transactionId);
        emit(OrderTrackingLoaded(trackingData));
      } catch (e) {
        emit(OrderError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<BulkTrackOrdersRequested>((event, emit) async {
      emit(OrderLoading());
      try {
        final bulkData =
            await orderRepository.bulkTrackOrders(event.transactionIds);
        emit(BulkOrderTrackingLoaded(bulkData));
      } catch (e) {
        emit(OrderError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
