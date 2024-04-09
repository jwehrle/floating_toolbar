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

  // play with these to change popup shape and size
  final ButtonShape _popupButtonShape = ButtonShape.circle;
  // for other shapes use width and height
  final double _popupRadius = 20.0;

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

  int customItemIndex = 2;
  List<ToolbarItem> buttons = [];
  Color background = Colors.blue;
  Color accent = Colors.white;

  @override
  void initState() {
    super.initState();

    for (int index = 0; index < iconList.length; index++) {
      if (index == customItemIndex) {
        buttons.add(_noPopItem(index));
      } else {
        buttons.add(_popItem(index, background, accent));
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
              child: Text(text),
            ),
            FloatingToolbar(
              data: ToolbarData(
                backgroundColor: background,
                alignment: ToolbarAlignment.bottomCenterHorizontal,
                margin: EdgeInsets.all(4.0),
                contentPadding: EdgeInsets.all(4.0),
                popupSpacing: 4.0,
                buttonSpacing: 4.0,
                buttonSize: Size(45.0, 40.0),
              ),
              onPressed: (key) => setState(() {
                print(key);
                if (key == customItemIndex.toString()) {
                  colorIndex = (colorIndex + 1) % colors.length;
                  Color color = colors[colorIndex];
                  colorNotifier.value = color;
                  text = colorText[color] ?? 'Whoops';
                }
              }),
              items: buttons,
            ),
          ],
        ),
      ),
    );
  }

  ToolbarItem _noPopItem(int index) {
    return ToolbarItem.noPop(
      itemKey: index.toString(),
      selectableButtonBuilder: (data) => _selectableButton(index, data),
    );
  }

  SelectableButton _selectableButton(index, data) {
    return SelectableButton(
      data: data,
      unselectedButton: ValueListenableBuilder<Color>(
        valueListenable: colorNotifier,
        builder: (context, color, _) {
          String label = numberNames[index]!;
          return ButtonTile(
            iconData: iconList[index],
            label: label,
            backgroundColor: color,
            decorationColor: color,
            foregroundColor: Colors.white,
            tooltip: 'This is $label',
          );
        },
      ),
    );
  }

  ToolbarItem _popItem(int index, Color background, Color accent) {
    return ToolbarItem.pop(
      itemKey: index.toString(),
      popupButtonBuilder: (data) => _popupButton(
        index,
        data,
        background,
        accent,
      ),
      popupListBuilder: (data) => _popupList(
        index,
        data,
        background,
        accent,
      ),
    );
  }

  PopupButton _popupButton(int index, data, background, accent) {
    IconData iconData = iconList[index];
    String label = numberNames[index]!;
    return PopupButton(
      data: data,
      unselectedButton: ButtonTile(
        iconData: iconData,
        label: label,
        backgroundColor: background,
        decorationColor: background,
        foregroundColor: accent,
        tooltip: 'This is $label',
      ),
      selectedButton: ButtonTile(
        iconData: iconData,
        label: label,
        backgroundColor: background,
        decorationColor: accent,
        foregroundColor: background,
        tooltip: 'This is $label',
      ),
    );
  }

  PopupList _popupList(int index, data, background, accent) {
    int num = 2 + (index % (3));
    List<Widget> buttons = [];
    for (int i = 0; i < num; i++) {
      buttons.add(_popup(background, accent));
    }
    return PopupList(
      data: data,
      buttons: buttons,
    );
  }

  int _loremIndex = 0;

  Widget _popup(Color background, Color accent) {
    return GestureDetector(
      onTap: () {
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
      child: ButtonTile(
        iconData: Icons.tag_faces,
        buttonShape: _popupButtonShape,
        radius: _popupRadius,
        backgroundColor: background,
        decorationColor: background,
        foregroundColor: accent,
        tooltip: 'This is a popup button!',
        preferTooltipBelow: false,
        isMaterialized: true,
        elevation: 2.0,
      ),
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
