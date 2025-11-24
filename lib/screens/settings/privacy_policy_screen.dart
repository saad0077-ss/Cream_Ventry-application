import 'package:cream_ventory/core/theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Privacy Policy'),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(gradient: AppTheme.appGradient),
          child: Markdown(
            data: '''     
# Privacy Policy for Creamventory App

**Last Updated: October 31, 2025**

Welcome to **Creamventory**, a mobile application designed to help you manage your ice cream business. With Creamventory, you can track ice cream stock, manage party orders, generate invoices, and capture photos of products or events — all in one place.

This Privacy Policy explains how we handle your data. **We do not collect, store, or transmit any personal or business data to our servers.** Everything stays on **your device**.



## 1. Information We Do NOT Collect
Creamventory is a **100% offline, local-first app**. We **do not**:
- Collect any personal information (name, email, phone, etc.)
- Access or store your location
- Track usage or analytics
- Use cookies, ads, or third-party tracking
- Transmit any data over the internet



## 2. Data Storage (Local Only)
- **All data is stored locally** on your device using **Hive** (a lightweight, secure local database).
- This includes:
  - Ice cream stock records
  - Party order details
  - Customer names (for orders)
  - Payment records
  - Photos of ice creams, events, or receipts
- **We have no access** to this data. It never leaves your phone.



## 3. Camera & Gallery Access
- The app may request permission to:
  - **Take photos** (e.g., of ice cream flavors, party setups)
  - **Select images from gallery**
- These images are **saved locally** and used only within the app.
- You can revoke permissions anytime in your device settings.



## 4. No Cloud Sync or Backups
- Creamventory does **not** sync data to any cloud.
- **You are responsible** for backing up your data (e.g., via device backup or manual export).
- If you uninstall the app or clear app data, **all information will be lost**.



## 5. Third-Party Libraries
The app uses open-source Flutter packages such as:
- `flutter`
- `hive`
- `image_picker`
- `path_provider`
- `provider`

These are used **only for local functionality**. We are not responsible for their updates or security. See their respective licenses for details.



## 6. Your Responsibilities
You are solely responsible for:
- The accuracy of stock, orders, and customer data
- Securing your device
- Backing up important business data
- Using customer photos or information lawfully



## 7. Children's Privacy
Creamventory is a business tool and **not intended for children under 13**. We do not knowingly collect data from children.



## 8. No Data Sharing or Selling
Since **no data leaves your device**, we do **not**:
- Share data with third parties
- Sell data
- Use data for advertising



## 9. Security
- Data is stored securely using **encrypted Hive boxes** (where supported).
- However, **no app is 100% secure**. Protect your device with a passcode or biometric lock.



## 10. Changes to This Policy
We may update this Privacy Policy. Changes will be reflected in the app with a new "Last Updated" date. Continued use means you accept the changes.



## 11. Contact Us
For support or privacy concerns:

**Muhammed Saad C**  
Email: muhammedsaad@gmail.com  
Phone: +91 8921873547


**By using Creamventory, you acknowledge that you have read and agree to this Privacy Policy.**




          ''',
            selectable: false,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(                                   
                fontSize: 16,
                color: Theme.of(context).colorScheme.onBackground,
                height: 1.9,
              ),
              h1: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              h2: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              strong: const TextStyle(fontWeight: FontWeight.bold),
              listBullet: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          ),
        ),
      ),
    );
  }
}
