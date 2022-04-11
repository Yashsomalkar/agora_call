import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../size_config.dart';

class DialButton extends StatelessWidget {
  const DialButton({
    Key? key,
    @required this.iconSrc,
    @required this.text,
    @required this.press,
    this.isActive = false,
  }) : super(key: key);

  final String? iconSrc, text;
  final VoidCallback? press;
  final bool? isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: SizedBox(
        width: getProportionateScreenWidth(120),
        child: Container(
          decoration: BoxDecoration(
              color: isActive! ? Colors.white.withOpacity(0.5) : Colors.transparent,
              shape: BoxShape.circle),
          padding: EdgeInsets.symmetric(
            vertical: getProportionateScreenWidth(20),
          ),
          child: Column(
            children: [
              SvgPicture.asset(
                iconSrc!,
                color: isActive! ? Colors.black : Colors.white,
                height: 36,
              ),
              VerticalSpacing(of: 5),
              Text(
                text!,
                style: TextStyle(
                  color: isActive! ? Colors.black : Colors.white,
                  fontSize: 13,
                ),
              )
            ],
          ),
        ),
      ),
    );

    // return SizedBox(
    //   width: getProportionateScreenWidth(120),
    //   child: Container(
    //     decoration: BoxDecoration(
    //       color: backgroundColor,
    //       shape: BoxShape.circle
    //     ),
    //     padding: EdgeInsets.symmetric(
    //       vertical: getProportionateScreenWidth(20),
    //     ),
    //     child: InkWell(
    //       onTap: press,
    //       child: Column(
    //       children: [
    //         SvgPicture.asset(
    //           iconSrc!,
    //           color: Colors.white,
    //           height: 36,
    //         ),
    //         VerticalSpacing(of: 5),
    //         Text(
    //           text!,
    //           style: TextStyle(
    //             color: Colors.white,
    //             fontSize: 13,
    //           ),
    //         )
    //       ],
    //     ),
    //     ),
    //   ),
    // );
  }
}
