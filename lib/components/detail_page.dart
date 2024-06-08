import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:frikandel_special999/components/post_model.dart';
import 'dart:html' as html;
import 'package:firebase_auth/firebase_auth.dart';

class DetailPage extends StatefulWidget {
  final Post post;
  final CarouselController _carouselController = CarouselController();

  DetailPage({Key? key, required this.post}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _currentUserDisplayName = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    print('DetailPage initialized');
    _getCurrentUserDisplayName();
  }

  Future<void> _getCurrentUserDisplayName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      print('Fetching username for user: ${user.uid}');
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            if (userData.containsKey('username')) {
              _currentUserDisplayName = userData['username'] ?? '';
            } else {
              _currentUserDisplayName = 'Unknown User';
              print('Field "username" does not exist, using default value.');
            }
            print('Current user username: $_currentUserDisplayName');
          });
        } else {
          print('User document does not exist or is null.');
        }
      } catch (error) {
        print('Error fetching user document: $error');
      }
    } else {
      print('No user is currently logged in.');
    }
  }

  Future<void> _submitComment() async {
    setState(() {
      _isSubmitting = true;
    });
    print("Submitting comment...");

    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() {
        _isSubmitting = false;
      });
      print("User not logged in.");
      _showLoginRequiredDialog();
      return;
    }

    try {
      if (_currentUserDisplayName.isEmpty) {
        print('Current user username is empty, fetching it now...');
        await _getCurrentUserDisplayName();
      } else {
        print('Current user username is already set: $_currentUserDisplayName');
      }

      final String commentId = _firestore
          .collection("posts")
          .doc(widget.post.id)
          .collection("comments")
          .doc()
          .id;
      final Comment newComment = Comment(
        id: commentId,
        userId: currentUser.uid,
        username: _currentUserDisplayName,
        profileImageUrl: currentUser.photoURL ?? '',
        text: _commentController.text.trim(),
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection("posts")
          .doc(widget.post.id)
          .collection("comments")
          .doc(newComment.id)
          .set(newComment.toMap());
      print("Comment submitted successfully.");

      setState(() {
        _commentController.clear();
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (error) {
      print('Fout bij het indienen van de commentaar: $error');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Fout'),
          content: const Text(
              'Er is een fout opgetreden bij het indienen van de commentaar. Probeer het opnieuw.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildComments() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('posts')
          .doc(widget.post.id)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('Geen reacties beschikbaar');
        }

        final commentsDocs = snapshot.data!.docs;
        final comments = commentsDocs.map((doc) {
          return Comment.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();

        return ListView.builder(
          controller: _scrollController,
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return ListTile(
              title: Text(comment.username.isNotEmpty
                  ? comment.username
                  : 'Unknown User'),
              subtitle: Text(comment.text),
            );
          },
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Plaats een reactie...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitComment,
            child:
                _isSubmitting ? CircularProgressIndicator() : Text('Plaatsen'),
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inloggen vereist'),
        content: const Text('U moet ingelogd zijn om een reactie te plaatsen.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) {
    html.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls = widget.post.imageUrls;
    final double contentWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
        backgroundColor: const Color(0xFF235d3a),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            DateFormat('dd-MM-yyyy HH:mm')
                                .format(widget.post.timestamp),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Container(
                              width: contentWidth,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  _buildImageSlideshow(imageUrls),
                                  if (imageUrls.length > 1) ...[
                                    Positioned(
                                      left: 0,
                                      child: IconButton(
                                        icon: Icon(Icons.arrow_back,
                                            size: 30, color: Colors.white),
                                        onPressed: () {
                                          widget._carouselController
                                              .previousPage();
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: IconButton(
                                        icon: Icon(Icons.arrow_forward,
                                            size: 30, color: Colors.white),
                                        onPressed: () {
                                          widget._carouselController.nextPage();
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Container(
                              width: contentWidth,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 3,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 300,
                                ),
                                child: SingleChildScrollView(
                                  child: Text(
                                    widget.post.description,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Reacties',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 300, // Adjust the height as needed
                            child: _buildComments(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildCommentInput(),
                ],
              ),
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

  Widget _buildImageSlideshow(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      print("Geen afbeeldingen beschikbaar");
      return Container();
    } else if (imageUrls.length == 1) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.network(
              imageUrls[0],
            ),
          ),
        ),
      );
    } else {
      print("Aantal afbeeldingen in slideshow: ${imageUrls.length}");
      return CarouselSlider.builder(
        carouselController: widget._carouselController,
        itemCount: imageUrls.length,
        itemBuilder: (context, index, realIdx) {
          return Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.network(
                  imageUrls[index],
                ),
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: 300,
          enlargeCenterPage: true,
          autoPlay: true,
          aspectRatio: 16 / 9,
          autoPlayCurve: Curves.fastOutSlowIn,
          enableInfiniteScroll: true,
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          viewportFraction: 0.8,
        ),
      );
    }
  }
}
