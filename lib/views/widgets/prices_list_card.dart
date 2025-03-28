import 'package:flutter/material.dart';

class PricesListCard extends StatefulWidget {
  const PricesListCard({super.key});

  @override
  State<PricesListCard> createState() => _PricesListCardState();
}

class _PricesListCardState extends State<PricesListCard> {

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int numberOfDashes = (screenWidth /10).round();
    String dashes = ('-' + ' ') * numberOfDashes;

    return Container(
                height: 215,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                ),
                child : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 10, left: 30, right: 30),
                          child: Text(
                            'Articles achetés ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(112,123,129, 1.0),
                              fontFamily: 'Lato',),
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 10, left: 30, right: 30),
                          child: Text(
                            '11.40€ ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,),
                          ),
                        ),
                      ]
                    ),
                    Text(
                      ' $dashes ',
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(112,123,129, 1.0),
                        fontFamily: 'Lato',),
                    ),
                    Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10, left: 30, right: 30),
                            child: Text(
                              'Coût total ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(112,123,129, 1.0),
                                fontFamily: 'Lato',),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10, left: 30, right: 30),
                            child: Text(
                              '15.90€ ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,),
                            ),
                          ),
                        ]
                    ),
                  ],
                ),
            );
  }
}
