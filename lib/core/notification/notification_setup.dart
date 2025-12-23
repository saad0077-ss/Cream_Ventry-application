import 'package:cream_ventory/database/functions/sale/sale_db.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:cream_ventory/screens/product/product_detailing_screen.dart';
import 'package:cream_ventory/screens/sale/sale_add_screen.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cream_ventory/core/notification/app_notification_service.dart';
import 'package:cream_ventory/database/functions/product_db.dart';
import 'package:cream_ventory/screens/splash/splash_screen.dart'; // Import your home screen

// Global navigator key for navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationSetup {
  /// Static method to handle notification actions in background
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // This method will be called even when app is terminated
    final payload = receivedAction.payload ?? {};
    final buttonKey = receivedAction.buttonKeyPressed;

    debugPrint('🔔 Background notification action: $buttonKey');

    // Handle background actions
    if (buttonKey == 'RESTOCK' || buttonKey == 'VIEW') {
      final productId = payload['productId'];
      if (productId != null) {
        // Navigate after app opens
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToProductDetails(productId);
        });
      }
    } else if (buttonKey == 'CHECK_NOW') {
      // Navigate to home screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToHome();
      });
    } else if (buttonKey == 'VIEW_ALL') {
      // Show low stock items
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLowStockItems();
      });
    }
  }

  /// Initialize all notification services
  static Future<void> initialize() async {
    try {
      // Initialize Awesome Notifications
      await InventoryNotificationService.initialize();
      debugPrint('✅ Notification service initialized');

      // Set up notification action listeners
      _setupActionListeners();

      // Schedule daily inventory check at 9 AM
      await InventoryNotificationService.scheduleDailyInventoryCheck(
        hour: 9,
        minute: 0,
      );
      debugPrint('✅ Daily inventory check scheduled');
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  /// Set up action listeners for notification buttons
  static void _setupActionListeners() {
    // Use the static method for background handling
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: (notification) async {
        debugPrint('🔔 Notification created: ${notification.id}');
      },
      onNotificationDisplayedMethod: (notification) async {
        debugPrint('🔔 Notification displayed: ${notification.id}');
      },
      onDismissActionReceivedMethod: (action) async {
        debugPrint('🔔 Notification dismissed: ${action.id}');
      },
    );

    // Also set up the InventoryNotificationService listeners for foreground
    InventoryNotificationService.setupActionListeners(
      onRestockTapped: (productId) async {
        debugPrint('🔔 Restock notification tapped for product: $productId');
        await _navigateToProductDetails(productId);
      },
      onViewDetailsTapped: (productId) async {
        debugPrint('🔔 View details tapped for product: $productId');
        await _navigateToProductDetails(productId);
      },
      onCheckNowTapped: () {
        debugPrint('🔔 Check now tapped');
        _navigateToHome();
      },
      onViewAllTapped: () {
        debugPrint('🔔 View all low stock items tapped');
        // You can navigate to a low stock screen if you have one
        _showLowStockItems();
      },
    );
    debugPrint('✅ Notification action listeners set up');
  }

  /// Navigate to product details screen
  static Future<void> _navigateToProductDetails(String productId) async {
    try {
      // Get the product from database
      final product = await ProductDB.getProduct(productId);

      if (product != null) {
        // Navigate to product details page using MaterialPageRoute
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: product),
          ),
        );
      } else {
        debugPrint('⚠️ Product not found: $productId');
        _showSnackBar('Product not found');
      }
    } catch (e) {
      debugPrint('❌ Error navigating to product details: $e');
      _showSnackBar('Error opening product details');
    }
  }

  /// Navigate to home screen
  static void _navigateToHome() {
    try {
      // Navigate to home screen (ScreenSplash or your main home screen)
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const ScreenSplash(),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('❌ Error navigating to home: $e');
    }
  }

  /// Show low stock items dialog or navigate to low stock screen
  static void _showLowStockItems() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final lowStockProducts = ProductDB.lowStockNotifier.value;

    if (lowStockProducts.isEmpty) {
      _showSnackBar('All products are well stocked! ✅');
      return;
    }

    // Show dialog with low stock items
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            Text('Low Stock Items (${lowStockProducts.length})'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: lowStockProducts.length,
            itemBuilder: (context, index) {
              final product = lowStockProducts[index];
              final isOutOfStock = product.stock == 0;

              return Card(
                color: isOutOfStock ? Colors.red[50] : Colors.orange[50],
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    isOutOfStock ? Icons.block : Icons.warning,
                    color: isOutOfStock ? Colors.red : Colors.orange,
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                    isOutOfStock
                        ? 'OUT OF STOCK'
                        : 'Stock: ${product.stock} units',
                    style: TextStyle(
                      color: isOutOfStock ? Colors.red : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToProductDetails(product.id);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Future<void> onActionReceivedMethodsaleOrder(
    ReceivedAction receivedAction, 
  ) async {
    final payload = receivedAction.payload ?? {};
    final buttonKey = receivedAction.buttonKeyPressed;

    debugPrint('🔔 Background notification action: $buttonKey');

    if (buttonKey == 'RESTOCK' || buttonKey == 'VIEW') {
      final productId = payload['productId'];
      if (productId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToProductDetails(productId);
        });
      }
    }
    // ✅ ADD THIS:
    else if (buttonKey == 'VIEW_SALE') {
      final saleId = payload['saleId'];
      if (saleId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToSaleDetails(saleId);
        });
      }
    } else if (buttonKey == 'CHECK_NOW') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToHome();
      });
    } else if (buttonKey == 'VIEW_ALL') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLowStockItems();
      });
    }
  }

// ✅ ADD THIS HELPER METHOD:
  static Future<void> _navigateToSaleDetails(String saleId) async {
    try {
      final sale = await SaleDB.getSaleById(saleId);

      if (sale != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => SaleScreen(
                sale: sale, transactionType: TransactionType.saleOrder),
          ),
        );
      } else {
        debugPrint('⚠️ Sale not found: $saleId');
        _showSnackBar('Sale not found');
      }
    } catch (e) {
      debugPrint('❌ Error navigating to sale details: $e');
      _showSnackBar('Error opening sale details');
    }
  }

  /// Show snackbar message
  static void _showSnackBar(String message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
