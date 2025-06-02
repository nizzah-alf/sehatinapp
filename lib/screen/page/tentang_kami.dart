import 'package:flutter/material.dart';

class TentangKamiPage extends StatefulWidget {
  const TentangKamiPage({super.key});

  @override
  State<TentangKamiPage> createState() => _TentangKamiPageState();
}

class _TentangKamiPageState extends State<TentangKamiPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_showScrollToTop) {
        setState(() {
          _showScrollToTop = true;
        });
      } else if (_scrollController.offset <= 100 && _showScrollToTop) {
        setState(() {
          _showScrollToTop = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Kami'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Apa itu Sehatin?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Sehatin hadir sebagai solusi digital untuk membantu masyarakat dalam menerapkan gaya hidup sehat secara konsisten dan menyenangkan. Kami memahami bahwa menjaga kesehatan tidak selalu mudah, terutama di tengah kesibukan dan kurangnya motivasi. Oleh karena itu, Sehatin dirancang untuk menjadi teman harian Anda dalam mencatat aktivitas sehat, memantau suasana hati, dan memberikan inspirasi hidup sehat secara berkelanjutan.',
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                'Kami terus berinovasi untuk memastikan Sehatin dapat menjadi platform yang ramah, mudah digunakan, dan relevan untuk berbagai kalangan. Komitmen kami adalah menghadirkan pengalaman digital yang tidak hanya membantu pengguna mencapai tujuan kesehatan mereka, tetapi juga membuat prosesnya terasa ringan dan menyenangkan.',
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              SizedBox(height: 20),
              Text(
                'Apa tujuan kami?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Sehatin hadir dengan tujuan utama untuk membantu pengguna menjalani pola hidup sehat dengan cara yang sederhana, menyenangkan, dan terarah. Kami percaya bahwa menjaga kesehatan bukanlah hal yang rumit, melainkan dapat dimulai dari kebiasaan kecil yang dilakukan secara konsisten setiap hari.',
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.only(left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• Kesadaran dan konsistensi pola hidup sehat',
                      style: TextStyle(fontSize: 15, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '• Dukungan digital kapan dan di mana saja',
                      style: TextStyle(fontSize: 15, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '• Fitur sederhana dan bermakna untuk kesehatan sehari-hari',
                      style: TextStyle(fontSize: 15, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '• Jembatan menuju hidup lebih sehat, seimbang, dan positif',
                      style: TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Dengan pendekatan yang interaktif dan praktis, kami berharap aplikasi ini bisa menjadi awal perubahan gaya hidup ke arah yang lebih baik dan berkelanjutan.',
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
      floatingActionButton:
          _showScrollToTop
              ? FloatingActionButton(
                onPressed: _scrollToTop,
                backgroundColor: Colors.blue,
                shape: const CircleBorder(),
                mini: true,
                child: const Icon(Icons.arrow_upward),
              )
              : null,
    );
  }
}
