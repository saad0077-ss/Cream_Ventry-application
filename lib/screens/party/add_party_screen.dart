import 'package:cream_ventory/models/party_model.dart';
import 'package:cream_ventory/screens/controller/add_party_form_controller.dart';
import 'package:cream_ventory/screens/party/add_party_screen_ui_components.dart';
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:flutter/material.dart';


class AddPartyPage extends StatefulWidget {
  final PartyModel? party;

  const AddPartyPage({super.key, this.party});

  @override
  State<AddPartyPage> createState() => _AddPartyPageState();
}
   
class _AddPartyPageState extends State<AddPartyPage> {
  late final PartyFormController _formController;

  @override
  void initState() {
    super.initState();
    _formController = PartyFormController(widget.party, () {
      setState(() {}); // Trigger rebuild on image pick or other updates
    });
    _formController.initializeForm();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.party != null ? 'Edit Party' : 'Add Party',
        fontSize: 30,
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(gradient: AppTheme.appGradient),
        child: Form(
          key: _formController.formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.05),
                PartyUIComponents.buildImagePicker(
                  screenWidth: screenWidth,
                  imageBytes: _formController.imageBytes,
                  imagePath: _formController.imagePath,
                  party: widget.party,
                  onPick: (bytes, path) {
                    setState(() {
                      _formController.imageBytes = bytes;
                      _formController.imagePath = path;
                    });
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                PartyUIComponents.buildPartyNameField(_formController.partyNameController),
                SizedBox(height: screenHeight * 0.02),
                PartyUIComponents.buildContactNumberField(_formController.contactNumberController),
                SizedBox(height: screenHeight * 0.02),
                PartyUIComponents.buildBalanceAndDateRow(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  openingBalanceController: _formController.openingBalanceController,
                  selectedDate: _formController.selectedDate,
                  isEditMode: widget.party != null,
                  pickDate: _formController.pickDate,
                  context: context,
                ),
                SizedBox(height: screenHeight * 0.02),
                PartyUIComponents.buildPaymentTypeSelector(
                  _formController.paymentType,
                  (value) {
                    setState(() {
                      _formController.paymentType = value.toString();
                    });
                  },
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Address',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                PartyUIComponents.buildBillingAddressField(_formController.billingAddressController),
                SizedBox(height: screenHeight * 0.02),
                PartyUIComponents.buildEmailField(_formController.emailController),
                SizedBox(height: screenHeight * 0.05),
                PartyUIComponents.buildActionButtons(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  party: widget.party,
                  onSaveAndNew: () => _formController.saveParty(context, clearFields: true),
                  onSave: () => _formController.saveParty(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}