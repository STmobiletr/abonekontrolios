import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/subscription_templates.dart';
import '../../../core/ui/glass_box.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../models/subscription_model.dart';
import '../providers/subscription_providers.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/stable_notif_id.dart';
import '../../settings/providers/settings_provider.dart';

/// Screen to add or edit a subscription
class AddSubscriptionScreen extends ConsumerStatefulWidget {
  final SubscriptionModel? subscription;

  const AddSubscriptionScreen({super.key, this.subscription});

  @override
  ConsumerState<AddSubscriptionScreen> createState() =>
      _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _cancelUrlController;

  Color _selectedColor = Colors.blue;
  String _billingCycle = AppStrings.monthlyValue;
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));
  String _selectedCategory = 'Eğlence';
  final List<String> _categories = [
    'Eğlence',
    'İş',
    'Faturalar',
    'Kişisel',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.subscription?.name ?? '',
    );
    _priceController = TextEditingController(
      text: widget.subscription?.price.toString() ?? '',
    );
    _cancelUrlController = TextEditingController(
      text: widget.subscription?.cancellationUrl ?? '',
    );

    if (widget.subscription != null) {
      _selectedColor = widget.subscription!.colorHex != null
          ? Color(
              int.parse(
                "0xFF${widget.subscription!.colorHex!.replaceAll('#', '')}",
              ),
            )
          : Colors.blue;
      final savedCycle = widget.subscription!.billingCycle;
      // Backward compatibility: accept both internal (Monthly/Yearly) and translated (Aylık/Yıllık) values
      if (savedCycle == AppStrings.monthlyValue || savedCycle == AppStrings.monthly) {
        _billingCycle = AppStrings.monthlyValue;
      } else if (savedCycle == AppStrings.yearlyValue || savedCycle == AppStrings.yearly) {
        _billingCycle = AppStrings.yearlyValue;
      } else {
        _billingCycle = AppStrings.monthlyValue;
      }
      _nextBillingDate = widget.subscription!.nextBillingDate;
      _selectedCategory = widget.subscription!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _cancelUrlController.dispose();
    super.dispose();
  }

  void _applyTemplate(SubscriptionTemplate template) {
    setState(() {
      _nameController.text = template.name;
      _priceController.text = template.defaultPrice.toString();
      _selectedColor = template.color;
      _cancelUrlController.text = template.cancellationUrl ?? '';
    });
  }

  Future<void> _saveSubscription() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.enterNamePrice)));
      return;
    }

    final newSub = SubscriptionModel(
      id: widget.subscription?.id ?? const Uuid().v4(),
      name: _nameController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      currency: ref.read(settingsNotifierProvider).currency,
      billingCycle: _billingCycle,
      nextBillingDate: _nextBillingDate,
      colorHex: '#${_selectedColor.value.toRadixString(16).substring(2)}',
      cancellationUrl: _cancelUrlController.text.isNotEmpty
          ? _cancelUrlController.text
          : null,
      category: _selectedCategory,
    );

    if (widget.subscription != null) {
      ref.read(subscriptionRepositoryProvider).updateSubscription(newSub);
    } else {
      ref.read(subscriptionRepositoryProvider).addSubscription(newSub);
    }

    // Bildirimler kapalıysa planlama yapma.
    final notificationsEnabled =
        ref.read(settingsNotifierProvider).notificationsEnabled;

    // Sadece yeni/edited abonelik için bildirim planla.
    // (Tümünü iptal edip yeniden planlamak iOS'ta bazen "hemen bildirim" gibi davranışlara yol açabiliyor.)
    if (notificationsEnabled) {
      final settings = ref.read(settingsNotifierProvider);
      final notifId = stableNotifId(newSub.id);

      await NotificationService().scheduleBillingNotification(
        id: notifId,
        title: "${AppStrings.upcomingCharge}${newSub.name}",
        body:
            "${AppStrings.youWillBeCharged}${settings.currencySymbol}${newSub.price.toStringAsFixed(2)}. "
            "Ödeme tarihi: ${AppStrings.formatDate(newSub.nextBillingDate)}. "
            "${AppStrings.chargeDisclaimer}",
        scheduledDate: newSub.nextBillingDate,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subscription != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isEditing ? AppStrings.editSubscription : AppStrings.newSubscription,
          style: TextStyle(color: textColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Add
            Text(
              AppStrings.quickAdd,
              style: TextStyle(color: textColor.withOpacity(0.5)),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: popularSubscriptions.map((template) {
                  return GestureDetector(
                    onTap: () => _applyTemplate(template),
                    child: Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: template.color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkGlassBorder
                                    : AppColors.lightGlassBorder,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                template.name[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            template.name,
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),

            // Form
            GlassBox(
              borderRadius: 20,
              padding: const EdgeInsets.all(20),
              color: _selectedColor.withOpacity(0.1),
              child: Column(
                children: [
                  // Name Input
                  Autocomplete<SubscriptionTemplate>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<SubscriptionTemplate>.empty();
                      }
                      return popularSubscriptions.where((
                        SubscriptionTemplate option,
                      ) {
                        return option.name.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        );
                      });
                    },
                    displayStringForOption: (SubscriptionTemplate option) =>
                        option.name,
                    onSelected: (SubscriptionTemplate selection) {
                      _applyTemplate(selection);
                    },
                    fieldViewBuilder:
                        (
                          BuildContext context,
                          TextEditingController fieldTextEditingController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted,
                        ) {
                          if (fieldTextEditingController.text !=
                              _nameController.text) {
                            fieldTextEditingController.text =
                                _nameController.text;
                          }

                          fieldTextEditingController.addListener(() {
                            _nameController.text =
                                fieldTextEditingController.text;
                          });

                          return TextField(
                            controller: fieldTextEditingController,
                            focusNode: fieldFocusNode,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              labelText: AppStrings.serviceName,
                              labelStyle: TextStyle(
                                color: textColor.withOpacity(0.5),
                              ),
                              prefixIcon: Icon(
                                Icons.subscriptions_outlined,
                                color: textColor.withOpacity(0.7),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.darkGlassBorder
                                      : AppColors.lightGlassBorder,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          );
                        },
                    optionsViewBuilder:
                        (
                          BuildContext context,
                          AutocompleteOnSelected<SubscriptionTemplate>
                          onSelected,
                          Iterable<SubscriptionTemplate> options,
                        ) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              color: Theme.of(context).cardColor,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width - 80,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                        final SubscriptionTemplate option =
                                            options.elementAt(index);
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: option.color,
                                            radius: 10,
                                          ),
                                          title: Text(
                                            option.name,
                                            style: TextStyle(color: textColor),
                                          ),
                                          onTap: () {
                                            onSelected(option);
                                          },
                                        );
                                      },
                                ),
                              ),
                            ),
                          );
                        },
                  ),
                  const SizedBox(height: 15),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: Theme.of(context).cardColor,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: AppStrings.category,
                      labelStyle: TextStyle(color: textColor.withOpacity(0.5)),
                      prefixIcon: Icon(
                        Icons.category,
                        color: textColor.withOpacity(0.7),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkGlassBorder
                              : AppColors.lightGlassBorder,
                        ),
                      ),
                    ),
                    items: _categories.map((String cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategory = val!),
                  ),
                  const SizedBox(height: 15),

                  // Price Input
                  _buildTextField(
                    context,
                    controller: _priceController,
                    label: AppStrings.priceMonthly,
                    icon: Icons.attach_money,
                    isNumber: true,
                    prefixIconWidget: SizedBox(
                      width: 48,
                      child: Center(
                        child: Text(
                          '₺',
                          style: TextStyle(
                            color: (Theme.of(context).textTheme.bodyLarge?.color ??
                                    AppColors.lightText)
                                .withOpacity(0.7),
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Cancel URL Input
                  _buildTextField(
                    context,
                    controller: _cancelUrlController,
                    label: AppStrings.cancelUrlOptional,
                    icon: Icons.link,
                  ),
                  const SizedBox(height: 15),

                  // Date Picker
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: textColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.firstBill,
                        style: TextStyle(color: textColor.withOpacity(0.7)),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            locale: const Locale('tr', 'TR'),
                            initialDate: _nextBillingDate,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 5),
                            ),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: isDark
                                      ? const ColorScheme.dark(
                                          primary: AppColors.primaryAccent,
                                          onPrimary: Colors.black,
                                          surface: AppColors.darkSurface,
                                          onSurface: Colors.white,
                                        )
                                      : const ColorScheme.light(
                                          primary: AppColors.primaryAccent,
                                          onPrimary: Colors.black,
                                          surface: Colors.white,
                                          onSurface: Colors.black,
                                        ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() => _nextBillingDate = picked);
                          }
                        },
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_nextBillingDate),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Billing Cycle Toggle
                  Row(
                    children: [
                      Icon(Icons.loop, color: textColor.withOpacity(0.7)),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.cycle,
                        style: TextStyle(color: textColor.withOpacity(0.7)),
                      ),
                      DropdownButton<String>(
                        value: _billingCycle,
                        dropdownColor: Theme.of(context).cardColor,
                        style: TextStyle(color: textColor),
                        underline: Container(),
                        items: [AppStrings.monthlyValue, AppStrings.yearlyValue].map((String value) {
                          final label = (value == AppStrings.monthlyValue)
                              ? AppStrings.monthly
                              : AppStrings.yearly;
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _billingCycle = val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 10,
                  shadowColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.4),
                ),
                onPressed: _saveSubscription,
                child: Text(
                  AppStrings.saveSubscription,
                  style: TextStyle(
                    color: isDark ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
    Widget? prefixIconWidget,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText;

    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor.withOpacity(0.5)),
        prefixIcon: prefixIconWidget ?? Icon(icon, color: textColor.withOpacity(0.7)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark
                ? AppColors.darkGlassBorder
                : AppColors.lightGlassBorder,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
