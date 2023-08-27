import 'package:dairy_app/app/themes/theme_models.dart';
import 'package:dairy_app/core/utils/utils.dart';
import 'package:dairy_app/core/widgets/glass_app_bar.dart';
import 'package:dairy_app/features/notes/presentation/bloc/notes/notes_bloc.dart';
import 'package:dairy_app/features/notes/presentation/widgets/note_title_input_field.dart';
import 'package:dairy_app/features/notes/presentation/widgets/rich_text_editor.dart';
import 'package:dairy_app/features/notes/presentation/widgets/show_notes_close_dialog.dart';
import 'package:dairy_app/features/notes/presentation/widgets/toggle_read_write_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/note_date_time_picker.dart';
import '../widgets/note_save_button.dart';
import '../widgets/notes_close_button.dart';

class NoteCreatePage extends StatefulWidget {
  // display page growing animation
  static String get routeThroughHome => '/note-create-though-home';

  // display fade transition animaiton
  static String get routeThroughNoteReadOnly =>
      '/note-create-through-note-read-only';

  const NoteCreatePage({Key? key}) : super(key: key);

  @override
  State<NoteCreatePage> createState() => _NoteCreatePageState();
}

class _NoteCreatePageState extends State<NoteCreatePage> {
  late bool _isInitialized = false;
  late final NotesBloc notesBloc;
  late Image neonImage;
  late double topPadding = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_isInitialized) {
      notesBloc = BlocProvider.of<NotesBloc>(context);

      // it is definetely a new note if we reached this page and the state is still NoteDummyState
      if (notesBloc.state is NoteDummyState) {
        notesBloc.add(const InitializeNote());
      }

      final backgroundImagePath = Theme.of(context)
          .extension<AdditionalThemeExtensions>()!
          .backgroundImage;

      neonImage = Image.asset(backgroundImagePath);

      precacheImage(neonImage.image, context);
      topPadding =
          MediaQuery.of(context).padding.top + AppBar().preferredSize.height;

      _isInitialized = true;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundImagePath = Theme.of(context)
        .extension<AdditionalThemeExtensions>()!
        .backgroundImage;

    return WillPopScope(
      onWillPop: () async {
        bool? result = await showCloseDialog(context);

        if (result == true) {
          notesBloc.add(RefreshNote());
          return true;
        }
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: GlassAppBar(
          automaticallyImplyLeading: false,
          leading: NotesCloseButton(onNotesClosed: _routeToHome),
          actions: const [
            NoteSaveButton(),
            DateTimePicker(),
            ToggleReadWriteButton(pageName: PageName.NoteCreatePage)
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(225, 234, 94, 141),
            image: DecorationImage(
              image: AssetImage(
                backgroundImagePath,
              ),
              fit: BoxFit.cover,
              alignment: const Alignment(0.725, 0.1),
            ),
          ),
          padding: EdgeInsets.only(
            top: topPadding,
            left: 10.0,
            right: 10.0,
            // bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: BlocListener<NotesBloc, NotesState>(
            bloc: notesBloc,
            listener: (context, state) {
              if (state is NoteFetchFailed) {
                showToast("feiled to fetch note");
              } else if (state is NotesSavingFailed) {
                showToast("Failed to save note");
              } else if (state is NoteSavedSuccesfully) {
                showToast(state.newNote!
                    ? "Note saved successfully"
                    : "Note updated successfully");
                _routeToHome();
              }
            },
            child: Column(
              children: [
                BlocBuilder<NotesBloc, NotesState>(
                  bloc: notesBloc,
                  buildWhen: (previousState, state) {
                    return previousState.title != state.title;
                  },
                  builder: (context, state) {
                    void _onTitleChanged(String title) {
                      notesBloc.add(UpdateNote(title: title));
                    }

                    if (!state.safe) {
                      return NoteTitleInputField(
                          initialValue: "", onTitleChanged: _onTitleChanged);
                    }
                    return NoteTitleInputField(
                      initialValue: state.title!,
                      onTitleChanged: _onTitleChanged,
                    );
                  },
                ),
                BlocBuilder<NotesBloc, NotesState>(
                  bloc: notesBloc,
                  buildWhen: (previousState, state) {
                    return previousState is NoteDummyState;
                  },
                  builder: (context, state) {
                    return RichTextEditor(
                      controller: state.controller,
                    );
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _routeToHome() {
    notesBloc.add(RefreshNote());
    Navigator.of(context).pop();
  }
}
