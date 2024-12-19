import 'package:pokeapi/generated/json/base/json_convert_content.dart';
import 'package:pokeapi/pokecard_entity.dart';

PokecardEntity $PokecardEntityFromJson(Map<String, dynamic> json) {
  final PokecardEntity pokecardEntity = PokecardEntity();
  final String? id = jsonConvert.convert<String>(json['id']);
  if (id != null) {
    pokecardEntity.id = id;
  }
  final String? set = jsonConvert.convert<String>(json['set']);
  if (set != null) {
    pokecardEntity.set = set;
  }
  final String? series = jsonConvert.convert<String>(json['series']);
  if (series != null) {
    pokecardEntity.series = series;
  }
  final String? generation = jsonConvert.convert<String>(json['generation']);
  if (generation != null) {
    pokecardEntity.generation = generation;
  }
  final String? releaseDate = jsonConvert.convert<String>(json['release_date']);
  if (releaseDate != null) {
    pokecardEntity.releaseDate = releaseDate;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    pokecardEntity.name = name;
  }
  final String? setNum = jsonConvert.convert<String>(json['set_num']);
  if (setNum != null) {
    pokecardEntity.setNum = setNum;
  }
  final String? types = jsonConvert.convert<String>(json['types']);
  if (types != null) {
    pokecardEntity.types = types;
  }
  final String? supertype = jsonConvert.convert<String>(json['supertype']);
  if (supertype != null) {
    pokecardEntity.supertype = supertype;
  }
  final int? hp = jsonConvert.convert<int>(json['hp']);
  if (hp != null) {
    pokecardEntity.hp = hp;
  }
  final String? evolvesfrom = jsonConvert.convert<String>(json['evolvesfrom']);
  if (evolvesfrom != null) {
    pokecardEntity.evolvesfrom = evolvesfrom;
  }
  final dynamic evolvesto = json['evolvesto'];
  if (evolvesto != null) {
    pokecardEntity.evolvesto = evolvesto;
  }
  final String? rarity = jsonConvert.convert<String>(json['rarity']);
  if (rarity != null) {
    pokecardEntity.rarity = rarity;
  }
  final String? flavortext = jsonConvert.convert<String>(json['flavortext']);
  if (flavortext != null) {
    pokecardEntity.flavortext = flavortext;
  }
  final String? imageUrl = jsonConvert.convert<String>(json['image_url']);
  if (imageUrl != null) {
    pokecardEntity.imageUrl = imageUrl;
  }
  return pokecardEntity;
}

Map<String, dynamic> $PokecardEntityToJson(PokecardEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['set'] = entity.set;
  data['series'] = entity.series;
  data['generation'] = entity.generation;
  data['release_date'] = entity.releaseDate;
  data['name'] = entity.name;
  data['set_num'] = entity.setNum;
  data['types'] = entity.types;
  data['supertype'] = entity.supertype;
  data['hp'] = entity.hp;
  data['evolvesfrom'] = entity.evolvesfrom;
  data['evolvesto'] = entity.evolvesto;
  data['rarity'] = entity.rarity;
  data['flavortext'] = entity.flavortext;
  data['image_url'] = entity.imageUrl;
  return data;
}

extension PokecardEntityExtension on PokecardEntity {
  PokecardEntity copyWith({
    String? id,
    String? set,
    String? series,
    String? generation,
    String? releaseDate,
    String? name,
    String? setNum,
    String? types,
    String? supertype,
    int? hp,
    String? evolvesfrom,
    dynamic evolvesto,
    String? rarity,
    String? flavortext,
    String? imageUrl,
  }) {
    return PokecardEntity()
      ..id = id ?? this.id
      ..set = set ?? this.set
      ..series = series ?? this.series
      ..generation = generation ?? this.generation
      ..releaseDate = releaseDate ?? this.releaseDate
      ..name = name ?? this.name
      ..setNum = setNum ?? this.setNum
      ..types = types ?? this.types
      ..supertype = supertype ?? this.supertype
      ..hp = hp ?? this.hp
      ..evolvesfrom = evolvesfrom ?? this.evolvesfrom
      ..evolvesto = evolvesto ?? this.evolvesto
      ..rarity = rarity ?? this.rarity
      ..flavortext = flavortext ?? this.flavortext
      ..imageUrl = imageUrl ?? this.imageUrl;
  }
}