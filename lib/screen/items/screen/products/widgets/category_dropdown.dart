// import 'package:cream_ventery/db/functions/category_db.dart';
// import 'package:cream_ventery/db/models/items/category/category_model.dart';
// import 'package:flutter/material.dart';

// class DropDown extends StatefulWidget {
//   const DropDown({Key? key}) : super(key: key);

//   @override
//   _DropDownState createState() => _DropDownState();
// }

// class _DropDownState extends State<DropDown> {
//   CategoryModel? selectedCategory;
//   String? categoryError;

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<CategoryModel>>(
//       future: Future.value(CategoryDB.getAllCategories()),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator();
//         }
//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return const Text("No categories available.");
//         }
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             DropdownButton<CategoryModel>(
//               hint: Text("Select Category"),
//               value: selectedCategory,
//               isExpanded: true,
//               onChanged: (CategoryModel? newValue) {
//                 setState(() {
//                   selectedCategory = newValue;
//                   categoryError = null;
//                 });
//               },
//               items: snapshot.data!.map<DropdownMenuItem<CategoryModel>>(
//                 (CategoryModel category) {
//                   return DropdownMenuItem<CategoryModel>(
//                     value: category,
//                     child: Text(category.name),
//                   );
//                 },
//               ).toList(),
//             ),
//             if (categoryError != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: Text(
//                   categoryError!,
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }