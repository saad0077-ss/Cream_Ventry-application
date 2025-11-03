import 'package:uuid/uuid.dart';
import 'category_model.dart';

class SampleCategories {
  // Static final ensures UUIDs are generated ONLY ONCE at class initialization
  static final List<CategoryModel> samples = [
    CategoryModel(
      id: const Uuid().v4(),
      name: 'ICE CREAM',
      imagePath: 'assets/image/iceee.jpeg',
      isAsset: true,
      discription:
          'Real ice cream is a creamy and indulgent dessert made with fresh dairy ingredients, offering a rich and authentic flavor. Unlike frozen desserts, it emphasizes natural textures and tastes, making every scoop a genuine treat.',
    ),
    CategoryModel(
      id: const Uuid().v4(),         
      name: 'FROZEN',
      imagePath: 'assets/image/ice_cream.jpg',
      isAsset: true, 
      discription:
          "Frozen dessert is a chilled treat made with a blend of ingredients like dairy, vegetable oils, and flavorings, offering a smooth and refreshing taste. It's a versatile option enjoyed in various forms, from scoops to bars, perfect for cooling down on a warm day.",
    ),
    CategoryModel(
      id: const Uuid().v4(),
      name: 'SUNDAE',
      imagePath: 'assets/image/sundae.jpg',
      isAsset: true,
      discription:
          'A sundae is a delightful dessert made by layering scoops of ice cream with toppings like syrup, whipped cream, nuts, and cherries. This customizable treat is perfect for satisfying your sweet cravings with endless flavor combinations.',
    ),
    CategoryModel(
      id: const Uuid().v4(),
      name: 'SIRUP',
      imagePath: 'assets/image/sirups.jpg',
      isAsset: true,
      discription:
          'Syrup is a sweet and versatile liquid often used as a topping or ingredient, enhancing desserts, beverages, and breakfast dishes with rich flavor. From classic chocolate and caramel to fruity and spiced varieties, syrups add a delicious finishing touch to countless creations.',
    ),
  ];

  // Backward compatibility: Keep getSamples() for existing code
  static List<CategoryModel> getSamples() => samples;
}             