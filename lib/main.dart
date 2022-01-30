import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const DateCountdown());

class DateCountdown extends StatelessWidget {
  const DateCountdown({Key? key}) : super(key: key);
  
  static const String _title = 'Date Countdown';
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    debugShowCheckedModeBanner: false,
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainActivity(title: _title),
    );
  }
}

class MainActivity extends StatefulWidget {
  const MainActivity({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainActivity> createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {

  DateTime _selectedDate = DateTime.now();
  late final SharedPreferences _prefs;
  bool _dateLoaded = false;
  
  void _loadDate() async{
    _prefs = await SharedPreferences.getInstance();
    var dateStr = _prefs.getString('date');
    if (dateStr != null) {
      setState(() {
        _selectedDate = DateTime.parse(dateStr);
      });
    }
    _dateLoaded = true;
  }
  
  // for some reason, there is a 0 difference between today
  // and tomorrow, so I had to swing some code golf
  Text get countdown {
    var now = DateTime.now();
    var diff = _selectedDate.difference(now).inDays;
    var until = 'until';
    if (diff < 0) {
        until = 'since';
        diff *= -1;
    } else diff++;
    if (diff == 1 && now.day == _selectedDate.day)
      diff = 0;
    var days = 'days';
    if (diff == 1) { 
      days = 'day';
    }
    return Text(
      '$diff $days $until',
      style: const TextStyle(
        fontSize: 28,
      ),
    );
  }
  
  // this is to rerender the CuptertinoDatePicker
  // since it only has initialDateTime and no date setter
  Key get datePickerKey {
    if (_dateLoaded)
      return Key('CDP0');
    return UniqueKey();
  }

  CupertinoDatePicker get datePicker => CupertinoDatePicker(
    key: datePickerKey,
    mode: CupertinoDatePickerMode.date,
    onDateTimeChanged: (DateTime dateTime) {
      setState(() {
        _selectedDate = dateTime;
      });
    },
    initialDateTime: _selectedDate,
  );
  
  ElevatedButton _getSaveButton(context) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 20,
      ),
    ),
    onPressed: () {
      _prefs.setString('date', _selectedDate.toString());
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: const Text('Saved!'),
          action: SnackBarAction(
            label: 'Reset',
            onPressed: () {
              _prefs.setString('date', DateTime.now().toString());
            }
          ),
        ),
      );
    },
    child: const Text('Save'),
  );
  
  @override
  void initState() {
    super.initState();
    _loadDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(flex: 2),
            Expanded(
              flex: 1,
              child: countdown,
            ),
            const Spacer(),
            Expanded(
              flex: 5,
              child: datePicker,
            ),
            const Spacer(),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Spacer(),
                  Expanded(
                    flex: 2,
                    child: _getSaveButton(context),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
