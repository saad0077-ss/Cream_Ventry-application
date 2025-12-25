import 'package:cream_ventory/database/functions/sale/sale_db.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:cream_ventory/screens/product/product_detailing_screen.dart';
import 'package:cream_ventory/screens/sale/sale_add_screen.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cream_ventory/core/notification/app_notification_service.dart';
import 'package:cream_ventory/database/functions/product_db.dart';
import 'package:cream_ventory/screens/splash/splash_screen.dart';

// Global navigator key for navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationSetup {
  /// ✅ IMPROVED: Static method to handle notification actions in background
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    final payload = receivedAction.payload ?? {};
    final buttonKey = receivedAction.buttonKeyPressed;

    debugPrint('🔔 Notification received - Type: ${payload['type']}, Button: $buttonKey');

    // ✅ CRITICAL: Handle scheduled due date check (runs at 9 AM daily)
    if (payload['type'] == 'check_due_dates') {
      debugPrint('⏰ Running scheduled due date check...');
      try {
        final sales = await SaleDB.getSales();
        await InventoryNotificationService.checkAndNotifyDueSales(sales);
        debugPrint('✅ Scheduled due date check completed');
      } catch (e) {
        debugPrint('❌ Error in scheduled due date check: $e');
      }
      return;
    }

    // ✅ Handle daily inventory check
    if (payload['type'] == 'daily_inventory_check' && buttonKey == 'CHECK_NOW') {
      debugPrint('📋 Running inventory check from notification...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToHome();
      });
      return;
    }
    
    // Handle product-related actions
    if (buttonKey == 'RESTOCK' || buttonKey == 'VIEW') {
      final productId = payload['productId'];
      if (productId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToProductDetails(productId);
        });
      }
    }
    
    // Handle sale-related actions
    else if (buttonKey == 'VIEW_SALE') {
      final saleId = payload['saleId'];
      if (saleId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToSaleDetails(saleId);
        });
      }
    }
    
    // Handle general actions
    else if (buttonKey == 'CHECK_NOW') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToHome();
      });
    } else if (buttonKey == 'VIEW_ALL') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLowStockItems();
      });
    }
  }

  /// ✅ IMPROVED: Initialize all notification services with proper startup checks
  static Future<void> initialize() async {
    try {
      debugPrint('🚀 Initializing notification system...');
      
      // Initialize Awesome Notifications
      await InventoryNotificationService.initialize();
      debugPrint('✅ Notification service initialized');

      // Set up notification action listeners
      _setupActionListeners();
      debugPrint('✅ Action listeners configured');

      // Schedule daily inventory check at 9 AM
      await InventoryNotificationService.scheduleDailyInventoryCheck(
        hour: 9,
        minute: 0,
      );
      debugPrint('✅ Daily inventory check scheduled (9:00 AM)');

      // ✅ Schedule daily due date check at 9 AM
      await InventoryNotificationService.scheduleDailyDueDateCheck(
        hour: 9,
        minute: 0,
      );
      debugPrint('✅ Daily due date check scheduled (9:00 AM)');

      // ✅ CRITICAL: Check low stock items on app startup
      try {
        final lowStockProducts = ProductDB.lowStockNotifier.value;
        if (lowStockProducts.isNotEmpty) {
          await InventoryNotificationService.checkAndNotifyLowStock(
            lowStockProducts,
            lowStockThreshold: 5,
          );
          debugPrint('✅ Low stock check completed: ${lowStockProducts.length} items checked');
        }
      } catch (e) {
        debugPrint('⚠️ Error checking low stock on startup: $e');
      }

      // ✅ CRITICAL: Check due dates on app startup
      try {
        final sales = await SaleDB.getSales();
        await InventoryNotificationService.checkAndNotifyDueSales(sales);
        debugPrint('✅ Due date check completed on startup');
      } catch (e) {
        debugPrint('⚠️ Error checking due dates on startup: $e');
      }

      debugPrint('✅✅✅ Notification system fully initialized');
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  /// Set up action listeners for notification buttons
  static void _setupActionListeners() {
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
        _showLowStockItems();
      },
    );
  }

  /// Navigate to product details screen
  static Future<void> _navigateToProductDetails(String productId) async {
    try {
      final product = await ProductDB.getProduct(productId);

      if (product != null) {
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

  /// ✅ Navigate to sale details screen
  static Future<void> _navigateToSaleDetails(String saleId) async {
    try {
      final sale = await SaleDB.getSaleById(saleId);

      if (sale != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => SaleScreen(
              sale: sale,
              transactionType: TransactionType.saleOrder,
            ),
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

  /// Navigate to home screen
  static void _navigateToHome() {
    try {
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

  /// ✅ HELPER: Call this when user updates a sale (payment received, etc.)
  static Future<void> onSaleUpdated(String saleId) async {
    try {
      await InventoryNotificationService.clearSaleNotification(saleId);
      debugPrint('✅ Notification cleared for sale: $saleId');
    } catch (e) {
      debugPrint('⚠️ Error clearing sale notification: $e');
    }
  }

  /// ✅ HELPER: Call this when user restocks a product
  static Future<void> onProductRestocked(String productId) async {
    try {
      await InventoryNotificationService.clearProductNotification(productId);
      debugPrint('✅ Notification cleared for product: $productId');
    } catch (e) {
      debugPrint('⚠️ Error clearing product notification: $e');
    }
  }
}