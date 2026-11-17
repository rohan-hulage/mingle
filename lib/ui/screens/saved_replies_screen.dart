import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/reply.dart';
import '../../state/app_controller.dart';
import '../theme.dart';
import '../widgets/section_title.dart';
import 'generator_screen.dart';

class SavedRepliesScreen extends StatelessWidget {
  const SavedRepliesScreen({
    super.key,
    required this.controller,
    required this.showFavorites,
  });

  final AppController controller;
  final bool showFavorites;

  @override
  Widget build(BuildContext context) {
    final title = showFavorites ? 'Your saved replies' : 'A little history';
    return Scaffold(
      appBar: AppBar(title: Text(showFavorites ? 'Favorites' : 'History')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final entries = showFavorites
              ? controller.favorites
              : controller.history;
          if (!showFavorites && !controller.saveHistory) {
            return _EmptyCollection(
              icon: Icons.lock_outline_rounded,
              title: 'History is private by default',
              subtitle:
                  'Turn on saved history in Settings to keep generated replies on this device.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              SectionTitle(title),
              const SizedBox(height: 7),
              Text(
                showFavorites
                    ? 'The replies you want to keep close.'
                    : 'Only generated replies are saved. Your original messages are never stored.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 17),
              if (entries.isEmpty)
                _EmptyCollection(
                  icon: showFavorites
                      ? Icons.favorite_border_rounded
                      : Icons.chat_bubble_outline_rounded,
                  title: showFavorites
                      ? 'Nothing saved just yet'
                      : 'No replies yet',
                  subtitle: showFavorites
                      ? 'Tap the heart on a reply to save it here.'
                      : 'Replies you generate will show up here.',
                )
              else
                ...entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SavedReplyCard(
                      reply: entry,
                      isFavorite: showFavorites,
                      onDelete: () => showFavorites
                          ? controller.deleteFavorite(entry)
                          : controller.deleteHistory(entry),
                      onCopy: () async {
                        await Clipboard.setData(
                          ClipboardData(text: entry.text),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard')),
                        );
                      },
                      onOpen: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => GeneratorScreen(
                            controller: controller,
                            initialMessage: entry.text,
                            initialTone: entry.tone,
                          ),
                        ),
                      ),
                      onFavorite: showFavorites
                          ? null
                          : () => controller.toggleFavorite(
                              entry.text,
                              entry.tone,
                            ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SavedReplyCard extends StatelessWidget {
  const _SavedReplyCard({
    required this.reply,
    required this.isFavorite,
    required this.onDelete,
    required this.onCopy,
    required this.onOpen,
    this.onFavorite,
  });

  final SavedReply reply;
  final bool isFavorite;
  final VoidCallback onDelete;
  final VoidCallback onCopy;
  final VoidCallback onOpen;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
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
                  reply.tone,
                  style: const TextStyle(
                    color: MingleTheme.purple,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(reply.createdAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(reply.text, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 6),
          Row(
            children: [
              TextButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded, size: 17),
                label: const Text('Copy'),
              ),
              TextButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new_rounded, size: 17),
                label: const Text('Reopen'),
              ),
              const Spacer(),
              if (onFavorite != null)
                IconButton(
                  tooltip: 'Save favorite',
                  onPressed: onFavorite,
                  icon: const Icon(Icons.favorite_border_rounded),
                ),
              IconButton(
                tooltip: isFavorite ? 'Remove favorite' : 'Delete',
                onPressed: onDelete,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.delete_outline_rounded,
                  color: isFavorite ? Colors.pinkAccent : null,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(35, 44, 35, 44),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEDE6FB),
            ),
            child: Icon(icon, size: 32, color: MingleTheme.purple),
          ),
          const SizedBox(height: 17),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  );
}
