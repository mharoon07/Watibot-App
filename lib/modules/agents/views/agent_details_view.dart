import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:watibot/modules/agents/controllers/agents_controller.dart';
import 'package:watibot/modules/agents/models/agent_model.dart';

class AgentDetailsView extends GetView<AgentsController> {
  const AgentDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AgentModel agent = Get.arguments as AgentModel;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Agent Profile',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF00B074)),
            onPressed: () => _showEditDialog(context, agent),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Card Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF00B074).withValues(alpha: 0.12),
                    child: Text(
                      agent.name.isNotEmpty ? agent.name[0].toUpperCase() : 'A',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00B074),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    agent.name,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    agent.email,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBadge(
                        agent.status,
                        agent.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        agent.isActive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                      ),
                      const SizedBox(width: 8),
                      _buildBadge(
                        agent.role,
                        const Color(0xFF6366F1),
                        const Color(0xFFEEF2FF),
                      ),
                      if (agent.department != null) ...[
                        const SizedBox(width: 8),
                        _buildBadge(
                          agent.department!.name,
                          const Color(0xFFF59E0B),
                          const Color(0xFFFEF3C7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Performance & Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    'Assigned Contacts',
                    '${agent.assignedContactsCount ?? 0}',
                    Icons.people_outline,
                    const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile(
                    'Sent Messages',
                    '${agent.sentMessagesCount ?? 0}',
                    Icons.mark_email_read_outlined,
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Agent Meta Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Information',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow('Agent ID', agent.id, Icons.fingerprint),
                  _buildDetailRow('Phone', agent.phoneNumber ?? 'Not provided', Icons.phone_outlined),
                  _buildDetailRow(
                    'Created Date',
                    agent.createdAt != null
                        ? DateFormat('MMM dd, yyyy · hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(agent.createdAt!))
                        : 'N/A',
                    Icons.calendar_today_outlined,
                  ),
                  _buildDetailRow(
                    'Last Login',
                    agent.lastLoginAt != null
                        ? DateFormat('MMM dd, yyyy · hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(agent.lastLoginAt!))
                        : 'Never',
                    Icons.access_time_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Module Permissions Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Assigned Permissions',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showPermissionsDialog(context, agent),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Edit Permissions',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF00B074)),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 16),
                  if (agent.permissions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Default role permissions inherited (${agent.role})',
                        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), fontStyle: FontStyle.italic),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: agent.permissions.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
              overflow: TextOverflow.ellipsis,
            ),

          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, AgentModel agent) {
    final nameCtrl = TextEditingController(text: agent.name);
    final emailCtrl = TextEditingController(text: agent.email);
    final phoneCtrl = TextEditingController(text: agent.phoneNumber ?? '');
    String selectedRole = agent.role;
    String selectedStatus = agent.status;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Agent', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'USER', child: Text('Agent (USER)')),
                  DropdownMenuItem(value: 'ADMIN', child: Text('Admin (ADMIN)')),
                  DropdownMenuItem(value: 'GUEST', child: Text('Viewer (GUEST)')),
                ],
                onChanged: (val) {
                  if (val != null) selectedRole = val;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                  DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
                ],
                onChanged: (val) {
                  if (val != null) selectedStatus = val;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.updateAgent(
                agent.id,
                name: nameCtrl.text,
                email: emailCtrl.text,
                phone: phoneCtrl.text,
                role: selectedRole,
                status: selectedStatus,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B074)),
            child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPermissionsDialog(BuildContext context, AgentModel agent) {
    final Map<String, String> currentPerms = Map<String, String>.from(
      agent.permissions.map((k, v) => MapEntry(k, v.toString())),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Module Permissions for ${agent.name}',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure granular access levels per CRM module',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: ListView.separated(
                      itemCount: controller.permissionModules.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final mod = controller.permissionModules[index];
                        final currentLevel = currentPerms[mod.key] ?? 'full';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  mod.name,
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: DropdownButton<String>(
                                  value: currentLevel,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  items: mod.accessLevels.map((lvl) {
                                    return DropdownMenuItem(
                                      value: lvl,
                                      child: Text(
                                        lvl.toUpperCase(),
                                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setStateModal(() {
                                        currentPerms[mod.key] = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await controller.updateAgent(
                          agent.id,
                          permissions: currentPerms,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B074),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Save Permissions', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
