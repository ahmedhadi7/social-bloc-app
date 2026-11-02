import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_bloc/componet/my_text_field.dart';
import 'package:social_bloc/features/profile/domin/entites/profile_user.dart';
import 'package:social_bloc/features/profile/presentation/pages/cubits/profile_cubit.dart';
import 'package:social_bloc/features/profile/presentation/pages/cubits/profile_state.dart';
import 'package:social_bloc/responsive/constrained_scaffold.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  //mobile image pick
  PlatformFile? imagePickedFile;

  //web image pick
  Uint8List? webImage;
  final nameTextController = TextEditingController();
  final bioTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // عرض القيم الحالية داخل الحقول
    nameTextController.text = widget.user.name;
    bioTextController.text = widget.user.bio;
  }

  @override
  void dispose() {
    nameTextController.dispose();
    bioTextController.dispose();
    super.dispose();
  }

  //pick image
  Future<void> pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  // update profile button pressed
  void updateProfile() {
    final profileCubit = context.read<ProfileCubit>();

    //prepare images
    final String uid = widget.user.uid;
    final String? newName =
        nameTextController.text.trim().isNotEmpty &&
            nameTextController.text.trim() != widget.user.name
        ? nameTextController.text.trim()
        : null;
    final String? newBio = bioTextController.text.isNotEmpty
        ? bioTextController.text
        : null;
    final imageMobilepath = kIsWeb ? null : imagePickedFile?.path;
    final imageWebBytes = kIsWeb ? imagePickedFile?.bytes : null;

    //only update profile if there is something to update

    if (imagePickedFile != null || newBio != null || newName != null) {
      profileCubit.updateProfile(
        uid: uid,
        newName: newName,
        newBio: newBio,
        imageWebBytes: imageWebBytes,
        imageMobilepath: imageMobilepath,
        imageWebExtension: imagePickedFile?.extension,
      );
    }
    //nothing to update
    else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      builder: (context, state) {
        //profile loading
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: CircularProgressIndicator()),
                  Text("Loading profile..."),
                ],
              ),
            ),
          );
        } else {
          return buildEditPage();
        }

        //profile error

        //edit forms
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  Widget buildEditPage({double uploadProgress = 0.0}) {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text("تعديل الحساب"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [IconButton(onPressed: updateProfile, icon: Icon(Icons.save))],
      ),
      body: Column(
        children: [
          //profile pic
          Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.hardEdge,
              child:
                  //display selected image for mobile
                  (!kIsWeb && imagePickedFile != null)
                  ? Image.file(File(imagePickedFile!.path!), fit: BoxFit.cover)
                  :
                    //display selected image for web
                    (kIsWeb && webImage != null)
                  ? Image.memory(webImage!, fit: BoxFit.cover)
                  :
                    //no image selected -> display existing profile pic
                    CachedNetworkImage(
                      imageUrl: widget.user.profileImageUrl,

                      //loading
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),

                      //error -> failed to load
                      errorWidget: (context, url, error) => Icon(
                        Icons.person,
                        size: 72,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      //loaded
                      imageBuilder: (context, imageProvider) =>
                          Image(image: imageProvider, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 30),

          //pick image button
          Center(
            child: MaterialButton(
              onPressed: pickImage,
              color: Colors.blue,
              child: const Text("اختيار صوره"),
            ),
          ),
          //name
          const Text("الاسم"),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: MyTextField(
              hintText: "الاسم",
              controller: nameTextController,
              obscureText: false,
            ),
          ),
          const SizedBox(height: 25),

        
        
          //bio
          Text("Bio"),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: MyTextField(
              hintText: widget.user.bio,
              controller: bioTextController,
              obscureText: false,
            ),
          ),
        ],
      ),
    );
  }
}
