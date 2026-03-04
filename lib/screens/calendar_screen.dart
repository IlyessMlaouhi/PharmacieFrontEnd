import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _weekStart = _getWeekStart(DateTime.now());

  static DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
      _selectedDay = _weekStart;
    });
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
      _selectedDay = _weekStart;
    });
  }

  // Dummy shifts — will come from API later
  // key = "yyyy-MM-dd", value = list of shifts for that day
  final Map<String, List<Map<String, String>>> _dummyShifts = {
    _todayKey(): [
      {'employee': 'Ahmed Ben Ali',    'start': '08:00', 'end': '16:00', 'occupation': 'PHARMACIST'},
      {'employee': 'Sara Meddeb',      'start': '14:00', 'end': '20:00', 'occupation': 'CASHIER'},
    ],
    _tomorrowKey(): [
      {'employee': 'Mohamed Trabelsi', 'start': '09:00', 'end': '17:00', 'occupation': 'STOCK_MANAGER'},
    ],
  };

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }

  static String _tomorrowKey() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return '${tomorrow.year}-${tomorrow.month.toString().padLeft(2,'0')}-${tomorrow.day.toString().padLeft(2,'0')}';
  }

  String _dayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
  }

  final List<String> _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  Color _occupationColor(String occ) {
    switch (occ) {
      case 'PHARMACIST':   return const Color(0xFF1565C0);
      case 'CASHIER':      return const Color(0xFF2E7D32);
      case 'STOCK_MANAGER': return const Color(0xFF6A1B9A);
      default:             return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shiftsForDay = _dummyShifts[_dayKey(_selectedDay)] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Column(
        children: [
          _buildWeekHeader(),
          _buildDayStrip(),
          const SizedBox(height: 8),
          // shifts list for selected day
          Expanded(
            child: shiftsForDay.isEmpty
                ? _buildEmptyDay()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: shiftsForDay.length,
              itemBuilder: (context, index) =>
                  _buildShiftCard(shiftsForDay[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: open add shift bottom sheet
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Shift'),
        backgroundColor: const Color(0xFF0A1F44),
        foregroundColor: Colors.white,
      ),
    );
  }

  // ─── WEEK NAVIGATION HEADER ───────────────────────────────────────────────
  Widget _buildWeekHeader() {
    final weekEnd = _weekStart.add(const Duration(days: 6));
    return Container(
      color: const Color(0xFF0A1F44),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: _previousWeek,
          ),
          Text(
            '${_monthNames[_weekStart.month]} ${_weekStart.day} – ${_monthNames[weekEnd.month]} ${weekEnd.day}, ${weekEnd.year}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: _nextWeek,
          ),
        ],
      ),
    );
  }

  // ─── 7-DAY STRIP ─────────────────────────────────────────────────────────
  Widget _buildDayStrip() {
    return Container(
      color: const Color(0xFF0A1F44),
      padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final day = _weekStart.add(Duration(days: i));
          final isSelected = _dayKey(day) == _dayKey(_selectedDay);
          final isToday = _dayKey(day) == _todayKey();
          final hasShifts = _dummyShifts.containsKey(_dayKey(day));

          return GestureDetector(
            onTap: () => setState(() => _selectedDay = day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    _dayLabels[i],
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? const Color(0xFF0A1F44)
                          : Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF0A1F44)
                          : isToday
                          ? Colors.amber
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // dot indicator if there are shifts that day
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasShifts
                          ? (isSelected ? const Color(0xFF0A1F44) : Colors.amber)
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── SHIFT CARD ───────────────────────────────────────────────────────────
  Widget _buildShiftCard(Map<String, String> shift) {
    final color = _occupationColor(shift['occupation']!);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // colored left bar — like a calendar event stripe
            Container(
              width: 4,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shift['employee']!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF0A1F44)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        '${shift['start']} – ${shift['end']}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // occupation chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                shift['occupation']!.replaceAll('_', ' '),
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onSelected: (value) {
                // TODO: handle edit / delete shift
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
      ),
    );
  }

  Widget _buildEmptyDay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No shifts for this day',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
          const SizedBox(height: 8),
          Text('Tap + to add a shift',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}