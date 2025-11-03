// import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
// import 'package:flutter/material.dart';

// class AwesomeSnackBarExample extends StatelessWidget {
//   const AwesomeSnackBarExample({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,  
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   final snackBar = SnackBar(
//                     /// Set properties for optimal AwesomeSnackbarContent display
//                     elevation: 0,
//                     behavior: SnackBarBehavior.floating,
//                     backgroundColor: Colors.transparent,
//                     duration: const Duration(seconds: 3),
//                     content: AwesomeSnackbarContent(
//                       title: 'Oh Snap!',
//                       message:
//                           'This is an example error message that will be shown in the body of snackbar!',
//                       contentType: ContentType.failure,
//                     ),
//                     margin: const EdgeInsets.only(
//                       bottom: 300
//                     ),
//                   );

//                   ScaffoldMessenger.of(context)
//                     ..removeCurrentSnackBar()
//                     ..showSnackBar(snackBar);
//                 },
//                 child: const Text('Show Awesome SnackBar'),
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: () {
//                   final materialBanner = MaterialBanner(
//                     dividerColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
//                     elevation: 0,
//                     backgroundColor: Colors.transparent,
//                     forceActionsBelow: true,
//                     content: AwesomeSnackbarContent(
//                       title: 'Oh Hey!!',
//                       message:
//                           'This is an example error message that will be shown in the body of materialBanner!',
//                       contentType: ContentType.failure,
//                       inMaterialBanner: true,
//                     ),
//                     actions: const [SizedBox.shrink()],
//                   );

//                   ScaffoldMessenger.of(context)
//                     ..removeCurrentMaterialBanner()
//                     ..showMaterialBanner(materialBanner);
//                 },
//                 child: const Text('Show Awesome Material Banner'),
//               ),
//             ],  
//           ),
//         ),
//       ),
//     );
//   }
// }       

import 'package:flutter/material.dart';

/// ---------------------------------------------------------------
///  Beautiful Custom Dropdown
/// ---------------------------------------------------------------
class BeautifulDropdown<T> extends StatelessWidget {
  const BeautifulDropdown({
    super.key,
    required this.items,
    required this.onSelected,
    this.hint = 'Select an option',
    this.selectedValue,
    this.width = 220,
    this.height = 48,
    this.icon = Icons.arrow_drop_down,
    this.borderRadius = 16,
    this.elevation = 12,
  });

  /// List of items to show
  final List<DropdownEntry<T>> items;

  /// Called when an item is picked
  final ValueChanged<T> onSelected;

  /// Hint shown when nothing is selected
  final String hint;

  /// Current selected value (optional – controlled mode)
  final T? selectedValue;

  /// Width / height of the button
  final double width, height;

  /// Icon on the right side
  final IconData icon;

  /// Styling
  final double borderRadius;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = items.firstWhereOrNull((e) => e.value == selectedValue);

    return PopupMenuButton<T>(
      // ---- The button that opens the menu ----
      offset: Offset(0, height),
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      itemBuilder: (context) => items                                    
          .map(
            (e) => PopupMenuItem<T>(
              value: e.value,
              height: 44,
              child: _MenuItemWidget(entry: e, theme: theme),
            ),
          ) 
          .toList(),
      onSelected: onSelected,
                                
      // ---- Custom button UI ----
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.85),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 4),
              blurRadius: 12,
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
        child: Row( 
          children: [
            Expanded(
              child: Text(
                selected?.title ?? hint,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: selected == null
                      ? theme.hintColor
                      : theme.textTheme.bodyLarge!.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(icon, size: 20, color: theme.hintColor),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------
///  Data holder for each dropdown entry
/// ---------------------------------------------------------------
class DropdownEntry<T> {
  const DropdownEntry({
    required this.value,
    required this.title,
    this.leading,
    this.trailing,
  });
 
  final T value;
  final String title;
  final Widget? leading;
  final Widget? trailing;
}

/// ---------------------------------------------------------------
///  Fancy menu item (inside the popup)
/// ---------------------------------------------------------------
class _MenuItemWidget extends StatelessWidget {
  const _MenuItemWidget({
    required this.entry,
    required this.theme,
  });

  final DropdownEntry entry;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),     
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ 
          
            Text(
            entry.title, 
            style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------
///  Helper – find first entry with a matching value
/// ---------------------------------------------------------------
extension _ListX<T> on List<DropdownEntry<T>> {
  DropdownEntry<T>? firstWhereOrNull(bool Function(DropdownEntry<T>) test) {
    try {
      return firstWhere(test);
    } catch (_) {
      return null;
    }
  }
}

/// ---------------------------------------------------------------
///  Example usage (you can paste this in a new screen)
/// ---------------------------------------------------------------
class DropdownDemoScreen extends StatefulWidget {
  const DropdownDemoScreen({super.key});
  @override State<DropdownDemoScreen> createState() => _DropdownDemoScreenState();
}

class _DropdownDemoScreenState extends State<DropdownDemoScreen> {
  String? _selected;

  final _options = [
    DropdownEntry(value: 'apple', title: 'Apple', leading: const Icon(Icons.local_florist, size: 20)),
    DropdownEntry(value: 'banana', title: 'Banana', leading: const Icon(Icons.star, size: 20)),
    DropdownEntry(value: 'cherry', title: 'Cherry', leading: const Icon(Icons.favorite, size: 20)),
    DropdownEntry(
      value: 'dragon',
      title: 'Dragon Fruit',
      leading: const Icon(Icons.auto_awesome, size: 20),
      trailing: const Chip(label: Text('NEW'), backgroundColor: Colors.amber),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beautiful Dropdown Demo')),
      body: Center(
        child: BeautifulDropdown<String>(
          items: _options,
          selectedValue: _selected,
          hint: 'Choose a fruit',
          onSelected: (v) => setState(() => _selected = v),
        ),
      ),
    );
  }
}