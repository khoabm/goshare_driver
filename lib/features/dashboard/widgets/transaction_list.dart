import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goshare_driver/features/dashboard/controllers/dash_board_controller.dart';
import 'package:goshare_driver/models/transaction_model.dart';
import 'package:goshare_driver/theme/pallet.dart';
import 'package:intl/intl.dart';

class TransactionList extends ConsumerStatefulWidget {
  const TransactionList({super.key});

  @override
  ConsumerState createState() => _TransactionListState();
}

class _TransactionListState extends ConsumerState<TransactionList> {
  final _scrollController = ScrollController();
  WalletTransactionModel? _walletTransactionModel;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMore();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMore(); // Initial load
    });
    // Initial load
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMore() async {
    if (_walletTransactionModel == null ||
        _walletTransactionModel!.hasNextPage) {
      int nextPage = (_walletTransactionModel?.page ?? 0) + 1;
      WalletTransactionModel? newPageData = await ref
          .watch(dashBoardControllerProvider.notifier)
          .getWalletTransaction(nextPage, 10, context);
      if (_walletTransactionModel == null) {
        _walletTransactionModel = newPageData;
      } else {
        _walletTransactionModel!.items.addAll(newPageData!.items);
        //_walletTransactionModel = newPageData;
        _walletTransactionModel!.copyWith(hasNextPage: newPageData.hasNextPage);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final oCcy = NumberFormat("#,##0", "vi_VN");
    return ListView.builder(
      controller: _scrollController,
      itemCount: _walletTransactionModel?.items.length ?? 0,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: _walletTransactionModel!.items[index].type == "DRIVER_WAGE"
                ? const Icon(
                    IconData(0xe1d7, fontFamily: 'MaterialIcons'),
                    color: Pallete.primaryColor,
                  )
                : const Icon(
                    Icons.monetization_on,
                    color: Colors.yellow,
                  ), // replace with your actual icon
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _walletTransactionModel!.items[index].type == "DRIVER_WAGE"
                      ? 'Tiền thanh toán xe'
                      : "Tiền nạp vào ví",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  _walletTransactionModel!.items[index].paymentMethod ==
                          "WALLET"
                      ? 'Ví'
                      : _walletTransactionModel!.items[index].paymentMethod ==
                              "VNPAY"
                          ? 'Vnpay'
                          : 'Tiền mặt',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('HH:mm - dd/MM/yyyy').format(
                        _walletTransactionModel!.items[index].createTime,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      ' ${oCcy.format(_walletTransactionModel!.items[index].amount)}đ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
