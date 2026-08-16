import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_care_plus/features/orders/data/order_model.dart';
import 'package:car_care_plus/features/orders/data/orders_repo.dart';
import 'package:car_care_plus/features/orders/logic/orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepo _repo;

  OrdersCubit(this._repo) : super(OrdersLoading());

  final List<OrderModel> _orders = [];

  Future<void> loadOrders() async {
    emit(OrdersLoading());
    try {
      final orders = await _repo.getOrders();
      _orders
        ..clear()
        ..addAll(orders);
      emit(OrdersLoaded(List.of(_orders)));
    } catch (e) {
      emit(OrdersError(_message(e)));
    }
  }

  /// تحديث صامت (بلا سبينر) — للاستطلاع الدوري بديلاً عن الإشعارات.
  Future<void> refreshSilently() async {
    try {
      final orders = await _repo.getOrders();
      _orders
        ..clear()
        ..addAll(orders);
      emit(OrdersLoaded(List.of(_orders)));
    } catch (_) {
      // نتجاهل — نُبقي القائمة الحالية.
    }
  }

  // assigned → in_progress
  Future<bool> startOrder(int id) =>
      _runAction(() => _repo.startOrder(id));

  // in_progress → completed
  Future<bool> completeOrder(int id) =>
      _runAction(() => _repo.completeOrder(id));

  /// تأكيد النقد بمعرّف الدفعة، ثم نعيد جلب الطلب لتحديث حالته/دفعاته.
  Future<bool> confirmCash({required int orderId, required int paymentId}) async {
    try {
      await _repo.confirmCash(paymentId);
      final refreshed = await _repo.getOrderDetails(orderId);
      _replace(refreshed);
      return true;
    } catch (_) {
      // نُبقي القائمة كما هي (لا نُفشل الشاشة) — الواجهة تعرض رسالة فشل.
      emit(OrdersLoaded(List.of(_orders)));
      return false;
    }
  }

  OrderModel? orderById(int id) {
    final index = _orders.indexWhere((o) => o.id == id);
    return index == -1 ? null : _orders[index];
  }

  /// يجلب تفاصيل الطلب الكاملة (بها payments والعلاقات) ويستبدل عنصر القائمة —
  /// لأن قائمة /bookings قد ترجع موديلاً مختصراً بلا payments.
  Future<void> loadOrderDetails(int id) async {
    try {
      final full = await _repo.getOrderDetails(id);
      _replace(full);
    } catch (_) {
      // نُبقي عنصر القائمة كما هو (تبقى الشاشة تعرض الملخّص).
    }
  }

  Future<bool> _runAction(Future<OrderModel> Function() call) async {
    try {
      final updated = await call();
      _replace(updated);
      return true;
    } catch (_) {
      emit(OrdersLoaded(List.of(_orders)));
      return false;
    }
  }

  void _replace(OrderModel order) {
    final index = _orders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      _orders[index] = order;
    } else {
      _orders.add(order);
    }
    emit(OrdersLoaded(List.of(_orders)));
  }

  String _message(Object e) => e.toString().replaceAll('Exception: ', '');
}
