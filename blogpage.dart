import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final String bucketName = 'jithu';
  String? uploadedFileUrl;
  List<Map<String, dynamic>> blogs = [];

  // To store the blog data in Supabase
  Future<void> uploadBlog(String title, String description, File imageFile) async {
    try {
      // Upload the image to Supabase Storage
      final imageName = imageFile.uri.pathSegments.last;
      final imagePath = 'uploads/$imageName';
      final uploadResponse = await supabase.storage.from(bucketName).upload(imagePath, imageFile);
      print(uploadResponse);
        final imagePublicUrl = supabase.storage.from(bucketName).getPublicUrl(imagePath);

        final response = await supabase.from('blogs').insert({
          'title': title,
          'description': description,
          'image_url': imagePublicUrl,
        }).execute();
          setState(() {
            blogs.add({
              'title': title,
              'description': description,
              'image_url': imagePublicUrl,
            });
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Blog uploaded successfully!')));
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading blog: $e')));
    }
  }

  // Fetch blogs from Supabase
  Future<void> fetchBlogs() async {
    try {
      final response = await supabase.from('blogs').select('*').execute();
        setState(() {
          blogs = List<Map<String, dynamic>>.from(response.data);
        });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching blogs: $e')));
    }
  }

  // Open a dialog box to upload a new blog
  void openUploadBlogDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Upload New Blog'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(hintText: 'Enter Blog Title'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(hintText: 'Enter Blog Description'),
                maxLines: 3,
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  // Pick the image file for the blog
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: false,
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'png', 'jpeg'],
                  );

                  if (result != null) {
                    selectedImage = File(result.files.single.path!);
                  }
                },
                child: Text('Pick Blog Image'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final title = titleController.text;
                final description = descriptionController.text;

                if (title.isNotEmpty && description.isNotEmpty && selectedImage != null) {
                  uploadBlog(title, description, selectedImage!);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields and select an image')));
                }
              },
              child: Text('Upload Blog'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchBlogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Supabase Blog Upload')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: openUploadBlogDialog,
              child: Text('Upload Blog'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: blogs.length,
                itemBuilder: (context, index) {
                  final blog = blogs[index];
                  return Card(
                    child: ListTile(
                      leading: Image.network(
                        blog['image_url'],
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(blog['title']),
                      subtitle: Text(blog['description']),
                      onTap: () {
                        // Navigate to full blog details (e.g., show a new screen or dialog)
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(blog['title']),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(blog['image_url']),
                                  SizedBox(height: 10),
                                  Text(blog['description']),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
