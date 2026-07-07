import 'package:flutter/foundation.dart';

@immutable
class Perso {
  const Perso({
    required this.id,
    required this.name,
    required this.image,
    required this.race,
    required this.affiliation,
    required this.ki,
    required this.maxKi,
    required this.gender,
    required this.description,
    this.originPlanet,
    this.transformations = const [],
  });

  final int id;
  final String name;
  final String image;
  final String race;
  final String affiliation;
  final String ki;
  final String maxKi;
  final String gender;
  final String description;
  final OriginPlanet? originPlanet;
  final List<Transformation> transformations;

  factory Perso.fromJson(Map<String, dynamic> json) {
    return Perso(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      race: json['race'] as String? ?? 'Unknown',
      affiliation: json['affiliation'] as String? ?? 'Unknown',
      ki: json['ki'] as String? ?? '0',
      maxKi: json['maxKi'] as String? ?? '0',
      gender: json['gender'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      originPlanet: json['originPlanet'] != null
          ? OriginPlanet.fromJson(json['originPlanet'] as Map<String, dynamic>)
          : null,
      transformations: json['transformations'] != null
          ? (json['transformations'] as List)
              .map((t) => Transformation.fromJson(t as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'race': race,
      'affiliation': affiliation,
      'ki': ki,
      'maxKi': maxKi,
      'gender': gender,
      'description': description,
      'originPlanet': originPlanet?.toJson(),
      'transformations': transformations.map((t) => t.toJson()).toList(),
    };
  }
}

@immutable
class OriginPlanet {
  const OriginPlanet({
    required this.id,
    required this.name,
    required this.isDestroyed,
    required this.description,
    required this.image,
  });

  final int id;
  final String name;
  final bool isDestroyed;
  final String description;
  final String image;

  factory OriginPlanet.fromJson(Map<String, dynamic> json) {
    return OriginPlanet(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      isDestroyed: json['isDestroyed'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isDestroyed': isDestroyed,
      'description': description,
      'image': image,
    };
  }
}

@immutable
class Transformation {
  const Transformation({
    required this.id,
    required this.name,
    required this.image,
    required this.ki,
  });

  final int id;
  final String name;
  final String image;
  final String ki;

  factory Transformation.fromJson(Map<String, dynamic> json) {
    return Transformation(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      ki: json['ki'] as String? ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'ki': ki,
    };
  }
}