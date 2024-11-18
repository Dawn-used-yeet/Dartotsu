import 'package:flutter/material.dart';

import '../../DataClass/Setting.dart';

class SettingItem extends StatelessWidget {
  final Setting setting;

  const SettingItem({super.key, required this.setting});

  @override
  Widget build(BuildContext context) { // setting item type: normal
    if (!setting.isVisible) return const SizedBox.shrink();

    return GestureDetector(
      onTap: setting.onClick,
      onLongPress: setting.onLongClick,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22.0, horizontal: 0.0),
        child: Row(
          children: [
            Icon(setting.icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 24.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(setting.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 6),
                  Text(setting.description,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          fontFamily: 'Poppins')),
                  if (setting.attach != null) setting.attach!(context),
                ],
              ),
            ),
            if (setting.isActivity)
              Icon(Icons.arrow_forward_ios,
                  color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }
}

class SettingSwitchItem extends StatelessWidget {
  final Setting setting;

  const SettingSwitchItem({super.key, required this.setting});

  @override
  Widget build(BuildContext context) { // setting item type: switch
    if (!setting.isVisible) return const SizedBox.shrink();

    return GestureDetector(
      onLongPress: setting.onLongClick,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22.0, horizontal: 0.0),
        child: Row(
          children: [
            Icon(setting.icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 24.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(setting.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              fontFamily: 'Poppins')),
                      Switch(
                        value: setting.isChecked,
                        onChanged: setting.onSwitchChange,
                      ),
                    ],
                  ),
                  Text(setting.description,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                          color: Colors.grey,
                          fontFamily: 'Poppins')),
                  if (setting.attach != null)
                    setting.attach!(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
