enum BucketListStatus { pending, done }

class UserModel {
  final String id;
  final String email;
  final String name;
  final String passwordHash;
  final String? coupleId;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.passwordHash,
    required this.coupleId,
    required this.createdAt,
  });

  UserModel copyWith({String? coupleId, String? name}) => UserModel(
    id: id,
    email: email,
    name: name ?? this.name,
    passwordHash: passwordHash,
    coupleId: coupleId ?? this.coupleId,
    createdAt: createdAt,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'name': name,
    'passwordHash': passwordHash,
    'coupleId': coupleId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
    id: m['id'] as String,
    email: m['email'] as String? ?? '',
    name: m['name'] as String? ?? '',
    passwordHash: m['passwordHash'] as String? ?? '',
    coupleId: m['coupleId'] as String?,
    createdAt:
        DateTime.tryParse(m['createdAt']?.toString() ?? '') ?? DateTime.now(),
  );
}

class CoupleModel {
  final String id;
  final String code;
  final List<String> memberIds;
  final Map<String, String> memberNames;
  final Set<String> foods;
  final Set<String> activities;
  final Set<String> locations;
  final double budget;
  final DateTime updatedAt;

  const CoupleModel({
    required this.id,
    required this.code,
    required this.memberIds,
    required this.memberNames,
    required this.foods,
    required this.activities,
    required this.locations,
    required this.budget,
    required this.updatedAt,
  });

  List<String> get names =>
      memberIds.map((id) => memberNames[id] ?? 'Partner').toList();

  CoupleModel copyWith({
    List<String>? memberIds,
    Map<String, String>? memberNames,
    Set<String>? foods,
    Set<String>? activities,
    Set<String>? locations,
    double? budget,
  }) => CoupleModel(
    id: id,
    code: code,
    memberIds: memberIds ?? this.memberIds,
    memberNames: memberNames ?? this.memberNames,
    foods: foods ?? this.foods,
    activities: activities ?? this.activities,
    locations: locations ?? this.locations,
    budget: budget ?? this.budget,
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'code': code,
    'memberIds': memberIds,
    'memberNames': memberNames,
    'foods': foods.toList(),
    'activities': activities.toList(),
    'locations': locations.toList(),
    'budget': budget,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory CoupleModel.fromMap(Map<String, dynamic> m) {
    final rawNames = Map<String, dynamic>.from(
      m['memberNames'] as Map? ?? const {},
    );
    return CoupleModel(
      id: m['id'] as String,
      code: m['code'] as String,
      memberIds: List<String>.from(m['memberIds'] as List? ?? const []),
      memberNames: rawNames.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      foods: Set<String>.from(m['foods'] as List? ?? const []),
      activities: Set<String>.from(m['activities'] as List? ?? const []),
      locations: Set<String>.from(m['locations'] as List? ?? const []),
      budget: (m['budget'] as num?)?.toDouble() ?? 0,
      updatedAt:
          DateTime.tryParse(m['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class BucketListItem {
  final String id;
  final String name;
  final String category;
  final String price;
  final String subtitle;
  final String addedBy;
  final DateTime createdAt;
  final BucketListStatus status;
  final double? rating;
  final String? note;
  final DateTime? completedAt;
  final String imageUrl;

  const BucketListItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.subtitle,
    required this.addedBy,
    required this.createdAt,
    required this.status,
    this.rating,
    this.note,
    this.completedAt,
    this.imageUrl = '',
  });

  BucketListItem copyWith({
    BucketListStatus? status,
    double? rating,
    String? note,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) => BucketListItem(
    id: id,
    name: name,
    category: category,
    price: price,
    subtitle: subtitle,
    addedBy: addedBy,
    createdAt: createdAt,
    status: status ?? this.status,
    rating: rating ?? this.rating,
    note: note ?? this.note,
    completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    imageUrl: imageUrl,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'price': price,
    'subtitle': subtitle,
    'addedBy': addedBy,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'rating': rating,
    'note': note,
    'completedAt': completedAt?.toIso8601String(),
    'imageUrl': imageUrl,
  };

  factory BucketListItem.fromMap(Map<String, dynamic> m) => BucketListItem(
    id: m['id'] as String,
    name: m['name'] as String? ?? 'Untitled date',
    category: m['category'] as String? ?? 'Other',
    price: m['price'] as String? ?? '',
    subtitle: m['subtitle'] as String? ?? '',
    addedBy: m['addedBy'] as String? ?? '',
    createdAt:
        DateTime.tryParse(m['createdAt']?.toString() ?? '') ?? DateTime.now(),
    status: BucketListStatus.values.firstWhere(
      (s) => s.name == m['status'],
      orElse: () => BucketListStatus.pending,
    ),
    rating: (m['rating'] as num?)?.toDouble(),
    note: m['note'] as String?,
    completedAt: m['completedAt'] == null
        ? null
        : DateTime.tryParse(m['completedAt'].toString()),
    imageUrl: m['imageUrl'] as String? ?? '',
  );
}

class DateSuggestion {
  final String id;
  final String title;
  final String subtitle;
  final String price;
  final String category;
  final String matchTag;
  final String location;
  final String imageUrl;

  const DateSuggestion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.category,
    required this.matchTag,
    required this.location,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'price': price,
    'category': category,
    'matchTag': matchTag,
    'location': location,
    'imageUrl': imageUrl,
  };
}
