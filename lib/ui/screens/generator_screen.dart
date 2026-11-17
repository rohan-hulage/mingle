import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/reply.dart';
import '../../state/app_controller.dart';
import '../theme.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({
    super.key,
    required this.controller,
    this.initialMessage = '',
    this.initialTone,
  });

  final AppController controller;
  final String initialMessage;
  final String? initialTone;

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  late final TextEditingController _message;
  final _context = TextEditingController();
  late String _tone;
  late String _language;
  late String _length;

  @override
  void initState() {
    super.initState();
    _message = TextEditingController(text: widget.initialMessage);
    _tone = widget.initialTone ?? widget.controller.defaultTone;
    _language = widget.controller.preferredLanguage;
    _length = widget.controller.replyLength;
  }

  @override
  void dispose() {
    _message.dispose();
    _context.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_message.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a message or conversation first.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    try {
      final personalization = [
        if (widget.controller.personality.trim().isNotEmpty)
          'Personality preferences: ${widget.controller.personality.trim()}',
        if (widget.controller.communicationStyle.trim().isNotEmpty)
          'Communication style: ${widget.controller.communicationStyle.trim()}',
        if (_context.text.trim().isNotEmpty) _context.text.trim(),
      ].join('\n');
      await widget.controller.generate(
        ReplyRequest(
          message: _message.text.trim(),
          tone: _tone,
          language: _language,
          length: _length,
          context: personalization,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not generate replies: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reply studio'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
          children: [
            Text(
              'Let’s find your words.',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            Text(
              'Tell us what’s going on. We’ll give you three ways to reply.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            _FieldLabel('THE MESSAGE'),
            const SizedBox(height: 8),
            TextField(
              controller: _message,
              minLines: 4,
              maxLines: 7,
              maxLength: 2000,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Paste or type the message here…',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            _FieldLabel('THE VIBE'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppController.tones.map((tone) {
                final selected = _tone == tone;
                return ChoiceChip(
                  label: Text(tone),
                  selected: selected,
                  onSelected: (_) => setState(() => _tone = tone),
                  selectedColor: const Color(0xFFEDE6FB),
                  labelStyle: TextStyle(
                    color: selected
                        ? MingleTheme.purple
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 17),
            Row(
              children: [
                Expanded(
                  child: _DropdownSetting(
                    label: 'LENGTH',
                    value: _length,
                    options: AppController.lengths,
                    onChanged: (value) => setState(() => _length = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DropdownSetting(
                    label: 'LANGUAGE',
                    value: _language,
                    options: AppController.languages,
                    onChanged: (value) => setState(() => _language = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            _FieldLabel('A LITTLE MORE CONTEXT  ·  OPTIONAL'),
            const SizedBox(height: 8),
            TextField(
              controller: _context,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'What’s your relationship? What do you want to say?',
                counterText: '',
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: controller.isGenerating ? null : _generate,
                icon: controller.isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(
                  controller.isGenerating
                      ? 'Finding your words…'
                      : 'Generate replies',
                ),
              ),
            ),
            if (controller.replies.isNotEmpty) ...[
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pick what feels like you',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: controller.isGenerating ? null : _generate,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Again'),
                  ),
                ],
              ),
              if (controller.lastResultIsMock)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.offline_bolt_outlined,
                        size: 15,
                        color: MingleTheme.violet,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Sample replies · connect the API for AI suggestions',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              for (var index = 0; index < controller.replies.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: _ReplyCard(
                    index: index,
                    suggestion: controller.replies[index],
                    isFavorite: controller.isFavorite(
                      controller.replies[index].text,
                    ),
                    onCopy: () => _copy(controller.replies[index].text),
                    onFavorite: () => controller.toggleFavorite(
                      controller.replies[index].text,
                      _tone,
                    ),
                    onEdit: () => _editReply(controller.replies[index], index),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  Future<void> _editReply(ReplySuggestion suggestion, int index) async {
    final editor = TextEditingController(text: suggestion.text);
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make it yours'),
        content: TextField(
          controller: editor,
          minLines: 3,
          maxLines: 7,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Edit your reply'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, editor.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    editor.dispose();
    if (text == null || text.isEmpty || !mounted) return;
    widget.controller.updateReply(index, text);
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 1.05,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}

class _DropdownSetting extends StatelessWidget {
  const _DropdownSetting({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _FieldLabel(label),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 13, vertical: 4),
        ),
        items: options
            .map(
              (option) => DropdownMenuItem(value: option, child: Text(option)),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    ],
  );
}

class _ReplyCard extends StatelessWidget {
  const _ReplyCard({
    required this.index,
    required this.suggestion,
    required this.isFavorite,
    required this.onCopy,
    required this.onFavorite,
    required this.onEdit,
  });

  final int index;
  final ReplySuggestion suggestion;
  final bool isFavorite;
  final VoidCallback onCopy;
  final VoidCallback onFavorite;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 15, 11, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE6FB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  suggestion.approach,
                  style: const TextStyle(
                    color: MingleTheme.purple,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '0${index + 1}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            suggestion.text,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              IconButton(
                tooltip: 'Copy',
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded, size: 19),
              ),
              IconButton(
                tooltip: 'Edit',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 19),
              ),
              IconButton(
                tooltip: isFavorite ? 'Remove favorite' : 'Save favorite',
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 20,
                  color: isFavorite ? Colors.pinkAccent : null,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.north_east_rounded, size: 16),
                label: const Text('Use reply'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
