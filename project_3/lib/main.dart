import 'package:flutter/material.dart';
import 'dart:collection';

class CalculatorFrame extends StatefulWidget{
  const CalculatorFrame({super.key});
  @override
  State<CalculatorFrame> createState() => _Calculator();
}

class _Calculator extends State<CalculatorFrame>{
  final TextEditingController _controller =
    TextEditingController();
  final List<String> symbols = [
    '(', 'CLR', 'DEL', '+',
    '7', '8', '9', '-',
    '4', '5', '6', '×',
    '1', '2', '3', '÷',
    ')', '0', '.', '='
  ];
  bool inputExceptionsExists() {
    if ((_controller.text.compareTo('math error') == 0) ||
        (_controller.text.compareTo('syntax error') == 0)) {
      _controller.text = "";
      return true;
    } return false;
  }
  void onPress(String value) {
    if (inputExceptionsExists()) {return;}
    else if (value == 'CLR') {onClear();}
    else if (value == 'DEL') {onDelete();}
    else if (value == '=') {onEqual();}
    else {_controller.text += value;}
  }
  void onClear() {
    _controller.text = "";
  }
  void onDelete() {
    if (_controller.text == "") {return;}
    _controller.text = _controller.text.substring(
      0, _controller.text.length - 1
    );
  }
  void onEqual() {
    String? exp = _controller.text;
    List<String> stack = [];
    Queue<String> queue = Queue<String>();
    String buffer = "";
    for (int i = 0; i < exp.length; i++) {
      if ('(+-×÷'.contains(exp[i])) {
        if (stack.isEmpty) {
          stack.add(exp[i]);
        } else if (
          '+-'.contains(exp[i]) &&
          '×÷'.contains(stack[stack.length - 1])
        ) {
          queue.add(stack.removeLast());
          stack.add(exp[i]);
        } else {stack.add(exp[i]);}
      } else if ('.0123456789'.contains(exp[i])) {
        buffer += exp[i];
        if (i + 1 < exp.length && '(+-×÷)'.contains(exp[i + 1])) {
          queue.add(buffer);
          buffer = "";
        } else {
          if (exp.length - 1 == i) {
            queue.add(buffer);
            buffer = "";
          }
        }
      }
      if (exp[i] == ')' || exp.length - 1 == i) {
        while (stack.isNotEmpty) {
          String value = stack.removeLast();
          if (value != '(') {
            queue.add(value);
          } else {continue;}
        }
      }
    }
    while (queue.isNotEmpty){
      String? item = queue.removeFirst();
      if ('+-×÷'.contains(item)) {
        double value2 = double.parse(stack.removeLast());
        double value1 = double.parse(stack.removeLast());
        try {
          if (item == "÷") {
            stack.add((value1/value2).toString());
          } else if (item == '×') {
            stack.add((value1*value2).toString());
          } else if (item == '-') {
            stack.add((value1-value2).toString());
          } else if (item == '+') {
            stack.add((value1+value2).toString());
          }
        } on Exception {
          _controller.text = 'syntax error';
        }
      } else {stack.add(item);}
    }
    if (stack[0].compareTo('Infinity') == 0) {
      _controller.text = 'math error';
    } else {
      _controller.text = stack.removeLast();
    }
  }
  List<Widget> assignSymbol(List<String> values) {
    List<Widget> textButtons = [];
    for (int i=0; i < values.length; i++) {
      Container buffer = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              width: 1.0,
              color: Colors.black
            )
          ),
          child: TextButton(
            onPressed: () => onPress(values[i]),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white70
            ),
            child: Text(
              values[i],
              textDirection: TextDirection.ltr,
              style: TextStyle(
                fontSize: 25,
                color: Colors.black
              )
            )
          )
      );
      textButtons.add(buffer);
    }
    return textButtons;
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              color: Colors.black,
              width: 1.0
            )
          ),
          child: TextFormField(
            showCursor: false,
            controller: _controller,
            style: TextStyle(
              fontSize: 30,
              color: Colors.black
            ),
          )
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            physics: NeverScrollableScrollPhysics(),
            children: assignSymbol(symbols)
          )
        )
      ]
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Calculator',
            textDirection: TextDirection.ltr
          ),
        ),
        body: CalculatorFrame()
      )
    )
  );
}