import 'package:flutter/material.dart';

Future<int?> showMinutesSelector(
    {required String title, required BuildContext context}) async {
  int selectedIndex = 29; // Pre-select the 30th item (index starts at 0)

  return await showDialog<int?>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Initialize FixedExtentScrollController to scroll to the initial index
          final controller =
              FixedExtentScrollController(initialItem: selectedIndex);

          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 0, 0, 39),
            title: Text(
              title,
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              height: 150,
              child: Column(
                children: [
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: controller, // Start at the 30th item
                      itemExtent: 40,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedIndex = index; // Update selected index
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) => Container(
                          decoration: BoxDecoration(
                            color: index == selectedIndex
                                ? Colors.yellow.withOpacity(0.3)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: index == selectedIndex
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: index == selectedIndex
                                    ? Colors.yellow
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                        childCount: 100, // Limit numbers (1-100)
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null), // Cancel
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(selectedIndex +
                      1); // Confirm (return the number, not the index)
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}
