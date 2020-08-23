import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:extended_text_field/extended_text_field.dart';

import '../label/my_special_text_span_builder.dart';
import '../pages/rich-html-cursor.dart';
import '../pages/rich-html-theme.dart';
import '../label/AsperctRaioImage.dart';
import '../label/my_extended_text_selection_controls.dart';

enum RichHtmlLabelType { IMAGE, VIDEO, P, TEXT, AT, EMOJI, EMAIL, DOLLAR, BLOCKQUOTE, B, LINK }

class RichHtmlData {
  RichHtmlLabelType type;
  dynamic data;

  RichHtmlData(
    RichHtmlLabelType type, {
    this.data,
  }) : super();
}

class RichHtmlDataImage {
  String src;
  var element;

  RichHtmlDataImage({this.src, this.element});
}

abstract class RichHtmlController {
  String _html;
  RichHtmlUtil _util = RichHtmlUtil();
  RichHtmlTheme theme = RichHtmlTheme();

  RichHtmlController({this.theme});

  set text(String value) {
    this._html = _util.remStringHtml(value);
  }

  set html(String value) {
    this._html = value ?? '';
  }

  // text将过滤所有标签(列如<img/>和<video/>)，它仅返回文字内容
  String get text => _util.remStringHtml(this._html);

  // 所有内容
  String get html => this._html;

  TextSelection textSelection;
  TextEditingController controller = TextEditingController();
  Function updateWidget;
  Function clearAll;

  Future<String> insertImage();

  Future<String> insertVideo();

  Widget generateImageView(String url,dynamic img) {
    double width = .0;
    double height = .0;
    bool autoWidth = true;
    bool autoheight = true;

    return AsperctRaioImage.network(url, builder: (context, snapshot, url) {
      if (img.attributes.containsKey('width')) {
        autoWidth = false;
        width = double.tryParse(img.attributes['width']);
      }
      if (img.attributes.containsKey('height')) {
        autoheight = false;
        height = double.tryParse(img.attributes['height']);
      }

      return Container(
        margin: EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Image.network(
          url,
          width: autoWidth ? snapshot.data.width.toDouble() : width,
          height: autoheight ? snapshot.data.height.toDouble() : height,
          fit: BoxFit.fill,
        ),
      );
    });
  }

  Widget generateVideoView(String url, video) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      color: Colors.black12,
      child: Center(
        child: Text("请构建[generateVideoView]"),
      ),
    );
  }
}

class RichHtmlUtil {
  String remStringHtml(String text) {
    RegExp reg = new RegExp("<[^>]*>");
    Iterable<RegExpMatch> matches = reg.allMatches(text);
    String value;
    matches.forEach((m) {
      value = m.input.toString().replaceAll(reg, "") ?? '';
    });
    return value;
  }
}

class RichHtml extends StatefulWidget {
  final RichHtmlController richhtmlController;

  // richhtml所支持的标签类型，具体支持详情请看[RichHtmlLabelType]
  final List<RichHtmlLabelType> richhtmlSupportLabel;
  final scrollPadding;
  final scrollPhysics;
  final toolbarOptions;
  final autofocus;
  final TextSelectionControls textSelectionControls;
  final textDirection;
  final textAlignVertical;
  final RichHtmlCursor richHtmlCursorStyle;
  final String placeholder;
  final Function onChanged;
  final Function onSubmitted;
  final Function onTap;
  final Function onEditingComplete;

  RichHtml(
    this.richhtmlController, {
    Key key,
    this.richhtmlSupportLabel = const <RichHtmlLabelType>[
      RichHtmlLabelType.IMAGE,
      RichHtmlLabelType.VIDEO,
      RichHtmlLabelType.P,
      RichHtmlLabelType.B,
      RichHtmlLabelType.TEXT,
    ],
    this.scrollPadding,
    this.scrollPhysics,
    this.toolbarOptions,
    this.autofocus,
    this.textSelectionControls,
    this.textDirection,
    this.textAlignVertical,
    // 光标样式
    // 对应Input的 [cursorWidth]和[cursorColor]和[cursorRadius]
    RichHtmlCursor richHtmlCursorStyle,
    // 规定帮助用户填写输入字段的提示。
    this.placeholder = '填写内容',
    Function onChanged,
    this.onSubmitted,
    Function onTap,
    Function onEditingComplete,
  })  : onEditingComplete = onEditingComplete ?? null,
        onTap = onTap ?? null,
        onChanged = onChanged ?? null,
        richHtmlCursorStyle = richHtmlCursorStyle ?? RichHtmlCursor();

  @override
  _RichHtmlState createState() => _RichHtmlState();
}

class _RichHtmlState extends State<RichHtml> {
  FocusNode _focusNode = FocusNode();
  ScrollController _ScrollController = ScrollController();

  @override
  void initState() {
    RichHtmlController _rhc = widget.richhtmlController;
    _rhc.updateWidget = _onUpdateWidget;
    _rhc.clearAll = _onClear;
    _rhc.controller.text = _rhc._html;
    _rhc.controller.addListener(() {
      _rhc.textSelection = _rhc.controller.selection;
    });

//    _rhc.controller.addListener(() {
//      print(_rhc.controller.text.substring(_rhc.controller.selection.baseOffset, _rhc.controller.selection.extentOffset));
//    });

    super.initState();
  }

  Future<bool> _onClear() async {
    await widget.richhtmlController.controller.clear();
    return true;
  }

  Future<String> _onUpdateWidget(String text) async {
    setState(() {
      widget.richhtmlController.controller.text = text;
    });
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: ExtendedTextField(
            controller: widget.richhtmlController.controller,
            minLines: 1,
            maxLines: null,
            focusNode: _focusNode,

            style: TextStyle(
              fontSize: 16,
            ),
            strutStyle: StrutStyle(
              fontSize: 16,
            ),

            specialTextSpanBuilder: MySpecialTextSpanBuilder(
              context,
              widget.richhtmlController.controller,
              richhtmlSupportLabel: widget.richhtmlSupportLabel,
              videoView: widget.richhtmlController.generateVideoView,
              imageView: widget.richhtmlController.generateImageView,
            ),
            scrollController: _ScrollController,
            scrollPadding: widget.scrollPadding ?? EdgeInsets.zero,
            scrollPhysics: widget.scrollPhysics ?? ScrollPhysics(),
            textCapitalization: TextCapitalization.words,
            textSelectionControls: widget.textSelectionControls ?? null,
            textDirection: widget.textDirection ?? TextDirection.ltr,
            textAlignVertical: widget.textAlignVertical ?? TextAlignVertical.top,
            toolbarOptions: widget.toolbarOptions ??
                ToolbarOptions(
                  selectAll: true,
                  copy: true,
                  paste: true,
                  cut: true,
                ),
            cursorWidth: widget.richHtmlCursorStyle.cursorWidth,
            cursorColor: widget.richHtmlCursorStyle.cursorColor,
            cursorRadius: widget.richHtmlCursorStyle.cursorRadius,
            autofocus: widget.autofocus ?? false,
            decoration: InputDecoration(
              hintText: widget.placeholder ?? '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            keyboardType: TextInputType.multiline,
            onChanged: (String value) {
              setState(() {
                widget.richhtmlController._html = value;
              });
              widget.onChanged(value);
            },
            onSubmitted: (String value) {
              print('onSubmitted $value');
              widget.onSubmitted(value);
            },
            onTap: () {
              if (widget.onTap != null) {
                widget.onTap();
              }
            },
            onEditingComplete: () {
              print('onEditingComplete');
              widget.onEditingComplete();
            },
          ),
        ),
      ],
    );
  }
}
