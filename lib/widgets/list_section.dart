import 'package:flutter/material.dart';

/// List section: header + 3x3 grid (first is CTA, rest are existing lists)
class ListSection extends StatelessWidget {
  const ListSection({super.key, required this.accent, this.height});

  final Color accent;
  final double? height;

  // Sample list data
  final List<Map<String, dynamic>> _lists = const [
    {'name': 'Weekly Groceries', 'items': '12 of 20', 'progress': 0.6, 'time': '2H AGO', 'icon': Icons.shopping_cart_outlined},
    {'name': 'Party Supplies', 'items': '5 of 15', 'progress': 0.33, 'time': '5H AGO', 'icon': Icons.celebration_outlined},
    {'name': 'Breakfast Items', 'items': '8 of 10', 'progress': 0.8, 'time': '1D AGO', 'icon': Icons.breakfast_dining_outlined},
    {'name': 'Cleaning', 'items': '3 of 8', 'progress': 0.37, 'time': '2D AGO', 'icon': Icons.cleaning_services_outlined},
    {'name': 'Healthy Snacks', 'items': '10 of 12', 'progress': 0.83, 'time': '3H AGO', 'icon': Icons.apple_outlined},
    {'name': 'Monthly Stock', 'items': '15 of 30', 'progress': 0.5, 'time': '4H AGO', 'icon': Icons.inventory_2_outlined},
    {'name': 'Baby Care', 'items': '6 of 10', 'progress': 0.6, 'time': '1D AGO', 'icon': Icons.child_care_outlined},
    {'name': 'Pet Supplies', 'items': '4 of 7', 'progress': 0.57, 'time': '6H AGO', 'icon': Icons.pets_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Lists', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              TextButton(onPressed: () {}, child: Text('View All', style: TextStyle(color: accent))),
            ],
          ),

          const SizedBox(height: 8),

          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 1.05,
              ),
              itemCount: 9, // 1 CTA + 8 lists
              itemBuilder: (context, index) {
                if (index == 0) {
                  // First item: CTA to create new list
                  return _buildCreateListCard();
                } else {
                  // Rest: existing lists
                  return _buildListCard(context, _lists[index - 1], theme);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateListCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1.6),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, size: 20, color: Colors.grey),
          SizedBox(height: 3),
          Text(
            'Create\nNew List',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 9, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(BuildContext context, Map<String, dynamic> list, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Due date in same row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 107, 95, 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(list['icon'], color: accent, size: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  list['time'],
                  style: const TextStyle(fontSize: 8, color: Colors.black54, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Title
          Text(
            list['name'],
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          // Number of items
          Text(
            '${list['items']} items',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 9, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 3.5,
              child: LinearProgressIndicator(
                value: list['progress'],
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(accent),
              ),
            ),
          ),
          const SizedBox(height: 3),
        ],
      ),
    );
  }
}
