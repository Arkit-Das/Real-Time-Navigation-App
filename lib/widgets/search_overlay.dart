import 'package:flutter/material.dart';
import '../services/ai_routing.dart';

class SearchOverlay extends StatefulWidget {
  final Function(double lat, double lon) onLocationSelected;

  SearchOverlay({required this.onLocationSelected});

  @override
  _SearchOverlayState createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final AIRoutingService _routingService = AIRoutingService();
  List<Map<String, dynamic>> _suggestions = [];
  final TextEditingController _controller = TextEditingController();

  // This function fetches suggestions as the user types
  void _onSearchChanged(String query) async {
    print("Search triggered for: $query");
    if (query.length > 2) {
      try {
        final results = await _routingService.getSearchSuggestions(query);
        print("Found ${results.length} suggestions");
        setState(() {
          _suggestions = results;
        });
      } catch (e) {
        print("Search failed: $e");
      }
    } else {
      setState(() => _suggestions = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // THE SEARCH BAR
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: TextField(
            controller: _controller,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: "Where to?",
              icon: Icon(Icons.search, color: Colors.blueAccent),
              border: InputBorder.none,
            ),
          ),
        ),

        // THE SUGGESTIONS LIST (Only shows when typing)
        if (_suggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8),
            constraints: BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final place = _suggestions[index];
                return ListTile(
                  leading: Icon(Icons.location_on, color: Colors.grey),
                  title: Text(
                    place['display_name'] ?? "Unknown Place",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // Send the coordinates back to map_screen.dart
                    widget.onLocationSelected(
                      double.parse(place['lat']),
                      double.parse(place['lon']),
                    );
                    // Clear search
                    setState(() {
                      _suggestions = [];
                      _controller.clear();
                    });
                    FocusScope.of(context).unfocus(); // Hide keyboard
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}