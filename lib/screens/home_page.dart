import 'dart:async'; // [BARU] Import Timer
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/home/home_bloc.dart';
import '../blocs/home/home_event.dart';
import '../blocs/home/home_state.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All Products', 'Best Seller', 'Vol 1', 'New Arrival'];

  // 👇 [BARU] Konfigurasi Auto-Slide Banner 👇
  final PageController _pageController = PageController();
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  final List<Map<String, String>> _bannerData = [
    {
      'image': 'assets/images/first_banner.png',
      'subtitle': '',
      'title': ''
    },
    {
      'image': 'assets/images/second_banner.png',
      'subtitle': '',
      'title': ''
    },
  ];

  @override
  void initState() {
    super.initState();
    // Mengatur Timer untuk menggeser banner setiap 4 detik
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentBannerIndex < _bannerData.length - 1) {
        _currentBannerIndex++;
      } else {
        _currentBannerIndex = 0; // Kembali ke awal jika sudah di ujung
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutQuart, // Animasi transisi yang elegan
        );
      }
    });
  }

  @override
  void dispose() {
    // [PENTING] Matikan timer dan controller saat pindah halaman agar tidak bocor memori (Memory Leak)
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
  // 👆 ========================================== 👆

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(productRepository: ProductRepository())..add(FetchHomeData()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.black));
              } else if (state is HomeError) {
                return Center(child: Text(state.message, textAlign: TextAlign.center));
              } else if (state is HomeLoaded) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildBannerSlider(), // Memanggil Banner Baru
                      _buildFilters(),
                      _buildProductGrid(state),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, Guest',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black87),
              ),
              SizedBox(height: 4),
              Text(
                'Discover your unique style',
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12, width: 2),
            ),
            child: const CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Guest+User&background=0D8ABC&color=fff'),
            ),
          ),
        ],
      ),
    );
  }

  // 👇 [BARU] UI BANNER YANG SUDAH DINAMIS 👇
  Widget _buildBannerSlider() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemCount: _bannerData.length,
        onPageChanged: (index) {
          setState(() {
            _currentBannerIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final banner = _bannerData[index];
          return _bannerItem(banner['image']!, banner['subtitle']!, banner['title']!);
        },
      ),
    );
  }

  Widget _bannerItem(String assetPath, String subtitle, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(assetPath), 
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: SizedBox(
        height: 35,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          itemCount: _filters.length,
          itemBuilder: (context, index) {
            bool isSelected = _selectedFilterIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilterIndex = index),
              child: Container(
                margin: const EdgeInsets.only(right: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _filters[index].toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey.shade400,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                    if (isSelected)
                      Container(height: 4, width: 4, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle))
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductGrid(HomeLoaded state) {
    final displayData = _selectedFilterIndex == 1 ? state.bestSellers : state.activeProducts;

    if (displayData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: Text("Tidak ada produk.", style: TextStyle(color: Colors.grey))),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: displayData.length,
        itemBuilder: (context, index) {
          final product = displayData[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              image: product.image != null
                  ? DecorationImage(
                      image: NetworkImage(product.image!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          product.name,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'Rp ${product.price.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black),
        ),
      ],
    );
  }
}