import 'package:dairy_app/core/widgets/glassmorphism_cover.dart';
import 'package:dairy_app/features/notes/presentation/bloc/notes/notes_bloc.dart';
import 'package:dairy_app/features/notes/presentation/widgets/note_title_input_field.dart';
import 'package:dairy_app/features/notes/presentation/widgets/rich_text_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoteCreatePage extends StatefulWidget {
  static String get route => '/note-create';

  const NoteCreatePage({Key? key}) : super(key: key);

  @override
  State<NoteCreatePage> createState() => _NoteCreatePageState();
}

class _NoteCreatePageState extends State<NoteCreatePage> {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<NotesBloc>(context);

    // it is definetely a new note if we reached this page and the state is still NoteDummyState
    if (bloc.state is NoteDummyState) {
      bloc.add(const InitializeNote());
    }

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: GlassAppBar(),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "assets/images/digital-art-neon-bubbles.jpg",
              ),
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.only(
            top: 15.0,
            left: 10.0,
            right: 10.0,
            // bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              SizedBox(
                height: AppBar().preferredSize.height,
              ),
              BlocBuilder<NotesBloc, NotesState>(
                bloc: bloc,
                builder: (context, state) {
                  void _onTitleChanged(String title) {
                    bloc.add(UpdateNote(title: title));
                  }

                  if (state is NoteDummyState) {
                    return NoteTitleInputField(
                        initialValue: "", onTitleChanged: _onTitleChanged);
                  }
                  return NoteTitleInputField(
                    initialValue: state.title!,
                    onTitleChanged: _onTitleChanged,
                  );
                },
              ),
              const SizedBox(height: 10),
              RichTextEditor(),
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom,
              )
            ],
          ),
        ),
      ),
    );
  }

  AppBar GlassAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Icon(Icons.visibility),
        )
      ],
      flexibleSpace: GlassMorphismCover(
        borderRadius: BorderRadius.circular(0.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.2),
              ],
              begin: AlignmentDirectional.topCenter,
              end: AlignmentDirectional.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }
}
