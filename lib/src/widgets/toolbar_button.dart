import 'package:floating_toolbar/src/utilities/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Toolbar button which shows a PopupList when selected
class PopupButton extends StatefulWidget {
  /// FloatingToolbar data used by PopupButton
  final PopupButtonData data;

  /// The primary child widget of this button
  final Widget unselectedButton;

  /// Optional child widget used when this button is selected
  final Widget? selectedButton;

  const PopupButton({
    Key? key,
    required this.data,
    required this.unselectedButton,
    this.selectedButton,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => PopupButtonState();
}

class PopupButtonState extends State<PopupButton> {
  final LayerLink _link = LayerLink();
  late final OverlayEntry _popupEntry;

  @override
  void initState() {
    super.initState();
    _popupEntry = OverlayEntry(
      builder: (context) => widget.data.popupListBuilder(
        PopupListData(
          itemKey: widget.data.itemKey,
          link: _link,
          selectionNotifier: widget.data.selectionNotifier,
          spacing: widget.data.popupSpacing,
          direction: widget.data.popupDirection,
          targetAnchor: widget.data.targetAnchor,
          followerAnchor: widget.data.followerAnchor,
          offset: widget.data.followerOffset,
        ),
      ),
    );
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      Overlay.of(context)?.insert(_popupEntry);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: SelectableButton(
        data: SelectableButtonData(
          itemKey: widget.data.itemKey,
          size: widget.data.size,
          selectionNotifier: widget.data.selectionNotifier,
          onSelectionChanged: widget.data.onSelectionChanged,
        ),
        unselectedButton: widget.unselectedButton,
        selectedButton: widget.selectedButton,
      ),
    );
  }

  @override
  void dispose() {
    _popupEntry.remove();
    super.dispose();
  }
}

/// Base button of FloatingToolbar. Selects this button in RadioButton fashion of
/// FloatingToolbar. Encapsulates parameters needed by SelectableButton from
/// FloatingToolbar.
class SelectableButtonData {
  /// The string associated by user with this button. Should be unique.
  final String itemKey;

  /// The size of this button
  final Size size;

  /// ValueNotifier for itemKeys of FloatingToolbar
  final ValueNotifier<String?> selectionNotifier;

  /// Callback for taps on buttons, passes itemKey
  final ValueChanged<String?>? onSelectionChanged;

  SelectableButtonData({
    required this.itemKey,
    required this.size,
    required this.selectionNotifier,
    required this.onSelectionChanged,
  });
}

/// Builder for SelectableButtons
typedef SelectableButtonBuilder = SelectableButton Function(
    SelectableButtonData data);

/// Toolbar button which is selectable withing FloatingToolbar
class SelectableButton extends StatelessWidget {
  /// FloatingToolbar data used by SelectableButton
  final SelectableButtonData data;

  /// The primary child widget of this button
  final Widget unselectedButton;

  /// Optional child widget used when this button is selected
  final Widget? selectedButton;

  const SelectableButton({
    Key? key,
    required this.data,
    required this.unselectedButton,
    this.selectedButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: data.size,
      child: GestureDetector(
        onTap: () {
          data.selectionNotifier.value =
              data.selectionNotifier.value == data.itemKey
                  ? null
                  : data.itemKey;
          if (data.onSelectionChanged != null) {
            data.onSelectionChanged!(data.itemKey);
          }
        },
        child: ValueListenableBuilder<String?>(
          valueListenable: data.selectionNotifier,
          builder: (context, key, _) {
            return key == data.itemKey
                ? selectedButton ?? unselectedButton
                : unselectedButton;
          },
        ),
      ),
    );
  }
}
