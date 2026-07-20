import 'package:flutter/material.dart';

class LoadingCampaign extends StatelessWidget {
  const LoadingCampaign({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 80, height: 14, color: const Color(0xFFF1F5F9)),
                  Container(width: 20, height: 14, color: const Color(0xFFF1F5F9)),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Container(width: 200, height: 20, color: const Color(0xFFE2E8F0)),
              const SizedBox(height: 16),
              // Meta row
              Row(
                children: [
                  Container(width: 60, height: 12, color: const Color(0xFFF1F5F9)),
                  const SizedBox(width: 24),
                  Container(width: 60, height: 12, color: const Color(0xFFF1F5F9)),
                ],
              ),
              const SizedBox(height: 16),
              // Stats row
              Row(
                children: [
                  Container(width: 50, height: 32, color: const Color(0xFFF1F5F9)),
                  const SizedBox(width: 24),
                  Container(width: 50, height: 32, color: const Color(0xFFF1F5F9)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
