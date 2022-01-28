import 'dart:io';

import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/controller/restaurant_controller.dart';
import 'package:efood_multivendor_restaurant/controller/splash_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/response/profile_model.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_app_bar.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_button.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_snackbar.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_time_picker.dart';
import 'package:efood_multivendor_restaurant/view/base/my_text_field.dart';
import 'package:efood_multivendor_restaurant/view/base/switch_button.dart';
import 'package:efood_multivendor_restaurant/view/screens/home/widget/off_day_check_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantSettingsScreen extends StatefulWidget {
  final Restaurant restaurant;
  RestaurantSettingsScreen({@required this.restaurant});

  @override
  State<RestaurantSettingsScreen> createState() => _RestaurantSettingsScreenState();
}

class _RestaurantSettingsScreenState extends State<RestaurantSettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _orderAmountController = TextEditingController();
  final TextEditingController _deliveryFeeController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _contactNode = FocusNode();
  final FocusNode _addressNode = FocusNode();
  final FocusNode _orderAmountNode = FocusNode();
  final FocusNode _deliveryFeeNode = FocusNode();
  Restaurant _restaurant;

  @override
  void initState() {
    super.initState();

    Get.find<RestaurantController>().initRestaurantData(widget.restaurant.offDay, widget.restaurant.gstStatus);

    _nameController.text = widget.restaurant.name;
    _contactController.text = widget.restaurant.phone;
    _addressController.text = widget.restaurant.address;
    _orderAmountController.text = widget.restaurant.minimumOrder.toString();
    _deliveryFeeController.text = widget.restaurant.deliveryCharge.toString();
    _gstController.text = widget.restaurant.gstCode;
    _restaurant = widget.restaurant;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'restaurant_settings'.tr),
      body: GetBuilder<RestaurantController>(builder: (restController) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          physics: BouncingScrollPhysics(),
          child: Column(children: [

            Text(
              'logo'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).disabledColor),
            ),
            SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            Align(alignment: Alignment.center, child: Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                child: restController.pickedLogo != null ? GetPlatform.isWeb ? Image.network(
                  restController.pickedLogo.path, width: 150, height: 120, fit: BoxFit.cover,
                ) : Image.file(
                  File(restController.pickedLogo.path), width: 150, height: 120, fit: BoxFit.cover,
                ) : FadeInImage.assetNetwork(
                  placeholder: Images.placeholder,
                  image: '${Get.find<SplashController>().configModel.baseUrls.restaurantImageUrl}/${widget.restaurant.logo}',
                  height: 120, width: 150, fit: BoxFit.cover,
                  imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder, height: 120, width: 150, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                bottom: 0, right: 0, top: 0, left: 0,
                child: InkWell(
                  onTap: () => restController.pickImage(true, false),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                    ),
                    child: Container(
                      margin: EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.white),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ])),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

            MyTextField(
              hintText: 'restaurant_name'.tr,
              controller: _nameController,
              focusNode: _nameNode,
              nextFocus: _contactNode,
              capitalization: TextCapitalization.words,
              inputType: TextInputType.name,
            ),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

            MyTextField(
              hintText: 'contact_number'.tr,
              controller: _contactController,
              focusNode: _contactNode,
              nextFocus: _addressNode,
              inputType: TextInputType.phone,
            ),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

            MyTextField(
              hintText: 'address'.tr,
              controller: _addressController,
              focusNode: _addressNode,
              nextFocus: _orderAmountNode,
              inputType: TextInputType.streetAddress,
            ),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

            Row(children: [
              Expanded(child: MyTextField(
                hintText: 'minimum_order_amount'.tr,
                controller: _orderAmountController,
                focusNode: _orderAmountNode,
                nextFocus: _restaurant.selfDeliverySystem == 1 ? _deliveryFeeNode : null,
                inputAction: _restaurant.selfDeliverySystem == 1 ? null : TextInputAction.done,
                inputType: TextInputType.number,
                isAmount: true,
              )),
              SizedBox(width: _restaurant.selfDeliverySystem == 1 ? Dimensions.PADDING_SIZE_SMALL : 0),
              _restaurant.selfDeliverySystem == 1 ? Expanded(child: MyTextField(
                hintText: 'delivery_fee'.tr,
                controller: _deliveryFeeController,
                focusNode: _deliveryFeeNode,
                inputAction: TextInputAction.done,
                inputType: TextInputType.number,
                isAmount: true,
              )) : SizedBox(),
            ]),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

            Row(children: [
             Expanded(child: Text(
               'gst'.tr,
               style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).disabledColor),
             )),
              Switch(
                value: restController.isGstEnabled,
                activeColor: Theme.of(context).primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (bool isActive) => restController.toggleGst(),
              ),
            ]),
            MyTextField(
              hintText: 'gst'.tr,
              controller: _gstController,
              inputAction: TextInputAction.done,
              title: false,
              isEnabled: restController.isGstEnabled,
            ),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

            Align(alignment: Alignment.centerLeft, child: Text(
              'weekly_off_day'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).disabledColor),
            )),
            Row(children: [
              OffDayCheckBox(weekDay: 1, restController: restController),
              OffDayCheckBox(weekDay: 2, restController: restController),
            ]),
            Row(children: [
              OffDayCheckBox(weekDay: 3, restController: restController),
              OffDayCheckBox(weekDay: 4, restController: restController),
            ]),
            Row(children: [
              OffDayCheckBox(weekDay: 5, restController: restController),
              OffDayCheckBox(weekDay: 6, restController: restController),
            ]),
            Row(children: [
              OffDayCheckBox(weekDay: 7, restController: restController),
            ]),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

            Row(children: [

              Expanded(child: CustomTimePicker(
                title: 'open_time'.tr, time: _restaurant.availableTimeStarts,
                onTimeChanged: (time) => _restaurant.availableTimeStarts = time,
              )),
              SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

              Expanded(child: CustomTimePicker(
                title: 'close_time'.tr, time: _restaurant.availableTimeEnds,
                onTimeChanged: (time) => _restaurant.availableTimeEnds = time,
              )),

            ]),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

            SwitchButton(icon: Icons.alarm_add, title: 'schedule_order'.tr, isButtonActive: widget.restaurant.scheduleOrder, onTap: () {
              _restaurant.scheduleOrder = !_restaurant.scheduleOrder;
            }),
            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

            SwitchButton(icon: Icons.delivery_dining, title: 'delivery'.tr, isButtonActive: widget.restaurant.delivery, onTap: () {
              _restaurant.delivery = !_restaurant.delivery;
            }),
            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

            SwitchButton(icon: Icons.house_siding, title: 'take_away'.tr, isButtonActive: widget.restaurant.takeAway, onTap: () {
              _restaurant.takeAway = !_restaurant.takeAway;
            }),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

            Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                child: restController.pickedCover != null ? GetPlatform.isWeb ? Image.network(
                  restController.pickedCover.path, width: context.width, height: 170, fit: BoxFit.cover,
                ) : Image.file(
                  File(restController.pickedCover.path), width: context.width, height: 170, fit: BoxFit.cover,
                ) : FadeInImage.assetNetwork(
                  placeholder: Images.restaurant_cover,
                  image: '${Get.find<SplashController>().configModel.baseUrls.restaurantCoverPhotoUrl}/${widget.restaurant.coverPhoto}',
                  height: 170, width: context.width, fit: BoxFit.cover,
                  imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder, height: 170, width: context.width, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                bottom: 0, right: 0, top: 0, left: 0,
                child: InkWell(
                  onTap: () => restController.pickImage(false, false),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                    ),
                    child: Container(
                      margin: EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        border: Border.all(width: 3, color: Colors.white),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 50),
                    ),
                  ),
                ),
              ),
            ]),
            SizedBox(height: 30),

            !restController.isLoading ? CustomButton(
              onPressed: () {
                String _name = _nameController.text.trim();
                String _contact = _contactController.text.trim();
                String _address = _addressController.text.trim();
                String _minimumOrder = _orderAmountController.text.trim();
                String _deliveryFee = _deliveryFeeController.text.trim();
                String _gstCode = _gstController.text.trim();
                if(_name.isEmpty) {
                  showCustomSnackBar('enter_your_restaurant_name'.tr);
                }else if(_contact.isEmpty) {
                  showCustomSnackBar('enter_restaurant_contact_number'.tr);
                }else if(_address.isEmpty) {
                  showCustomSnackBar('enter_restaurant_address'.tr);
                }else if(_minimumOrder.isEmpty) {
                  showCustomSnackBar('enter_minimum_order_amount'.tr);
                }else if(_restaurant.selfDeliverySystem == 1 && _deliveryFee.isEmpty) {
                  showCustomSnackBar('enter_delivery_fee'.tr);
                }else if(restController.isGstEnabled && _gstCode.isEmpty) {
                  showCustomSnackBar('enter_gst_code'.tr);
                }else {
                  _restaurant.name = _name;
                  _restaurant.phone = _contact;
                  _restaurant.address = _address;
                  _restaurant.minimumOrder = double.parse(_minimumOrder);
                  _restaurant.gstStatus = restController.isGstEnabled;
                  _restaurant.gstCode = _gstCode;
                  _restaurant.offDay = restController.weekendString;
                  _restaurant.deliveryCharge = double.parse(_deliveryFee);
                  restController.updateRestaurant(_restaurant, Get.find<AuthController>().getUserToken());
                }
              },
              buttonText: 'update'.tr,
            ) : Center(child: CircularProgressIndicator()),

          ]),
        );
      }),
    );
  }
}
