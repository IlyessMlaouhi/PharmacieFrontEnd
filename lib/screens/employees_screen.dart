import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final EmployeeService _service = EmployeeService();

  // like an Angular component property bound to *ngFor
  List<Employee> _employees = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEmployees(); // like ngOnInit calling this.employeeService.getAll()
  }

  Future<void> _loadEmployees() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final employees = await _service.getAllEmployees();
      setState(() { _employees = employees; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _deleteEmployee(int id) async {
    try {
      await _service.deleteEmployee(id);
      _loadEmployees(); // refresh list — like calling ngOnInit again
    } catch (e) {
      _showError('Failed to delete employee');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // opens the bottom sheet for add OR edit
  // like opening an Angular Material Dialog with optional data passed in
  void _openEmployeeForm({Employee? employee}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // lets the sheet grow with the keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EmployeeFormSheet(
        employee: employee,
        onSave: (emp) async {
          try {
            if (employee == null) {
              await _service.createEmployee(emp);
              _showSuccess('Employee added successfully');
            } else {
              await _service.updateEmployee(employee.id!, emp);
              _showSuccess('Employee updated successfully');
            }
            _loadEmployees();
          } catch (e) {
            _showError(e.toString());
          }
        },
      ),
    );
  }

  void _confirmDelete(Employee employee) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEmployee(employee.id!);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0A1F44)))
          : _error != null
          ? _buildError()
          : _employees.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
        onRefresh: _loadEmployees, // pull to refresh
        color: const Color(0xFF0A1F44),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _employees.length,
          itemBuilder: (context, index) {
            return _EmployeeCard(
              employee: _employees[index],
              onEdit: () => _openEmployeeForm(employee: _employees[index]),
              onDelete: () => _confirmDelete(_employees[index]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEmployeeForm(),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Employee'),
        backgroundColor: const Color(0xFF0A1F44),
        foregroundColor: Colors.white,
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
            onPressed: _loadEmployees,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A1F44)),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
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

// ─── EMPLOYEE CARD ─────────────────────────────────────────────────────────────

class _EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EmployeeCard({
    required this.employee,
    required this.onEdit,
    required this.onDelete,
  });

  Map<String, dynamic> _occupationStyle(String occupation) {
    switch (occupation) {
      case 'PHARMACIST':    return {'label': 'Pharmacist',    'color': const Color(0xFF1565C0)};
      case 'CASHIER':       return {'label': 'Cashier',       'color': const Color(0xFF2E7D32)};
      case 'STOCK_MANAGER': return {'label': 'Stock Manager', 'color': const Color(0xFF6A1B9A)};
      default:              return {'label': occupation,      'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _occupationStyle(employee.occupation);
    final initials = employee.name.split(' ').take(2)
        .map((w) => w[0]).join().toUpperCase();

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
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF0A1F44),
              child: Text(initials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(employee.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF0A1F44))),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (style['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(style['label'],
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: style['color'] as Color)),
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.mail_outline, size: 13, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(employee.email,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ]),
                ],
              ),
            ),
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
                  child: Text('${employee.weeklyHours.toInt()}h/week',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0A1F44))),
                ),
                const SizedBox(height: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
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
          ],
        ),
      ),
    );
  }
}

// ─── EMPLOYEE FORM BOTTOM SHEET ────────────────────────────────────────────────
// like an Angular reactive form inside a Material Dialog

class _EmployeeFormSheet extends StatefulWidget {
  final Employee? employee; // null = create, non-null = edit
  final Future<void> Function(Employee) onSave;

  const _EmployeeFormSheet({this.employee, required this.onSave});

  @override
  State<_EmployeeFormSheet> createState() => _EmployeeFormSheetState();
}

class _EmployeeFormSheetState extends State<_EmployeeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // like FormControl in Angular reactive forms
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _hoursCtrl;
  String _selectedOccupation = 'PHARMACIST';

  final List<String> _occupations = ['PHARMACIST', 'CASHIER', 'STOCK_MANAGER'];

  @override
  void initState() {
    super.initState();
    // pre-fill if editing — like patchValue() in Angular
    _nameCtrl  = TextEditingController(text: widget.employee?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.employee?.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.employee?.phone ?? '');
    _hoursCtrl = TextEditingController(
        text: widget.employee?.weeklyHours.toInt().toString() ?? '');
    _selectedOccupation = widget.employee?.occupation ?? 'PHARMACIST';
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _hoursCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final emp = Employee(
      name: _nameCtrl.text.trim(),
      occupation: _selectedOccupation,
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      weeklyHours: double.parse(_hoursCtrl.text.trim()));
    await widget.onSave(emp);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.employee != null;
    return Padding(
      // pushes the form up when keyboard appears — like CSS position sticky
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
                // handle bar
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(isEdit ? 'Edit Employee' : 'New Employee',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A1F44))),
                const SizedBox(height: 20),

                _buildField(_nameCtrl,  'Full Name',     Icons.person_outline,  validator: (v) => v!.isEmpty ? 'Required' : null),
                _buildField(_emailCtrl, 'Email',         Icons.mail_outline,    keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Required' : null),
                _buildField(_phoneCtrl, 'Phone',         Icons.phone_outlined,  keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Required' : null),
                _buildField(_hoursCtrl, 'Weekly Hours',  Icons.schedule_outlined, keyboardType: TextInputType.number, validator: (v) {
                  if (v!.isEmpty) return 'Required';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0 || n > 60) return 'Enter a valid number (1-60)';
                  return null;
                }),

                // occupation dropdown
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: _selectedOccupation,
                  decoration: InputDecoration(
                    labelText: 'Occupation',
                    prefixIcon: const Icon(Icons.work_outline, color: Color(0xFF0A1F44)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF0A1F44))),
                  ),
                  items: _occupations.map((occ) => DropdownMenuItem(
                    value: occ,
                    child: Text(occ.replaceAll('_', ' ')),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedOccupation = v!),
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
                        : Text(isEdit ? 'Update Employee' : 'Add Employee',
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
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

  Widget _buildField(
      TextEditingController ctrl,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF0A1F44)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF0A1F44))),
        ),
      ),
    );
  }
}