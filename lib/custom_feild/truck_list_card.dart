import 'package:flutter/material.dart';

import '../modal/user_vehicle_modal.dart';
import 'icon_with_text.dart';

class TruckListCard extends StatelessWidget {
  final Color backgroundColor;
  final UserVehicle vehicle;

  const TruckListCard({
    super.key,
    required this.backgroundColor,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                IconWithText(
                  text: vehicle.imeiNumber,
                  icon: Icons.confirmation_num_outlined,
                  fontsize: 10,
                  txtalign: TextAlign.left,
                ),
                IconWithText(
                  text: vehicle.gpsDeviceType,
                  icon: Icons.device_unknown,
                  fontsize: 10,
                  txtalign: TextAlign.left,
                ),
              ],
            ),
            IconWithText(
              text: vehicle.vehNumber,
              icon: Icons.fire_truck_outlined,
              fontsize: 10,
              txtalign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
