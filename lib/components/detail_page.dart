import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:frikandel_special999/components/post_model.dart';
import 'dart:html' as html;

class DetailPage extends StatelessWidget {
  final Post post;

  const DetailPage({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
        backgroundColor: const Color(0xFF235d3a), // Donkergroen thema
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double contentWidth = constraints.maxWidth *
                      0.8; // 80% van de breedte van de parent container
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                DateFormat('dd-MM-yyyy HH:mm').format(post
                                    .timestamp
                                    .toDate()), // Timestamp omzetten naar DateTime
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: Container(
                                  width: contentWidth,
                                  child: _buildImageSlideshow(post.imageUrls),
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
                                        offset: Offset(0, 3), // Schaduwpositie
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    post.text, // Post tekst hier weergeven
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (post.description.isNotEmpty)
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _launchURL(post.description),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF235d3a), // Kleur van de knop
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: const Text(
                              'Bekijk meer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
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
      return Container();
    } else if (imageUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrls[0],
          fit: BoxFit.cover,
          width: double.infinity,
          height: 300, // Pas de hoogte aan indien nodig
        ),
      );
    } else {
      return CarouselSlider.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index, realIdx) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrls[index],
              fit: BoxFit.cover,
              width: double.infinity,
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

  void _launchURL(String url) {
    html.window.open(url, '_blank');
  }
}
