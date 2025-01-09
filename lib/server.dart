import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:postgres/postgres.dart';
import 'package:mime/mime.dart';
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';

void main() async {
  final connection = await Connection.open(Endpoint(
      host: "effortlessly-seasoned-zebu.data-1.apse1.tembo.io",
      database: 'Doan',
      username: "Goatt",
      password: "123"));

  final router = Router();
  // Route to serve images
  router.get('/cards/<id>/<filename>', (Request request, String id, String filename) async {
    // First verify if this card exists and has this set_num
    final cardResult = await connection.execute(
      Sql.named('SELECT set_num FROM pokemon_cards WHERE id = @id'),
      parameters: {'id': id}
    );
    
    if (cardResult.isEmpty) {
      return Response.notFound('Card not found');
    }
    
    final correctSetNum = cardResult[0][0] as String;
    final requestedSetNum = filename.split('.')[0]; // Get "1" from "1.jpg"
    
    if (correctSetNum != requestedSetNum) {
      return Response.notFound('Image does not belong to this card');
    }

    final setName = id.split('-')[0]; // Extract 'base1' from 'base1-1'
    final file = File('./uploads/$setName/$filename');
    if (!await file.exists()) {
      return Response.notFound('Image not found');
    }

    final bytes = await file.readAsBytes();
    return Response.ok(bytes, headers: {
      'Content-Type': 'image/jpeg',
      'Content-Length': bytes.length.toString(),
    });
  });  // Upload image locally and store reference
  router.post('/upload', (Request request) async {
    try {
      final cardId = request.url.queryParameters['id'];
      if (cardId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Card ID is required'}));
      }

      // Verify if card exists in database
      final cardExists = await connection.execute(
        Sql.named('SELECT set_num FROM pokemon_cards WHERE id = @id'),
        parameters: {'id': cardId}
      );
      
      if (cardExists.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Card ID not found'}));
      }

      final setNum = cardExists[0][0] as String;
      final setName = cardId.split('-')[0]; // Extract 'base1' from 'base1-1'
      
      final contentType = request.headers['content-type'];
      if (contentType == null || !contentType.contains('multipart/form-data')) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid Content-Type'}));
      }

      // Create base uploads directory
      final baseDir = Directory('./uploads');
      if (!await baseDir.exists()) {
        await baseDir.create();
      }

      // Create set-specific directory
      final setDir = Directory('./uploads/$setName');
      if (!await setDir.exists()) {
        await setDir.create();
      }

      final boundary = contentType.split('boundary=').last;
      final transformer = MimeMultipartTransformer(boundary);
      final parts = await transformer.bind(request.read()).toList();

      if (parts.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'No file provided'}));
      }

      for (final part in parts) {
        final contentDisposition = part.headers['content-disposition'];
        if (contentDisposition == null) continue;

        final originalFilename = RegExp(r'filename="([^"]*)"')
            .firstMatch(contentDisposition)?.group(1);
        if (originalFilename == null) continue;

        // Use set_num for the filename
        final newFilename = '$setNum.jpg';
        final file = File('./uploads/$setName/$newFilename');
        
        await file.writeAsBytes(
          await part.toList().then((list) => list.expand((e) => e).toList())
        );

        return Response.ok(
          jsonEncode({
            'message': 'File uploaded successfully',
            'filename': newFilename,
            'path': '/uploads/$setName/$newFilename'
          }),
          headers: {'Content-Type': 'application/json'}
        );
      }

      return Response.badRequest(body: jsonEncode({'error': 'No valid file found in request'}));
    } catch (e) {
      print('Upload error: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Error processing upload: $e'}),
        headers: {'Content-Type': 'application/json'}
      );
    }
  });
  // GET all pokemon_cards
  router.get('/cards', (Request request) async {
    try {
      final result = await connection.execute('SELECT * FROM pokemon_cards');
      if (result.isEmpty) {
        return Response.ok(
          jsonEncode({'cards': []}),
          headers: {'Content-Type': 'application/json'}
        );
      }
      
      final jsonData = result.map((row) {
        final map = row.toColumnMap();
        map.updateAll((key, value) {
          if (value is DateTime) {
            return value.toString().split(' ')[0]; // This will return YYYY-MM-DD format
          }
          return value;
        });
        return map;
      }).toList();

      return Response.ok(
        jsonEncode({'cards': jsonData}),
        headers: {'Content-Type': 'application/json'}
      );
    } catch (e) {
      print('Database error: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Database error occurred'}),
        headers: {'Content-Type': 'application/json'}
      );
    }
  });

  // GET a card by ID
  router.get('/cards/<id>', (Request request, String id) async {
    final result = await connection.execute(
        Sql.named('SELECT * FROM pokemon_cards WHERE id = @id'),
        parameters: {'id': id}
    );
    if (result.isEmpty) {
      return Response.notFound(jsonEncode({'error': 'Card not found'}),
          headers: {'Content-Type': 'application/json'});
    }
    final jsonData = result.map((row) {
      final map = row.toColumnMap();
      map.updateAll((key, value) {
        if (value is DateTime) {
          return value.toString().split(' ')[0]; // This will return YYYY-MM-DD format
        }
        return value;
      });
      // Add image URL using set_num
      map['image_url'] = 'https://localhost:8000/cards/${map['id']}/${map['set_num']}.jpg';
      return map;
    }).toList();

    return Response.ok(jsonEncode({'cards': jsonData}), headers: {'Content-Type': 'application/json'});
    
  });
  // POST: Insert a new card
  router.post('/cards', (Request request) async {
    try {
      final body = await request.readAsString();
      final card = jsonDecode(body);
      
      await connection.execute(
        Sql.named('''
          INSERT INTO pokemon_cards (
            id, set, series, generation, release_date, name, 
            set_num, types, supertype, hp, evolvesfrom, 
            evolvesto, rarity, flavortext
          ) VALUES (
            @id, @set, @series, @generation, @release_date, @name,
            @set_num, @types, @supertype, @hp, @evolvesfrom,
            @evolvesto, @rarity, @flavortext
          )
        '''),
        parameters: {
          'id': card['id'],
          'set': card['set'],
          'series': card['series'],
          'generation': card['generation'],
          'release_date': card['release_date'],
          'name': card['name'],
          'set_num': card['set_num'],
          'types': card['types'],
          'supertype': card['supertype'],
          'hp': card['hp'],
          'evolvesfrom': card['evolvesfrom'],
          'evolvesto': card['evolvesto'],
          'rarity': card['rarity'],
          'flavortext': card['flavortext']
        }
      );

      return Response.ok(
        jsonEncode({'message': 'Card added successfully'}),
        headers: {'Content-Type': 'application/json'}
      );
    } catch (e) {
      print('Error adding card: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to add card: $e'}),
        headers: {'Content-Type': 'application/json'}
      );
    }
  });  
  // PUT: Update a card
  router.put('/cards/<id>', (Request request, String id) async {
    try {
      final body = await request.readAsString();
      final card = jsonDecode(body);
    
      await connection.execute(
        Sql.named('''
          UPDATE pokemon_cards SET 
            set = @set,
            series = @series,
            generation = @generation,
            release_date = @release_date,
            name = @name,
            set_num = @set_num,
            types = @types,
            supertype = @supertype,
            hp = @hp,
            evolvesfrom = @evolvesfrom,
            evolvesto = @evolvesto,
            rarity = @rarity,
            flavortext = @flavortext
          WHERE id = @id
        '''),
        parameters: {
          'id': id,
          'set': card['set'],
          'series': card['series'],
          'generation': card['generation'],
          'release_date': card['release_date'],
          'name': card['name'],
          'set_num': card['set_num'],
          'types': card['types'],
          'supertype': card['supertype'],
          'hp': card['hp'],
          'evolvesfrom': card['evolvesfrom'],
          'evolvesto': card['evolvesto'],
          'rarity': card['rarity'],
          'flavortext': card['flavortext']
        }
      );

      return Response.ok(
        jsonEncode({'message': 'Card updated successfully'}),
        headers: {'Content-Type': 'application/json'}
      );
    } catch (e) {
      print('Error updating card: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update card: $e'}),
        headers: {'Content-Type': 'application/json'}
      );
    }
  });
  // DELETE: Delete a card
  router.delete('/cards/<id>', (Request request, String id) async {
    final result = await connection.execute(
        Sql.named('SELECT * FROM pokemon_cards WHERE id = @id'),
        parameters: {'id': id}
    );
    return Response.ok(jsonEncode({'message': 'Card deleted successfully'}),
        headers: {'Content-Type': 'application/json'});
  });


  router.get('/pokemon/names', (Request request) async {
    try {
      // Query to fetch all Pokémon names and ids
      final result = await connection.execute(
          Sql('SELECT id, name FROM pokemon_cards'));

      if (result.isEmpty) {
        return Response.ok(
            jsonEncode({'data': []}),
            headers: {'Content-Type': 'application/json'});
      }

      // Map query result to JSON
      final data = result.map((row) {
        final map = row.toColumnMap();
        return {
          'id': map['id'] as String, // Xử lý id là kiểu String
          'name': map['name'] as String, // Xử lý name là kiểu String
        };
      }).toList();

      return Response.ok(
          jsonEncode({'data': data}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      print('Error fetching Pokémon data: $e');
      return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to fetch Pokémon data'}),
          headers: {'Content-Type': 'application/json'});
    }
  });
  
  // Create separate handlers
  final apiHandler = Pipeline()
      .addMiddleware(corsHeaders(
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token',
      'Access-Control-Allow-Credentials': 'true',
      'Access-Control-Max-Age': '86400', // 24 hours
    },
  ))
      .addHandler(router);
  final swaggerHandler = SwaggerUI(
    'pokecard.yaml',
    title: 'Pokemon Cards API',
  );

  final handler = Pipeline()
      .addMiddleware(corsHeaders(headers: {
    'Access-Control-Allow-Origin': '*', // Cho phép tất cả các domain
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Credentials': 'true',
    'Access-Control-Expose-Headers': 'Content-Length, Content-Type',
  }))
      .addHandler((request) {
    // Kiểm tra các route API
    if (request.url.path.startsWith('cards') ||
        request.url.path.startsWith('upload') ||
        request.url.path.startsWith('pokemon/names')) {
      return apiHandler(request); // Xử lý API
    }
    // Phục vụ Swagger UI
    if (request.url.path == 'pokecard.yaml') {
      final file = File('pokecard.yaml'); // Đường dẫn tới file YAML
      if (file.existsSync()) {
        return Response.ok(file.readAsStringSync(), headers: {
          'Content-Type': 'application/x-yaml',
        });
      } else {
        return Response.notFound('pokecard.yaml not found');
      }
    }
    return swaggerHandler(request); // Trả về Swagger UI
  });


  final server = await io.serve(handler, '0.0.0.0', 8000);

  print('Server running on http://${server.address.host}:${server.port}');
}
