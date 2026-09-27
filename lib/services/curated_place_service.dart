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
      id: 'gardens-bay-singapore',
      name: 'Gardens by the Bay',
      country: 'Singapore',
      city: 'Singapore',
      address: '18 Marina Gardens Drive, Singapore 018953',
      categories: {'Garden', 'Outdoor', 'Museum', 'Attraction'},
      tags: {'Walk', 'Chill', 'Adventurous', 'Outdoor', 'Culture'},
      foodTypes: {'Cafe', 'Food'},
      currency: 'SGD',
      estimatedCostMin: 0,
      estimatedCostMax: 70,
      budgetLevel: 2,
      imageAsset: 'assets/places/gardens_by_the_bay.jpg',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Gardens%20by%20the%20Bay%20Singapore',
      officialWebsiteUrl: 'https://www.gardensbythebay.com.sg/',
      menuUrl: 'https://www.gardensbythebay.com.sg/en/dine-and-shop.html',
      hours: 'Outdoor gardens generally 5:00 AM–2:00 AM; attraction hours vary',
      description:
          'A large waterfront garden complex with outdoor gardens, conservatories, Supertrees, food options, and evening experiences.',
      verifiedSourceUrl:
          'https://www.gardensbythebay.com.sg/en/plan-your-visit/opening-hours.html',
    ),
    CuratedPlace(
      id: 'cafe-aa-seoul',
      name: 'Cafe aA',
      country: 'South Korea',
      city: 'Seoul',
      address: '19-18 Wausan-ro 17-gil, Mapo-gu, Seoul, South Korea',
      categories: {'Cafe', 'Museum', 'Dessert'},
      tags: {'Cafe hopping', 'Cafe', 'Chill', 'Culture', 'Walk'},
      foodTypes: {'Cafe', 'Dessert'},
      currency: 'KRW',
      estimatedCostMin: 20000,
      estimatedCostMax: 50000,
      budgetLevel: 2,
      imageAsset: 'assets/places/cafe_aa_seoul.jpg',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Cafe%20aA%20Seoul%20South%20Korea',
      officialWebsiteUrl:
          'https://english.visitseoul.net/area/cafe-aA-EN/ENP000997',
      menuUrl: '',
      hours: 'Daily, 12:00 PM–11:30 PM',
      description:
          'A museum cafe and furniture showroom in Seoul that works well for a relaxed cafe-and-conversation date.',
      verifiedSourceUrl:
          'https://english.visitseoul.net/area/cafe-aA-EN/ENP000997',
    ),
    CuratedPlace(
      id: 'teumari-seoul',
      name: 'Teumari Cafe',
      country: 'South Korea',
      city: 'Seoul',
      address: '107-1 Seosulla-gil, Jongno-gu, Seoul, South Korea',
      categories: {'Cafe', 'Dessert', 'Culture'},
      tags: {'Cafe hopping', 'Cafe', 'Chill', 'Walk', 'Culture'},
      foodTypes: {'Cafe', 'Dessert'},
      currency: 'KRW',
      estimatedCostMin: 12000,
      estimatedCostMax: 50000,
      budgetLevel: 2,
      imageAsset: 'assets/places/teumari_cafe_seoul.jpg',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Teumari%20Cafe%20Seoul%20South%20Korea',
      officialWebsiteUrl:
          'https://english.visitseoul.net/restaurants/2024-cafeteumari/ENP1gia34',
      menuUrl: '',
      hours: 'Monday–Saturday 11:00 AM–11:00 PM; Sunday 11:00 AM–10:00 PM',
      description:
          'A hanok cafe and wine bar beside the Jongmyo Shrine Stonewall Path with coffee, desserts, and light snacks.',
      verifiedSourceUrl:
          'https://english.visitseoul.net/restaurants/2024-cafeteumari/ENP1gia34',
    ),
    CuratedPlace(
      id: 'gallery-sowyen-seoul',
      name: 'Gallery SOWYEN Cafe',
      country: 'South Korea',
      city: 'Seoul',
      address: '149 Seosulla-gil, Jongno-gu, Seoul, South Korea',
      categories: {'Cafe', 'Gallery', 'Dessert'},
      tags: {'Cafe hopping', 'Cafe', 'Chill', 'Culture'},
      foodTypes: {'Cafe', 'Dessert'},
      currency: 'KRW',
      estimatedCostMin: 10000,
      estimatedCostMax: 40000,
      budgetLevel: 2,
      imageAsset: 'assets/places/gallery_sowyen_seoul.jpg',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Gallery%20SOWYEN%20Cafe%20Seoul',
      officialWebsiteUrl:
          'https://english.visitseoul.net/dongdaemunarea/Gallery-SOWYEN-Cafe/ENP039309',
      menuUrl: '',
      hours: 'Saturday 11:00 AM–10:00 PM; Sunday–Friday 11:00 AM–9:00 PM',
      description:
          'A gallery cafe along Seosulla-gil offering drinks, food, crafts, and a quieter date atmosphere.',
      verifiedSourceUrl:
          'https://english.visitseoul.net/dongdaemunarea/Gallery-SOWYEN-Cafe/ENP039309',
    ),
    CuratedPlace(
      id: 'cheongwadae-sarangchae-seoul',
      name: 'Cheongwadae Sarangchae',
      country: 'South Korea',
      city: 'Seoul',
      address: '45 Hyoja-ro 13-gil, Jongno-gu, Seoul, South Korea',
      categories: {'Museum', 'Culture', 'Indoor'},
      tags: {'Museum', 'Culture', 'Chill', 'Walk'},
      foodTypes: {'Cafe', 'Tea'},
      currency: 'KRW',
      estimatedCostMin: 0,
      estimatedCostMax: 20000,
      budgetLevel: 1,
      imageAsset: 'assets/places/cheongwadae_sarangchae.jpg',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Cheongwadae%20Sarangchae%20Seoul',
      officialWebsiteUrl:
          'https://english.visitseoul.net/area/Cheongwadae-Sarangchae/ENP006007',
      menuUrl: '',
      hours: '9:00 AM–6:00 PM; closed Tuesdays',
      description:
          'A historical memorial museum with exhibitions, cultural experiences, a resting area, and a cafe.',
      verifiedSourceUrl:
          'https://english.visitseoul.net/area/Cheongwadae-Sarangchae/ENP006007',
    ),
    CuratedPlace(
      id: 'national-gallery-singapore',
      name: 'National Gallery Singapore',
      country: 'Singapore',
      city: 'Singapore',
      address: '1 St Andrew’s Road, Singapore 178957',
      categories: {'Museum', 'Culture', 'Indoor'},
      tags: {'Museum', 'Culture', 'Chill', 'Walk'},
      foodTypes: {'Cafe', 'Food'},
      currency: 'SGD',
      estimatedCostMin: 0,
      estimatedCostMax: 80,
      budgetLevel: 2,
      imageAsset: 'assets/places/national_gallery_singapore.jpg',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=National%20Gallery%20Singapore',
      officialWebsiteUrl: 'https://www.nationalgallery.sg/',
      menuUrl: '',
      hours: 'Check the official gallery visitor information before visiting',
      description:
          'A major Southeast Asian art museum in Singapore’s Civic District, suitable for an art-and-conversation date.',
      verifiedSourceUrl:
          'https://www.visitsingapore.com/content/visitsingapore/en/travel-tips/travelling-to-singapore/itineraries/7-days-in-singapore/',
    ),
    CuratedPlace(
      id: 'universal-studios-singapore',
      name: 'Universal Studios Singapore',
      country: 'Singapore',
      city: 'Singapore',
      address: '8 Sentosa Gateway, Singapore 098269',
      categories: {'Theme Park', 'Outdoor', 'Activity'},
      tags: {'Adventurous', 'Movies', 'Walk', 'Premium'},
      foodTypes: {'Food', 'Cafe'},
      currency: 'SGD',
      estimatedCostMin: 120,
      estimatedCostMax: 300,
      budgetLevel: 4,
      imageAsset: 'assets/places/universal_studios_singapore.jpg',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Universal%20Studios%20Singapore',
      officialWebsiteUrl:
          'https://www.rwsentosa.com/en/play/universal-studios-singapore',
      menuUrl: '',
      hours: 'Opening hours vary; check official park information',
      description:
          'A movie-themed theme park on Sentosa with rides, shows, themed areas, and food options.',
      verifiedSourceUrl:
          'https://www.visitsingapore.com/content/visitsingapore/en/travel-tips/travelling-to-singapore/itineraries/7-days-in-singapore/',
    ),
    CuratedPlace(
      id: 'british-museum-london',
      name: 'The British Museum',
      country: 'United Kingdom',
      city: 'London',
      address: 'Great Russell Street, London WC1B 3DG, United Kingdom',
      categories: {'Museum', 'Culture', 'Indoor'},
      tags: {'Museum', 'Culture', 'Chill', 'Walk'},
      foodTypes: {'Cafe', 'Food'},
      currency: 'GBP',
      estimatedCostMin: 0,
      estimatedCostMax: 40,
      budgetLevel: 1,
      imageAsset: 'assets/places/british_museum_london.jpg',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=British%20Museum%20London',
      officialWebsiteUrl: 'https://www.britishmuseum.org/',
      menuUrl: '',
      hours: 'Check the official museum visitor information before visiting',
      description:
          'A major museum in London with extensive history, art, and cultural collections, making it a low-cost culture date.',
      verifiedSourceUrl:
          'https://www.visitlondon.com/things-to-do/sightseeing/london-attraction/museum',
    ),
    CuratedPlace(
      id: 'sky-garden-london',
      name: 'Sky Garden',
      country: 'United Kingdom',
      city: 'London',
      address: '1 Sky Garden Walk, London EC3M 8AF, United Kingdom',
      categories: {'Viewpoint', 'Indoor', 'Attraction'},
      tags: {'Chill', 'Walk', 'Romantic', 'Culture'},
      foodTypes: {'Cafe', 'Food'},
      currency: 'GBP',
      estimatedCostMin: 0,
      estimatedCostMax: 50,
      budgetLevel: 2,
      imageAsset: 'assets/places/sky_garden_london.jpg',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Sky%20Garden%20London',
      officialWebsiteUrl: 'https://skygarden.london/',
      menuUrl: '',
      hours:
          'Reservation and opening information should be checked before visiting',
      description:
          'A free city-view experience in London that can be paired with a cafe or meal nearby.',
      verifiedSourceUrl:
          'https://www.visitlondon.com/things-to-do/top-london-date-ideas/cheap-date-ideas-london',
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
    CuratedPlace(
      id: 'tokyo-skytree',
      name: 'Tokyo Skytree',
      country: 'Japan',
      city: 'Tokyo',
      address: '1 Chome-1-2 Oshiage, Sumida City, Tokyo, Japan',
      categories: {'Viewpoint', 'Attraction', 'Indoor'},
      tags: {'Adventurous', 'Photography', 'Chill', 'Walk', 'Culture'},
      foodTypes: {'Cafe', 'Food', 'Dessert'},
      currency: 'JPY',
      estimatedCostMin: 3000,
      estimatedCostMax: 9000,
      budgetLevel: 3,
      imageAsset: '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Tokyo%20Skytree',
      officialWebsiteUrl: 'https://www.tokyo-skytree.jp/en/',
      menuUrl: '',
      hours: 'Opening hours vary; check official ticket information',
      description:
          'A Tokyo landmark with observation decks, shopping, dining, and city views.',
      verifiedSourceUrl: 'https://www.tokyo-skytree.jp/en/',
    ),
    CuratedPlace(
      id: 'meiji-jingu-tokyo',
      name: 'Meiji Jingu',
      country: 'Japan',
      city: 'Tokyo',
      address: '1-1 Yoyogikamizonocho, Shibuya City, Tokyo, Japan',
      categories: {'Shrine', 'Culture', 'Outdoor'},
      tags: {'Culture', 'Walk', 'Chill', 'Photography'},
      foodTypes: {'Food', 'Cafe'},
      currency: 'JPY',
      estimatedCostMin: 0,
      estimatedCostMax: 3000,
      budgetLevel: 1,
      imageAsset: '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Meiji%20Jingu%20Tokyo',
      officialWebsiteUrl: 'https://www.meijijingu.or.jp/en/',
      menuUrl: '',
      hours: 'Open daily; shrine opening and closing times vary by season',
      description:
          'A large Shinto shrine surrounded by forest in central Tokyo, suited to a quiet walking date.',
      verifiedSourceUrl: 'https://www.meijijingu.or.jp/en/',
    ),
    CuratedPlace(
      id: 'chatuchak-market-bangkok',
      name: 'Chatuchak Weekend Market',
      country: 'Thailand',
      city: 'Bangkok',
      address: 'Kamphaeng Phet 2 Road, Chatuchak, Bangkok, Thailand',
      categories: {'Market', 'Shopping', 'Outdoor'},
      tags: {'Shopping', 'Food', 'Walk', 'Adventurous', 'Photography'},
      foodTypes: {'Food', 'Dessert', 'Cafe'},
      currency: 'THB',
      estimatedCostMin: 400,
      estimatedCostMax: 1800,
      budgetLevel: 1,
      imageAsset: '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Chatuchak%20Weekend%20Market%20Bangkok',
      officialWebsiteUrl: 'https://www.chatuchakmarket.org/',
      menuUrl: '',
      hours:
          'Weekend market hours vary by section; check current visitor information',
      description:
          'A huge Bangkok market with food, shopping, crafts, and plenty of walking.',
      verifiedSourceUrl: 'https://www.chatuchakmarket.org/',
    ),
    CuratedPlace(
      id: 'louvre-paris',
      name: 'Louvre Museum',
      country: 'France',
      city: 'Paris',
      address: 'Rue de Rivoli, 75001 Paris, France',
      categories: {'Museum', 'Art', 'Culture', 'Indoor'},
      tags: {'Museum', 'Art', 'Culture', 'Walk', 'Photography'},
      foodTypes: {'Cafe', 'Food', 'Dessert'},
      currency: 'EUR',
      estimatedCostMin: 0,
      estimatedCostMax: 50,
      budgetLevel: 2,
      imageAsset: '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Louvre%20Museum%20Paris',
      officialWebsiteUrl: 'https://www.louvre.fr/en',
      menuUrl: '',
      hours: 'Opening days and hours vary; check official visitor information',
      description:
          'A world-famous museum in central Paris for an art and culture date.',
      verifiedSourceUrl: 'https://www.louvre.fr/en',
    ),
    CuratedPlace(
      id: 'colosseum-rome',
      name: 'Colosseum',
      country: 'Italy',
      city: 'Rome',
      address: 'Piazza del Colosseo, 1, 00184 Rome, Italy',
      categories: {'Historic Site', 'Culture', 'Outdoor'},
      tags: {'Culture', 'Walk', 'Photography', 'Adventurous'},
      foodTypes: {'Food', 'Cafe', 'Dessert'},
      currency: 'EUR',
      estimatedCostMin: 20,
      estimatedCostMax: 70,
      budgetLevel: 2,
      imageAsset: '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Colosseum%20Rome',
      officialWebsiteUrl: 'https://colosseo.it/en/',
      menuUrl: '',
      hours: 'Opening times vary by season; check official visitor information',
      description:
          'An iconic ancient Roman amphitheatre for a history and walking date.',
      verifiedSourceUrl: 'https://colosseo.it/en/',
    ),
    CuratedPlace(
      id: 'central-park-nyc',
      name: 'Central Park',
      country: 'United States',
      city: 'New York City',
      address: 'New York, NY, United States',
      categories: {'Park', 'Outdoor', 'Walk'},
      tags: {'Walk', 'Picnic', 'Chill', 'Photography', 'Outdoor'},
      foodTypes: {'Food', 'Cafe', 'Dessert'},
      currency: 'USD',
      estimatedCostMin: 0,
      estimatedCostMax: 60,
      budgetLevel: 1,
      imageAsset: '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=Central%20Park%20New%20York',
      officialWebsiteUrl: 'https://www.centralparknyc.org/',
      menuUrl: '',
      hours: 'Open daily, 6:00 AM–1:00 AM',
      description:
          'A large urban park for walking, picnics, scenery, and a flexible low-cost date.',
      verifiedSourceUrl: 'https://www.centralparknyc.org/',
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
