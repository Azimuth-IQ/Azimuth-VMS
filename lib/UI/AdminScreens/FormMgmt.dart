import 'package:flutter/material.dart';
import 'package:azimuth_vms/Helpers/VolunteerFormHelperFirebase.dart';
import 'package:azimuth_vms/Helpers/SystemUserHelperFirebase.dart';
import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:azimuth_vms/Models/SystemUser.dart';

class FormMgmt extends StatefulWidget {
  const FormMgmt({super.key});

  @override
  State<FormMgmt> createState() => _FormMgmtState();
}

class _FormMgmtState extends State<FormMgmt> {
  final VolunteerFormHelperFirebase _formHelper = VolunteerFormHelperFirebase();
  final SystemUserHelperFirebase _userHelper = SystemUserHelperFirebase();
  List<VolunteerForm> _allForms = [];
  List<VolunteerForm> _filteredForms = [];
  bool _isLoading = false;
  String _searchQuery = '';
  VolunteerFormStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadForms();
  }

  Future<void> _loadForms() async {
    setState(() => _isLoading = true);
    try {
      final forms = await _formHelper.GetAllForms();
      setState(() {
        _allForms = forms;
        _filteredForms = forms;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading forms: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading forms: $e')));
      }
    }
  }

  void _filterForms() {
    setState(() {
      _filteredForms = _allForms.where((form) {
        // Filter by search query (name or phone)
        final matchesSearch =
            _searchQuery.isEmpty || (form.fullName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) || (form.mobileNumber?.contains(_searchQuery) ?? false);

        // Filter by status
        final matchesStatus = _selectedStatus == null || form.status == _selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  bool _hasDocument(String? path) {
    // Check if document path exists and is valid
    return path != null && path.isNotEmpty && path != 'null';
  }

  Future<void> _syncVolunteersWithForms() async {
    try {
      setState(() => _isLoading = true);

      // Get all forms
      final forms = await _formHelper.GetAllForms();

      // Get all system users
      final users = await _userHelper.GetAllSystemUsers();

      int updatedCount = 0;

      // For each volunteer user, attach their form if missing
      for (var user in users) {
        if (user.role == SystemUserRole.VOLUNTEER && user.volunteerForm == null) {
          // Find their form
          final form = forms.firstWhere(
            (f) => f.mobileNumber == user.phone,
            orElse: () => VolunteerForm(), // Empty form as fallback
          );

          if (form.mobileNumber != null) {
            user.volunteerForm = form;
            _userHelper.UpdateSystemUser(user);
            updatedCount++;
            print('Synced form for volunteer: ${user.name}');
          }
        }
      }

      setState(() => _isLoading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Synced $updatedCount volunteer(s) with their forms'), backgroundColor: Colors.green));
    } catch (e) {
      print('Error syncing volunteers: $e');
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Volunteer Forms Management'),
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.sync), tooltip: 'Sync Volunteers with Forms', onPressed: _syncVolunteersWithForms)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/admin-form-fill').then((_) => _loadForms());
        },
        icon: const Icon(Icons.add),
        label: const Text('New Form'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Field
                TextField(
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterForms();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone number...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 12),
                // Status Filter
                Row(
                  children: [
                    const Icon(Icons.filter_list, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text('Filter by status:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<VolunteerFormStatus?>(
                        initialValue: _selectedStatus,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Statuses')),
                          ...VolunteerFormStatus.values.map((status) {
                            return DropdownMenuItem(value: status, child: Text(_getStatusLabel(status)));
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedStatus = value);
                          _filterForms();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Forms List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredForms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(_searchQuery.isEmpty && _selectedStatus == null ? 'No forms yet' : 'No forms found', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Text('Create a new form to get started', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadForms,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredForms.length,
                      itemBuilder: (context, index) {
                        final form = _filteredForms[index];
                        return _buildFormCard(form);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(VolunteerForm form) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to form details or edit page
          Navigator.pushNamed(context, '/admin-form-fill', arguments: form).then((_) => _loadForms());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      form.fullName?.substring(0, 1).toUpperCase() ?? '?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and Phone
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(form.fullName ?? 'Unknown', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(form.mobileNumber ?? 'N/A', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(form.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getStatusColor(form.status).withOpacity(0.3)),
                    ),
                    child: DropdownButton<VolunteerFormStatus>(
                      value: form.status,
                      underline: const SizedBox(),
                      isDense: true,
                      icon: Icon(Icons.arrow_drop_down, color: _getStatusColor(form.status)),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _getStatusColor(form.status)),
                      items: VolunteerFormStatus.values.map((status) {
                        return DropdownMenuItem(value: status, child: Text(_getStatusLabel(status)));
                      }).toList(),
                      onChanged: (newStatus) {
                        if (newStatus != null) {
                          _updateFormStatus(form, newStatus);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Document Checklist
              Row(
                children: [
                  const Icon(Icons.assignment_turned_in, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text('Documents:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildDocumentChip('Photo', _hasDocument(form.photoPath)),
                        _buildDocumentChip('ID Front', _hasDocument(form.idFrontPath)),
                        _buildDocumentChip('ID Back', _hasDocument(form.idBackPath)),
                        _buildDocumentChip('Residence Front', _hasDocument(form.residenceFrontPath)),
                        _buildDocumentChip('Residence Back', _hasDocument(form.residenceBackPath)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Additional Info
              Row(
                children: [
                  if (form.formNumber != null) ...[
                    Icon(Icons.numbers, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('Form #${form.formNumber}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(width: 16),
                  ],
                  if (form.profession != null) ...[
                    Icon(Icons.work_outline, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(form.profession!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentChip(String label, bool exists) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: exists ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: exists ? Colors.green.shade200 : Colors.red.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(exists ? Icons.check_circle : Icons.cancel, size: 12, color: exists ? Colors.green.shade700 : Colors.red.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: exists ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(VolunteerFormStatus? status) {
    switch (status) {
      case VolunteerFormStatus.Sent:
        return 'Sent';
      case VolunteerFormStatus.Pending:
        return 'Pending';
      case VolunteerFormStatus.Approved1:
        return 'Approved 1';
      case VolunteerFormStatus.Rejected1:
        return 'Rejected 1';
      case VolunteerFormStatus.Approved2:
        return 'Approved 2';
      case VolunteerFormStatus.Rejected2:
        return 'Rejected 2';
      case VolunteerFormStatus.Completed:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(VolunteerFormStatus? status) {
    switch (status) {
      case VolunteerFormStatus.Sent:
        return Colors.blue;
      case VolunteerFormStatus.Pending:
        return Colors.orange;
      case VolunteerFormStatus.Approved1:
      case VolunteerFormStatus.Approved2:
        return Colors.green;
      case VolunteerFormStatus.Rejected1:
      case VolunteerFormStatus.Rejected2:
        return Colors.red;
      case VolunteerFormStatus.Completed:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateFormStatus(VolunteerForm form, VolunteerFormStatus newStatus) async {
    setState(() {
      form.status = newStatus;
    });
    _formHelper.UpdateForm(form);

    // When approved, create SystemUser with VOLUNTEER role
    if (newStatus == VolunteerFormStatus.Approved1 || newStatus == VolunteerFormStatus.Approved2) {
      try {
        // Check if user already exists
        final existingUser = await _userHelper.GetSystemUserByPhone(form.mobileNumber!);

        if (existingUser == null) {
          // Create new SystemUser with volunteerForm attached
          final systemUser = SystemUser(
            id: form.mobileNumber!,
            phone: form.mobileNumber!,
            name: form.fullName ?? 'Volunteer',
            role: SystemUserRole.VOLUNTEER,
            password: form.mobileNumber!, // Use phone as password
            volunteerForm: form, // Attach the approved volunteer form
          );

          _userHelper.CreateSystemUser(systemUser);
          print('SystemUser created for approved volunteer: ${form.mobileNumber}');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${_getStatusLabel(newStatus)} - Volunteer account created'), backgroundColor: Colors.green, duration: const Duration(seconds: 3)),
            );
          }
        } else {
          // Update existing user's volunteer form
          existingUser.volunteerForm = form;
          _userHelper.UpdateSystemUser(existingUser);
          print('SystemUser updated with form for: ${form.mobileNumber}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to ${_getStatusLabel(newStatus)}'), duration: const Duration(seconds: 2)));
          }
        }
      } catch (e) {
        print('Error creating SystemUser: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated but error creating account: $e'), backgroundColor: Colors.orange));
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to ${_getStatusLabel(newStatus)}'), duration: const Duration(seconds: 2)));
      }
    }
  }
}
