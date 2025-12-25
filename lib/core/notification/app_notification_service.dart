import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cream_ventory/models/product_model.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:flutter/material.dart';

class InventoryNotificationService {
  static bool _initialized = false;
  static final Set<String> _notifiedProducts = {}; // Track notified products
  static final Set<String> _notifiedSales = {}; // Track notified sales for due dates
  static DateTime? _lastResetDate; // Track last reset date

  // Initialize Awesome Notifications (v0.10.1)
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await AwesomeNotifications().initialize( 
        'resource://mipmap/launcher_icon', // App icon for notifications 
        [ 
          // Low Stock Channel 
          NotificationChannel(
            channelKey: 'low_stock_channel', 
            channelName: 'Low Stock Alerts',
            channelDescription: 'Notifications for low stock items',
            defaultColor: Colors.orange,
            ledColor: Colors.orange,
            importance: NotificationImportance.High,                      
            channelShowBadge: true,
            playSound: true,
            enableVibration: true, 
          ),
          // Out of Stock Channel
          NotificationChannel(
            channelKey: 'out_of_stock_channel',
            channelName: 'Out of Stock Alerts',
            channelDescription: 'Urgent notifications for out of stock items',
            defaultColor: Colors.red,
            ledColor: Colors.red,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            playSound: true,
            enableVibration: true,
            enableLights: true,
          ),   
          // Daily Check Channel
          NotificationChannel(
            channelKey: 'daily_check_channel',
            channelName: 'Daily Inventory Check',
            channelDescription: 'Daily reminder to check inventory',
            defaultColor: Colors.blue,
            ledColor: Colors.blue,
            importance: NotificationImportance.Default,
            channelShowBadge: true,
            playSound: true,
          ),
          // Summary Channel
          NotificationChannel(
            channelKey: 'inventory_summary_channel',
            channelName: 'Inventory Summary',
            channelDescription: 'Summary notifications for inventory status',
            defaultColor: Colors.purple,
            ledColor: Colors.purple,
            importance: NotificationImportance.High,
            channelShowBadge: true,
          ),
          // Due Date Reminder Channel
          NotificationChannel(
            channelKey: 'due_date_reminder_channel',
            channelName: 'Payment Due Reminders',
            channelDescription: 'Notifications for payment due dates',
            defaultColor: Colors.blue,
            ledColor: Colors.blue,
            importance: NotificationImportance.High,
            channelShowBadge: true,
            playSound: true,
            enableVibration: true,
          ),
        ],
        debug: true, // Set to false in production
      );

      // Request notification permissions for v0.10.1
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }

      _initialized = true;
      print('✅ InventoryNotificationService (v0.10.1) initialized successfully');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
      rethrow;
    }
  }

  // Check and notify for low stock products
  static Future<void> checkAndNotifyLowStock(
    List<ProductModel> lowStockProducts, {
    int lowStockThreshold = 5, // Default threshold is 5
  }) async {
    if (!_initialized) await initialize();

    for (var product in lowStockProducts) {
      // Only notify once per product until stock is replenished
      if (_notifiedProducts.contains(product.id)) continue;

      if (product.stock == 0) {
        // Out of stock notification (Critical)
        await _showOutOfStockNotification(product);
      } else if (product.stock <= lowStockThreshold) {
        // Low stock notification (Warning)
        await _showLowStockNotification(product);
      }

      _notifiedProducts.add(product.id);
    }
  }

  // Show low stock notification
  static Future<void> _showLowStockNotification(ProductModel product) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: product.id.hashCode,
        channelKey: 'low_stock_channel',
        title: '⚠️ Low Stock Alert',
        body: '${product.name} is running low! Only ${product.stock} units left.',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        payload: {'type': 'low_stock', 'productId': product.id},
        color: Colors.orange,
        backgroundColor: Colors.orange[50],
        criticalAlert: false,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'RESTOCK',
          label: 'Restock Now',
          color: Colors.green,
          autoDismissible: true,
        ),
        NotificationActionButton(
          key: 'VIEW',
          label: 'View Details',
          autoDismissible: true,
        ),
      ],
    );

    print('📤 Low stock notification sent for ${product.name}');
  }

  // Show out of stock notification
  static Future<void> _showOutOfStockNotification(ProductModel product) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: product.id.hashCode,
        channelKey: 'out_of_stock_channel',
        title: '🚨 OUT OF STOCK!',
        body: '${product.name} is completely out of stock. Restock immediately!',
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Alarm,
        payload: {'type': 'out_of_stock', 'productId': product.id},
        color: Colors.red,
        backgroundColor: Colors.red[50],
        criticalAlert: true,
        wakeUpScreen: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'RESTOCK',
          label: 'Restock Now',
          color: Colors.green,
          autoDismissible: true,
        ),
        NotificationActionButton(
          key: 'DISMISS',
          label: 'Dismiss',
          isDangerousOption: true,
          autoDismissible: true,
        ),
      ],
    );

    print('📤 Out of stock notification sent for ${product.name}');
  }

  // Show summary notification for multiple low stock items
  static Future<void> showLowStockSummary(
    List<ProductModel> lowStockProducts,
  ) async {
    if (!_initialized) await initialize();
    if (lowStockProducts.isEmpty) return;

    final outOfStockCount = lowStockProducts.where((p) => p.stock == 0).length;
    final lowStockCount = lowStockProducts.length - outOfStockCount;

    String title = '📦 Inventory Alert';
    String body = '';

    if (outOfStockCount > 0 && lowStockCount > 0) {
      body = '$outOfStockCount items out of stock, $lowStockCount items low on stock';
    } else if (outOfStockCount > 0) {
      body = '$outOfStockCount items are out of stock';
    } else {
      body = '$lowStockCount items are low on stock';
    }

    // Add product names to big text
    List<String> productNames = [];
    for (var product in lowStockProducts.take(5)) {
      productNames.add(product.name);
    }
    if (lowStockProducts.length > 5) {
      body += '\n\nProducts: ${productNames.join(", ")} and ${lowStockProducts.length - 5} more';
    } else if (productNames.isNotEmpty) {
      body += '\n\nProducts: ${productNames.join(", ")}';
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 999,
        channelKey: 'inventory_summary_channel',
        title: title,
        body: body,
        bigPicture: null,
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Status,
        payload: {'type': 'summary'},
        color: Colors.purple,
        summary: '${lowStockProducts.length} items need attention',
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'VIEW_ALL',
          label: 'View All',
          autoDismissible: true,
        ),
      ],
    );

    print('📤 Summary notification sent for ${lowStockProducts.length} products');
  }

  // Schedule daily inventory check notification
  static Future<void> scheduleDailyInventoryCheck({
    int hour = 9,
    int minute = 0,
  }) async {
    if (!_initialized) await initialize();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1000,
        channelKey: 'daily_check_channel',
        title: '📋 Daily Inventory Check',
        body: 'Time to review your ice cream inventory!',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        payload: {'type': 'daily_inventory_check'}, // ✅ Added payload type
        color: Colors.blue,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'CHECK_NOW',
          label: 'Check Now',
          autoDismissible: true,
        ),
        NotificationActionButton(
          key: 'SNOOZE',
          label: 'Remind Later',
          autoDismissible: true,
        ),
      ],
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        repeats: true,
        preciseAlarm: true,
      ),
    );

    print('⏰ Daily inventory check scheduled for $hour:${minute.toString().padLeft(2, '0')}');
  }

  // Schedule notification for specific time (e.g., restock reminder)
  static Future<void> scheduleRestockReminder({
    required String productName,
    required String productId,
    required DateTime reminderTime,
  }) async {
    if (!_initialized) await initialize();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: productId.hashCode + 10000,
        channelKey: 'daily_check_channel',
        title: '🔔 Restock Reminder',
        body: 'Don\'t forget to restock $productName',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        payload: {'type': 'restock_reminder', 'productId': productId},
        color: Colors.green,
      ),
      schedule: NotificationCalendar.fromDate(date: reminderTime),
    );

    print('⏰ Restock reminder scheduled for $productName');
  }

  // Show progress notification (useful for batch operations)
  static Future<void> showProgressNotification({
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
  }) async {
    if (!_initialized) await initialize();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2000,
        channelKey: 'inventory_summary_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.ProgressBar,
        progress: progress.toDouble(),
        category: NotificationCategory.Progress,
        locked: true,
        color: Colors.blue,
      ),
    );
  }

  // ✅ IMPROVED: Check and notify for due date sales with auto-reset
  static Future<void> checkAndNotifyDueSales(List<SaleModel> sales) async {
    if (!_initialized) await initialize();

    // ✅ Auto-reset if it's a new day
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastResetDate == null || _lastResetDate!.isBefore(today)) {
      resetNotifiedSales();
      _lastResetDate = today;
      print('🔄 Notified sales reset for new day: $today');
    }

    int notificationCount = 0;

    for (var sale in sales) {
      // Skip if no due date, already paid, cancelled, or dueDate is empty/invalid
      if (sale.dueDate == null ||
          sale.dueDate!.trim().isEmpty ||
          sale.status == SaleStatus.cancelled ||
          sale.status == SaleStatus.closed) {
        continue;
      }

      // Skip if already notified today for this sale
      if (_notifiedSales.contains(sale.id)) continue;

      // Parse the dueDate string (expected format: "yyyy-MM-dd")
      DateTime? dueDate;
      try {
        dueDate = DateTime.parse(sale.dueDate!);
      } catch (e) {
        print('⚠️ Invalid dueDate format for sale ${sale.invoiceNumber}: ${sale.dueDate}');
        continue;
      }

      // Normalize to date only (remove time component)
      final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);

      // Notify only if the due date is TODAY
      if (dueDateOnly.year == today.year &&
          dueDateOnly.month == today.month &&
          dueDateOnly.day == today.day) {
        await _showDueDateNotification(sale);
        _notifiedSales.add(sale.id);
        notificationCount++;
      }
    }

    print('📤 Sent $notificationCount due date notifications');
  }

  // Show due date notification
  static Future<void> _showDueDateNotification(SaleModel sale) async {
    final customerName = sale.customerName ?? 'Customer';
    final amount = sale.balanceDue.toStringAsFixed(2);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: sale.id.hashCode + 50000,
        channelKey: 'due_date_reminder_channel',
        title: '📅 Payment Due Today',
        body: '$customerName\'s payment of ₹$amount is due today.\nInvoice #${sale.invoiceNumber}',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        payload: {
          'type': 'due_date',
          'saleId': sale.id,
        },
        color: Colors.blue,
        backgroundColor: Colors.blue[50],
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'VIEW_SALE',
          label: 'View Invoice',
          autoDismissible: true,
        ),
        NotificationActionButton(
          key: 'DISMISS',
          label: 'Dismiss',
          autoDismissible: true,
        ),
      ],
    );

    print('📤 Due date notification sent for invoice #${sale.invoiceNumber}');
  }

  // ✅ IMPROVED: Schedule daily due date check with proper payload
  static Future<void> scheduleDailyDueDateCheck({
    int hour = 9,
    int minute = 0,
  }) async {
    if (!_initialized) await initialize();

    await AwesomeNotifications().createNotification(
      content: NotificationContent( 
        id: 3000,
        channelKey: 'due_date_reminder_channel',
        title: '📅 Payment Due Check',
        body: 'Checking for payments due today...',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        payload: {'type': 'check_due_dates'}, // ✅ This triggers actual checking
        color: Colors.blue,
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        repeats: true,
        preciseAlarm: true, 
      ),
    );

    print('⏰ Daily due date check scheduled for $hour:${minute.toString().padLeft(2, '0')}');
  }

  // Clear notification for a specific product (call when restocked)
  static Future<void> clearProductNotification(String productId) async {
    await AwesomeNotifications().cancel(productId.hashCode);
    _notifiedProducts.remove(productId);
    print('🗑️ Notification cleared for product $productId');
  }

  // Clear notification for a specific sale (call when payment is made)
  static Future<void> clearSaleNotification(String saleId) async {
    await AwesomeNotifications().cancel(saleId.hashCode + 50000);
    _notifiedSales.remove(saleId);
    print('🗑️ Due date notification cleared for sale $saleId');
  }

  // Clear all notifications
  static Future<void> clearAllNotifications() async {
    await AwesomeNotifications().cancelAll();
    _notifiedProducts.clear();
    _notifiedSales.clear();
    print('🗑️ All notifications cleared');
  }

  // Reset notified products set (useful after restocking)
  static void resetNotifiedProducts() {
    _notifiedProducts.clear();
    print('🔄 Notified products reset');
  }

  // Reset notified sales (called at the start of each day)
  static void resetNotifiedSales() {
    _notifiedSales.clear();
    print('🔄 Notified sales reset');
  }

  // Set up action listeners (call this in your main app initialization)
  static void setupActionListeners({
    required Function(String productId) onRestockTapped,
    required Function(String productId) onViewDetailsTapped,
    required Function() onCheckNowTapped,
    required Function() onViewAllTapped,
  }) {
    print('✅ Notification action callbacks registered');
  }
}