import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/themes.dart';

class LoadingShimmer extends StatelessWidget {
  final bool isList;
  final double height;

  const LoadingShimmer({super.key, this.isList = true, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colors.surface2,
      highlightColor: context.colors.surface3,
      child: isList
          ? ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: 4,
              itemBuilder: (context, index) => Container(
                height: height,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: context.colors.surface2,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            )
          : Container(
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: context.colors.surface2,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
    );
  }
}
