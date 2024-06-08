import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:frikandel_special999/components/post_model.dart';
import 'detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedPage extends StatefulWidget {
  final VoidCallback callback;

  const FeedPage({Key? key, required this.callback}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
            const Color(0xFF235d3a),
            const Color(0xFF235d3a).withOpacity(0.8),
            const Color(0xFF235d3a).withOpacity(0.6),
            const Color(0xFF235d3a).withOpacity(0.4),
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
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Geen posts beschikbaar'));
          }

          final posts = snapshot.data!.docs.map((doc) {
            return Post.fromFirestore(doc);
          }).toList();

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildPostCard(post);
            },
          );
        },
      ),
    );
  }

  Future<List<Post>> _fetchProfileImages(List<Post> posts) async {
    for (var post in posts) {
      if (post.userId.isNotEmpty) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(post.userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final profileImageUrl = userData['profileImageUrl'] ?? '';
          // Update profileImageUrl in the Post object
          post.profileImageUrl = profileImageUrl;
        }
      }
    }
    return posts;
  }

  Future<void> _toggleLike(Post post) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }
    final isLiked = post.likedBy.contains(user.uid);
    final newLikes = isLiked ? post.likes - 1 : post.likes + 1;
    final newLikedBy = isLiked
        ? post.likedBy.where((id) => id != user.uid).toList()
        : [...post.likedBy, user.uid];

    await _firestore.collection('posts').doc(post.id).update({
      'likes': newLikes,
      'likedBy': newLikedBy,
    });
    setState(() {
      post.likes = newLikes;
      post.likedBy = newLikedBy;
      // Voeg hier een update toe voor de lijst met reacties
      post.comments = post.comments;
    });
  }

  Widget _buildPostCard(Post post) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(post: post),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: post.profileImageUrl.isNotEmpty
                        ? NetworkImage(post.profileImageUrl)
                        : null,
                    child: post.profileImageUrl.isEmpty
                        ? const Icon(Icons.person, size: 35, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.username,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF235d3a),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd-MM-yyyy HH:mm').format(post.timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          post.description,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  post.imageUrls.isNotEmpty
                      ? Image.network(
                          post.imageUrls[0],
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image, size: 140);
                          },
                        )
                      : Container(
                          width: 140,
                          height: 140,
                          color: Colors.grey[200],
                          child:
                              Icon(Icons.image, size: 140, color: Colors.grey),
                        ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          post.likedBy.contains(_auth.currentUser?.uid)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: post.likedBy.contains(_auth.currentUser?.uid)
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onPressed: () => _toggleLike(post),
                      ),
                      Text('${post.likes} likes'),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.restaurant,
                          color: Colors.grey), // Koks-icoontje
                      SizedBox(width: 4),
                      Text(
                          'Recensies'), // Vervang het aantal reacties door het woord "Recensies"
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
