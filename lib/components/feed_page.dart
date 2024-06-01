import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:frikandel_special999/components/post_model.dart';

class FeedPage extends StatefulWidget {
  final VoidCallback callback;

  FeedPage({Key? key, required this.callback}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildPostList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF235d3a),
            Color(0xFF235d3a).withOpacity(0.8),
            Color(0xFF235d3a).withOpacity(0.6),
            Color(0xFF235d3a).withOpacity(0.4),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text('Feed Page'),
    );
  }

  Widget _buildPostList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Toon een laadindicator als de data nog geladen wordt
            print('Waiting for data...');
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Toon een foutmelding als er een fout is opgetreden
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Toon een bericht als er geen data beschikbaar is
            print('No data available');
            return const Center(child: Text('Geen posts beschikbaar'));
          }

          // Maak een lijst van Post-objecten van de Firestore-documenten
          final posts = snapshot.data!.docs.map((doc) {
            print('Post document gevonden: ${doc.data()}');
            return Post.fromFirestore(doc.data() as Map<String, dynamic>);
          }).toList();

          return FutureBuilder<List<Post>>(
            future: _fetchProfileImages(posts),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Geen posts beschikbaar'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final post = snapshot.data![index];
                  return _buildPostCard(post);
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Post>> _fetchProfileImages(List<Post> posts) async {
    for (var post in posts) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(post.userId).get();
        if (userDoc.exists) {
          print('Gebruikersdocument gevonden: ${userDoc.data()}');
          post.setProfileImageUrl(
              (userDoc.data() as Map<String, dynamic>)['profileImageUrl'] ??
                  '');
        } else {
          print('Gebruikersdocument niet gevonden voor userId: ${post.userId}');
        }
      } catch (e) {
        print('Fout bij het ophalen van gebruikersgegevens: $e');
      }
    }
    return posts;
  }

  Widget _buildPostCard(Post post) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: post.profileImageUrl.isNotEmpty
              ? NetworkImage(post.profileImageUrl)
              : null,
          child: post.profileImageUrl.isEmpty
              ? Icon(Icons.person, size: 30, color: Colors.grey)
              : null,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.username,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              DateFormat('dd-MM-yyyy HH:mm').format(post.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8.0),
            Text(post.text),
          ],
        ),
        trailing: post.imageUrl.isNotEmpty
            ? Image.network(
                post.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, color: Colors.red);
                },
              )
            : const Icon(Icons.image_not_supported),
      ),
    );
  }
}
