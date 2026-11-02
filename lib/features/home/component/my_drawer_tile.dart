import 'package:flutter/material.dart';

class MyDrawerTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final void Function()? onTap;
  const MyDrawerTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  State<MyDrawerTile> createState() => _MyDrawerTileState();
}

class _MyDrawerTileState extends State<MyDrawerTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.title,
        style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
      ),
      leading: Icon(
        widget.icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: widget.onTap,
    );
  }
}
