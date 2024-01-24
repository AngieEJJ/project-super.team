import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:leute/data/models/foods_model.dart';
import 'package:leute/data/models/refrige_model.dart';
import 'package:leute/view/page/my_food_detail_page/my_food_detail_view_model.dart';
import 'package:leute/view/widget/custom_dialog/two_answer_dialog.dart';
import 'package:leute/styles/app_text_colors.dart';
import 'package:leute/styles/app_text_style.dart';
import 'package:leute/view/widget/my_food_detail_page_widget/my_food_detail_page_widget.dart';

import '../../../data/repository/foods_repository.dart';
import '../../../data/repository/refrige_repository.dart';

class MyFoodDetail extends StatefulWidget {
  const MyFoodDetail(
      {super.key, required this.myFoodItem, required this.ourRefrigeItem});

  final FoodDetail myFoodItem;
  final RefrigeDetail ourRefrigeItem;

  @override
  State<MyFoodDetail> createState() => _MyFoodDetailState();
}

class _MyFoodDetailState extends State<MyFoodDetail> {

  final myFoodViewModel = MyFoodDetailViewModel();
  int _remainPeriod =0;
  bool _isOld = false;

  @override
  void initState() {
    _isOld = myFoodViewModel.isOld(widget.myFoodItem, widget.ourRefrigeItem);
    initData();
    super.initState();
    _remainPeriod = myFoodViewModel.calculateRemainPeriod(
        widget.myFoodItem, widget.ourRefrigeItem);
  }

  void initData() async {
    final foods = RegisterdFoodsRepository().getFirebaseFoodsData();
    setState(() {
      foods;
    });
  }

  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일');
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyFoodDetailPageWidget(
                  itemImage: widget.myFoodItem.foodImage,
                ),
              ),
            );
          },
          child: Hero(
            tag: 'imageTag',
            child: Container(
              height: 200.h,
              width: 300.w,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.network(widget.myFoodItem.foodImage,
                    fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        SizedBox(height: 32.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                      '등록일: ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(widget.myFoodItem.registerDate))}',
                      style: AppTextStyle.body14R()),
                ],
              ),
              Row(
                children: [
                  Text('남은기간: ', style: AppTextStyle.body14R()),
                  Text(
                    '$_remainPeriod일',
                    style: AppTextStyle.body14R(
                        color: myFoodViewModel.isOld(
                                widget.myFoodItem, widget.ourRefrigeItem)
                            ? AppColors.caution
                            : AppColors.mainText),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[50]),
                    onPressed: _isOld
                        ? () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return TwoAnswerDialog(
                                      title: '연장하시겠습니까?',
                                      firstButton: '네',
                                      secondButton: '아니오',
                                      onTap: () {
                                        setState(() {
                                         _isOld = false;
                                          _remainPeriod =
                                              myFoodViewModel.extendPeriod(
                                                  widget.myFoodItem,
                                                  widget.ourRefrigeItem);
                                        });
                                        Navigator.of(context).pop();
                                      });
                                });
                          }
                        : null,
                    child: const Text('연장하기'),
                  )
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return TwoAnswerDialog(
                                  title: '등록한 음식을 삭제하시겠습니까?',
                                  firstButton: '네',
                                  secondButton: '아니오',
                                  onTap: () {
                                    Navigator.of(context).pop(); //네 버튼 동작
                                  });
                            });
                      },
                      child: const Text('삭제하기')),
                ],
              ),
              SizedBox(height: 32.h),
              myFoodViewModel.isOld(widget.myFoodItem, widget.ourRefrigeItem)
                  ? Text('곧 폐기됩니다.',
                      style: AppTextStyle.body14R(color: AppColors.caution))
                  : const Text('아직은 연장이 불가해요.'),
            ],
          ),
        ),
      ]),
    );
  }
}