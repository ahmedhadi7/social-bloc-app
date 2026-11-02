import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_bloc/componet/my_text_field.dart';
import 'package:social_bloc/features/auth/domain/entities/app_user.dart';
import 'package:social_bloc/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:social_bloc/features/post/domain/entities/post.dart';
import 'package:social_bloc/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_bloc/features/post/presentation/cubits/post_state.dart';
import 'package:social_bloc/responsive/constrained_scaffold.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  //mobile img pic
  PlatformFile? imagePickedFile;
  //web img pic
  Uint8List? webImage;
  //text controller
  final textController = TextEditingController();

  //current user
  AppUser? currentUser;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  //get current user
  void getCurrentUser() async {
    //get current user from auth cubit
    final authCubit = context.read<AuthCubits>();
    currentUser = authCubit.currentUser;
  }

  //pick image
  /*
  Future<void> pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: kIsWeb, // for web,
    );

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }*/
  Future<void> pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;

        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  //create and upload post
  void uploadPost() {
    //check if both image and text are empty
    if (imagePickedFile == null && textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image or enter text.')),
      );

      return;
    }
    //create a new post object
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: textController.text,
      imageUrl: '',
      timestamp: DateTime.now(),
      likes: [],
      comments: [],
    );
    //post cubit
    final postCubit = context.read<PostCubit>();
    //web image bytes
    if (kIsWeb) {
      postCubit.createPost(
        newPost,
        imageBytes: imagePickedFile?.bytes,
        imageExtension: imagePickedFile?.extension,
      );
    }
    //mobile
    else {
      postCubit.createPost(newPost, imagePath: imagePickedFile?.path);
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //bloc cunsumer ->builder -> listener
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state) {
        print(state);
        //loading or uploading
        if (state is PostUploading || state is PostLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        //build upload image
        return buildUpladPage();
      },
      listener: (context, state) {
        if (state is PostsLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildUpladPage() {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text('انشاء منشور'),

        foregroundColor: Theme.of(context).primaryColor,
        actions: [
          //upload Button
          //IconButton(onPressed: uploadPost, icon: const Icon(Icons.upload, color: Colors.blue,)),
        ],
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              //image preview
              if (kIsWeb && webImage != null) Image.memory(webImage!),

              //image preview for mobile
              if (!kIsWeb && imagePickedFile != null)
                Image.file(File(imagePickedFile!.path!)),

              //pick image button
             

              MyTextField(
                hintText: "اكتب وصف للمنشور (اختياري)",
                controller: textController,
                obscureText: false,
              ),
              SizedBox(height: 25,),
               MaterialButton(
                onPressed: pickImage,
                color: Colors.blue,
                child: const Text("اختر صوره للمنشور"),
              ),

               SizedBox(height: 25,),

               MaterialButton(
                onPressed: uploadPost,
                color: Colors.blue,
                child: const Text("نشر"),
              ),


              
            ],
          ),
        ),
      ),
    );
  }
}
