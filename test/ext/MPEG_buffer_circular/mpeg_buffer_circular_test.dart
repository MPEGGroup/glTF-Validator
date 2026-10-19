import 'package:gltf/src/base/gltf.dart';
import 'package:gltf/src/context.dart';
import 'package:gltf/src/errors.dart';
import 'package:gltf/src/ext/MPEG_buffer_circular/mpeg_buffer_circular.dart';
import 'package:gltf/src/ext/MPEG_media/mpeg_media.dart';
import 'package:test/test.dart';

// Register explicitly so these tests do not depend on CLI defaults.
Context _context() => Context()
  ..registerExtensions([mpegMediaExtension, mpegBufferCircularExtension]);

Gltf _asset(Context context, int media, {bool includeMedia = true}) =>
    Gltf.fromMap(<String, Object>{
      'asset': <String, Object>{'version': '2.0'},
      'extensionsUsed': <Object>[
        'MPEG_buffer_circular',
        if (includeMedia) 'MPEG_media',
      ],
      if (includeMedia)
        'extensions': <String, Object>{
          'MPEG_media': <String, Object>{
            'media': <Object>[
              <String, Object>{
                'alternatives': <Object>[
                  <String, Object>{
                    'uri': 'media.mp4',
                    'mimeType': 'video/mp4',
                  }
                ]
              }
            ]
          }
        },
      'buffers': <Object>[
        <String, Object>{
          'byteLength': 4,
          'uri': 'data:application/octet-stream;base64,AAAAAA==',
          'extensions': <String, Object>{
            'MPEG_buffer_circular': <String, Object>{
              'count': 2,
              'media': media,
            }
          }
        }
      ],
    }, context);

MPEGBufferCircular _extension(Gltf gltf) =>
    gltf.buffers[0].extensions['MPEG_buffer_circular'] as MPEGBufferCircular;

void main() {
  group('MPEG_buffer_circular parsing', () {
    test('reads count, media and tracks', () {
      final context = Context();
      final extension = MPEGBufferCircular.fromMap(<String, Object>{
        'count': 3,
        'media': 0,
        'tracks': <Object>[0, 2],
      }, context);
      expect(extension.count, 3);
      expect(extension.media, 0);
      expect(extension.tracks, [0, 2]);
      expect(context.issues, isEmpty);
    });

    test('allows omitted tracks', () {
      final context = Context();
      final extension = MPEGBufferCircular.fromMap(
          <String, Object>{'count': 2, 'media': 0}, context);
      expect(extension.tracks, isNull);
      expect(context.issues, isEmpty);
    });

    test('requires a media index', () {
      final context = Context();
      MPEGBufferCircular.fromMap(<String, Object>{'count': 2}, context);
      expect(context.errors.map((i) => i.type),
          contains(SchemaError.undefinedProperty));
    });

    for (final count in <Object>[0, 1, -1, 2.5, '2', null]) {
      test('rejects count $count (${count.runtimeType})', () {
        final context = Context();
        MPEGBufferCircular.fromMap(
            <String, Object>{'count': count, 'media': 0}, context);
        expect(context.errors, isNotEmpty);
      });
    }

    for (final tracks in <Object>[
      'invalid',
      <Object>[],
      <Object>[-1],
      <Object>[0, 0],
      <Object>['0']
    ]) {
      test('rejects invalid tracks $tracks', () {
        final context = Context();
        MPEGBufferCircular.fromMap(<String, Object>{
          'count': 2,
          'media': 0,
          'tracks': tracks,
        }, context);
        expect(context.errors, isNotEmpty);
      });
    }
  });

  group('MPEG_buffer_circular linking', () {
    test('explicit link resolves media and marks it used', () {
      final context = _context();
      final gltf = _asset(context, 0);
      context.path
        ..clear()
        ..addAll(['buffers', '0', 'extensions', 'MPEG_buffer_circular']);
      _extension(gltf).link(gltf, context);
      final media = gltf.extensions['MPEG_media'] as MPEGMediaObject;
      expect(media.media[0].isUsed, isTrue);
      expect(context.errors, isEmpty);
    });

    test('explicit link reports out-of-range media', () {
      final context = _context();
      final gltf = _asset(context, 999);
      _extension(gltf).link(gltf, context);
      expect(context.errors.map((i) => i.type),
          contains(LinkError.unresolvedReference));
    });

    test('explicit link reports missing MPEG_media', () {
      final context = _context();
      final gltf = _asset(context, 0, includeMedia: false);
      _extension(gltf).link(gltf, context);
      expect(context.errors.map((i) => i.type),
          contains(LinkError.unresolvedReference));
    });

    // Regression: parsing must invoke the buffer extension's link method.
    // Do not call link manually here: that would conceal the integration bug.
    test('normal asset parsing reports unresolved media', () {
      final context = _context();
      _asset(context, 999);
      expect(context.errors.map((i) => i.type),
          contains(LinkError.unresolvedReference));
    });
  });
}
