  // void showFilterBottomSheet(
  //   BuildContext context,
  //   List<CategoryModel> categories, 
  // ) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
  //     ),
  //     backgroundColor: const Color.fromARGB(255, 21, 21, 21),
  //     builder: (sheetContext) {
  //       return SingleChildScrollView(
  //         child: Padding(
  //           padding: const EdgeInsets.all(10.0),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [ 
  //               // Category Section
  //               const Text(
  //                 'Category',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 18,
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               ListTile(
  //                 title: const Text(
  //                   'All Categories',
  //                   style: TextStyle(color: Colors.white),
  //                 ),
  //                 onTap: () {
  //                   setState(() {
  //                     selectedCategory = null;
  //                   });
  //                   Navigator.pop(sheetContext);
  //                 },
  //                 tileColor:
  //                     selectedCategory == null
  //                         ? Colors.black.withOpacity(0.2)
  //                         : null,
  //               ),
  //               ...categories.map((category) {
  //                 return ListTile(
  //                   title: Text(
  //                     category.name,
  //                     style: const TextStyle(color: Colors.white),
  //                   ),
  //                   onTap: () {
  //                     setState(() {
  //                       selectedCategory = category;
  //                     });
  //                     Navigator.pop(sheetContext);
  //                   },
  //                   tileColor:
  //                       selectedCategory == category
  //                           ? Colors.black.withOpacity(0.2)
  //                           : null,
  //                 );
  //               }),
  //               const Divider(color: Colors.white54),
  //               // Date Section
  //               const Text(
  //                 'Date',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 18,
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               ListTile(
  //                 title: const Text(
  //                   'Today',
  //                   style: TextStyle(color: Colors.white),
  //                 ),
  //                 onTap: () {
  //                   setState(() {
  //                     selectedDateFilter = 'today';
  //                   });
  //                   Navigator.pop(sheetContext);
  //                 },
  //                 tileColor:
  //                     selectedDateFilter == 'today'
  //                         ? Colors.black.withOpacity(0.2)
  //                         : null,
  //               ),
  //               ListTile(
  //                 title: const Text(
  //                   'Last 7 Days',
  //                   style: TextStyle(color: Colors.white),
  //                 ),
  //                 onTap: () {
  //                   setState(() {
  //                     selectedDateFilter = 'last7days';
  //                   });
  //                   Navigator.pop(sheetContext);
  //                 },
  //                 tileColor:
  //                     selectedDateFilter == 'last7days'
  //                         ? Colors.black.withOpacity(0.2)
  //                         : null,
  //               ),
  //               ListTile(
  //                 title: const Text(
  //                   'Last 30 Days',
  //                   style: TextStyle(color: Colors.white),
  //                 ),
  //                 onTap: () {
  //                   setState(() {
  //                     selectedDateFilter = 'last30days';
  //                   });
  //                   Navigator.pop(sheetContext);
  //                 },
  //                 tileColor:
  //                     selectedDateFilter == 'last30days'
  //                         ? Colors.black.withOpacity(0.2)
  //                         : null,
  //               ),
  //               ListTile(
  //                 title: const Text(
  //                   'Custom Date Range',    
  //                   style: TextStyle(color: Colors.white),
  //                 ),
  //                 onTap: () {
  //                   Navigator.pop(sheetContext);
  //                   if (mounted) {
  //                     _pickDate(context, true).then((_) {
  //                       if (mounted && selectedStartDate != null) {
  //                         _pickDate(context, false);
  //                       }
  //                     });
  //                   }
  //                 },
  //                 tileColor:
  //                     selectedDateFilter == 'Custom'
  //                         ? Colors.black.withOpacity(0.2)
  //                         : null,
  //               ),
  //               const Divider(color: Colors.white54),
  //               // Clear Filters
  //               Center(
  //                 child: ElevatedButton(
  //                   onPressed: () {
  //                     setState(() {
  //                       selectedCategory = null;
  //                       selectedDateFilter = null;
  //                       selectedStartDate = null;
  //                       selectedEndDate = null;
  //                       _searchController.clear();
  //                       _searchQuery = '';
  //                     }); 
  //                     Navigator.pop(sheetContext);
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.black,
  //                     foregroundColor: Colors.white,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                   child: const Text('Clear All Filters'),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }