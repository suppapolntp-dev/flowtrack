import 'package:flutter/material.dart';
import 'package:flowtrack/screens/add.dart';
import 'package:flowtrack/screens/home.dart';
import 'package:flowtrack/screens/statistics.dart';
import 'package:flowtrack/screens/wallet.dart';
import 'package:flowtrack/screens/category_manager.dart';

class Bottom extends StatefulWidget {
  const Bottom({super.key});

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  int index_color = 0;

  @override
  Widget build(BuildContext context) {
    // กำหนดหน้าจอต่างๆ
    List<Widget> screens = [
      Home(), // หน้าแรก
      Statistics(), // สถิติ
      WalletScreen(), // Wallet (หน้าใหม่)
      CategoryManagerScreen(), // จัดการหมวดหมู่ (แทน Personal)
    ];

    return Scaffold(
      body: screens[index_color],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Add_Screen()));
        },
        backgroundColor: Color(0xFFFFC870),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.only(top: 7.5, bottom: 7.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Home
              GestureDetector(
                onTap: () {
                  setState(() {
                    index_color = 0;
                  });
                },
                child: Icon(
                  Icons.home,
                  size: 30,
                  color: index_color == 0 ? Color(0xFFFFC870) : Colors.grey,
                ),
              ),

              // Statistics
              GestureDetector(
                onTap: () {
                  setState(() {
                    index_color = 1;
                  });
                },
                child: Icon(
                  Icons.bar_chart_outlined,
                  size: 30,
                  color: index_color == 1 ? Color(0xFFFFC870) : Colors.grey,
                ),
              ),

              // Spacer for FAB
              SizedBox(width: 10),

              // Wallet
              GestureDetector(
                onTap: () {
                  setState(() {
                    index_color = 2;
                  });
                },
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 30,
                  color: index_color == 2 ? Color(0xFFFFC870) : Colors.grey,
                ),
              ),

              // Category Manager (แทน Personal)
              GestureDetector(
                onTap: () {
                  setState(() {
                    index_color = 3;
                  });
                },
                child: Icon(
                  Icons.category_outlined,
                  size: 30,
                  color: index_color == 3 ? Color(0xFFFFC870) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
