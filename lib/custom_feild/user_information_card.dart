import 'package:flutter/material.dart';

class UserInformationCard extends StatelessWidget {
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String city;
  final String state;
  final String country;
  final String zipcode;
  final String imageurl;

  const UserInformationCard(
      {super.key,
      required this.name,
      required this.email,
      required this.phoneNumber,
      required this.address,
      required this.city,
      required this.state,
      required this.country,
      required this.zipcode,
      required this.imageurl});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      color: Colors.grey.shade100,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: EdgeInsets.all(10.0),
        width: double.infinity,
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                // Clip the image to be circular
                child: imageurl.isNotEmpty
                    ? Image.network(
                        imageurl,
                        fit: BoxFit.cover,
                        width: 70,
                        height: 70,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child; // Image is loaded
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            );
                          }
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 20),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Color(0xFF123456),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.email_outlined, color: Colors.grey, size: 16),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          email,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, color: Colors.grey, size: 16),
                      SizedBox(width: 5),
                      Text(
                        phoneNumber,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.grey, size: 16),
                      SizedBox(width: 5),
                      Text(
                        '$address, \n$city, $state, \n$country - $zipcode',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
