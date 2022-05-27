import 'package:floating_toolbar/toolbar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp() : super();

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
  List<IconData> _iconList = [
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

  Map<int, String> _numberNames = {
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

  int _reactiveIndex = 6;
  bool _reactiveButtonEnabled = true;
  ButtonController _reactiveController = ButtonController();
  List<ButtonController> _popupControllers = [];
  int _loremIndex = 0;
  List<FloatingToolbarItem> _primaryItems = [];
  late EdgeInsets _margin;
  late ToolbarAlignment _toolbarAlignment;

  void _snack() {
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
  }

  void _enabledSnack() => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enabled!'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );

  @override
  void initState() {
    super.initState();
    _margin = EdgeInsets.all(4.0);
    _toolbarAlignment = ToolbarAlignment.bottomCenterHorizontal;
    for (int index = 0; index < _iconList.length; index++) {
      String label = _numberNames[index]!;
      if (index == _reactiveIndex) {
        _primaryItems.add(
          FloatingToolbarItem.custom(
            IconicButton(
              controller: _reactiveController,
              iconData: _iconList[index],
              onPressed: _enabledSnack,
              label: 'Enable?',
              tooltip: 'This is the enabled/disabled button',
            ),
          ),
        );
      } else {
        int num = 2 + (index % (3));
        List<PopupItemBuilder> buttons = [];
        for (int i = 0; i < num; i++) {
          ButtonController buttonController = ButtonController();
          _popupControllers.add(buttonController);
          buttons.add(
            PopupItemBuilder(
              controller: buttonController,
              builder: (context, state, child) {
                ThemeData theme = Theme.of(context);
                return BaseIconicButton(
                  state: state,
                  iconData: Icons.tag_faces,
                  style: selectableStyleFrom(
                    elevation: 4.0,
                    shape: CircleBorder(),
                    primary: theme.primaryColor,
                    onPrimary: theme.colorScheme.onPrimary,
                    onSurface: theme.colorScheme.onSurface,
                  ),
                  onPressed: _snack,
                  preferTooltipBelow: false,
                  tooltip: 'Popup tooltip!',
                );
              },
            ),
          );
        }
        _primaryItems.add(
          FloatingToolbarItem.standard(
            IconicItem(
              iconData: _iconList[index],
              label: label,
              tooltip: 'This is $label',
            ),
            buttons,
          ),
        );
      }
    }
  }

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
              child: SwitchListTile.adaptive(
                title: Text('Enable button'),
                value: _reactiveButtonEnabled,
                onChanged: (value) => setState(() {
                  _reactiveButtonEnabled = value;
                  if (_reactiveButtonEnabled) {
                    _reactiveController.enable();
                  } else {
                    _reactiveController.disable();
                  }
                }),
              ),
            ),
            FloatingToolbar(
              items: _primaryItems,
              backgroundColor: Theme.of(context).primaryColor,
              preferTooltipBelow: false,
              alignment: _toolbarAlignment,
              margin: _margin,
              contentPadding: EdgeInsets.all(4.0),
              popupSpacing: 4.0,
              buttonSpacing: 4.0,
              onValueChanged: (key) => setState(() => print('Pressed $key')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _popupControllers.forEach((element) => element.dispose());
    _reactiveController.dispose();
    super.dispose();
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
