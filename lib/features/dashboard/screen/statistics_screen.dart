import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/features/dashboard/controllers/dash_board_controller.dart';
import 'package:goshare_driver/features/dashboard/widgets/transaction_list.dart';
import 'package:goshare_driver/models/statistic_model.dart';
import 'package:intl/intl.dart';

class StatisticScreen extends ConsumerStatefulWidget {
  const StatisticScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StatisticScreenState();
}

class _StatisticScreenState extends ConsumerState<StatisticScreen> {
  List<StatisticModel> list = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initStatistic();
    });
  }

  void initStatistic() async {
    list = await ref
        .watch(dashBoardControllerProvider.notifier)
        .getStatistic(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: list.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined),
            onPressed: () {
              context.pop();
            },
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: list.reversed
                .map(
                  (item) => Container(
                    width: MediaQuery.of(context).size.width /
                        4, // Set the width of each tab to one third of the screen width
                    child: Tab(
                      child: DefaultTextStyle(
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        child: Text('Tháng ${item.month}'),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          title: const Text('Thống kê thu nhập theo tháng'),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                // height: 170, // Set this to the height you want
                child: TabBarView(
                  children:
                      list.reversed.map((item) => IncomeDetails(item)).toList(),
                ),
              ),
            ),
            const Expanded(
              flex: 7,
              child: Column(
                children: [
                  Text(
                    'Lịch sử giao dịch',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: TransactionList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IncomeDetails extends StatelessWidget {
  final StatisticModel statisticModel;

  const IncomeDetails(this.statisticModel, {super.key});

  @override
  Widget build(BuildContext context) {
    final oCcy = NumberFormat("#,##0", "vi_VN");
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Tổng thu nhập: ${oCcy.format(statisticModel.monthTotal)}đ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              //color: Colors.grey,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Thu nhập trung bình mỗi tuần: ${oCcy.format(statisticModel.weekAverage)}đ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              //color: Colors.grey,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Chênh lệch so với tháng trước: ${(statisticModel.compareToLastMonth * 100).toStringAsFixed(2)}%',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              //color: Colors.grey,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
