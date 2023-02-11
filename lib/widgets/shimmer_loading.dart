

import 'package:flutter/material.dart';

class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(

      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 20,
                    width: MediaQuery.of(context).size.width / 1.6,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5))),
                const SizedBox(height: 5),
                Container(
                    height: 8,
                    width: MediaQuery.of(context).size.width / 5,
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(5))),
              ],
            )
          ],
        ),

        const SizedBox(height: 15,)
      ],
    );
  }
}
