import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goshare_driver/common/app_text_field.dart';
import 'package:goshare_driver/features/money-topup/money-topup-controller.dart';
import 'package:goshare_driver/features/money-topup/web-view-page.dart';
import 'package:goshare_driver/models/transaction_model.dart';
import 'package:goshare_driver/theme/pallet.dart';
import 'package:intl/intl.dart';

class MoneyTopupPage extends ConsumerStatefulWidget {
  const MoneyTopupPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MoneyTopupPageState();
}

class TransactionCard extends StatelessWidget {
  final String? id;
  final String? tripId;
  final double? amount;
  final String? paymentMethod;
  final String? externalTransactionId;
  final String? status;
  final String? type;
  final DateTime? createTime;

  const TransactionCard(
      {Key? key,
      this.id,
      this.tripId,
      this.amount,
      this.paymentMethod,
      this.externalTransactionId,
      this.status,
      this.type,
      this.createTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final oCcy = NumberFormat("#,##0", "vi_VN");
    return GestureDetector(
      onTap: () => print('hehehheeehhehe'),
      child: Stack(children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '+${oCcy.format(amount)}đ',
                        style: TextStyle(
                            decoration: status == "FAILED"
                                ? TextDecoration.lineThrough
                                : null,
                            decorationThickness: 5,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: status == "SUCCESSFULL"
                                ? Colors.green[400]
                                : status == "FAILED"
                                    ? Colors.red[400]
                                    : Colors.grey[400]),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        DateFormat('HH:mm - dd/MM/yyyy').format(createTime!),
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 10.0,
          right: 10.0,
          child: Stack(
            children: [
              Text(
                status == "SUCCESSFULL"
                    ? "Thành công"
                    : status == "FAILED"
                        ? "Thất bại"
                        : "Đang xử lí",
              ) //
            ],
          ),
        ),
      ]),
    );
  }
}

class _MoneyTopupPageState extends ConsumerState<MoneyTopupPage> {
  final TextEditingController _topupAmountController = TextEditingController();
  double currentBalance = 0.0;
  bool _showTopupForm = false;
  final _scrollController = ScrollController();
  WalletTransactionModel? _walletTransactionModel;

  // final List<Contact> contacts = [
  //   Contact(
  //       name: 'John Doe',
  //       phoneNumber: '(123) 456-7890',
  //       avatarUrl: 'https://imgflip.com/s/meme/Cute-Cat.jpg',
  //       id: "d6ac0127-d60b-4c56-b31d-a667c940041e",
  //       tripId: null,
  //       amount: 100,
  //       paymentMethod: "VNPAY",
  //       externalTransactionId: null,
  //       status: "PENDING",
  //       type: "TOPUP",
  //       createTime: "2023-11-14T18:48:03.813334"),
  // ];

  // List<TransactionResult> _transactionList = [];
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMore();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await ref
          .read(MoneyTopupControllerProvider.notifier)
          .getBalance(context);
      setState(() {
        currentBalance = double.parse(result.balance!);
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // final transactionResult = await ref
      //     .read(MoneyTopupControllerProvider.notifier)
      //     .getTransaction(context);
      // // print("kjergherkuyrteku" + transactionResult);
      // setState(() {
      //   _transactionList = transactionResult;
      // });
      _loadMore();
    });
  }

  void _loadMore() async {
    if (_walletTransactionModel == null ||
        _walletTransactionModel!.hasNextPage) {
      int nextPage = (_walletTransactionModel?.page ?? 0) + 1;
      WalletTransactionModel? newPageData = await ref
          .watch(MoneyTopupControllerProvider.notifier)
          .getWalletTransaction('Topup', nextPage, 10, context);
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
  void dispose() {
    super.dispose();
    _topupAmountController.dispose();
  }

  void _onSubmit(WidgetRef ref) async {
    int topupAmount = int.parse(_topupAmountController.text);

    final result = await ref
        .read(MoneyTopupControllerProvider.notifier)
        .moneyTopup(topupAmount, context);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewPage(url: result),
        ),
      ).then((value) async {
        print('MAN HINH POP');
        final balanceResult = await ref
            .read(MoneyTopupControllerProvider.notifier)
            .getBalance(context);
        setState(() {
          currentBalance = double.parse(balanceResult.balance!);
          _walletTransactionModel = null;
          _loadMore();
        });
      });
    }
  }

  String _formatBalance(double balance) {
    int roundedBalance = balance.round();
    String balanceString = roundedBalance.toString();
    for (int i = balanceString.length - 3; i > 0; i -= 3) {
      balanceString = balanceString.replaceRange(i, i, '.');
    }
    return balanceString;
  }

  @override
  Widget build(BuildContext context) {
    final oCcy = NumberFormat("#,##0", "vi_VN");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ví của tôi'),
        automaticallyImplyLeading: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.green[400],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16.0),
                  const Text(
                    'Số dư hiện tại',
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    '${_formatBalance(currentBalance)}đ',
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Column(
              children: [
                GestureDetector(
                  onTap: () => {
                    setState(() {
                      _showTopupForm = !(_showTopupForm);
                    })
                  },
                  child: Container(
                    margin: const EdgeInsets.all(0.0),
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey.shade200,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/vnpay.png',
                          width: 32.0,
                          height: 25.0,
                          fit: BoxFit.fill,
                        ),
                        const SizedBox(width: 10.0),
                        const Text("Nạp tiền vào ví với VNPay"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                AnimatedOpacity(
                  opacity: _showTopupForm ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Visibility(
                    visible: _showTopupForm,
                    child: Column(
                      children: [
                        AppTextField(
                          prefixIcons: const Icon(Icons.money),
                          controller: _topupAmountController,
                          hintText: 'Nhập số tiền',
                          inputType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Số tiền không được trống';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            final topupAmount =
                                double.tryParse(_topupAmountController.text) ??
                                    0.0;
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Xác nhận nạp tiền'),
                                content: Text(
                                    'Bạn có chắc chắn muốn nạp ${oCcy.format(topupAmount)}đ vào ví của bạn không?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final topupAmount = double.tryParse(
                                              _topupAmountController.text) ??
                                          0.0;
                                      _onSubmit(ref);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Xác nhận'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Nạp tiền'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              "Lịch sử giao dịch",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _walletTransactionModel?.items.length ?? 0,
                itemBuilder: (context, index) {
                  final transaction = _walletTransactionModel?.items[index];
                  return transaction?.type == "TOPUP"
                      ? TransactionCard(
                          id: transaction?.id,
                          tripId: transaction?.tripId,
                          amount: transaction?.amount,
                          paymentMethod: transaction?.paymentMethod,
                          externalTransactionId:
                              transaction?.externalTransactionId,
                          status: transaction?.status,
                          type: transaction?.type,
                          createTime: transaction?.createTime,
                          // Add onTap or any other logic as needed
                        )
                      : const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Contact {
  final String name;
  final String phoneNumber;
  final String avatarUrl;

  final String? id;
  final String? tripId;
  final int? amount;
  final String? paymentMethod;
  final String? externalTransactionId;
  final String? status;
  final String? type;
  final String? createTime;

  Contact(
      {required this.name,
      required this.phoneNumber,
      required this.avatarUrl,
      required this.id,
      required this.tripId,
      required this.amount,
      required this.paymentMethod,
      required this.externalTransactionId,
      required this.status,
      required this.type,
      required this.createTime});
}
