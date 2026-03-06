import 'package:flutter/material.dart';
import '../models/shift.dart';
import '../models/employee.dart';
import '../services/shift_service.dart';
import '../services/employee_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ShiftService _shiftService = ShiftService();
  final EmployeeService _employeeService = EmployeeService();

  DateTime _selectedDay = DateTime.now();
  DateTime _weekStart = _getWeekStart(DateTime.now());

  List<Shift> _allShifts = [];
  List<Employee> _employees = [];
  bool _isLoading = true;
  String? _error;

  bool _showTableView = false;

  static DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  String _dayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime get _weekEnd => _weekStart.add(const Duration(days: 6));

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final shifts = await _shiftService.getShiftsByDateRange(
        _dayKey(_weekStart), _dayKey(_weekEnd),
      );
      final employees = await _employeeService.getAllEmployees();
      setState(() {
        _allShifts = shifts;
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
      _selectedDay = _weekStart;
    });
    _loadData();
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
      _selectedDay = _weekStart;
    });
    _loadData();
  }

  List<Shift> get _shiftsForSelectedDay =>
      _allShifts.where((s) => s.date == _dayKey(_selectedDay)).toList();

  Map<String, List<Shift>> get _shiftsByDay {
    final Map<String, List<Shift>> map = {};
    for (final shift in _allShifts) {
      map.putIfAbsent(shift.date, () => []).add(shift);
    }
    return map;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  void _confirmDelete(Shift shift) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Shift'),
        content: Text(
            'Delete shift for ${shift.employeeName ?? 'this employee'} on ${shift.date}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _shiftService.deleteShift(shift.id!);
                _showSuccess('Shift deleted');
                _loadData();
              } catch (e) {
                _showError('Failed to delete shift');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openShiftForm({Shift? shift}) {
    if (_employees.isEmpty) {
      _showError('No employees found. Add employees first.');
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ShiftFormSheet(
        shift: shift,
        employees: _employees,
        selectedDate: _dayKey(_selectedDay),
        onSave: (s) async {
          try {
            if (shift == null) {
              await _shiftService.createShift(s);
              _showSuccess('Shift added');
            } else {
              await _shiftService.updateShift(shift.id!, s);
              _showSuccess('Shift updated');
            }
            _loadData();
          } catch (e) {
            _showError(e.toString());
          }
        },
      ),
    );
  }

  final List<String> _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  Color _occupationColor(String? occ) {
    switch (occ) {
      case 'PHARMACIST':    return const Color(0xFF1565C0);
      case 'CASHIER':       return const Color(0xFF2E7D32);
      case 'STOCK_MANAGER': return const Color(0xFF6A1B9A);
      default:              return const Color(0xFF0A1F44);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Column(
        children: [
          _buildWeekHeader(),
          if (!_showTableView) _buildDayStrip(),
          const SizedBox(height: 4),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0A1F44)))
                : _error != null
                ? _buildError()
                : _showTableView
                ? _buildTableView()
                : _buildListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openShiftForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Shift'),
        backgroundColor: const Color(0xFF0A1F44),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildWeekHeader() {
    return Container(
      color: const Color(0xFF0A1F44),
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: _previousWeek,
          ),
          Expanded(
            child: Text(
              '${_monthNames[_weekStart.month]} ${_weekStart.day} – ${_monthNames[_weekEnd.month]} ${_weekEnd.day}, ${_weekEnd.year}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: _nextWeek,
          ),
          IconButton(
            tooltip: _showTableView ? 'List view' : 'Table view',
            icon: Icon(
              _showTableView ? Icons.view_list : Icons.grid_view,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _showTableView = !_showTableView),
          ),
        ],
      ),
    );
  }

  Widget _buildDayStrip() {
    return Container(
      color: const Color(0xFF0A1F44),
      padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final day = _weekStart.add(Duration(days: i));
          final isSelected = _dayKey(day) == _dayKey(_selectedDay);
          final isToday = _dayKey(day) == _dayKey(DateTime.now());
          final hasShifts = _shiftsByDay.containsKey(_dayKey(day));

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
                  Text(_dayLabels[i],
                      style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? const Color(0xFF0A1F44) : Colors.white70,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('${day.day}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF0A1F44)
                              : isToday ? Colors.amber : Colors.white)),
                  const SizedBox(height: 4),
                  Container(
                    width: 5, height: 5,
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

  Widget _buildListView() {
    final shifts = _shiftsForSelectedDay;
    if (shifts.isEmpty) {
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
    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF0A1F44),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: shifts.length,
        itemBuilder: (_, i) => _buildShiftCard(shifts[i]),
      ),
    );
  }

  Widget _buildTableView() {
    if (_employees.isEmpty) {
      return const Center(child: Text('No employees found'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
          defaultColumnWidth: const FixedColumnWidth(110),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFF0A1F44)),
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('Employee',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                ...List.generate(7, (i) {
                  final day = _weekStart.add(Duration(days: i));
                  final isToday = _dayKey(day) == _dayKey(DateTime.now());
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(_dayLabels[i],
                            style: TextStyle(
                                color: isToday ? Colors.amber : Colors.white70,
                                fontSize: 11)),
                        Text('${day.day}',
                            style: TextStyle(
                                color: isToday ? Colors.amber : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ],
                    ),
                  );
                }),
              ],
            ),
            ..._employees.map((emp) {
              return TableRow(
                decoration: BoxDecoration(color: Colors.white,),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(emp.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Color(0xFF0A1F44))),
                  ),
                  ...List.generate(7, (i) {
                    final day = _weekStart.add(Duration(days: i));
                    final key = _dayKey(day);
                    final shiftsForCell = (_shiftsByDay[key] ?? [])
                        .where((s) => s.employeeId == emp.id)
                        .toList();

                    return Padding(
                      padding: const EdgeInsets.all(4),
                      child: shiftsForCell.isEmpty
                          ? Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      )
                          : Column(
                        children: shiftsForCell.map((s) => GestureDetector(
                          onLongPress: () => _confirmDelete(s),
                          onTap: () => _openShiftForm(shift: s),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            decoration: BoxDecoration(
                              color: _occupationColor(emp.occupation).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: _occupationColor(emp.occupation).withOpacity(0.4)),
                            ),
                            child: Text(
                              '${s.startDisplay}–${s.endDisplay}',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _occupationColor(emp.occupation)),
                            ),
                          ),
                        )).toList(),
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftCard(Shift shift) {
    final color = _occupationColor(null);
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
            Container(
              width: 4, height: 52,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shift.employeeName ?? 'Unknown',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF0A1F44))),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.access_time, size: 13, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text('${shift.startDisplay} – ${shift.endDisplay}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    if (shift.durationHours != null) ...[
                      const SizedBox(width: 8),
                      Text('(${shift.durationHours!.toStringAsFixed(1)}h)',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                    ]
                  ]),
                  if (shift.description != null && shift.description!.isNotEmpty)
                    Text(shift.description!,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onSelected: (value) {
                if (value == 'edit') _openShiftForm(shift: shift);
                if (value == 'delete') _confirmDelete(shift);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0A1F44)),
                      SizedBox(width: 10), Text('Edit'),
                    ])),
                const PopupMenuItem(value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 10), Text('Delete', style: TextStyle(color: Colors.red)),
                    ])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Could not reach server',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A1F44)),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}


class _ShiftFormSheet extends StatefulWidget {
  final Shift? shift;
  final List<Employee> employees;
  final String selectedDate;
  final Future<void> Function(Shift) onSave;

  const _ShiftFormSheet({
    this.shift,
    required this.employees,
    required this.selectedDate,
    required this.onSave,
  });

  @override
  State<_ShiftFormSheet> createState() => _ShiftFormSheetState();
}

class _ShiftFormSheetState extends State<_ShiftFormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late int _selectedEmployeeId;
  late TextEditingController _dateCtrl;
  late TextEditingController _startCtrl;
  late TextEditingController _endCtrl;
  late TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _selectedEmployeeId = widget.shift?.employeeId ?? widget.employees.first.id!;
    _dateCtrl  = TextEditingController(text: widget.shift?.date ?? widget.selectedDate);
    _startCtrl = TextEditingController(text: widget.shift?.startDisplay ?? '08:00');
    _endCtrl   = TextEditingController(text: widget.shift?.endDisplay ?? '16:00');
    _descCtrl  = TextEditingController(text: widget.shift?.description ?? '');
  }

  @override
  void dispose() {
    _dateCtrl.dispose(); _startCtrl.dispose();
    _endCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final parts = ctrl.text.split(':');
    final initial = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts[1]) ?? 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      ctrl.text =
      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateCtrl.text) ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF0A1F44)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dateCtrl.text =
      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final shift = Shift(
      employeeId: _selectedEmployeeId,
      date: _dateCtrl.text,
      startTime: '${_startCtrl.text}:00',
      endTime: '${_endCtrl.text}:00',
      description: _descCtrl.text.trim(),
    );
    await widget.onSave(shift);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.shift != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(isEdit ? 'Edit Shift' : 'New Shift',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A1F44))),
                const SizedBox(height: 20),

                DropdownButtonFormField<int>(
                  value: _selectedEmployeeId,
                  decoration: InputDecoration(
                    labelText: 'Employee',
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF0A1F44)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF0A1F44))),
                  ),
                  items: widget.employees.map((e) => DropdownMenuItem(
                    value: e.id,
                    child: Text(e.name),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedEmployeeId = v!),
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _dateCtrl,
                  readOnly: true,
                  onTap: _pickDate,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF0A1F44)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF0A1F44))),
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startCtrl,
                        readOnly: true,
                        onTap: () => _pickTime(_startCtrl),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                        decoration: InputDecoration(
                          labelText: 'Start',
                          prefixIcon: const Icon(Icons.access_time, color: Color(0xFF0A1F44)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF0A1F44))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _endCtrl,
                        readOnly: true,
                        onTap: () => _pickTime(_endCtrl),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                        decoration: InputDecoration(
                          labelText: 'End',
                          prefixIcon: const Icon(Icons.access_time_filled, color: Color(0xFF0A1F44)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF0A1F44))),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _descCtrl,
                  decoration: InputDecoration(
                    labelText: 'Note (optional)',
                    prefixIcon: const Icon(Icons.notes, color: Color(0xFF0A1F44)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF0A1F44))),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A1F44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : Text(isEdit ? 'Update Shift' : 'Add Shift',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}