
import 'dart:ui';

import 'package:flutter_quill/flutter_quill.dart';

class QuillConfigurations {

  static QuillEditorConfigurations getEditorConfigurations({required QuillController controller}) {
    return const QuillEditorConfigurations(
      sharedConfigurations: QuillSharedConfigurations(
        locale: Locale('en'),
      ),
    );
  }

  static QuillSimpleToolbarConfigurations getToolbarConfigurations({required QuillController controller}) {
    return const QuillSimpleToolbarConfigurations(
      toolbarSize: 40,
      showUndo: false,
      showRedo: false,
      showFontFamily: false,
      showAlignmentButtons: false,
      showStrikeThrough: false,
      showSubscript: false,
      showSuperscript: false,
      showClipboardCut: false,
      showClipboardPaste: false,
      showLeftAlignment: false,
      showRightAlignment: false,
      showQuote: false,
      showIndent: false,
      showSearchButton: false,
      showLink: false,
      showClipboardCopy: false,
      showInlineCode: false,
      showHeaderStyle: false,
      showBackgroundColorButton: false,
      showCodeBlock: false
    );
  }
}
