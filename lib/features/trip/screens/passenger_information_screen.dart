import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:goshare_driver/models/trip_model.dart';
import 'package:goshare_driver/providers/is_chat_on_provider.dart';
import 'package:goshare_driver/theme/pallet.dart';
import 'package:intl/intl.dart';

class PassengerInformationScreen extends ConsumerStatefulWidget {
  final Trip? trip;
  const PassengerInformationScreen({
    this.trip,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PassengerInformationScreenState();
}

class _PassengerInformationScreenState
    extends ConsumerState<PassengerInformationScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final oCcy = NumberFormat("#,##0", "vi_VN");
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Thông tin khách hàng'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            context.pop();
            // ref
            //     .watch(isPassengerInformationOnProvider.notifier)
            //     .setIsPassengerInformation(false);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  Center(
                    child: CircleAvatar(
                      radius: 50.0,
                      backgroundImage: NetworkImage(
                        widget.trip?.booker.avatarUrl ??
                            'https://firebasestorage.googleapis.com/v0/b/goshare-bc3c4.appspot.com/o/7b0ae9e0-013b-4213-9e33-3321fda277b3%2F7b0ae9e0-013b-4213-9e33-3321fda277b3_avatar?alt=media',
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    widget.trip?.passenger.name ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  widget.trip?.type == 2
                      ? const Text(
                          'Chuyến đi này yêu cầu hình ảnh để đón khách và kết thúc chuyến',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    '${oCcy.format(widget.trip?.price)}đ',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[500],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      //padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[350],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    '${widget.trip?.distance.toString() ?? 1} km',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width: 1,
                                  color: Pallete.primaryColor,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    widget.trip?.paymentMethod == 0
                                        ? 'Ví'
                                        : 'Tiền mặt',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: [
                              Container(
                                // Adjust the height as needed
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 8.0,
                                ),
                                width: double.infinity,
                                child: Text(
                                  (widget.trip?.startLocation.address != null)
                                      ? 'Từ: ${widget.trip?.startLocation.address}'
                                      : 'Địa điểm đi',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                // Adjust the height as needed
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 8.0,
                                ),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[350],
                                ),
                                child: Text(
                                  widget.trip?.endLocation.address != null
                                      ? 'Đến: ${widget.trip?.endLocation.address}'
                                      : "Địa điểm đến",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 8.0,
                            ),
                            child: Text(
                              widget.trip?.note != null
                                  ? 'Ghi chú: ${widget.trip?.note}'
                                  : 'Ghi chú',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
