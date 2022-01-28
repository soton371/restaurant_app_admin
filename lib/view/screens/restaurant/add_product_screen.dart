import 'dart:io';

import 'package:efood_multivendor_restaurant/controller/addon_controller.dart';
import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/controller/restaurant_controller.dart';
import 'package:efood_multivendor_restaurant/controller/splash_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/response/attribute_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/product_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/variant_type_model.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_app_bar.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_button.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_snackbar.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_time_picker.dart';
import 'package:efood_multivendor_restaurant/view/base/my_text_field.dart';
import 'package:efood_multivendor_restaurant/view/screens/restaurant/widget/attribute_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProductScreen extends StatefulWidget {
  final Product product;
  AddProductScreen({@required this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  TextEditingController _c = TextEditingController();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _priceNode = FocusNode();
  final FocusNode _discountNode = FocusNode();
  final FocusNode _descriptionNode = FocusNode();
  bool _update;
  Product _product;

  @override
  void initState() {
    super.initState();

    _product = widget.product;
    _update = widget.product != null;
    Get.find<RestaurantController>().getAttributeList(widget.product);
    if(_update) {
      _nameController.text = _product.name;
      _priceController.text = _product.price.toString();
      _discountController.text = _product.discount.toString();
      _descriptionController.text = _product.description;
      Get.find<RestaurantController>().setDiscountTypeIndex(_product.discountType == 'percent' ? 0 : 1, false);
    }else {
      _product = Product();
      Get.find<RestaurantController>().pickImage(false, true);
      _product.availableTimeStarts = Get.find<AuthController>().profileModel.restaurants[0].availableTimeStarts;
      _product.availableTimeEnds = Get.find<AuthController>().profileModel.restaurants[0].availableTimeEnds;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.product != null ? 'update_food'.tr : 'add_food'.tr),
      body: GetBuilder<RestaurantController>(builder: (restController) {

        return restController.attributeList != null ? Column(children: [

          Expanded(child: SingleChildScrollView(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            physics: BouncingScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              MyTextField(
                hintText: 'food_name'.tr,
                controller: _nameController,
                capitalization: TextCapitalization.words,
                focusNode: _nameNode,
                nextFocus: _priceNode,
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

              MyTextField(
                hintText: 'price'.tr,
                controller: _priceController,
                focusNode: _priceNode,
                nextFocus: _discountNode,
                isAmount: true,
                amountIcon: true,
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

              Row(children: [

                Expanded(child: MyTextField(
                  hintText: 'discount'.tr,
                  controller: _discountController,
                  focusNode: _discountNode,
                  isAmount: true,
                )),
                SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'discount_type'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).disabledColor),
                  ),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 2, blurRadius: 5, offset: Offset(0, 5))],
                    ),
                    child: DropdownButton<String>(
                      value: restController.discountTypeIndex == 0 ? 'percent' : 'amount',
                      items: <String>['percent', 'amount'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.tr),
                        );
                      }).toList(),
                      onChanged: (value) {
                        restController.setDiscountTypeIndex(value == 'percent' ? 0 : 1, true);
                      },
                      isExpanded: true,
                      underline: SizedBox(),
                    ),
                  ),
                ])),

              ]),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

              Row(children: [

                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'category'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).disabledColor),
                  ),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 2, blurRadius: 5, offset: Offset(0, 5))],
                    ),
                    child: DropdownButton<int>(
                      value: restController.categoryIndex,
                      items: restController.categoryIds.map((int value) {
                        return DropdownMenuItem<int>(
                          value: restController.categoryIds.indexOf(value),
                          child: Text(value != 0 ? restController.categoryList[(restController.categoryIds.indexOf(value)-1)].name : 'Select'),
                        );
                      }).toList(),
                      onChanged: (int value) {
                        restController.setCategoryIndex(value, true);
                        restController.getSubCategoryList(value != 0 ? restController.categoryList[value-1].id : 0, null);
                      },
                      isExpanded: true,
                      underline: SizedBox(),
                    ),
                  ),
                ])),
                SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'sub_category'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).disabledColor),
                  ),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 2, blurRadius: 5, offset: Offset(0, 5))],
                    ),
                    child: DropdownButton<int>(
                      value: restController.subCategoryIndex,
                      items: restController.subCategoryIds.map((int value) {
                        return DropdownMenuItem<int>(
                          value: restController.subCategoryIds.indexOf(value),
                          child: Text(value != 0 ? restController.subCategoryList[(restController.subCategoryIds.indexOf(value)-1)].name : 'Select'),
                        );
                      }).toList(),
                      onChanged: (int value) {
                        restController.setSubCategoryIndex(value, true);
                      },
                      isExpanded: true,
                      underline: SizedBox(),
                    ),
                  ),
                ])),

              ]),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

              AttributeView(restController: restController, product: widget.product),

              Text(
                'addons'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).disabledColor),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
              GetBuilder<AddonController>(builder: (addonController) {
                List<int> _addons = [];
                if(addonController.addonList != null) {
                  for(int index=0; index<addonController.addonList.length; index++) {
                    _addons.add(index);
                  }
                }
                return Autocomplete<int>(
                  optionsBuilder: (TextEditingValue value) {
                    if(value.text.isEmpty) {
                      return Iterable<int>.empty();
                    }else {
                      return _addons.where((addon) => addonController.addonList[addon].name.toLowerCase().contains(value.text.toLowerCase()));
                    }
                  },
                  fieldViewBuilder: (context, controller, node, onComplete) {
                    _c = controller;
                    return Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 2, blurRadius: 5, offset: Offset(0, 5))],
                      ),
                      child: TextField(
                        controller: controller,
                        focusNode: node,
                        onEditingComplete: () {
                          onComplete();
                          controller.text = '';
                        },
                        decoration: InputDecoration(
                          hintText: 'addons'.tr,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), borderSide: BorderSide.none),
                        ),
                      ),
                    );
                  },
                  displayStringForOption: (value) => addonController.addonList[value].name,
                  onSelected: (int value) {
                    _c.text = '';
                    restController.setSelectedAddonIndex(value, true);
                    //_addons.removeAt(value);
                  },
                );
              }),
              SizedBox(height: restController.selectedAddons.length > 0 ? Dimensions.PADDING_SIZE_SMALL : 0),
              SizedBox(
                height: restController.selectedAddons.length > 0 ? 40 : 0,
                child: ListView.builder(
                  itemCount: restController.selectedAddons.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      ),
                      child: Row(children: [
                        GetBuilder<AddonController>(builder: (addonController) {
                          return Text(
                            addonController.addonList[restController.selectedAddons[index]].name,
                            style: robotoRegular.copyWith(color: Theme.of(context).cardColor),
                          );
                        }),
                        InkWell(
                          onTap: () => restController.removeAddon(index),
                          child: Padding(
                            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            child: Icon(Icons.close, size: 15, color: Theme.of(context).cardColor),
                          ),
                        ),
                      ]),
                    );
                  },
                ),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

              Row(children: [

                Expanded(child: CustomTimePicker(
                  title: 'available_time_starts'.tr, time: _product.availableTimeStarts,
                  onTimeChanged: (time) => _product.availableTimeStarts = time,
                )),
                SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                Expanded(child: CustomTimePicker(
                  title: 'available_time_ends'.tr, time: _product.availableTimeEnds,
                  onTimeChanged: (time) => _product.availableTimeEnds = time,
                )),

              ]),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

              MyTextField(
                hintText: 'description'.tr,
                controller: _descriptionController,
                focusNode: _descriptionNode,
                capitalization: TextCapitalization.sentences,
                maxLines: 5,
                inputAction: TextInputAction.newline,
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

              Text(
                'food_image'.tr,
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
                    image: '${Get.find<SplashController>().configModel.baseUrls.productImageUrl}/${_product.image != null ? _product.image : ''}',
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

            ]),
          )),

          !restController.isLoading ? CustomButton(
            buttonText: _update ? 'update'.tr : 'submit'.tr,
            margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            height: 50,
            onPressed: () {
              String _name = _nameController.text.trim();
              String _price = _priceController.text.trim();
              String _discount = _discountController.text.trim();
              String _description = _descriptionController.text.trim();
              bool _haveBlankVariant = false;
              bool _blankVariantPrice = false;
              for(AttributeModel attr in restController.attributeList) {
                if(attr.active && attr.variants.length == 0) {
                  _haveBlankVariant = true;
                  break;
                }
              }
              for(VariantTypeModel variantType in restController.variantTypeList) {
                if(variantType.controller.text.isEmpty) {
                  _blankVariantPrice = true;
                  break;
                }
              }
              if(_name.isEmpty) {
                showCustomSnackBar('enter_food_name'.tr);
              }else if(_price.isEmpty) {
                showCustomSnackBar('enter_food_price'.tr);
              }else if(_discount.isEmpty) {
                showCustomSnackBar('enter_food_discount'.tr);
              }else if(restController.categoryIndex == 0) {
                showCustomSnackBar('select_a_category'.tr);
              }else if(_haveBlankVariant) {
                showCustomSnackBar('add_at_least_one_variant_for_every_attribute'.tr);
              }else if(_blankVariantPrice) {
                showCustomSnackBar('enter_price_for_every_variant'.tr);
              }else if(!_update && restController.pickedLogo == null) {
                showCustomSnackBar('upload_food_image'.tr);
              }else {
                _product.name = _name;
                _product.price = double.parse(_price);
                _product.discount = double.parse(_discount);
                _product.discountType = restController.discountTypeIndex == 0 ? 'percent' : 'amount';
                _product.categoryIds = [];
                _product.categoryIds.add(CategoryIds(id: restController.categoryList[restController.categoryIndex-1].id.toString()));
                if(restController.subCategoryIndex != 0) {
                  _product.categoryIds.add(CategoryIds(id: restController.subCategoryList[restController.subCategoryIndex-1].id.toString()));
                }
                _product.description = _description;
                _product.addOns = [];
                restController.selectedAddons.forEach((index) {
                  _product.addOns.add(Get.find<AddonController>().addonList[index]);
                });
                restController.addProduct(_product, Get.find<AuthController>().getUserToken(), widget.product == null);
              }
            },
          ) : Center(child: CircularProgressIndicator()),

        ]) : Center(child: CircularProgressIndicator());
      }),
    );
  }
}