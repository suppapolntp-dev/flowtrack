import 'package:flutter/material.dart';
import 'package:flowtrack/data/models/add_date.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Add_Screen extends StatefulWidget {
  const Add_Screen({super.key});

  @override
  State<Add_Screen> createState() => _Add_ScreenState();
}

class _Add_ScreenState extends State<Add_Screen> {
  final box = Hive.box<Add_data>('data');
  DateTime date = DateTime.now();
  String? selctedItem;
  String? selctedItemi = "Income";
  final TextEditingController expalin_C = TextEditingController();
  FocusNode ex = FocusNode();
  final TextEditingController amount_c = TextEditingController();
  FocusNode amount_ = FocusNode();
  final List<String> _item = [
    'Food',
    "Coffee",
    "Grocery",
    "Food-delivery",
    "Gas-pump",
    "Public Transport",
    "Rent or Mortgage",
    "Water Bill",
    "Electricity Bill",
    "Internet Bill",
    "Clothes",
    "Shoes",
    "Accessories",
    "Personal Care Items",
    "Movie",
    "Concert",
    "Hobby",
    "Travel",
    "Health-Report",
    "Doctor VisitsHospital",
    "Education",
    "Bank Fees",
    "Giftbox",
    "Donation",
  ];
  final List<String> _itemei = ['Income', "Expand"];
  @override
  void initState() {
    super.initState();
    selctedItemi = _itemei.first; // กำหนดให้เลือกตัวแรกเป็นค่าเริ่มต้น
    ex.addListener(() {
      setState(() {});
    });
    amount_.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            background_container(context),
            Positioned(top: 120, child: main_container()),
          ],
        ),
      ),
    );
  }

  Container main_container() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      height: 550,
      width: 340,
      child: Column(
        children: [
          SizedBox(height: 50),
          name(),
          SizedBox(height: 30),
          explain(),
          SizedBox(height: 30),
          amount(),
          SizedBox(height: 30),
          How(),
          SizedBox(height: 30),
          date_time(),
          Spacer(),
          save(),
          SizedBox(height: 25),
        ],
      ),
    );
  }

  GestureDetector save() {
    return GestureDetector(
      onTap: () {
        // เช็คว่าข้อมูลครับหรือยัง
        if (selctedItemi == null ||
            selctedItem == null ||
            amount_c.text.isEmpty ||
            expalin_C.text.isEmpty) {
          // แสดง snackbar แจ้งเตือน
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        var add = Add_data(
          selctedItemi!,
          amount_c.text,
          date,
          expalin_C.text,
          selctedItem!,
        );
        box.add(add);
        Navigator.of(context).pop();
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(0xFFFFC870 ),
        ),
        width: 120,
        height: 50,
        child: Text(
          'Save',
          style: TextStyle(
            fontFamily: 'f',
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  Widget date_time() {
    return Container(
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 2, color: Color(0xffC5C5C5)),
      ),
      width: 300,
      child: TextButton(
        onPressed: () async {
          DateTime? newDate = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (newDate == Null) return;
          setState(() {
            date = newDate!;
          });
        },
        child: Text(
          'Date : ${date.year} / ${date.day} / ${date.month}',
          style: TextStyle(fontSize: 15, color: Colors.black),
        ),
      ),
    );
  }

  Padding How() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: _itemei
            .map((item) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selctedItemi = item;
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 2,
                              color: selctedItemi == item
                                  ? Colors.blue
                                  : Color(0xffC5C5C5)),
                          color: selctedItemi == item
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selctedItemi == item
                                      ? Colors.blue
                                      : Colors.black,
                                  fontWeight: selctedItemi == item
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                )),
                            SizedBox(width: 5),
                            if (selctedItemi == item)
                              Icon(Icons.check_circle,
                                  color: Colors.blue, size: 20)
                            else
                              Icon(Icons.radio_button_unchecked,
                                  color: Colors.grey, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Padding amount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        keyboardType: TextInputType.number,
        focusNode: amount_,
        controller: amount_c,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'amount',
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade500),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 2, color: Color(0xffC5C5C5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 2, color: Color(0xFFFFC870 )),
          ),
        ),
      ),
    );
  }

  Padding explain() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        focusNode: ex,
        controller: expalin_C,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'explain',
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade500),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 2, color: Color(0xffC5C5C5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 2, color: Color(0xFFFFC870 )),
          ),
        ),
      ),
    );
  }

  Padding name() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InputDecorator(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'Payment type',
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade500),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 2, color: Color(0xffC5C5C5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 2, color: Color(0xFFFFC870 )),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selctedItem,
            onChanged: ((value) {
              setState(() {
                selctedItem = value!;
              });
            }),
            items: _item
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            child: Image.asset('images/${e}.png'),
                          ),
                          SizedBox(width: 10),
                          Text(e, style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
            selectedItemBuilder: (BuildContext context) => _item
                .map(
                  (e) => Row(
                    children: [
                      SizedBox(width: 42, child: Image.asset('images/$e.png')),
                      SizedBox(width: 5),
                      Text(e),
                    ],
                  ),
                )
                .toList(),
            hint: Text('Select payment type',
                style: TextStyle(color: Colors.grey)),
            dropdownColor: Colors.white,
            isExpanded: true,
          ),
        ),
      ),
    );
  }

  Column background_container(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: Color(0xFFFFC870 ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      'Adding',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Icon(Icons.attach_file_outlined, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
