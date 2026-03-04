import 'package:flutter/material.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  // Dummy data — same idea as a hardcoded array in an Angular component
  // before you wire up the HTTP service
  static const List<Map<String, String>> _dummyEmployees = [
    {'name': 'Ahmed Ben Ali',    'occupation': 'PHARMACIST',    'email': 'ahmed@pharma.com',   'hours': '35'},
    {'name': 'Sara Meddeb',      'occupation': 'CASHIER',        'email': 'sara@pharma.com',    'hours': '20'},
    {'name': 'Mohamed Trabelsi', 'occupation': 'STOCK_MANAGER',  'email': 'med@pharma.com',     'hours': '40'},
    {'name': 'Lina Gharbi',      'occupation': 'PHARMACIST',    'email': 'lina@pharma.com',    'hours': '35'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: _dummyEmployees.isEmpty
          ? _buildEmpty()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _dummyEmployees.length,
        itemBuilder: (context, index) {
          return _EmployeeCard(employee: _dummyEmployees[index]);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: open add employee bottom sheet
        },
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Employee'),
        backgroundColor: const Color(0xFF0A1F44),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No employees yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text('Tap + to add your first employee',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}

// ─── EMPLOYEE CARD ────────────────────────────────────────────────────────────
// Think of this as a child Angular component  <app-employee-card [employee]="e">
// It receives one employee map and renders the card UI

class _EmployeeCard extends StatelessWidget {
  final Map<String, String> employee;
  const _EmployeeCard({required this.employee});

  // map occupation string to a readable label + color
  Map<String, dynamic> _occupationStyle(String occupation) {
    switch (occupation) {
      case 'PHARMACIST':
        return {'label': 'Pharmacist', 'color': const Color(0xFF1565C0)};
      case 'CASHIER':
        return {'label': 'Cashier', 'color': const Color(0xFF2E7D32)};
      case 'STOCK_MANAGER':
        return {'label': 'Stock Manager', 'color': const Color(0xFF6A1B9A)};
      default:
        return {'label': occupation, 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _occupationStyle(employee['occupation']!);
    final initials = employee['name']!
        .split(' ')
        .take(2)
        .map((w) => w[0])
        .join()
        .toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // avatar circle with initials
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF0A1F44),
              child: Text(
                initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            const SizedBox(width: 14),

            // name + occupation badge + email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee['name']!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF0A1F44)),
                  ),
                  const SizedBox(height: 4),
                  // occupation badge — like an Angular ngClass chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (style['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      style['label'],
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: style['color'] as Color),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.mail_outline, size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(employee['email']!,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),

            // hours badge + action menu
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    '${employee['hours']}h/week',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0A1F44)),
                  ),
                ),
                const SizedBox(height: 8),
                // 3-dot menu — edit / delete
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onSelected: (value) {
                    // TODO: handle edit / delete
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0A1F44)),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}