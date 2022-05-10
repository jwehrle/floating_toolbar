import 'package:floating_toolbar/toolbar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FloatingToolbar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'FloatingToolbar Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String text = 'Blue';
  List<IconData> iconList = [
    Icons.link,
    Icons.arrow_downward,
    Icons.looks,
    Icons.margin,
    Icons.wrong_location,
    Icons.portrait,
    Icons.visibility,
    Icons.style,
    Icons.landscape,
  ];

  int colorIndex = 0;
  ValueNotifier<Color> colorNotifier = ValueNotifier(Colors.blue);
  List colors = [
    Colors.blue,
    Colors.red,
    Colors.yellow,
    Colors.indigo,
    Colors.deepOrange,
    Colors.amber,
  ];
  Map<Color, String> colorText = {
    Colors.blue: 'Blue',
    Colors.red: 'Red',
    Colors.yellow: 'Yellow',
    Colors.indigo: 'Indigo',
    Colors.deepOrange: 'Deep Orange',
    Colors.amber: 'Amber',
  };
  Map<int, String> numberNames = {
    0: 'One',
    1: 'Two',
    2: 'Three',
    3: 'Four',
    4: 'Five',
    5: 'Six',
    6: 'Seven',
    7: 'Eight',
    8: 'Nine',
  };

  int _colorItemIndex = 2;
  int _reactiveIndex = 6;
  List<FloatingToolbarItem> buttons = [];
  Color background = Colors.blue;
  Color accent = Colors.white;

  @override
  void initState() {
    super.initState();

    for (int index = 0; index < iconList.length; index++) {
      if (index == _colorItemIndex) {
        buttons.add(_colorFTItem(index));
      } else if (index == _reactiveIndex) {
        buttons.add(_reactiveFTItem(index));
      } else {
        buttons.add(_popItem(index, background, accent));
      }
    }
  }

  bool _reactiveButtonEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: kThemeChangeDuration,
                    width: 200.0,
                    height: 100.0,
                    alignment: Alignment.center,
                    color: colors[colorIndex],
                    child: Text(
                      text,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 16.0)),
                  SwitchListTile.adaptive(
                    title: Text('Enable button'),
                    value: _reactiveButtonEnabled,
                    onChanged: (value) => setState(() {
                      _reactiveButtonEnabled = value;
                      final button = _reactiveButtonKey.currentState;
                      if (_reactiveButtonEnabled) {
                        button?.enable();
                        button?.reset(label: 'Enabled');
                      } else {
                        button?.disable();
                        button?.reset(label: 'Disabled');
                      }
                    }),
                  )
                ],
              ),
            ),
            FloatingToolbar(
              items: buttons,
              preferTooltipBelow: false,
              popupStyle: buttonStyleFrom(
                elevation: 4.0,
                shape: CircleBorder(),
              ),
              alignment: ToolbarAlignment.bottomCenterHorizontal,
              margin: EdgeInsets.all(4.0),
              contentPadding: EdgeInsets.all(4.0),
              popupSpacing: 4.0,
              buttonSpacing: 4.0,
              onValueChanged: (key) =>
                  setState(() => print('ValueChanged called with $key')),
            ),
          ],
        ),
      ),
    );
  }

  GlobalKey<IconicButtonState> _reactiveButtonKey =
      GlobalKey<IconicButtonState>();

  FloatingToolbarItem _reactiveFTItem(int index) {
    return FloatingToolbarItem.custom(
        index.toString(),
        IconicButton(
          key: _reactiveButtonKey,
          iconData: iconList[index],
          onPressed: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(
                  SnackBar(
                    content: Text('Enabled!'),
                    action: SnackBarAction(
                      label: 'OK',
                      onPressed: () =>
                          ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                    ),
                  ),
                )
                .closed
                .then((value) => setState(() => _loremIndex++));
          },
          label: 'Enabled',
          tooltip: 'This is the enabled/disabled button',
        ));
  }

  GlobalKey<IconicButtonState> _colorButtonKey = GlobalKey<IconicButtonState>();

  FloatingToolbarItem _colorFTItem(int index) {
    return FloatingToolbarItem.custom(
        index.toString(),
        IconicButton(
          key: _colorButtonKey,
          iconData: iconList[index],
          style: buttonStyleFrom(primary: colors[colorIndex]),
          onPressed: () {
            setState(() {
              colorIndex = (colorIndex + 1) % colors.length;
              text = colorText[colors[colorIndex]] ?? 'Whoops';
              _colorButtonKey.currentState
                  ?.reset(style: buttonStyleFrom(primary: colors[colorIndex]));
            });
          },
          label: 'Color!',
          tooltip: 'This is $text button',
        ));
  }

  FloatingToolbarItem _popItem(int index, Color background, Color accent) {
    String label = numberNames[index]!;
    return FloatingToolbarItem.standard(
      index.toString(),
      IconicItem(
        iconData: iconList[index],
        onPressed: () => print('Pressed index: $index'),
        label: label,
        tooltip: 'This is $label',
      ),
      _popupList(index),
    );
  }

  List<IconicItem> _popupList(int index) {
    int num = 2 + (index % (3));
    List<IconicItem> buttons = [];
    for (int i = 0; i < num; i++) {
      buttons.add(_popup());
    }
    return buttons;
  }

  int _loremIndex = 0;

  IconicItem _popup() {
    return IconicItem(
      iconData: Icons.tag_faces,
      onPressed: () {
        String text = lorem[_loremIndex % lorem.length];
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Text(text),
                action: SnackBarAction(
                  label: 'OK',
                  onPressed: () =>
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                ),
              ),
            )
            .closed
            .then((value) => setState(() => _loremIndex++));
      },
    );
  }
}

List<String> lorem = [
  "Lorem ipsum dolor sit amet,",
  "consectetur adipiscing elit,",
  "sed do eiusmod tempor incididunt",
  "ut labore et dolore magna aliqua.",
  "Ut enim ad minim veniam,",
  "quis nostrud exercitation ullamco",
  "laboris nisi ut aliquip",
  "ex ea commodo consequat.",
  "Duis aute irure dolor in reprehenderit",
  "in voluptate velit esse cillum dolore",
  "eu fugiat nulla pariatur.",
  "Excepteur sint occaecat cupidatat",
  "non proident, sunt in culpa qui",
  "officia deserunt mollit",
  "anim id est laborum.",
];
