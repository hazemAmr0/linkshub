import 'package:flutter/material.dart';
import '../models/link_model.dart';
import '../services/database_service.dart';
import '../utils/social_icons.dart';

class AddEditLinkScreen extends StatefulWidget {
  final LinkModel? link;
  final int? index;

  const AddEditLinkScreen({
    super.key,
    this.link,
    this.index,
  });

  @override
  State<AddEditLinkScreen> createState() => _AddEditLinkScreenState();
}

class _AddEditLinkScreenState extends State<AddEditLinkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _noteController = TextEditingController();
  
  SocialPlatform _selectedPlatform = SocialPlatform.website;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.link != null) {
      _titleController.text = widget.link!.title;
      _urlController.text = widget.link!.url;
      _noteController.text = widget.link!.note ?? '';
      _selectedPlatform = SocialPlatform.values.firstWhere(
        (platform) => platform.name == widget.link!.iconType,
        orElse: () => SocialPlatform.website,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.link != null;

  Future<void> _saveLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final link = LinkModel(
        title: _titleController.text.trim(),
        url: _urlController.text.trim(),
        iconType: _selectedPlatform.name,
        createdAt: _isEditing ? widget.link!.createdAt : now,
        updatedAt: now,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      if (_isEditing) {
        await DatabaseService.updateLink(widget.index!, link);
      } else {
        await DatabaseService.addLink(link);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Link updated successfully' : 'Link added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Link' : 'Add New Link'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.preview),
              onPressed: _showPreview,
              tooltip: 'Preview',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview Card
              _buildPreviewCard(),
              
              const SizedBox(height: 32),
              
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter link title',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              
              const SizedBox(height: 16),
              
              // URL Field
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'URL/Text',
                  hintText: 'Enter URL or any text',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter URL or text';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              
              const SizedBox(height: 16),
              
              // Note Field
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  hintText: 'Add a note to explain what this link is about',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                onChanged: (value) => setState(() {}),
              ),
              
              const SizedBox(height: 24),
              
              // Platform Selection
              Text(
                'Select Platform',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 12),
              
              _buildPlatformSelector(),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEditing ? 'Update Link' : 'Add Link',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final iconData = SocialIcons.getIcon(_selectedPlatform);
    final title = _titleController.text.trim().isEmpty 
        ? 'Link Title' 
        : _titleController.text.trim();
    final url = _urlController.text.trim().isEmpty 
        ? 'https://example.com' 
        : _urlController.text.trim();
    final note = _noteController.text.trim();

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              iconData.color.withOpacity(0.1),
              iconData.color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preview',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconData.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      iconData.icon,
                      color: iconData.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          url,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[400],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (note.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              note,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[300],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformSelector() {
    return Container(
      height: 120,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: SocialPlatform.values.length,
        itemBuilder: (context, index) {
          final platform = SocialPlatform.values[index];
          final iconData = SocialIcons.getIcon(platform);
          final isSelected = _selectedPlatform == platform;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedPlatform = platform;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected 
                    ? iconData.color.withOpacity(0.2)
                    : Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? iconData.color : Colors.grey[700]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconData.icon,
                    color: iconData.color,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    iconData.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? iconData.color : Colors.grey[400],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPreview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Preview'),
        content: _buildPreviewCard(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
