import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NotificationItemCard extends StatelessWidget {
  const NotificationItemCard({
    super.key,
    required this.isDarkMode,
    required this.theme,
    required this.firstName,
    required this.surname,
    required this.email,
    required this.image,
    this.showTrailing = false,
    this.onTrailingPressed,
  });

  final bool isDarkMode;
  final ThemeData theme;
  final String? firstName;
  final String? surname;
  final String? email;
  final String? image;
  final bool showTrailing;
  final VoidCallback? onTrailingPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: ListTile(
            title: Text(
              '$firstName $surname',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            subtitle: Text(
              email ?? 'No email provided',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            trailing: showTrailing
                ? GestureDetector(
                    onTap: onTrailingPressed,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Center(
                          child: Icon(Iconsax.edit),
                        ),
                      ),
                    ),
                  )
                : null,
            leading: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blueAccent,
                image: image != null && image!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(image!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
