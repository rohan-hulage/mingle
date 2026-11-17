import 'package:flutter/material.dart';

import '../../state/app_controller.dart';
import '../theme.dart';
import '../widgets/brand_mark.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _personality;
  late final TextEditingController _style;

  @override
  void initState() {
    super.initState();
    _personality = TextEditingController(text: widget.controller.personality);
    _style = TextEditingController(text: widget.controller.communicationStyle);
  }

  @override
  void dispose() {
    _personality.dispose();
    _style.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [MingleTheme.purple, MingleTheme.violet],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(23),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Mingle',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Make every conversation flow.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.edit_outlined,
                    color: Colors.white70,
                    size: 19,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _GroupTitle('PERSONALIZE YOUR REPLIES'),
            const SizedBox(height: 10),
            _SettingsCard(
              children: [
                _DropdownRow(
                  icon: Icons.translate_rounded,
                  title: 'Preferred language',
                  value: controller.preferredLanguage,
                  options: AppController.languages,
                  onChanged: controller.setLanguage,
                ),
                const Divider(height: 1, indent: 54),
                _DropdownRow(
                  icon: Icons.mood_rounded,
                  title: 'Default tone',
                  value: controller.defaultTone,
                  options: AppController.tones,
                  onChanged: controller.setTone,
                ),
                const Divider(height: 1, indent: 54),
                _DropdownRow(
                  icon: Icons.short_text_rounded,
                  title: 'Reply length',
                  value: controller.replyLength,
                  options: AppController.lengths,
                  onChanged: controller.setLength,
                ),
                const Divider(height: 1, indent: 54),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _personality,
                        maxLength: 160,
                        decoration: const InputDecoration(
                          labelText: 'Personality preferences',
                          hintText: 'e.g. Warm, direct, a little playful',
                          counterText: '',
                        ),
                        onChanged: controller.setPersonality,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _style,
                        maxLength: 160,
                        decoration: const InputDecoration(
                          labelText: 'Communication style',
                          hintText: 'e.g. Keep it natural and concise',
                          counterText: '',
                        ),
                        onChanged: controller.setCommunicationStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 23),
            _GroupTitle('APP PREFERENCES'),
            const SizedBox(height: 10),
            _SettingsCard(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark appearance'),
                  subtitle: const Text('A little easier on the eyes'),
                  value: controller.darkMode,
                  onChanged: controller.setDarkMode,
                ),
                const Divider(height: 1, indent: 54),
                SwitchListTile(
                  secondary: const Icon(Icons.history_rounded),
                  title: const Text('Save reply history'),
                  subtitle: const Text(
                    'Off by default. Only generated replies are kept on this device.',
                  ),
                  value: controller.saveHistory,
                  onChanged: controller.setSaveHistory,
                ),
              ],
            ),
            const SizedBox(height: 23),
            _GroupTitle('PRIVACY & ABOUT'),
            const SizedBox(height: 10),
            _SettingsCard(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy'),
                  subtitle: const Text(
                    'Messages are sent only when you request suggestions.',
                  ),
                  onTap: () => _showPrivacy(context),
                ),
                const Divider(height: 1, indent: 54),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('About Mingle'),
                  subtitle: const Text(
                    'Version 1.0.0 · Make every conversation flow.',
                  ),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Mingle',
                    applicationVersion: '1.0.0',
                    applicationIcon: const BrandMark(
                      size: 42,
                      showWordmark: false,
                    ),
                    applicationLegalese:
                        'AI-assisted replies for conversations that sound like you.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Your voice. Your choice. Always.',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your privacy matters'),
        content: const Text(
          'Mingle never reads conversations from other apps and never sends messages for you. The text you submit is sent to the configured reply service only when you tap Generate. Conversation prompts are not saved to device history. Favorites are saved locally; generated-reply history is optional and off by default. Configure a trusted backend before sharing sensitive content.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      letterSpacing: 1.2,
      fontWeight: FontWeight.w800,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(child: Column(children: children));
}

class _DropdownRow extends StatelessWidget {
  const _DropdownRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    trailing: DropdownButton<String>(
      value: value,
      underline: const SizedBox.shrink(),
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    ),
  );
}
