import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'mongodbmodel.dart';

class DonatePage extends StatefulWidget {
  final MongoDbModel user;
  const DonatePage({super.key,required this.user});

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final String bucketName = 'jithu';
  String? uploadedFileUrl;
  List<Map<String, dynamic>> donations = [];
  List<Map<String,dynamic>> mydonations = [];
  int orderedcount = 0;

  // To store the blog data in Supabase
  Future<void> uploadDonate(String title, String description, File imageFile, String price) async {
    try {
      // Upload the image to Supabase Storage
      final imageName = imageFile.uri.pathSegments.last;
      final imagePath = 'donates/$imageName';
      final uploadResponse = await supabase.storage.from(bucketName).upload(imagePath, imageFile);
      print(uploadResponse);
      final imagePublicUrl = supabase.storage.from(bucketName).getPublicUrl(imagePath);

      final response = await supabase.from('donate').insert({
        'title': title,
        'description': description,
        'image_url': imagePublicUrl,
        'seller':widget.user.username,
        'sellercontact':widget.user.phoneNumber,
        'price':price,
      }).execute();
      setState(() {
        mydonations.add({
          'title': title,
          'description': description,
          'image_url': imagePublicUrl,
          'seller':widget.user.username,
          'sellercontact':widget.user.phoneNumber,
          'price':price,
          'buyer':'',
          'buyercontact':'',
          'status':'no',
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Blog uploaded successfully!')));
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading blog: $e')));
    }
  }

  // Fetch blogs from Supabase
  Future<void> fetchDonate() async {
    try {
      final response = await supabase.from('donate').select('*').execute();
      List<Map<String, dynamic>> fetchedDonations = List<Map<String, dynamic>>.from(response.data);
      setState(() {
        donations = fetchedDonations.where((donation) => donation['seller'] != widget.user.username).toList();
        mydonations = fetchedDonations.where((donation) => donation['seller'] == widget.user.username).toList();
        orderedcount = mydonations.where((donation) => donation['status'] == 'ordered').length;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching blogs: $e')));
    }
  }

  void openUploadDonationDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Upload New Donation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(hintText: 'Enter Donation Title'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(hintText: 'Enter Donation Description'),
                maxLines: 3,
              ),
              SizedBox(height: 8),
              TextField(
                controller: priceController,
                decoration: InputDecoration(hintText: 'Enter Price'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  // Pick the image file for the donation
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: false,
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'png', 'jpeg'],
                  );

                  if (result != null) {
                    selectedImage = File(result.files.single.path!);
                  }
                },
                child: Text('Pick Donation Image'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final title = titleController.text;
                final description = descriptionController.text;
                final price = priceController.text;

                if (title.isNotEmpty && description.isNotEmpty && selectedImage != null && price.isNotEmpty) {
                  uploadDonate(title, description, selectedImage!, price);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields and select an image')));
                }
              },
              child: Text('Upload Donation'),
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

  Future<void> updateDonationStatus(int donationId) async {
    try {
      final response = await supabase.from('donate').update({
        'buyer': widget.user.username,
        'buyercontact': widget.user.phoneNumber,
        'status': 'ordered',
      }).eq('id', donationId).execute();

        print("Donation updated successfully.");
        setState(() {
          final donationIndex = mydonations.indexWhere((donation) => donation['id'] == donationId);
          if (donationIndex != -1) {
            mydonations[donationIndex]['status'] = 'ordered';
            mydonations[donationIndex]['buyer'] = widget.user.username;
            mydonations[donationIndex]['buyercontact'] = widget.user.phoneNumber;
          }
        });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> deleteDonation(int donationId) async {
    try {
      final donationResponse = await supabase
          .from('donate')
          .select('image_url')
          .eq('id', donationId)
          .single()
          .execute();
      String imageUrl = donationResponse.data['image_url'];
      if (imageUrl.isNotEmpty) {
        Uri uri = Uri.parse(imageUrl);
        String imageName = uri.pathSegments.last;
        final deleteImageResponse = await supabase.storage.from('jithu').remove(['donates/'+imageName]);
        print("Image deleted successfully.");
      }
      final deleteDonationResponse = await supabase
          .from('donate')
          .delete()
          .eq('id', donationId)
          .execute();
      setState(() {
        mydonations.removeWhere((donation) => donation['id'] == donationId);
      });
      print("Donation deleted successfully.");
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDonate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Donation Upload')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: openUploadDonationDialog,
              child: Text('Upload Donation'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  final donation = donations[index];
                  return Card(
                    child: ListTile(
                      leading: Image.network(
                        donation['image_url'],
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(donation['title']),
                      subtitle: Text(donation['description']),
                      trailing: Text('\$${donation['price']}'),
                      onTap: () {
                        // Navigate to full donation details (e.g., show a new screen or dialog)
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(donation['title']),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(donation['image_url']),
                                  SizedBox(height: 10),
                                  Text(donation['description']),
                                  SizedBox(height: 10),
                                  Text('Price: \$${donation['price']}'),
                                  SizedBox(height: 10),
                                  Text('Seller: ${donation['seller']}'),
                                  Text('Contact: ${donation['sellercontact']}'),
                                  if(donation['status']=='no')
                                  SizedBox(
                                    width: 90,
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        updateDonationStatus(donation['id']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: EdgeInsets.zero,
                                        elevation: 3,
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.monetization_on_outlined,
                                            size: 24, // Optional: adjust size if needed
                                          ),
                                          Text("Buy"),
                                        ],
                                      ),
                                    ),
                                  ),
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
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            elevation: 1,
            onPressed: () {
              // Navigate to a screen showing only mydonations with status "ordered"
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyDonationsPage(mydonations: mydonations,onDonationUpdate: deleteDonation,),
                ),
              );
            },
            child: Icon(Icons.shopping_cart),
          ),
          if (orderedcount>0)
            Positioned(
              right: 0,
              top: -3,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  orderedcount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MyDonationsPage extends StatelessWidget {
  final List<Map<String, dynamic>> mydonations;
  final Future<void> Function(int) onDonationUpdate;

  const MyDonationsPage({super.key, required this.mydonations, required this.onDonationUpdate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Donations')),
      body: ListView.builder(
        itemCount: mydonations.length,
        itemBuilder: (context, index) {
          final donation = mydonations[index];
          return Stack(
            children: [
              Card(
                child: ListTile(
                  leading: Image.network(
                    donation['image_url'],
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(donation['title']),
                  subtitle: Text(donation['description']),
                  trailing: Text('\$${donation['price']}'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(donation['title']),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(donation['image_url']),
                              SizedBox(height: 10),
                              Text(donation['description']),
                              SizedBox(height: 10),
                              Text('Price: \$${donation['price']}'),
                              SizedBox(height: 10),
                              Text('Seller: ${donation['seller']}'),
                              Text('Contact: ${donation['sellercontact']}'),
                              Text('Buyer: ${donation['buyer']}'),
                              Text('Buyer Contact: ${donation['buyercontact']}'),
                              if(donation['status']=='ordered')
                                SizedBox(
                                  width: 90,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      print(donation['id']);
                                      onDonationUpdate(donation['id']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.zero,
                                      elevation: 3,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.sell,
                                          size: 24, // Optional: adjust size if needed
                                        ),
                                        Text("Sell"),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (donation['status']=='ordered')
                Positioned(
                  right: 5,
                  top: -4,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      "1",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ]
          );
        },
      ),
    );
  }
}
