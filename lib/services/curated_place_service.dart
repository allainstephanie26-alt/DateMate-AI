import '../models/curated_place.dart';

class CuratedPlaceService {
  static const places = <CuratedPlace>[
    CuratedPlace(
      id: 'hardin-angeles',
      name: 'Hardin',
      country: 'Philippines',
      city: 'Angeles City',
      address:
          '914 Fields Avenue, Balibago, Angeles City, Pampanga 2009, Philippines',
      categories: {'Food', 'Restaurant', 'Grill'},
      tags: {'Food', 'Foodie', 'Chill', 'Live music'},
      foodTypes: {'Food', 'Pasta', 'Steak'},
      currency: 'PHP',
      estimatedCostMin: 800,
      estimatedCostMax: 1800,
      budgetLevel: 2,
      imageAsset: '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Hardin%20914%20Fields%20Avenue%20Balibago%20Angeles%20City',
      officialWebsiteUrl: 'https://www.hardin.ph/',
      menuUrl: 'https://www.hardin.ph/',
      hours: 'Monday–Sunday, 4:00 PM–1:00 AM',
      description:
          'A Filipino garden grill in Balibago with steaks, pasta, shared plates, and live music on selected evenings.',
      verifiedSourceUrl: 'https://www.hardin.ph/',
    ),
    CuratedPlace(
      id: 'daitoku-ramen-angeles',
      name: 'Daitoku Ramen Food House',
      country: 'Philippines',
      city: 'Angeles City',
      address:
          'Friendship Highway corner Villa Dolores, Barangay Santo Domingo, Angeles City, Pampanga, Philippines',
      categories: {'Food', 'Ramen', 'Japanese'},
      tags: {'Food', 'Foodie', 'Chill'},
      foodTypes: {'Ramen', 'Japanese', 'Food'},
      currency: 'PHP',
      estimatedCostMin: 800,
      estimatedCostMax: 1200,
      budgetLevel: 1,
      imageAsset: '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Daitoku%20Ramen%20Food%20House%20Angeles%20City%20Pampanga',
      officialWebsiteUrl: 'https://daitokuramen.com/',
      menuUrl: 'https://daitokuramen.com/',
      hours: 'Monday–Sunday, 3:00 PM–11:00 PM',
      description:
          'A ramen house on Friendship Highway serving tonkotsu, tantanmen, miso, and seafood ramen.',
      verifiedSourceUrl: 'https://daitokuramen.com/',
    ),
    CuratedPlace(
      id: 'makimura-ramen-angeles',
      name: 'Makimura Ramen Bar',
      country: 'Philippines',
      city: 'Angeles City',
      address:
          'Tinio Building, MacArthur Highway, Balibago, Angeles City, Pampanga 2009, Philippines',
      categories: {'Food', 'Ramen', 'Japanese'},
      tags: {'Food', 'Foodie', 'Chill'},
      foodTypes: {'Ramen', 'Japanese', 'Food'},
      currency: 'PHP',
      estimatedCostMin: 700,
      estimatedCostMax: 1000,
      budgetLevel: 1,
      imageAsset: '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Makimura%20Ramen%20Bar%20Angeles%20City%20Pampanga',
      officialWebsiteUrl: 'https://www.facebook.com/makimuraramenbar/',
      menuUrl:
          'https://www.foodpanda.ph/restaurant/s1dl/makimura-ramen-bar-balibago',
      hours: 'Daily, 4:00 PM–12:00 AM',
      description:
          'A Japanese ramen bar in Balibago known for tonkotsu and other ramen bowls.',
      verifiedSourceUrl:
          'https://www.tripadvisor.com.ph/Restaurant_Review-g469410-d15364534-Reviews-Makimura_Ramen_Bar-Angeles_City_Pampanga_Province_Central_Luzon_Region_Luzon.html',
    ),
    CuratedPlace(
      id: 'nisu-ramen-angeles',
      name: 'Nisu Ramen - Balibago',
      country: 'Philippines',
      city: 'Angeles City',
      address:
          'Unit 123 Reno Hotel, Arayat Street, Diamond Subdivision, Balibago, Angeles City, Pampanga, Philippines',
      categories: {'Food', 'Ramen', 'Japanese'},
      tags: {'Food', 'Foodie'},
      foodTypes: {'Ramen', 'Japanese', 'Food'},
      currency: 'PHP',
      estimatedCostMin: 500,
      estimatedCostMax: 900,
      budgetLevel: 1,
      imageAsset: '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Nisu%20Ramen%20Balibago%20Angeles%20City%20Pampanga',
      officialWebsiteUrl: '',
      menuUrl: 'https://www.foodpanda.ph/restaurant/ud1d/nisu-ramen-balibago',
      hours: 'Check current store hours before visiting',
      description:
          'A Balibago ramen restaurant with tonkotsu, shio, seafood, and other Japanese dishes.',
      verifiedSourceUrl:
          'https://www.foodpanda.ph/restaurant/ud1d/nisu-ramen-balibago',
    ),
    CuratedPlace(
      id: 'ramen-nagi-clark',
      name: 'Ramen Nagi - SM City Clark',
      country: 'Philippines',
      city: 'Clark',
      address:
          'SM City Clark, Manuel A. Roxas Highway, Clark Freeport Zone, Angeles, Pampanga, Philippines',
      categories: {'Food', 'Ramen', 'Japanese'},
      tags: {'Food', 'Foodie', 'Chill'},
      foodTypes: {'Ramen', 'Japanese', 'Food'},
      currency: 'PHP',
      estimatedCostMin: 1200,
      estimatedCostMax: 1800,
      budgetLevel: 2,
      imageAsset: '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Ramen%20Nagi%20SM%20City%20Clark',
      officialWebsiteUrl: 'https://www.ramennagi.com/',
      menuUrl:
          'https://www.foodpanda.ph/restaurant/nj7w/ramen-nagi-sm-city-clark',
      hours: 'Check SM City Clark and restaurant schedule before visiting',
      description:
          'A Japanese ramen restaurant at SM City Clark serving signature Ramen Nagi bowls.',
      verifiedSourceUrl:
          'https://www.foodpanda.ph/restaurant/nj7w/ramen-nagi-sm-city-clark',
    ),
    CuratedPlace(
      id: 'mind-museum-bgc',
      name: 'The Mind Museum',
      country: 'Philippines',
      city: 'Taguig',
      address:
          'JY Campos Park, 3rd Avenue, Bonifacio Global City, Taguig City 1634, Philippines',
      categories: {'Museum', 'Indoor', 'Educational'},
      tags: {'Museum', 'Walk', 'Chill', 'Adventurous', 'Culture'},
      foodTypes: {'Cafe'},
      currency: 'PHP',
      estimatedCostMin: 800,
      estimatedCostMax: 1800,
      budgetLevel: 2,
      imageAsset: 'assets/places/the_mind_museum.jpg',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=The%20Mind%20Museum%20Taguig%20Philippines',
      officialWebsiteUrl: 'https://www.themindmuseum.org/',
      menuUrl: '',
      hours: 'Tuesday–Sunday, 9:00 AM–6:00 PM; closed Monday',
      description:
          'An interactive science museum with galleries, exhibits, and science experiences suitable for a curious indoor date.',
      verifiedSourceUrl:
          'https://www.themindmuseum.org/visit-us/plan-your-visit',
    ),
    CuratedPlace(
      id: 'ayala-museum-makati',
      name: 'Ayala Museum',
      country: 'Philippines',
      city: 'Makati',
      address:
          'Makati Avenue corner De La Rosa Street, Greenbelt Park, Makati City 1224, Philippines',
      categories: {'Museum', 'Culture', 'Indoor'},
      tags: {'Museum', 'Culture', 'Chill', 'Walk'},
      foodTypes: {'Cafe'},
      currency: 'PHP',
      estimatedCostMin: 500,
      estimatedCostMax: 1600,
      budgetLevel: 2,
      imageAsset: 'assets/places/ayala_museum.jpg',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Ayala%20Museum%20Makati%20Philippines',
      officialWebsiteUrl: 'https://ayalamuseum.org/',
      menuUrl: '',
      hours: 'Check the official visitor schedule before visiting',
      description:
          'A museum date focused on Philippine history, art, culture, exhibitions, and immersive experiences.',
      verifiedSourceUrl: 'https://ayalafoundation.org/programs/ayala-museum/',
    ),
    CuratedPlace(
      id: 'mimosa-plus-clark',
      name: 'Mimosa Plus Golf Course',
      country: 'Philippines',
      city: 'Clark',
      address: 'Clark Freeport Zone, Pampanga, Philippines',
      categories: {'Outdoor', 'Golf', 'Activity'},
      tags: {'Adventurous', 'Outdoor', 'Walk', 'Premium'},
      foodTypes: {'Cafe'},
      currency: 'PHP',
      estimatedCostMin: 7000,
      estimatedCostMax: 15000,
      budgetLevel: 4,
      imageAsset: 'assets/places/mimosa_plus_golf.jpg',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Mimosa%20Plus%20Golf%20Course%20Clark%20Pampanga',
      officialWebsiteUrl: 'https://www.mimosaplus.com.ph/explore/leisure',
      menuUrl: '',
      hours: 'Check the official course schedule and booking information',
      description:
          'A premium outdoor golf-date option in Clark with 18-hole courses, practice facilities, and a scenic setting.',
      verifiedSourceUrl: 'https://www.mimosaplus.com.ph/explore/leisure',
    ),
    CuratedPlace(
      id: 'national-museum-manila',
      name: 'National Museum of Fine Arts',
      country: 'Philippines',
      city: 'Manila',
      address: 'Padre Burgos Avenue, Ermita, Manila, Philippines',
      categories: {'Museum', 'Culture', 'Indoor'},
      tags: {'Museum', 'Culture', 'Chill', 'Art', 'Walk'},
      foodTypes: {'Cafe', 'Food'},
      currency: 'PHP',
      estimatedCostMin: 0,
      estimatedCostMax: 600,
      budgetLevel: 1,
      imageAsset: '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=National%20Museum%20of%20Fine%20Arts%20Manila',
      officialWebsiteUrl: 'https://www.nationalmuseum.gov.ph/',
      menuUrl: '',
      hours: 'Tuesday–Sunday, 9:00 AM–6:00 PM; closed Monday',
      description:
          'A Philippine art museum in the historic National Museum Complex, suited to a relaxed culture date.',
      verifiedSourceUrl: 'https://www.nationalmuseum.gov.ph/',
    ),
    CuratedPlace(
      id: 'ayala-triangle-makati',
      name: 'Ayala Triangle Gardens',
      country: 'Philippines',
      city: 'Makati',
      address: 'Ayala Avenue, Makati, Metro Manila, Philippines',
      categories: {'Garden', 'Outdoor', 'Walk'},
      tags: {'Walk', 'Chill', 'Culture', 'Photography', 'Food'},
      foodTypes: {'Cafe', 'Food', 'Dessert'},
      currency: 'PHP',
      estimatedCostMin: 300,
      estimatedCostMax: 1500,
      budgetLevel: 1,
      imageAsset: '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Ayala%20Triangle%20Gardens%20Makati',
      officialWebsiteUrl: 'https://www.ayalaland.com/',
      menuUrl: '',
      hours: 'Open daily; individual establishments have separate hours',
      description:
          'A landscaped Makati destination with green space, dining options, and an easy city walk.',
      verifiedSourceUrl: 'https://www.ayalaland.com/',
    ),
    CuratedPlace(
      id: 'pinto-art-museum-antipolo',
      name: 'Pinto Art Museum',
      country: 'Philippines',
      city: 'Antipolo',
      address:
          '1 Sierra Madre Street, Grand Heights, Antipolo, Rizal, Philippines',
      categories: {'Museum', 'Art', 'Garden'},
      tags: {'Art', 'Museum', 'Culture', 'Walk', 'Photography', 'Chill'},
      foodTypes: {'Cafe', 'Dessert'},
      currency: 'PHP',
      estimatedCostMin: 700,
      estimatedCostMax: 1600,
      budgetLevel: 2,
      imageAsset: '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Pinto%20Art%20Museum%20Antipolo',
      officialWebsiteUrl: 'https://www.pintoart.org/',
      menuUrl: '',
      hours:
          'Tuesday–Sunday; check official visitor information before visiting; closed Monday',
      description:
          'A contemporary and indigenous art museum set among gardens and whitewashed galleries in Antipolo.',
      verifiedSourceUrl: 'https://www.pintoart.org/',
    ),
    CuratedPlace(
      id: 'burnham-park-baguio',
      name: 'Burnham Park',
      country: 'Philippines',
      city: 'Baguio',
      address: 'Jose Abad Santos Drive, Baguio City, Benguet, Philippines',
      categories: {'Park', 'Outdoor', 'Walk'},
      tags: {'Walk', 'Chill', 'Outdoor', 'Photography', 'Picnic'},
      foodTypes: {'Food', 'Cafe', 'Dessert'},
      currency: 'PHP',
      estimatedCostMin: 0,
      estimatedCostMax: 1200,
      budgetLevel: 1,
      imageAsset: '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Burnham%20Park%20Baguio',
      officialWebsiteUrl: 'https://www.baguio.gov.ph/',
      menuUrl: '',
      hours:
          'Open daily; individual activities and vendors have separate hours',
      description:
          'A central Baguio park for walking, boating, snacks, and a simple outdoor date.',
      verifiedSourceUrl: 'https://www.baguio.gov.ph/',
    ),
    CuratedPlace(
      id: 'museo-sugbo-cebu',
      name: 'Museo Sugbo',
      country: 'Philippines',
      city: 'Cebu City',
      address: 'M. J. Cuenco Avenue, Cebu City, Philippines',
      categories: {'Museum', 'Culture', 'Indoor'},
      tags: {'Museum', 'Culture', 'Chill', 'Walk', 'Art'},
      foodTypes: {'Food', 'Cafe'},
      currency: 'PHP',
      estimatedCostMin: 300,
      estimatedCostMax: 900,
      budgetLevel: 1,
      imageAsset: '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Museo%20Sugbo%20Cebu',
      officialWebsiteUrl: 'https://www.cebu.gov.ph/',
      menuUrl: '',
      hours: 'Check provincial visitor information before visiting',
      description:
          'A heritage museum complex in Cebu City that works well for a culture-focused date.',
      verifiedSourceUrl: 'https://www.cebu.gov.ph/',
    ),
  ];

  static List<CuratedPlace> forLocation(Set<String> locations) {
    if (locations.isEmpty) {
      return [];
    }

    return places.where((place) {
      return locations.any(place.matchesLocation);
    }).toList();
  }

  static CuratedPlace? byId(String id) {
    for (final place in places) {
      if (place.id == id) {
        return place;
      }
    }

    return null;
  }
}
