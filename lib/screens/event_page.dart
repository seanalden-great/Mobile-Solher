import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/event/event_bloc.dart';
import '../blocs/event/event_event.dart';
import '../blocs/event/event_state.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  String _activeSeason = 'All';
  String _activeYear = 'All';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventBloc(eventRepository: EventRepository())..add(FetchEvents()),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeroSection()),
              SliverToBoxAdapter(
                child: BlocBuilder<EventBloc, EventState>(
                  builder: (context, state) {
                    if (state is EventLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 100.0),
                        child: Center(child: CircularProgressIndicator(color: Colors.black)),
                      );
                    } else if (state is EventError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 100.0),
                        child: Center(child: Text(state.message)),
                      );
                    } else if (state is EventLoaded) {
                      return _buildBody(state.events);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: const Column(
        children: [
          Text(
            'ARCHIVE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 3, color: Colors.grey),
          ),
          SizedBox(height: 24),
          Text(
            'MOMENTS OF',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, fontFamily: 'serif', height: 1.1),
            textAlign: TextAlign.center,
          ),
          Text(
            'Elegance',
            style: TextStyle(fontSize: 36, fontStyle: FontStyle.italic, color: Colors.grey, fontFamily: 'serif', height: 1.1),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'A journey through our past collections and monumental fashion runways.',
            style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w300),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<EventModel> allEvents) {
    // Kumpulkan filter unik
    final seasons = {'All', ...allEvents.map((e) => e.season).where((s) => s.isNotEmpty)}.toList();
    final years = {'All', ...allEvents.map((e) => e.year).where((y) => y.isNotEmpty)}.toList();
    // Urutkan tahun dari terbaru
    years.sort((a, b) => a == 'All' ? -1 : (b == 'All' ? 1 : b.compareTo(a)));

    // Terapkan Filter
    final filteredEvents = allEvents.where((e) {
      final matchSeason = _activeSeason == 'All' || e.season == _activeSeason;
      final matchYear = _activeYear == 'All' || e.year == _activeYear;
      return matchSeason && matchYear;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FILTERS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: seasons.map((season) {
                        final isSelected = _activeSeason == season;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(season.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _activeSeason = season),
                            selectedColor: Colors.black,
                            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade600),
                            backgroundColor: Colors.transparent,
                            shape: StadiumBorder(side: BorderSide(color: isSelected ? Colors.black : Colors.grey.shade300)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Dropdown Year
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: 2))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _activeYear,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                      onChanged: (val) => setState(() => _activeYear = val!),
                      items: years.map((y) => DropdownMenuItem(value: y, child: Text(y == 'All' ? 'ALL YEARS' : y))).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // LIST EVENTS
          if (filteredEvents.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80.0),
              child: Center(child: Text("No events found.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredEvents.length,
              separatorBuilder: (context, index) => const SizedBox(height: 60),
              itemBuilder: (context, index) {
                return _EventCardWidget(event: filteredEvents[index]);
              },
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGET KHUSUS EVENT CARD DENGAN AUTO-SHUFFLE SLIDER INDEPENDEN
// ============================================================================
class _EventCardWidget extends StatefulWidget {
  final EventModel event;
  const _EventCardWidget({required this.event});

  @override
  State<_EventCardWidget> createState() => _EventCardWidgetState();
}

class _EventCardWidgetState extends State<_EventCardWidget> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Memulai auto-shuffle jika gambar lebih dari 1
    if (widget.event.fullImageUrls.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!mounted) return;
        _currentIndex = (_currentIndex + 1) % widget.event.fullImageUrls.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 1000), // Crossfade animation duration
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.event.fullImageUrls;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Slider
          if (images.isNotEmpty)
            Container(
              height: 450,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: images.length,
                      onPageChanged: (index) => setState(() => _currentIndex = index),
                      itemBuilder: (context, index) {
                        return Image.network(images[index], fit: BoxFit.cover);
                      },
                    ),
                  ),
                  // Indikator Halaman (1/4)
                  if (images.length > 1)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          '${_currentIndex + 1} / ${images.length}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Teks Detail
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(20)),
            child: Text(
              '${widget.event.season} • ${widget.event.year}'.toUpperCase(),
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.event.title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'serif', color: Colors.black),
          ),
          Container(margin: const EdgeInsets.symmetric(vertical: 16), height: 3, width: 40, color: Colors.black),
          Text(
            widget.event.description.isEmpty ? 'No description available for this event.' : widget.event.description,
            style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.6, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}