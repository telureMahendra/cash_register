import 'package:cash_register/common_utils/common_functions.dart';
import 'package:cash_register/helper/stream_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductFinalAmountWidget extends StatefulWidget {
  const ProductFinalAmountWidget({super.key});

  @override
  State<ProductFinalAmountWidget> createState() =>
      _ProductFinalAmountWidgetState();
}

class _ProductFinalAmountWidgetState extends State<ProductFinalAmountWidget> {
  String total = '';
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return StreamBuilder(
        stream: StreamHelper.cartFinalAmountStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              total = snapshot.data.toString();
              return SizedBox(
                width: width * 0.80,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Total: ",
                                style: TextStyle(
                                  fontSize: getadaptiveTextSize(context, 17),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                inrFormat.format(
                                    double.parse(snapshot.data.toString())),
                                style: TextStyle(
                                  fontSize: getadaptiveTextSize(context, 17),
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return SizedBox(
                                      width: width,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10.0,
                                          horizontal: 25.0,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Payment Details",
                                              style: TextStyle(
                                                  fontSize: getadaptiveTextSize(
                                                      context, 15),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: height * 0.015),
                                              child: Row(
                                                children: List.generate(
                                                  20,
                                                  (index) {
                                                    return Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 4.0,
                                                                right: 4.0),
                                                        child: Container(
                                                          height: 2,
                                                          width: 8,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Sub Total:",
                                                        style: TextStyle(
                                                          fontSize:
                                                              getadaptiveTextSize(
                                                                  context, 14),
                                                        ),
                                                      ),
                                                      Text(
                                                        inrFormat.format(double
                                                            .parse(snapshot.data
                                                                .toString())),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getadaptiveTextSize(
                                                                  context, 14),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Tax:",
                                                        style: TextStyle(
                                                          fontSize:
                                                              getadaptiveTextSize(
                                                                  context, 14),
                                                        ),
                                                      ),
                                                      Text(
                                                        "0.00",
                                                        style: TextStyle(
                                                          fontSize:
                                                              getadaptiveTextSize(
                                                                  context, 14),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Discount",
                                                        style: TextStyle(
                                                          fontSize:
                                                              getadaptiveTextSize(
                                                                  context, 14),
                                                        ),
                                                      ),
                                                      Text(
                                                        "0.00",
                                                        style: TextStyle(
                                                          fontSize:
                                                              getadaptiveTextSize(
                                                                  context, 14),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Total:",
                                                    style: TextStyle(
                                                      fontSize:
                                                          getadaptiveTextSize(
                                                              context, 16),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    inrFormat.format(
                                                        double.parse(snapshot
                                                            .data
                                                            .toString())),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getadaptiveTextSize(
                                                              context, 16),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Card(
                                              elevation: 2,
                                              shadowColor: Colors.black,
                                              color: Colors.white,
                                              child: SizedBox(
                                                  width: width * 0.90,
                                                  // height: height * 0.050,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          "Payment Method",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  getadaptiveTextSize(
                                                                      context,
                                                                      18),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                            "Please choose the one that suits you best."),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: height *
                                                                      0.015,
                                                                  bottom:
                                                                      height *
                                                                          0.015),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              OutlinedButton(
                                                                style: OutlinedButton
                                                                    .styleFrom(
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(6),
                                                                  ),
                                                                ),
                                                                onPressed:
                                                                    () {},
                                                                child: SizedBox(
                                                                  // height: 50,
                                                                  // width: 50,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            10.0),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .money,
                                                                          color:
                                                                              Colors.black,
                                                                          size: getadaptiveTextSize(
                                                                              context,
                                                                              15),
                                                                        ),
                                                                        Text(
                                                                          "Cash",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                getadaptiveTextSize(context, 15),
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              OutlinedButton(
                                                                onPressed:
                                                                    () {},
                                                                child: SizedBox(
                                                                  height: 50,
                                                                  width: 50,
                                                                  child: Text(
                                                                      "Cash"),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // background
                              foregroundColor: Colors.black, // foreground
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(6), // <-- Radius
                              ),
                            ),
                            child: SizedBox(
                              height: height * 0.060,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.print,
                                    color: Colors.black,
                                  ),
                                  Text(
                                    "Print",
                                    style: TextStyle(
                                      fontSize:
                                          getadaptiveTextSize(context, 13),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          }
          return Container();
        });
  }
}
