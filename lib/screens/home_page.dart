// import 'dart:async'; // [BARU] Import Timer
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../blocs/home/home_bloc.dart';
// import '../blocs/home/home_event.dart';
// import '../blocs/home/home_state.dart';
// import '../models/product_model.dart';
// import '../repositories/product_repository.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _selectedFilterIndex = 0;
//   final List<String> _filters = ['All Products', 'Best Seller', 'Vol 1', 'New Arrival'];

//   // 👇 [BARU] Konfigurasi Auto-Slide Banner 👇
//   final PageController _pageController = PageController();
//   Timer? _bannerTimer;
//   int _currentBannerIndex = 0;

//   final List<Map<String, String>> _bannerData = [
//     {
//       'image': 'assets/images/first_banner.png',
//       'subtitle': '',
//       'title': ''
//     },
//     {
//       'image': 'assets/images/second_banner.png',
//       'subtitle': '',
//       'title': ''
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     // Mengatur Timer untuk menggeser banner setiap 4 detik
//     _bannerTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
//       if (_currentBannerIndex < _bannerData.length - 1) {
//         _currentBannerIndex++;
//       } else {
//         _currentBannerIndex = 0; // Kembali ke awal jika sudah di ujung
//       }

//       if (_pageController.hasClients) {
//         _pageController.animateToPage(
//           _currentBannerIndex,
//           duration: const Duration(milliseconds: 600),
//           curve: Curves.easeInOutQuart, // Animasi transisi yang elegan
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     // [PENTING] Matikan timer dan controller saat pindah halaman agar tidak bocor memori (Memory Leak)
//     _bannerTimer?.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }
//   // 👆 ========================================== 👆

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => HomeBloc(productRepository: ProductRepository())..add(FetchHomeData()),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: BlocBuilder<HomeBloc, HomeState>(
//             builder: (context, state) {
//               if (state is HomeLoading) {
//                 return const Center(child: CircularProgressIndicator(color: Colors.black));
//               } else if (state is HomeError) {
//                 return Center(child: Text(state.message, textAlign: TextAlign.center));
//               } else if (state is HomeLoaded) {
//                 return SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildHeader(),
//                       _buildBannerSlider(), // Memanggil Banner Baru
//                       _buildFilters(),
//                       _buildProductGrid(state),
//                     ],
//                   ),
//                 );
//               }
//               return const SizedBox.shrink();
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Hi, Guest',
//                 style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black87),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 'Discover your unique style',
//                 style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.black12, width: 2),
//             ),
//             child: const CircleAvatar(
//               radius: 22,
//               backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Sean+User&background=0D8ABC&color=fff'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 👇 [BARU] UI BANNER YANG SUDAH DINAMIS 👇
//   Widget _buildBannerSlider() {
//     return SizedBox(
//       height: 180,
//       child: PageView.builder(
//         controller: _pageController,
//         physics: const BouncingScrollPhysics(),
//         itemCount: _bannerData.length,
//         onPageChanged: (index) {
//           setState(() {
//             _currentBannerIndex = index;
//           });
//         },
//         itemBuilder: (context, index) {
//           final banner = _bannerData[index];
//           return _bannerItem(banner['image']!, banner['subtitle']!, banner['title']!);
//         },
//       ),
//     );
//   }

//   Widget _bannerItem(String assetPath, String subtitle, String title) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 24.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         image: DecorationImage(
//           image: AssetImage(assetPath),
//           fit: BoxFit.cover,
//           colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Text(
//               subtitle,
//               style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilters() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 24.0),
//       child: SizedBox(
//         height: 35,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           physics: const BouncingScrollPhysics(),
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           itemCount: _filters.length,
//           itemBuilder: (context, index) {
//             bool isSelected = _selectedFilterIndex == index;
//             return GestureDetector(
//               onTap: () => setState(() => _selectedFilterIndex = index),
//               child: Container(
//                 margin: const EdgeInsets.only(right: 24),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       _filters[index].toUpperCase(),
//                       style: TextStyle(
//                         color: isSelected ? Colors.black : Colors.grey.shade400,
//                         fontWeight: FontWeight.w800,
//                         fontSize: 13,
//                         letterSpacing: 1,
//                       ),
//                     ),
//                     if (isSelected)
//                       Container(height: 4, width: 4, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle))
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildProductGrid(HomeLoaded state) {
//     final displayData = _selectedFilterIndex == 1 ? state.bestSellers : state.activeProducts;

//     if (displayData.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(24.0),
//         child: Center(child: Text("Tidak ada produk.", style: TextStyle(color: Colors.grey))),
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0),
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 0.65,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//         ),
//         itemCount: displayData.length,
//         itemBuilder: (context, index) {
//           final product = displayData[index];
//           return _buildProductCard(product);
//         },
//       ),
//     );
//   }

//   Widget _buildProductCard(ProductModel product) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(16),
//               image: product.image != null
//                   ? DecorationImage(
//                       image: NetworkImage(product.image!),
//                       fit: BoxFit.cover,
//                     )
//                   : null,
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         Text(
//           product.name,
//           style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         const SizedBox(height: 4),
//         Text(
//           'Rp ${product.price.toStringAsFixed(0)}',
//           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black),
//         ),
//       ],
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../blocs/category/category_bloc.dart';
// import '../blocs/category/category_event.dart';
// import '../blocs/category/category_state.dart';
// import '../blocs/product/product_bloc.dart';
// import '../blocs/product/product_event.dart';
// import '../blocs/product/product_state.dart';
// import 'package:solher_mobile/models/product_model.dart';
// import '../repositories/category_repository.dart';
// import '../repositories/product_repository.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _selectedFilterIndex = 0;

//   // Konfigurasi Auto-Slide Banner
//   final PageController _pageController = PageController();
//   Timer? _bannerTimer;
//   int _currentBannerIndex = 0;

//   // Konfigurasi Lazy Loading
//   final ScrollController _scrollController = ScrollController();
//   bool _isFetchingMore = false; // Flag mencegah fetch berulang

//   final List<Map<String, String>> _bannerData = [
//     {
//       'image': 'assets/images/first_banner.png',
//       'subtitle': 'NEW COLLECTION',
//       'title': 'Elegance Redefined'
//     },
//     {
//       'image': 'assets/images/second_banner.png',
//       'subtitle': 'SUMMER SALE',
//       'title': 'Up to 50% Off'
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _setupBannerTimer();

//     // Listener untuk Lazy Loading Horizontal Scroll
//     _scrollController.addListener(_onScroll);
//   }

//   void _setupBannerTimer() {
//     _bannerTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
//       if (_currentBannerIndex < _bannerData.length - 1) {
//         _currentBannerIndex++;
//       } else {
//         _currentBannerIndex = 0;
//       }

//       if (_pageController.hasClients) {
//         _pageController.animateToPage(
//           _currentBannerIndex,
//           duration: const Duration(milliseconds: 600),
//           curve: Curves.easeInOutQuart,
//         );
//       }
//     });
//   }

//   void _onScroll() {
//     // Jika posisi scroll sudah mencapai 80% dari total panjang konten
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent * 0.8) {
//       if (!_isFetchingMore) {
//         setState(() => _isFetchingMore = true);

//         // TODO: Ganti dengan event pagination jika API sudah mendukung (misal: LoadMoreProductsEvent)
//         // context.read<ProductBloc>().add(LoadMoreProductsEvent());

//         // Simulasi delay sementara flag dilepas setelah request selesai
//         Future.delayed(const Duration(seconds: 2), () {
//           if (mounted) setState(() => _isFetchingMore = false);
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _bannerTimer?.cancel();
//     _pageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) =>
//               CategoryBloc(categoryRepository: CategoryRepository())
//                 ..add(FetchCategories()),
//         ),
//         BlocProvider(
//           create: (context) =>
//               ProductBloc(productRepository: ProductRepository())
//                 ..add(FetchActiveProductsEvent()),
//         ),
//       ],
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeader(),
//                 _buildBannerSlider(),
//                 _buildCategoryFilters(),
//                 const SizedBox(height: 16),
//                 _buildHorizontalProductList(),
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Hi, Sean',
//                 style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.w900,
//                     color: Colors.black87),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 'Discover your unique style',
//                 style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                     fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.black12, width: 2),
//             ),
//             child: const CircleAvatar(
//               radius: 22,
//               backgroundImage: NetworkImage(
//                   'https://ui-avatars.com/api/?name=Sean+Alden&background=0D8ABC&color=fff'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBannerSlider() {
//     return SizedBox(
//       height: 180,
//       child: PageView.builder(
//         controller: _pageController,
//         physics: const BouncingScrollPhysics(),
//         itemCount: _bannerData.length,
//         onPageChanged: (index) {
//           setState(() {
//             _currentBannerIndex = index;
//           });
//         },
//         itemBuilder: (context, index) {
//           final banner = _bannerData[index];
//           return _bannerItem(
//               banner['image']!, banner['subtitle']!, banner['title']!);
//         },
//       ),
//     );
//   }

//   Widget _bannerItem(String assetPath, String subtitle, String title) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 24.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         image: DecorationImage(
//           image: AssetImage(assetPath),
//           fit: BoxFit.cover,
//           colorFilter:
//               ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Text(
//               subtitle,
//               style: const TextStyle(
//                   color: Colors.white70,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: 2),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.w900),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget _buildCategoryFilters() {
//   //   return BlocBuilder<CategoryBloc, CategoryState>(
//   //     builder: (context, state) {
//   //       if (state is CategoryLoading) {
//   //         return const Padding(
//   //           padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
//   //           child: LinearProgressIndicator(color: Colors.black),
//   //         );
//   //       } else if (state is CategoryLoaded) {
//   //         // Menambahkan default filter 'All Products' di awal list
//   //         final categories = [
//   //           'All Products',
//   //           ...state.categories.map((c) => c.name)
//   //         ];

//   //         return Padding(
//   //           padding: const EdgeInsets.symmetric(vertical: 24.0),
//   //           child: SizedBox(
//   //             height: 35,
//   //             child: ListView.builder(
//   //               scrollDirection: Axis.horizontal,
//   //               physics: const BouncingScrollPhysics(),
//   //               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//   //               itemCount: categories.length,
//   //               itemBuilder: (context, index) {
//   //                 bool isSelected = _selectedFilterIndex == index;
//   //                 return GestureDetector(
//   //                   onTap: () {
//   //                     setState(() => _selectedFilterIndex = index);
//   //                     // Trigger perubahan data produk berdasarkan kategori
//   //                     if (index == 0) {
//   //                       context
//   //                           .read<ProductBloc>()
//   //                           .add(FetchActiveProductsEvent());
//   //                     } else {
//   //                       // Jika ada event pencarian berdasarkan kategori
//   //                       // context.read<ProductBloc>().add(FetchProductsByCategoryEvent(categories[index]));
//   //                     }
//   //                   },
//   //                   child: Container(
//   //                     margin: const EdgeInsets.only(right: 24),
//   //                     child: Column(
//   //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                       crossAxisAlignment: CrossAxisAlignment.center,
//   //                       children: [
//   //                         Text(
//   //                           categories[index].toUpperCase(),
//   //                           style: TextStyle(
//   //                             color: isSelected
//   //                                 ? Colors.black
//   //                                 : Colors.grey.shade400,
//   //                             fontWeight: FontWeight.w800,
//   //                             fontSize: 13,
//   //                             letterSpacing: 1,
//   //                           ),
//   //                         ),
//   //                         if (isSelected)
//   //                           Container(
//   //                               height: 4,
//   //                               width: 4,
//   //                               decoration: const BoxDecoration(
//   //                                   color: Colors.black,
//   //                                   shape: BoxShape.circle))
//   //                       ],
//   //                     ),
//   //                   ),
//   //                 );
//   //               },
//   //             ),
//   //           ),
//   //         );
//   //       }
//   //       return const SizedBox.shrink();
//   //     },
//   //   );
//   // }

//   Widget _buildCategoryFilters() {
//     return BlocBuilder<CategoryBloc, CategoryState>(
//       builder: (context, state) {
//         // 1. Tangani saat pertama kali dijalankan atau sedang loading
//         if (state is CategoryInitial || state is CategoryLoading) {
//           return const Padding(
//             padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
//             child: LinearProgressIndicator(color: Colors.black),
//           );
//         }
//         // 2. Tangani jika data berhasil didapatkan
//         else if (state is CategoryLoaded) {
//           final categories = [
//             'All Products',
//             ...state.categories.map((c) => c.name)
//           ];

//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 24.0),
//             child: SizedBox(
//               height: 35,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 physics: const BouncingScrollPhysics(),
//                 padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                 itemCount: categories.length,
//                 itemBuilder: (context, index) {
//                   bool isSelected = _selectedFilterIndex == index;
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() => _selectedFilterIndex = index);
//                       if (index == 0) {
//                         context
//                             .read<ProductBloc>()
//                             .add(FetchActiveProductsEvent());
//                       } else {
//                         // TODO: Event fetch per category
//                       }
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.only(right: 24),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             categories[index].toUpperCase(),
//                             style: TextStyle(
//                               color: isSelected
//                                   ? Colors.black
//                                   : Colors.grey.shade400,
//                               fontWeight: FontWeight.w800,
//                               fontSize: 13,
//                               letterSpacing: 1,
//                             ),
//                           ),
//                           if (isSelected)
//                             Container(
//                                 height: 4,
//                                 width: 4,
//                                 decoration: const BoxDecoration(
//                                     color: Colors.black,
//                                     shape: BoxShape.circle))
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           );
//         }
//         // 3. [BARU] Tangani jika terjadi error dari API
//         else if (state is CategoryError) {
//           return Padding(
//             padding:
//                 const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
//             child: Row(
//               children: [
//                 const Icon(Icons.error_outline, color: Colors.red, size: 20),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     "Gagal memuat kategori: ${state.message}",
//                     style: const TextStyle(color: Colors.red, fontSize: 12),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return const SizedBox.shrink();
//       },
//     );
//   }

//   Widget _buildHorizontalProductList() {
//     return BlocBuilder<ProductBloc, ProductState>(
//       builder: (context, state) {
//         if (state is ProductLoading && !_isFetchingMore) {
//           return const Center(
//             child: Padding(
//               padding: EdgeInsets.all(40.0),
//               child: CircularProgressIndicator(color: Colors.black),
//             ),
//           );
//         } else if (state is ProductError) {
//           return Center(child: Text(state.message));
//         } else if (state is ProductListLoaded) {
//           final displayData = state.products;

//           if (displayData.isEmpty) {
//             return const Padding(
//               padding: EdgeInsets.all(24.0),
//               child: Center(
//                   child: Text("Tidak ada produk.",
//                       style: TextStyle(color: Colors.grey))),
//             );
//           }

//           // Tinggi statis untuk horizontal ListView
//           return SizedBox(
//             height: 280,
//             child: ListView.builder(
//               controller: _scrollController,
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//               itemCount: displayData.length + (_isFetchingMore ? 1 : 0),
//               itemBuilder: (context, index) {
//                 // Menampilkan indikator loading di item terakhir saat fetch more
//                 if (index == displayData.length) {
//                   return const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.0),
//                     child: Center(
//                         child: CircularProgressIndicator(color: Colors.black)),
//                   );
//                 }

//                 final product = displayData[index];
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 16.0),
//                   child: SizedBox(
//                     width:
//                         160, // Lebar card dikunci agar rapi saat horizontal scroll
//                     child: _buildProductCard(product),
//                   ),
//                 );
//               },
//             ),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }

//   Widget _buildProductCard(ProductModel product) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(16),
//               image: product.image != null
//                   ? DecorationImage(
//                       image: NetworkImage(product.image!),
//                       fit: BoxFit.cover,
//                     )
//                   : null,
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         Text(
//           product.name,
//           style: const TextStyle(
//               fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         const SizedBox(height: 4),
//         Text(
//           'Rp ${product.price.toStringAsFixed(0)}',
//           style: const TextStyle(
//               fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black),
//         ),
//       ],
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:solher_mobile/models/category_model.dart';
// import '../blocs/category/category_bloc.dart';
// import '../blocs/category/category_event.dart';
// import '../blocs/category/category_state.dart';
// import '../blocs/product/product_bloc.dart';
// import '../blocs/product/product_event.dart';
// import '../blocs/product/product_state.dart';
// import 'package:solher_mobile/models/product_model.dart';
// import '../repositories/category_repository.dart';
// import '../repositories/product_repository.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _selectedFilterIndex = 0;

//   final PageController _pageController = PageController();
//   Timer? _bannerTimer;
//   int _currentBannerIndex = 0;

//   final ScrollController _scrollController = ScrollController();
//   bool _isFetchingMore = false;

//   final List<Map<String, String>> _bannerData = [
//     {
//       'image': 'assets/images/first_banner.png',
//       'subtitle': 'NEW COLLECTION',
//       'title': 'Elegance Redefined'
//     },
//     {
//       'image': 'assets/images/second_banner.png',
//       'subtitle': 'SUMMER SALE',
//       'title': 'Up to 50% Off'
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _setupBannerTimer();
//     _scrollController.addListener(_onScroll);

//     // Opsional: Memunculkan Promo Popup mirip Vue saat pertama kali aplikasi dibuka
//     // WidgetsBinding.instance.addPostFrameCallback((_) => _showPromoPopup());
//   }

//   void _setupBannerTimer() {
//     _bannerTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
//       if (_currentBannerIndex < _bannerData.length - 1) {
//         _currentBannerIndex++;
//       } else {
//         _currentBannerIndex = 0;
//       }
//       if (_pageController.hasClients) {
//         _pageController.animateToPage(
//           _currentBannerIndex,
//           duration: const Duration(milliseconds: 600),
//           curve: Curves.easeInOutQuart,
//         );
//       }
//     });
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent * 0.8) {
//       if (!_isFetchingMore) {
//         setState(() => _isFetchingMore = true);
//         Future.delayed(const Duration(seconds: 2), () {
//           if (mounted) setState(() => _isFetchingMore = false);
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _bannerTimer?.cancel();
//     _pageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) =>
//               CategoryBloc(categoryRepository: CategoryRepository())
//                 ..add(FetchCategories()),
//         ),
//         BlocProvider(
//           create: (context) =>
//               ProductBloc(productRepository: ProductRepository())
//                 ..add(FetchActiveProductsEvent()),
//         ),
//       ],
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeader(),
//                 _buildBannerSlider(),

//                 // 👇 Meniru "Featured Split Banners" dari Vue 👇
//                 const SizedBox(height: 24),
//                 _buildSplitBanners(),

//                 // Bagian Filter Kategori & Produk
//                 _buildCategoryFilters(),
//                 _buildHorizontalProductList(),

//                 // 👇 Meniru "Why Choose Us" dari Vue 👇
//                 _buildValueProposition(),
//                 const SizedBox(height: 40),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Hi, Sean',
//                 style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.w900,
//                     color: Colors.black87),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 'Discover your unique style',
//                 style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                     fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.black12, width: 2),
//             ),
//             child: const CircleAvatar(
//               radius: 22,
//               backgroundImage: NetworkImage(
//                   'https://ui-avatars.com/api/?name=Sean+Alden&background=0D8ABC&color=fff'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBannerSlider() {
//     return SizedBox(
//       height: 200,
//       child: PageView.builder(
//         controller: _pageController,
//         physics: const BouncingScrollPhysics(),
//         itemCount: _bannerData.length,
//         onPageChanged: (index) => setState(() => _currentBannerIndex = index),
//         itemBuilder: (context, index) {
//           final banner = _bannerData[index];
//           return _bannerItem(
//               banner['image']!, banner['subtitle']!, banner['title']!);
//         },
//       ),
//     );
//   }

//   Widget _bannerItem(String assetPath, String subtitle, String title) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 24.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         image: DecorationImage(
//           image: AssetImage(assetPath),
//           fit: BoxFit.cover,
//           colorFilter:
//               ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Text(
//               subtitle,
//               style: const TextStyle(
//                   color: Colors.white70,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: 2),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.w900),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // 👇 STRUKTUR BARU: Split Banners ala Vue 👇
//   Widget _buildSplitBanners() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildSplitBannerItem(
//                 'assets/images/DSCF2648.jpg', 'DISCOVER ZAHARA'),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child:
//                 _buildSplitBannerItem('assets/images/DSCF7586.jpg', 'AUREVE'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSplitBannerItem(String imagePath, String btnText) {
//     return Container(
//       height: 220,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         image: DecorationImage(
//           image: AssetImage(imagePath), // Pastikan gambar ada di assets
//           fit: BoxFit.cover,
//           colorFilter:
//               ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
//         ),
//       ),
//       child: Center(
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
//           ),
//           child: Text(
//             btnText,
//             style: const TextStyle(
//                 fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
//           ),
//         ),
//       ),
//     );
//   }

//   // 👇 PERBAIKAN LOGIKA FILTER KATEGORI 👇
//   Widget _buildCategoryFilters() {
//     return BlocBuilder<CategoryBloc, CategoryState>(
//       builder: (context, state) {
//         if (state is CategoryLoading || state is CategoryInitial) {
//           return const Padding(
//             padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
//             child: LinearProgressIndicator(color: Colors.black),
//           );
//         } else if (state is CategoryLoaded) {
//           // Membuat list komprehensif yang berisi model Category seutuhnya
//           final List<Category> filterCategories = [
//             Category(id: 0, code: 'ALL', name: 'All Products'), // Item Default
//             ...state.categories
//           ];

//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 32.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Mengadopsi teks "Trending Now" dari Vue
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 24.0),
//                   child: Text(
//                     "Our Collections",
//                     style: TextStyle(
//                         fontSize: 24,
//                         fontStyle: FontStyle.italic,
//                         fontWeight: FontWeight.w300),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   height: 35,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     itemCount: filterCategories.length,
//                     itemBuilder: (context, index) {
//                       bool isSelected = _selectedFilterIndex == index;
//                       final category = filterCategories[index];

//                       return GestureDetector(
//                         onTap: () {
//                           setState(() => _selectedFilterIndex = index);

//                           // Eksekusi pemanggilan data berdasarkan ID
//                           if (category.id == 0) {
//                             context
//                                 .read<ProductBloc>()
//                                 .add(FetchActiveProductsEvent());
//                           } else {
//                             // PASTIKAN EVENT INI SUDAH ADA DI PRODUCT BLOC ANDA
//                             context.read<ProductBloc>().add(
//                                 FetchProductsByCategoryEvent(category.id!));
//                           }
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.only(right: 24),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 category.name.toUpperCase(),
//                                 style: TextStyle(
//                                   color: isSelected
//                                       ? Colors.black
//                                       : Colors.grey.shade400,
//                                   fontWeight: FontWeight.w800,
//                                   fontSize: 12,
//                                   letterSpacing: 1.5,
//                                 ),
//                               ),
//                               if (isSelected)
//                                 Container(
//                                   height: 4,
//                                   width: 4,
//                                   decoration: const BoxDecoration(
//                                       color: Colors.black,
//                                       shape: BoxShape.circle),
//                                 )
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         } else if (state is CategoryError) {
//           return Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Text("Gagal memuat kategori: ${state.message}",
//                 style: const TextStyle(color: Colors.red)),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }

//   Widget _buildHorizontalProductList() {
//     return BlocBuilder<ProductBloc, ProductState>(
//       builder: (context, state) {
//         if (state is ProductLoading && !_isFetchingMore) {
//           return const Center(
//             child: Padding(
//                 padding: EdgeInsets.all(40.0),
//                 child: CircularProgressIndicator(color: Colors.black)),
//           );
//         } else if (state is ProductError) {
//           return Center(child: Text(state.message));
//         } else if (state is ProductListLoaded) {
//           final displayData = state.products;

//           if (displayData.isEmpty) {
//             return const Padding(
//               padding: EdgeInsets.all(24.0),
//               child: Center(
//                   child: Text("Tidak ada produk.",
//                       style: TextStyle(color: Colors.grey))),
//             );
//           }

//           return SizedBox(
//             height: 320, // Diperbesar sedikit menyesuaikan style Vue
//             child: ListView.builder(
//               controller: _scrollController,
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//               itemCount: displayData.length + (_isFetchingMore ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index == displayData.length) {
//                   return const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.0),
//                     child: Center(
//                         child: CircularProgressIndicator(color: Colors.black)),
//                   );
//                 }

//                 return Padding(
//                   padding: const EdgeInsets.only(right: 16.0),
//                   child: SizedBox(
//                     width: 180, // Lebih lebar sesuai estetik Vue
//                     child: _buildProductCard(displayData[index]),
//                   ),
//                 );
//               },
//             ),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }

//   // 👇 DESAIN KARTU PRODUK ALA VUE 👇
// // 👇 DESAIN KARTU PRODUK ALA VUE 👇
//   Widget _buildProductCard(ProductModel product) {
//     bool hasDiscount =
//         product.discountPrice != null && product.discountPrice! > 0;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Container(
//             // HAPUS BARIS 'position' DI SINI
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(12),
//               image: product.image != null
//                   ? DecorationImage(
//                       image: NetworkImage(product.image!), fit: BoxFit.cover)
//                   : null,
//             ),
//             child: Stack(
//               children: [
//                 // Badge HOT atau Stock
//                 Positioned(
//                   top: 12,
//                   left: 12,
//                   child: Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Text(
//                       'HOT',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 9,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1.5),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         Text(
//           product.name.toUpperCase(),
//           style: const TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w800,
//               color: Colors.black87,
//               letterSpacing: 1.2),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         const SizedBox(height: 4),
//         Row(
//           children: [
//             if (hasDiscount) ...[
//               Text(
//                 'Rp ${product.discountPrice!.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w900,
//                     color: Colors.red),
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 'Rp ${product.price.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                     fontSize: 10,
//                     color: Colors.grey,
//                     decoration: TextDecoration.lineThrough),
//               ),
//             ] else ...[
//               Text(
//                 'Rp ${product.price.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w900,
//                     color: Colors.black),
//               ),
//             ]
//           ],
//         ),
//       ],
//     );
//   }

//   // 👇 STRUKTUR BARU: Why Choose Us / Value Proposition 👇
//   Widget _buildValueProposition() {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(top: 40),
//       padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
//       decoration: const BoxDecoration(
//         color: Color(0xFFFAFAFA),
//         border: Border(top: BorderSide(color: Colors.black12)),
//       ),
//       child: Column(
//         children: [
//           const Text(
//             "Why Choose Solher",
//             style: TextStyle(
//                 fontSize: 24,
//                 fontStyle: FontStyle.italic,
//                 fontWeight: FontWeight.w300),
//           ),
//           const SizedBox(height: 4),
//           const Text(
//             "THE SOLHER DIFFERENCE",
//             style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 2,
//                 color: Colors.grey),
//           ),
//           const SizedBox(height: 32),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                   child: _buildValueItem(
//                       Icons.diamond_outlined,
//                       'PREMIUM MATERIALS',
//                       'Crafted with the finest vegan leather.')),
//               const SizedBox(width: 16),
//               Expanded(
//                   child: _buildValueItem(
//                       Icons.design_services_outlined,
//                       'UNIQUE DESIGN',
//                       'Stand out with our exclusive silhouettes.')),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildValueItem(IconData icon, String title, String desc) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration:
//               const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//           child: Icon(icon, size: 28, color: Colors.black87),
//         ),
//         const SizedBox(height: 12),
//         Text(title,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//                 fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
//         const SizedBox(height: 6),
//         Text(desc,
//             textAlign: TextAlign.center,
//             style:
//                 const TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
//       ],
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:solher_mobile/models/category_model.dart';
// import '../blocs/category/category_bloc.dart';
// import '../blocs/category/category_event.dart';
// import '../blocs/category/category_state.dart';
// import '../blocs/product/product_bloc.dart';
// import '../blocs/product/product_event.dart';
// import '../blocs/product/product_state.dart';
// import 'package:solher_mobile/models/product_model.dart';
// import '../repositories/category_repository.dart';
// import '../repositories/product_repository.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _selectedFilterIndex = 0;

//   final PageController _pageController = PageController();
//   Timer? _bannerTimer;
//   int _currentBannerIndex = 0;

//   final ScrollController _scrollController = ScrollController();
//   bool _isFetchingMore = false;

//   final List<Map<String, String>> _bannerData = [
//     {
//       'image': 'assets/images/first_banner.png',
//       'subtitle': 'NEW COLLECTION',
//       'title': 'Elegance Redefined'
//     },
//     {
//       'image': 'assets/images/second_banner.png',
//       'subtitle': 'SUMMER SALE',
//       'title': 'Up to 50% Off'
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _setupBannerTimer();
//     _scrollController.addListener(_onScroll);

//     // Opsional: Memunculkan Promo Popup mirip Vue saat pertama kali aplikasi dibuka
//     // WidgetsBinding.instance.addPostFrameCallback((_) => _showPromoPopup());
//   }

//   void _setupBannerTimer() {
//     _bannerTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
//       if (_currentBannerIndex < _bannerData.length - 1) {
//         _currentBannerIndex++;
//       } else {
//         _currentBannerIndex = 0;
//       }
//       if (_pageController.hasClients) {
//         _pageController.animateToPage(
//           _currentBannerIndex,
//           duration: const Duration(milliseconds: 600),
//           curve: Curves.easeInOutQuart,
//         );
//       }
//     });
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent * 0.8) {
//       if (!_isFetchingMore) {
//         setState(() => _isFetchingMore = true);
//         Future.delayed(const Duration(seconds: 2), () {
//           if (mounted) setState(() => _isFetchingMore = false);
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _bannerTimer?.cancel();
//     _pageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) =>
//               CategoryBloc(categoryRepository: CategoryRepository())
//                 ..add(FetchCategories()),
//         ),
//         // ProductBloc ini KHUSUS digunakan untuk bagian Our Collections & Filter
//         BlocProvider(
//           create: (context) =>
//               ProductBloc(productRepository: ProductRepository())
//                 ..add(FetchActiveProductsEvent()),
//         ),
//       ],
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: const Text('Home', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'serif')),
//           backgroundColor: Colors.grey[500],
//           foregroundColor: Colors.white,
//           elevation: 2,
//           centerTitle: true,
//         ),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeader(),
//                 _buildBannerSlider(),

//                 // Bagian Filter Kategori & Produk
//                 _buildCategoryFilters(),
//                 _buildHorizontalProductList(),

//                 // 👇 BAGIAN BEST SELLER DITAMBAHKAN DI SINI 👇
//                 _buildBestSellerSection(),

//                 // Why Choose Us
//                 _buildValueProposition(),
//                 const SizedBox(height: 40),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Hi, Sean',
//                 style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.w900,
//                     color: Colors.black87),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 'Discover your unique style',
//                 style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                     fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.black12, width: 2),
//             ),
//             child: const CircleAvatar(
//               radius: 22,
//               backgroundImage: NetworkImage(
//                   'https://ui-avatars.com/api/?name=Sean+Alden&background=0D8ABC&color=fff'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBannerSlider() {
//     return SizedBox(
//       height: 200,
//       child: PageView.builder(
//         controller: _pageController,
//         physics: const BouncingScrollPhysics(),
//         itemCount: _bannerData.length,
//         onPageChanged: (index) => setState(() => _currentBannerIndex = index),
//         itemBuilder: (context, index) {
//           final banner = _bannerData[index];
//           return _bannerItem(
//               banner['image']!, banner['subtitle']!, banner['title']!);
//         },
//       ),
//     );
//   }

//   Widget _bannerItem(String assetPath, String subtitle, String title) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 24.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         image: DecorationImage(
//           image: AssetImage(assetPath),
//           fit: BoxFit.cover,
//           colorFilter:
//               ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Text(
//               subtitle,
//               style: const TextStyle(
//                   color: Colors.white70,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: 2),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.w900),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryFilters() {
//     return BlocBuilder<CategoryBloc, CategoryState>(
//       builder: (context, state) {
//         if (state is CategoryLoading || state is CategoryInitial) {
//           return const Padding(
//             padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
//             child: LinearProgressIndicator(color: Colors.black),
//           );
//         } else if (state is CategoryLoaded) {
//           final List<Category> filterCategories = [
//             Category(id: 0, code: 'ALL', name: 'All Products'),
//             ...state.categories
//           ];

//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 32.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 24.0),
//                   child: Text(
//                     "Our Collections",
//                     style: TextStyle(
//                         fontSize: 24,
//                         fontStyle: FontStyle.italic,
//                         fontWeight: FontWeight.w300),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   height: 35,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     itemCount: filterCategories.length,
//                     itemBuilder: (context, index) {
//                       bool isSelected = _selectedFilterIndex == index;
//                       final category = filterCategories[index];

//                       return GestureDetector(
//                         onTap: () {
//                           setState(() => _selectedFilterIndex = index);

//                           if (category.id == 0) {
//                             context
//                                 .read<ProductBloc>()
//                                 .add(FetchActiveProductsEvent());
//                           } else {
//                             context.read<ProductBloc>().add(
//                                 FetchProductsByCategoryEvent(category.id!));
//                           }
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.only(right: 24),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 category.name.toUpperCase(),
//                                 style: TextStyle(
//                                   color: isSelected
//                                       ? Colors.black
//                                       : Colors.grey.shade400,
//                                   fontWeight: FontWeight.w800,
//                                   fontSize: 12,
//                                   letterSpacing: 1.5,
//                                 ),
//                               ),
//                               if (isSelected)
//                                 Container(
//                                   height: 4,
//                                   width: 4,
//                                   decoration: const BoxDecoration(
//                                       color: Colors.black,
//                                       shape: BoxShape.circle),
//                                 )
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         } else if (state is CategoryError) {
//           return Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Text("Gagal memuat kategori: ${state.message}",
//                 style: const TextStyle(color: Colors.red)),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }

//   Widget _buildHorizontalProductList() {
//     return BlocBuilder<ProductBloc, ProductState>(
//       builder: (context, state) {
//         if (state is ProductLoading && !_isFetchingMore) {
//           return const Center(
//             child: Padding(
//                 padding: EdgeInsets.all(40.0),
//                 child: CircularProgressIndicator(color: Colors.black)),
//           );
//         } else if (state is ProductError) {
//           return Center(child: Text(state.message));
//         } else if (state is ProductListLoaded) {
//           final displayData = state.products;

//           if (displayData.isEmpty) {
//             return const Padding(
//               padding: EdgeInsets.all(24.0),
//               child: Center(
//                   child: Text("Tidak ada produk.",
//                       style: TextStyle(color: Colors.grey))),
//             );
//           }

//           return SizedBox(
//             height: 320,
//             child: ListView.builder(
//               controller: _scrollController,
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//               itemCount: displayData.length + (_isFetchingMore ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index == displayData.length) {
//                   return const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.0),
//                     child: Center(
//                         child: CircularProgressIndicator(color: Colors.black)),
//                   );
//                 }

//                 return Padding(
//                   padding: const EdgeInsets.only(right: 16.0),
//                   child: SizedBox(
//                     width: 180,
//                     child: _buildProductCard(displayData[index]),
//                   ),
//                 );
//               },
//             ),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }

//   // 👇 STRUKTUR BARU: Bagian Best Seller Mandiri 👇
//   Widget _buildBestSellerSection() {
//     return BlocProvider(
//       // Sengaja membuat instance ProductBloc baru yang terisolasi
//       create: (context) => ProductBloc(productRepository: ProductRepository())
//         ..add(FetchBestSellersEvent()),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(
//                 left: 24.0, right: 24.0, top: 40.0, bottom: 16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Best Sellers",
//                   style: TextStyle(
//                       fontSize: 24,
//                       fontStyle: FontStyle.italic,
//                       fontWeight: FontWeight.w300),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   "OUR MOST LOVED PIECES",
//                   style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 2,
//                       color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//           BlocBuilder<ProductBloc, ProductState>(
//             builder: (context, state) {
//               if (state is ProductLoading) {
//                 return const Center(
//                   child: Padding(
//                       padding: EdgeInsets.all(40.0),
//                       child: CircularProgressIndicator(color: Colors.black)),
//                 );
//               } else if (state is ProductError) {
//                 return Center(child: Text(state.message));
//               } else if (state is ProductListLoaded) {
//                 final displayData = state.products;

//                 if (displayData.isEmpty) {
//                   return const Padding(
//                     padding: EdgeInsets.all(24.0),
//                     child: Center(
//                         child: Text("Tidak ada produk best seller.",
//                             style: TextStyle(color: Colors.grey))),
//                   );
//                 }

//                 return SizedBox(
//                   height: 320,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     itemCount: displayData.length,
//                     itemBuilder: (context, index) {
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 16.0),
//                         child: SizedBox(
//                           width: 180,
//                           child: _buildProductCard(displayData[index]),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               }
//               return const SizedBox.shrink();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProductCard(ProductModel product) {
//     bool hasDiscount =
//         product.discountPrice != null && product.discountPrice! > 0;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(12),
//               image: product.image != null
//                   ? DecorationImage(
//                       image: NetworkImage(product.image!), fit: BoxFit.cover)
//                   : null,
//             ),
//             child: Stack(
//               children: [
//                 Positioned(
//                   top: 12,
//                   left: 12,
//                   child: Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Text(
//                       'HOT',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 9,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1.5),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         Text(
//           product.name.toUpperCase(),
//           style: const TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w800,
//               color: Colors.black87,
//               letterSpacing: 1.2),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         const SizedBox(height: 4),
//         Row(
//           children: [
//             if (hasDiscount) ...[
//               Text(
//                 'Rp ${product.discountPrice!.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w900,
//                     color: Colors.red),
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 'Rp ${product.price.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                     fontSize: 10,
//                     color: Colors.grey,
//                     decoration: TextDecoration.lineThrough),
//               ),
//             ] else ...[
//               Text(
//                 'Rp ${product.price.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w900,
//                     color: Colors.black),
//               ),
//             ]
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildValueProposition() {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(top: 40),
//       padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
//       decoration: const BoxDecoration(
//         color: Color(0xFFFAFAFA),
//         border: Border(top: BorderSide(color: Colors.black12)),
//       ),
//       child: Column(
//         children: [
//           const Text(
//             "Why Choose Solher",
//             style: TextStyle(
//                 fontSize: 24,
//                 fontStyle: FontStyle.italic,
//                 fontWeight: FontWeight.w300),
//           ),
//           const SizedBox(height: 4),
//           const Text(
//             "THE SOLHER DIFFERENCE",
//             style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 2,
//                 color: Colors.grey),
//           ),
//           const SizedBox(height: 32),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                   child: _buildValueItem(
//                       Icons.diamond_outlined,
//                       'PREMIUM MATERIALS',
//                       'Crafted with the finest vegan leather.')),
//               const SizedBox(width: 16),
//               Expanded(
//                   child: _buildValueItem(
//                       Icons.design_services_outlined,
//                       'UNIQUE DESIGN',
//                       'Stand out with our exclusive silhouettes.')),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildValueItem(IconData icon, String title, String desc) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration:
//               const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//           child: Icon(icon, size: 28, color: Colors.black87),
//         ),
//         const SizedBox(height: 12),
//         Text(title,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//                 fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
//         const SizedBox(height: 6),
//         Text(desc,
//             textAlign: TextAlign.center,
//             style:
//                 const TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
//       ],
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:solher_mobile/models/category_model.dart';
// import 'package:solher_mobile/screens/product_detail_page.dart';
// import '../blocs/category/category_bloc.dart';
// import '../blocs/category/category_event.dart';
// import '../blocs/category/category_state.dart';
// import '../blocs/product/product_bloc.dart';
// import '../blocs/product/product_event.dart';
// import '../blocs/product/product_state.dart';
// import 'package:solher_mobile/models/product_model.dart';
// import '../repositories/category_repository.dart';
// import '../repositories/product_repository.dart';

// // 👇 [BARU] Import AuthBloc dan AuthState 👇
// import '../blocs/auth/auth_bloc.dart';
// import '../blocs/auth/auth_state.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _selectedFilterIndex = 0;

//   final PageController _pageController = PageController();
//   Timer? _bannerTimer;
//   int _currentBannerIndex = 0;

//   final ScrollController _scrollController = ScrollController();
//   bool _isFetchingMore = false;

//   final List<Map<String, String>> _bannerData = [
//     {
//       'image': 'assets/images/first_banner.png',
//       // 'subtitle': 'NEW COLLECTION',
//       'subtitle': '',
//       // 'title': 'Elegance Redefined'
//       'title': ''
//     },
//     {
//       'image': 'assets/images/second_banner.png',
//       // 'subtitle': 'SUMMER SALE',
//       'subtitle': '',
//       // 'title': 'Up to 50% Off'
//       'title': ''
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _setupBannerTimer();
//     _scrollController.addListener(_onScroll);
//   }

//   void _setupBannerTimer() {
//     _bannerTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
//       if (_currentBannerIndex < _bannerData.length - 1) {
//         _currentBannerIndex++;
//       } else {
//         _currentBannerIndex = 0;
//       }
//       if (_pageController.hasClients) {
//         _pageController.animateToPage(
//           _currentBannerIndex,
//           duration: const Duration(milliseconds: 600),
//           curve: Curves.easeInOutQuart,
//         );
//       }
//     });
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent * 0.8) {
//       if (!_isFetchingMore) {
//         setState(() => _isFetchingMore = true);
//         Future.delayed(const Duration(seconds: 2), () {
//           if (mounted) setState(() => _isFetchingMore = false);
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _bannerTimer?.cancel();
//     _pageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) =>
//               CategoryBloc(categoryRepository: CategoryRepository())
//                 ..add(FetchCategories()),
//         ),
//         BlocProvider(
//           create: (context) =>
//               ProductBloc(productRepository: ProductRepository())
//                 ..add(FetchActiveProductsEvent()),
//         ),
//       ],
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: const Text('Home',
//               style:
//                   TextStyle(fontWeight: FontWeight.w900, fontFamily: 'serif')),
//           backgroundColor: Colors.grey[500],
//           foregroundColor: Colors.white,
//           elevation: 2,
//           centerTitle: true,
//         ),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeader(),
//                 _buildBannerSlider(),
//                 _buildCategoryFilters(),
//                 _buildHorizontalProductList(),
//                 _buildBestSellerSection(),
//                 _buildValueProposition(),
//                 const SizedBox(height: 40),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // 👇 STRUKTUR BARU: Header Dinamis Berdasarkan AuthState 👇
//   // Widget _buildHeader() {
//   //   return BlocBuilder<AuthBloc, AuthState>(
//   //     builder: (context, state) {
//   //       // Fallback untuk Guest User
//   //       String displayName = 'Guest';
//   //       String profileImage =
//   //           'https://ui-avatars.com/api/?name=Guest&background=0D8ABC&color=fff';

//   //       // Jika terdeteksi login, ubah nama dan gambar
//   //       if (state is AuthAuthenticated) {
//   //         final user = state.user;
//   //         // Asumsi properti nama pada UserModel adalah 'firstName'. Sesuaikan jika berbeda.
//   //         displayName = user.firstName ?? 'User';

//   //         if (user.profileImage != null && user.profileImage!.isNotEmpty) {
//   //           profileImage = user.profileImage!;
//   //         } else {
//   //           // Gambar otomatis jika user belum upload foto
//   //           profileImage =
//   //               'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&background=000&color=fff';
//   //         }
//   //       }

//   //       return Padding(
//   //         padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
//   //         child: Row(
//   //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //           children: [
//   //             Column(
//   //               crossAxisAlignment: CrossAxisAlignment.start,
//   //               children: [
//   //                 Text(
//   //                   'Hi, $displayName',
//   //                   style: const TextStyle(
//   //                       fontSize: 26,
//   //                       fontWeight: FontWeight.w900,
//   //                       color: Colors.black87),
//   //                 ),
//   //                 const SizedBox(height: 4),
//   //                 const Text(
//   //                   'Discover your unique style',
//   //                   style: TextStyle(
//   //                       fontSize: 14,
//   //                       color: Colors.grey,
//   //                       fontWeight: FontWeight.w500),
//   //                 ),
//   //               ],
//   //             ),
//   //             Container(
//   //               decoration: BoxDecoration(
//   //                 shape: BoxShape.circle,
//   //                 border: Border.all(color: Colors.black12, width: 2),
//   //               ),
//   //               child: CircleAvatar(
//   //                 radius: 22,
//   //                 backgroundImage: NetworkImage(profileImage),
//   //                 backgroundColor: Colors.grey
//   //                     .shade200, // Background antisipasi saat loading gambar
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }

//   Widget _buildHeader() {
//     return BlocBuilder<AuthBloc, AuthState>(
//       builder: (context, state) {
//         // Fallback untuk Guest User
//         String displayName = 'Guest';

//         // Menggunakan ImageProvider agar bisa menampung Asset maupun Network
//         ImageProvider avatarImage =
//             const AssetImage('assets/images/profile.png');

//         // Jika terdeteksi login, ubah nama dan gambar
//         if (state is AuthAuthenticated) {
//           final user = state.user;
//           // Asumsi properti nama pada UserModel adalah 'firstName'. Sesuaikan jika berbeda.
//           displayName = user.firstName ?? 'User';

//           // Jika user punya foto profil dari server, ganti avatarImage menjadi NetworkImage
//           if (user.profileImage != null && user.profileImage!.isNotEmpty) {
//             avatarImage = NetworkImage(user.profileImage!);
//           }
//           // Jika kosong/null, ia akan tetap menggunakan AssetImage default di atas.
//         }

//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Hi, $displayName',
//                     style: const TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.w900,
//                         color: Colors.black87),
//                   ),
//                   const SizedBox(height: 4),
//                   const Text(
//                     'Discover your unique style',
//                     style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                         fontWeight: FontWeight.w500),
//                   ),
//                 ],
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.black12, width: 2),
//                 ),
//                 child: CircleAvatar(
//                   radius: 22,
//                   backgroundImage:
//                       avatarImage, // Langsung masukkan ImageProvider di sini
//                   backgroundColor: Colors.grey.shade200,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildBannerSlider() {
//     return SizedBox(
//       height: 200,
//       child: PageView.builder(
//         controller: _pageController,
//         physics: const BouncingScrollPhysics(),
//         itemCount: _bannerData.length,
//         onPageChanged: (index) => setState(() => _currentBannerIndex = index),
//         itemBuilder: (context, index) {
//           final banner = _bannerData[index];
//           return _bannerItem(
//               banner['image']!, banner['subtitle']!, banner['title']!);
//         },
//       ),
//     );
//   }

//   Widget _bannerItem(String assetPath, String subtitle, String title) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 24.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         image: DecorationImage(
//           image: AssetImage(assetPath),
//           fit: BoxFit.cover,
//           colorFilter:
//               ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Text(
//               subtitle,
//               style: const TextStyle(
//                   color: Colors.white70,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: 2),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.w900),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryFilters() {
//     return BlocBuilder<CategoryBloc, CategoryState>(
//       builder: (context, state) {
//         if (state is CategoryLoading || state is CategoryInitial) {
//           return const Padding(
//             padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
//             child: LinearProgressIndicator(color: Colors.black),
//           );
//         } else if (state is CategoryLoaded) {
//           final List<Category> filterCategories = [
//             Category(id: 0, code: 'ALL', name: 'All Products'),
//             ...state.categories
//           ];

//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 32.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 24.0),
//                   child: Text(
//                     "Our Collections",
//                     style: TextStyle(
//                         fontSize: 24,
//                         fontStyle: FontStyle.italic,
//                         fontWeight: FontWeight.w300),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   height: 35,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     itemCount: filterCategories.length,
//                     itemBuilder: (context, index) {
//                       bool isSelected = _selectedFilterIndex == index;
//                       final category = filterCategories[index];

//                       return GestureDetector(
//                         onTap: () {
//                           setState(() => _selectedFilterIndex = index);

//                           if (category.id == 0) {
//                             context
//                                 .read<ProductBloc>()
//                                 .add(FetchActiveProductsEvent());
//                           } else {
//                             context.read<ProductBloc>().add(
//                                 FetchProductsByCategoryEvent(category.id!));
//                           }
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.only(right: 24),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 category.name.toUpperCase(),
//                                 style: TextStyle(
//                                   color: isSelected
//                                       ? Colors.black
//                                       : Colors.grey.shade400,
//                                   fontWeight: FontWeight.w800,
//                                   fontSize: 12,
//                                   letterSpacing: 1.5,
//                                 ),
//                               ),
//                               if (isSelected)
//                                 Container(
//                                   height: 4,
//                                   width: 4,
//                                   decoration: const BoxDecoration(
//                                       color: Colors.black,
//                                       shape: BoxShape.circle),
//                                 )
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         } else if (state is CategoryError) {
//           return Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Text("Gagal memuat kategori: ${state.message}",
//                 style: const TextStyle(color: Colors.red)),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }

//   Widget _buildHorizontalProductList() {
//     return BlocBuilder<ProductBloc, ProductState>(
//       builder: (context, state) {
//         if (state is ProductLoading && !_isFetchingMore) {
//           return const Center(
//             child: Padding(
//                 padding: EdgeInsets.all(40.0),
//                 child: CircularProgressIndicator(color: Colors.black)),
//           );
//         } else if (state is ProductError) {
//           return Center(child: Text(state.message));
//         } else if (state is ProductListLoaded) {
//           final displayData = state.products;

//           if (displayData.isEmpty) {
//             return const Padding(
//               padding: EdgeInsets.all(24.0),
//               child: Center(
//                   child: Text("Tidak ada produk.",
//                       style: TextStyle(color: Colors.grey))),
//             );
//           }

//           return SizedBox(
//             height: 320,
//             child: ListView.builder(
//               controller: _scrollController,
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//               itemCount: displayData.length + (_isFetchingMore ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index == displayData.length) {
//                   return const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.0),
//                     child: Center(
//                         child: CircularProgressIndicator(color: Colors.black)),
//                   );
//                 }

//                 return Padding(
//                   padding: const EdgeInsets.only(right: 16.0),
//                   child: SizedBox(
//                     width: 180,
//                     child: _buildProductCard(displayData[index]),
//                   ),
//                 );
//               },
//             ),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }

//   Widget _buildBestSellerSection() {
//     return BlocProvider(
//       create: (context) => ProductBloc(productRepository: ProductRepository())
//         ..add(FetchBestSellersEvent()),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(
//                 left: 24.0, right: 24.0, top: 40.0, bottom: 16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Best Sellers",
//                   style: TextStyle(
//                       fontSize: 24,
//                       fontStyle: FontStyle.italic,
//                       fontWeight: FontWeight.w300),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   "OUR MOST LOVED PIECES",
//                   style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 2,
//                       color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//           BlocBuilder<ProductBloc, ProductState>(
//             builder: (context, state) {
//               if (state is ProductLoading) {
//                 return const Center(
//                   child: Padding(
//                       padding: EdgeInsets.all(40.0),
//                       child: CircularProgressIndicator(color: Colors.black)),
//                 );
//               } else if (state is ProductError) {
//                 return Center(child: Text(state.message));
//               } else if (state is ProductListLoaded) {
//                 final displayData = state.products;

//                 if (displayData.isEmpty) {
//                   return const Padding(
//                     padding: EdgeInsets.all(24.0),
//                     child: Center(
//                         child: Text("Tidak ada produk best seller.",
//                             style: TextStyle(color: Colors.grey))),
//                   );
//                 }

//                 return SizedBox(
//                   height: 320,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     itemCount: displayData.length,
//                     itemBuilder: (context, index) {
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 16.0),
//                         child: SizedBox(
//                           width: 180,
//                           child: _buildProductCard(displayData[index]),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               }
//               return const SizedBox.shrink();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget _buildProductCard(ProductModel product) {
//   //   bool hasDiscount =
//   //       product.discountPrice != null && product.discountPrice! > 0;

//   //   return Column(
//   //     crossAxisAlignment: CrossAxisAlignment.start,
//   //     children: [
//   //       Expanded(
//   //         child: Container(
//   //           decoration: BoxDecoration(
//   //             color: Colors.grey[100],
//   //             borderRadius: BorderRadius.circular(12),
//   //             image: product.image != null
//   //                 ? DecorationImage(
//   //                     image: NetworkImage(product.image!), fit: BoxFit.cover)
//   //                 : null,
//   //           ),
//   //           child: Stack(
//   //             children: [
//   //               Positioned(
//   //                 top: 12,
//   //                 left: 12,
//   //                 child: Container(
//   //                   padding:
//   //                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//   //                   decoration: BoxDecoration(
//   //                     color: Colors.black,
//   //                     borderRadius: BorderRadius.circular(20),
//   //                   ),
//   //                   child: const Text(
//   //                     'HOT',
//   //                     style: TextStyle(
//   //                         color: Colors.white,
//   //                         fontSize: 9,
//   //                         fontWeight: FontWeight.bold,
//   //                         letterSpacing: 1.5),
//   //                   ),
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ),
//   //       const SizedBox(height: 12),
//   //       Text(
//   //         product.name.toUpperCase(),
//   //         style: const TextStyle(
//   //             fontSize: 11,
//   //             fontWeight: FontWeight.w800,
//   //             color: Colors.black87,
//   //             letterSpacing: 1.2),
//   //         maxLines: 1,
//   //         overflow: TextOverflow.ellipsis,
//   //       ),
//   //       const SizedBox(height: 4),
//   //       Row(
//   //         children: [
//   //           if (hasDiscount) ...[
//   //             Text(
//   //               'Rp ${product.discountPrice!.toStringAsFixed(0)}',
//   //               style: const TextStyle(
//   //                   fontSize: 13,
//   //                   fontWeight: FontWeight.w900,
//   //                   color: Colors.red),
//   //             ),
//   //             const SizedBox(width: 6),
//   //             Text(
//   //               'Rp ${product.price.toStringAsFixed(0)}',
//   //               style: const TextStyle(
//   //                   fontSize: 10,
//   //                   color: Colors.grey,
//   //                   decoration: TextDecoration.lineThrough),
//   //             ),
//   //           ] else ...[
//   //             Text(
//   //               'Rp ${product.price.toStringAsFixed(0)}',
//   //               style: const TextStyle(
//   //                   fontSize: 13,
//   //                   fontWeight: FontWeight.w900,
//   //                   color: Colors.black),
//   //             ),
//   //           ]
//   //         ],
//   //       ),
//   //     ],
//   //   );
//   // }

//   // 👇 1. Tambahkan parameter BuildContext context 👇
//   Widget _buildProductCard(BuildContext context, ProductModel product) {
//     bool hasDiscount =
//         product.discountPrice != null && product.discountPrice! > 0;

//     // 👇 2. Bungkus dengan GestureDetector 👇
//     return GestureDetector(
//       onTap: () {
//         // Navigasi ke Halaman Detail dengan membawa data produk awal
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ProductDetailPage(initialProduct: product),
//           ),
//         );
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(12),
//                 image: product.image != null
//                     ? DecorationImage(
//                         image: NetworkImage(product.image!), fit: BoxFit.cover)
//                     : null,
//               ),
//               child: Stack(
//                 children: [
//                   Positioned(
//                     top: 12,
//                     left: 12,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.black,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Text(
//                         'HOT',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 9,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1.5),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             product.name.toUpperCase(),
//             style: const TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.black87,
//                 letterSpacing: 1.2),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 4),
//           Row(
//             children: [
//               if (hasDiscount) ...[
//                 Text(
//                   'Rp ${product.discountPrice!.toStringAsFixed(0)}',
//                   style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w900,
//                       color: Colors.red),
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   'Rp ${product.price.toStringAsFixed(0)}',
//                   style: const TextStyle(
//                       fontSize: 10,
//                       color: Colors.grey,
//                       decoration: TextDecoration.lineThrough),
//                 ),
//               ] else ...[
//                 Text(
//                   'Rp ${product.price.toStringAsFixed(0)}',
//                   style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w900,
//                       color: Colors.black),
//                 ),
//               ]
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildValueProposition() {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(top: 40),
//       padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
//       decoration: const BoxDecoration(
//         color: Color(0xFFFAFAFA),
//         border: Border(top: BorderSide(color: Colors.black12)),
//       ),
//       child: Column(
//         children: [
//           const Text(
//             "Why Choose Solher",
//             style: TextStyle(
//                 fontSize: 24,
//                 fontStyle: FontStyle.italic,
//                 fontWeight: FontWeight.w300),
//           ),
//           const SizedBox(height: 4),
//           const Text(
//             "THE SOLHER DIFFERENCE",
//             style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 2,
//                 color: Colors.grey),
//           ),
//           const SizedBox(height: 32),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                   child: _buildValueItem(
//                       Icons.diamond_outlined,
//                       'PREMIUM MATERIALS',
//                       'Crafted with the finest vegan leather.')),
//               const SizedBox(width: 16),
//               Expanded(
//                   child: _buildValueItem(
//                       Icons.design_services_outlined,
//                       'UNIQUE DESIGN',
//                       'Stand out with our exclusive silhouettes.')),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildValueItem(IconData icon, String title, String desc) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration:
//               const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//           child: Icon(icon, size: 28, color: Colors.black87),
//         ),
//         const SizedBox(height: 12),
//         Text(title,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//                 fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
//         const SizedBox(height: 6),
//         Text(desc,
//             textAlign: TextAlign.center,
//             style:
//                 const TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
//       ],
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solher_mobile/models/category_model.dart';
import 'package:solher_mobile/screens/product_detail_page.dart';
import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_event.dart';
import '../blocs/category/category_state.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../blocs/product/product_state.dart';
import 'package:solher_mobile/models/product_model.dart';
import '../repositories/category_repository.dart';
import '../repositories/product_repository.dart';

// 👇 [BARU] Import AuthBloc dan AuthState 👇
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedFilterIndex = 0;

  final PageController _pageController = PageController();
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;

  final List<Map<String, String>> _bannerData = [
    {'image': 'assets/images/first_banner.png', 'subtitle': '', 'title': ''},
    {'image': 'assets/images/second_banner.png', 'subtitle': '', 'title': ''},
  ];

  @override
  void initState() {
    super.initState();
    _setupBannerTimer();
    _scrollController.addListener(_onScroll);
  }

  void _setupBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentBannerIndex < _bannerData.length - 1) {
        _currentBannerIndex++;
      } else {
        _currentBannerIndex = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutQuart,
        );
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isFetchingMore) {
        setState(() => _isFetchingMore = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isFetchingMore = false);
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              CategoryBloc(categoryRepository: CategoryRepository())
                ..add(FetchCategories()),
        ),
        BlocProvider(
          create: (context) =>
              ProductBloc(productRepository: ProductRepository())
                ..add(FetchActiveProductsEvent()),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Home',
              style:
                  TextStyle(fontWeight: FontWeight.w900, fontFamily: 'serif')),
          backgroundColor: Colors.grey[500],
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildBannerSlider(),
                _buildCategoryFilters(),
                _buildHorizontalProductList(),
                _buildBestSellerSection(),
                _buildValueProposition(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Fallback untuk Guest User
        String displayName = 'Guest';

        // Menggunakan ImageProvider agar bisa menampung Asset maupun Network
        ImageProvider avatarImage =
            const AssetImage('assets/images/profile.png');

        // Jika terdeteksi login, ubah nama dan gambar
        if (state is AuthAuthenticated) {
          final user = state.user;
          // Asumsi properti nama pada UserModel adalah 'firstName'. Sesuaikan jika berbeda.
          displayName =
              user.firstName; // Bisa juga ditambahkan penanganan jika null

          // Jika user punya foto profil dari server, ganti avatarImage menjadi NetworkImage
          if (user.profileImage != null && user.profileImage!.isNotEmpty) {
            avatarImage = NetworkImage(user.profileImage!);
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $displayName',
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Discover your unique style',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12, width: 2),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: avatarImage,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBannerSlider() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemCount: _bannerData.length,
        onPageChanged: (index) => setState(() => _currentBannerIndex = index),
        itemBuilder: (context, index) {
          final banner = _bannerData[index];
          return _bannerItem(
              banner['image']!, banner['subtitle']!, banner['title']!);
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
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
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
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading || state is CategoryInitial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
            child: LinearProgressIndicator(color: Colors.black),
          );
        } else if (state is CategoryLoaded) {
          final List<Category> filterCategories = [
            Category(id: 0, code: 'ALL', name: 'All Products'),
            ...state.categories
          ];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "Our Collections",
                    style: TextStyle(
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemCount: filterCategories.length,
                    itemBuilder: (context, index) {
                      bool isSelected = _selectedFilterIndex == index;
                      final category = filterCategories[index];

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedFilterIndex = index);

                          if (category.id == 0) {
                            context
                                .read<ProductBloc>()
                                .add(FetchActiveProductsEvent());
                          } else {
                            context.read<ProductBloc>().add(
                                FetchProductsByCategoryEvent(category.id!));
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                category.name.toUpperCase(),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey.shade400,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  height: 4,
                                  width: 4,
                                  decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle),
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else if (state is CategoryError) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text("Gagal memuat kategori: ${state.message}",
                style: const TextStyle(color: Colors.red)),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHorizontalProductList() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading && !_isFetchingMore) {
          return const Center(
            child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(color: Colors.black)),
          );
        } else if (state is ProductError) {
          return Center(child: Text(state.message));
        } else if (state is ProductListLoaded) {
          final displayData = state.products;

          if (displayData.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                  child: Text("Tidak ada produk.",
                      style: TextStyle(color: Colors.grey))),
            );
          }

          return SizedBox(
            height: 320,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              itemCount: displayData.length + (_isFetchingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == displayData.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.black)),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: SizedBox(
                    width: 180,
                    // 👇 PERBAIKAN: Menambahkan `context, ` sebagai argumen pertama 👇
                    child: _buildProductCard(context, displayData[index]),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBestSellerSection() {
    return BlocProvider(
      create: (context) => ProductBloc(productRepository: ProductRepository())
        ..add(FetchBestSellersEvent()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
                left: 24.0, right: 24.0, top: 40.0, bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Best Sellers",
                  style: TextStyle(
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300),
                ),
                SizedBox(height: 4),
                Text(
                  "OUR MOST LOVED PIECES",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.grey),
                ),
              ],
            ),
          ),
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Colors.black)),
                );
              } else if (state is ProductError) {
                return Center(child: Text(state.message));
              } else if (state is ProductListLoaded) {
                final displayData = state.products;

                if (displayData.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                        child: Text("Tidak ada produk best seller.",
                            style: TextStyle(color: Colors.grey))),
                  );
                }

                return SizedBox(
                  height: 320,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemCount: displayData.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: SizedBox(
                          width: 180,
                          // 👇 PERBAIKAN: Menambahkan `context, ` sebagai argumen pertama 👇
                          child: _buildProductCard(context, displayData[index]),
                        ),
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    bool hasDiscount =
        product.discountPrice != null && product.discountPrice! > 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(initialProduct: product),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                image: product.image != null
                    ? DecorationImage(
                        image: NetworkImage(product.image!), fit: BoxFit.cover)
                    : null,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'HOT',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.name.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: 1.2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (hasDiscount) ...[
                Text(
                  'Rp ${product.discountPrice!.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.red),
                ),
                const SizedBox(width: 6),
                Text(
                  'Rp ${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough),
                ),
              ] else ...[
                Text(
                  'Rp ${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.black),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueProposition() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Column(
        children: [
          const Text(
            "Why Choose Solher",
            style: TextStyle(
                fontSize: 24,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 4),
          const Text(
            "THE SOLHER DIFFERENCE",
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _buildValueItem(
                      Icons.diamond_outlined,
                      'PREMIUM MATERIALS',
                      'Crafted with the finest vegan leather.')),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildValueItem(
                      Icons.design_services_outlined,
                      'UNIQUE DESIGN',
                      'Stand out with our exclusive silhouettes.')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem(IconData icon, String title, String desc) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(icon, size: 28, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 6),
        Text(desc,
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
      ],
    );
  }
}
