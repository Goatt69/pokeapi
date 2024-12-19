import 'package:pokeapi/generated/json/base/json_field.dart';
import 'package:pokeapi/generated/json/pokecard_entity.g.dart';
import 'dart:convert';
export 'package:pokeapi/generated/json/pokecard_entity.g.dart';

@JsonSerializable()
class PokecardEntity {
	String? id;
	String? set;
	String? series;
	String? generation;
	@JSONField(name: "release_date")
	String? releaseDate;
	String? name;
	@JSONField(name: "set_num")
	String? setNum;
	String? types;
	String? supertype;
	int? hp;
	String? evolvesfrom;
	dynamic evolvesto;
	String? rarity;
	String? flavortext;
	@JSONField(name: "image_url")
	String? imageUrl;

	PokecardEntity();

	factory PokecardEntity.fromJson(Map<String, dynamic> json) => $PokecardEntityFromJson(json);

	Map<String, dynamic> toJson() => $PokecardEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}