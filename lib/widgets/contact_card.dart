import 'package:material_ui/material_ui.dart';

import '../app_theme.dart';
import '../models/contact.dart';
import 'contact_photo.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({super.key, required this.contact, required this.onDelete});

  final Contact contact;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ColoredBox(
        color: AppTheme.cream,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ContactPhoto(bytes: contact.photo),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cream,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          contact.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.navy,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _detail(Icons.mail_outline_rounded, contact.email),
                  const SizedBox(height: 9),
                  _detail(Icons.phone_outlined, contact.phone),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: onDelete,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      backgroundColor: AppTheme.red,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.red.withValues(
                        alpha: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    label: const Text('Delete', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _detail(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 18, color: AppTheme.navy),
      const SizedBox(width: 6),
      Expanded(
        child: Tooltip(
          message: text,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.navy, fontSize: 12),
          ),
        ),
      ),
    ],
  );
}
