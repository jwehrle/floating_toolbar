import 'package:floating_toolbar/toolbar.dart';
import 'package:flutter/material.dart';
import 'package:iconic_button/iconic_button.dart';

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
  bool _reactiveButtonSelected = false;
  ButtonController _reactiveController = ButtonController();
  List<ButtonController> _popupControllers = [];
  int _loremIndex = 0;
  List<FloatingToolbarItem> _primaryItems = [];
  late EdgeInsets _margin;
  final EdgeInsets _buttonContentPadding =
      EdgeInsets.symmetric(horizontal: 8.0);
  ValueNotifier<String?> _displayTextNotifier = ValueNotifier(null);

  void _snack() {
    // _hideIndices.value = {2};
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
    _itemSelector.selected = null;
  }

  void _snackSelected() => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('You tapped the an enabled button and now it is selected'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );

  void _snackUnselected() => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('You tapped the an enabled button and now it is unselected'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );

  void _enabledButtonOnPressed() {
    _reactiveButtonSelected = !_reactiveButtonSelected;
    print(_reactiveButtonSelected);
    if (_reactiveButtonSelected) {
      _snackSelected();
    } else {
      _snackUnselected();
    }
  }

  FocusNode _focusNode = FocusNode();
  ValueNotifier<bool> _hasFocus = ValueNotifier(false);
  ItemSelector _itemSelector = ItemSelector();
  Set<int> _hideIndices = {};

  void _focusListener() {
    _hasFocus.value = _focusNode.hasFocus;
    setState(() {
      _margin = _focusNode.hasFocus ? EdgeInsets.zero : EdgeInsets.all(4.0);
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_focusListener);
    _margin = EdgeInsets.all(4.0);
    for (int index = 0; index < _iconList.length; index++) {
      String label = _numberNames[index]!;
      if (index == 0) {
        _primaryItems.add(
          FloatingToolbarItem.custom(
            ValueListenableBuilder<bool>(
                valueListenable: _hasFocus,
                builder: (context, value, _) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    width: value ? 250.0 : 200.0,
                    child: TextField(
                      focusNode: _focusNode,
                      onSubmitted: (value) {
                        if (value.toLowerCase().contains('hide')) {
                          setState(() => _hideIndices = {1});
                        }
                        if (value.toLowerCase().contains('show')) {
                          setState(() => _hideIndices = {});
                        }
                      },
                      onChanged: (text) => _displayTextNotifier.value = text,
                      decoration: InputDecoration(
                        hintText: '\"hide\" or \"show\"',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(),
                        isDense: true,
                        // isCollapsed: true,
                      ),
                    ),
                  );
                }),
          ),
        );
      } else if (index == _reactiveIndex) {
        _primaryItems.add(
          FloatingToolbarItem.basic(
            IconicButton(
              controller: _reactiveController,
              iconData: _iconList[index],
              onPressed: _enabledButtonOnPressed,
              elevation: 0.0,
              label: 'Diff',
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
                  isEnabled: state.contains(ButtonState.enabled),
                  isSelected: state.contains(ButtonState.selected),
                  iconData: Icons.tag_faces,
                  elevation: 4.0,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(8.0),
                  primary: theme.primaryColor,
                  onPrimary: theme.colorScheme.onPrimary,
                  onSurface: theme.colorScheme.onSurface,
                  onPressed: _snack,
                  preferTooltipBelow: false,
                  tooltip: 'Popup tooltip!',
                );
              },
            ),
          );
        }
        _primaryItems.add(
          FloatingToolbarItem.popup(
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
    final theme = Theme.of(context);
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ValueListenableBuilder<String?>(
                        valueListenable: _displayTextNotifier,
                        builder: (context, value, _) {
                          if (value?.contains('hide') ?? false) {
                            value = 'Hiding $_hideIndices';
                          }
                          if (value?.contains('show') ?? false) {
                            value = 'Showing all indicies';
                          }
                          return Text(value ?? 'Enter text in toolbar');
                        }),
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 16.0)),
                  SwitchListTile.adaptive(
                    title: Text('Enable/Disable Button'),
                    subtitle:
                        Text('Scroll to find the button that says Enable'),
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
                ],
              ),
            ),
            FloatingToolbar(
              items: _primaryItems,
              toolbarStyle: ToolbarStyle.bottomCenterHorizontal(
                margin: _margin,
                backgroundColor: theme.primaryColor,
              ),
              toolbarButtonStyle: ToolbarButtonStyle(
                padding: _buttonContentPadding,
                preferTooltipBelow: false,
                equalizedSize: findEqualizedSize(
                  context: context,
                  items: _primaryItems,
                  textStyle: theme.textTheme.labelSmall,
                  padding: _buttonContentPadding,
                ),
              ),
              onValueChanged: (index) => print(index),
              itemSelector: _itemSelector,
              barrier: ToolbarBarrier(),
              hide: _hideIndices,
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
    _displayTextNotifier.dispose();
    _focusNode.removeListener(_focusListener);
    _focusNode.dispose();
    _hasFocus.dispose();
    _itemSelector.dispose();
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
