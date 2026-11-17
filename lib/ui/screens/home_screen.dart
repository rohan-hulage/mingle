import 'package:flutter/material.dart';

import '../../state/app_controller.dart';
import '../theme.dart';
import '../widgets/brand_mark.dart';
import '../widgets/section_title.dart';
import 'generator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _message = TextEditingController();
  String _tone = 'Friendly';

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _openGenerator({String? prompt}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GeneratorScreen(
          controller: widget.controller,
          initialMessage: prompt ?? _message.text,
          initialTone: _tone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  const BrandMark(size: 38),
                  const Spacer(),
                  IconButton.filledTonal(
                    tooltip: 'Keyboard setup',
                    onPressed: _showKeyboardInfo,
                    icon: const Icon(Icons.keyboard_alt_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 27),
              Text(
                'A better way to\nsay it.',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Find your words. Keep your voice.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 25),
              _ComposeCard(
                message: _message,
                tone: _tone,
                onToneChanged: (tone) => setState(() => _tone = tone),
                onGenerate: () => _openGenerator(),
              ),
              const SizedBox(height: 25),
              SectionTitle(
                'Try a conversation starter',
                trailing: const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: MingleTheme.violet,
                ),
              ),
              const SizedBox(height: 12),
              _StarterTile(
                text: '“What’s something you’re looking forward to?”',
                icon: Icons.wb_sunny_outlined,
                onTap: () => _openGenerator(
                  prompt: 'What’s something you’re looking forward to?',
                ),
              ),
              const SizedBox(height: 9),
              _StarterTile(
                text: '“I had a really good time yesterday…”',
                icon: Icons.favorite_border_rounded,
                onTap: () => _openGenerator(
                  prompt: 'I had a really good time yesterday…',
                ),
              ),
              const SizedBox(height: 23),
              SectionTitle(
                'Your recent replies',
                trailing: Text(
                  widget.controller.saveHistory
                      ? '${widget.controller.history.length} saved'
                      : 'History off',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (!widget.controller.saveHistory)
                _RecentHint(
                  icon: Icons.lock_outline_rounded,
                  text:
                      'History is off. Turn it on in Settings to save replies.',
                )
              else if (widget.controller.history.isEmpty)
                const _RecentHint(
                  icon: Icons.chat_bubble_outline_rounded,
                  text: 'Your generated replies will appear here.',
                )
              else
                ...widget.controller.history
                    .take(2)
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: _StarterTile(
                          text: entry.text,
                          icon: Icons.chat_bubble_outline_rounded,
                          onTap: () => _openGenerator(prompt: entry.text),
                        ),
                      ),
                    ),
            ]),
          ),
        ),
      ],
    ),
  );

  void _showKeyboardInfo() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mingle keyboard',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Text(
              'Keyboard extensions are a separate native setup. They can only work with text you choose to type or insert; Mingle never reads conversations in other apps or sends messages for you.',
            ),
            const SizedBox(height: 12),
            Text(
              'Android keyboards are enabled in system settings. iPhone keyboards require adding a separate extension in Xcode and enabling it in Settings. The in-app reply composer is ready to use now.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposeCard extends StatelessWidget {
  const _ComposeCard({
    required this.message,
    required this.tone,
    required this.onToneChanged,
    required this.onGenerate,
  });

  final TextEditingController message;
  final String tone;
  final ValueChanged<String> onToneChanged;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: MingleTheme.ink.withValues(alpha: .045),
          blurRadius: 22,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.mark_chat_unread_outlined, size: 19),
            const SizedBox(width: 8),
            Text(
              'What did they say?',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 13),
        TextField(
          controller: message,
          minLines: 3,
          maxLines: 5,
          maxLength: 2000,
          decoration: const InputDecoration(
            hintText: 'Paste a message or describe the conversation…',
            counterText: '',
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 14),
        Text(
          'PICK YOUR VIBE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.15,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: ['Friendly', 'Funny', 'Flirty', 'Professional']
              .map(
                (option) => ChoiceChip(
                  label: Text(option),
                  selected: tone == option,
                  onSelected: (_) => onToneChanged(option),
                  selectedColor: const Color(0xFFEDE6FB),
                  labelStyle: TextStyle(
                    color: tone == option
                        ? MingleTheme.purple
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 17),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onGenerate,
            icon: const Icon(Icons.auto_awesome_rounded, size: 19),
            label: const Text('Generate a reply'),
          ),
        ),
        const SizedBox(height: 9),
        Center(
          child: Text(
            'You review every suggestion before using it.',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}

class _StarterTile extends StatelessWidget {
  const _StarterTile({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, size: 19, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 7),
            const Icon(Icons.arrow_forward_rounded, size: 17),
          ],
        ),
      ),
    ),
  );
}

class _RecentHint extends StatelessWidget {
  const _RecentHint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(17),
    ),
    child: Row(
      children: [
        Icon(icon, size: 19, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 11),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    ),
  );
}
