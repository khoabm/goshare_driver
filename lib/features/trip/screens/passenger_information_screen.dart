import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:goshare_driver/models/trip_model.dart';
import 'package:goshare_driver/providers/is_chat_on_provider.dart';
import 'package:goshare_driver/theme/pallet.dart';

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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Thông tin khách hàng'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            ref
                .watch(isPassengerInformationOnProvider.notifier)
                .setIsPassengerInformation(false);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 20.0,
            ),
            Center(
              child: CircleAvatar(
                radius: 50.0,
                backgroundImage: NetworkImage(
                  widget.trip?.passenger.avatarUrl ??
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
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              'Xe ${widget.trip?.cartype.capacity} chỗ',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
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
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            widget.trip?.distance.toString() ?? '1km',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
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
                          Text(
                            widget.trip?.paymentMethod == 0 ? 'Ví' : 'Tiền mặt',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.trip?.startLocation.address ?? 'Địa điểm đi',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                      size: 30,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 60, // Adjust the height as needed
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 8.0,
                      ),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                      ),
                      child: Text(
                        widget.trip?.endLocation.address ?? "Địa điểm đến",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 8.0,
                      ),
                      child: Text(
                        widget.trip?.note ?? 'Ghi chú',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
    );
  }
}
