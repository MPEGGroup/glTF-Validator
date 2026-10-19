import 'package:gltf/src/base/gltf.dart';
import 'package:gltf/src/context.dart';
import 'package:gltf/src/errors.dart';
import 'package:gltf/src/ext/MPEG_accessor_timed/mpeg_accessor_timed.dart';
import 'package:test/test.dart';

Gltf _asset(Context context, Map<String, Object> extension,
        {bool baseBufferView = true}) =>
    Gltf.fromMap(<String, Object>{
      'asset': <String, Object>{'version': '2.0'},
      'extensionsUsed': <Object>['MPEG_accessor_timed'],
      'buffers': <Object>[
        for (var i = 0; i < 2; i++)
          <String, Object>{
            'byteLength': 8,
            'uri': 'data:application/octet-stream;base64,AAAAAAAAAAA=',
          }
      ],
      'bufferViews': <Object>[
        <String, Object>{'buffer': 0, 'byteLength': 4},
        <String, Object>{'buffer': 0, 'byteOffset': 4, 'byteLength': 4},
        <String, Object>{'buffer': 1, 'byteLength': 4},
      ],
      'accessors': <Object>[
        <String, Object>{
          if (baseBufferView) 'bufferView': 0,
          'componentType': 5126,
          'count': 1,
          'type': 'SCALAR',
          'extensions': <String, Object>{'MPEG_accessor_timed': extension},
        }
      ],
    }, context);

Context _context() =>
    Context()..registerExtensions([mpegTimedAccessorExtension]);

void main() {
  group('MPEG_accessor_timed parsing', () {
    test('defaults immutable and suggested update rate', () {
      final context = Context();
      final extension = MPEGAccessorTimed.fromMap(<String, Object>{}, context);
      expect(extension.m_immutable, isTrue);
      expect(extension.m_updateRate, 25.0);
      expect(context.issues, isEmpty);
    });

    test('reads explicit properties', () {
      final context = Context();
      final extension = MPEGAccessorTimed.fromMap(<String, Object>{
        'immutable': false,
        'bufferView': 0,
        'suggestedUpdateRate': 60,
      }, context);
      expect(extension.m_immutable, isFalse);
      expect(extension.m_updateRate, 60.0);
      expect(context.issues, isEmpty);
    });

    for (final entry in <String, Object>{
      'immutable': 'true',
      'suggestedUpdateRate': '25',
      'bufferView': -1,
    }.entries) {
      test('rejects invalid ${entry.key}', () {
        final context = Context();
        MPEGAccessorTimed.fromMap(
            <String, Object>{entry.key: entry.value}, context);
        expect(context.errors, isNotEmpty);
      });
    }
  });

  group('MPEG_accessor_timed linking', () {
    test('resolves view in the same buffer and marks it used', () {
      final context = _context();
      final gltf = _asset(context, <String, Object>{'bufferView': 1});
      final extension = gltf.accessors[0].extensions['MPEG_accessor_timed']
          as MPEGAccessorTimed;
      expect(extension.bufferView, same(gltf.bufferViews[1]));
      expect(gltf.bufferViews[1].isUsed, isTrue);
      expect(context.errors, isEmpty);
    });

    test('allows the base accessor view when extension view is omitted', () {
      final context = _context();
      _asset(context, <String, Object>{});
      expect(context.errors, isEmpty);
    });

    test('allows an extension view without a base accessor view', () {
      final context = _context();
      _asset(context, <String, Object>{'bufferView': 1}, baseBufferView: false);
      expect(context.errors, isEmpty);
    });

    test('reports views referring to different buffers', () {
      final context = _context();
      _asset(context, <String, Object>{'bufferView': 2});
      expect(context.errors.map((i) => i.type),
          contains(LinkError.mpegAccessorTimedBufferReferenceMissmatch));
    });

    test('reports missing views on both accessor and extension', () {
      final context = _context();
      _asset(context, <String, Object>{}, baseBufferView: false);
      expect(context.errors.map((i) => i.type),
          contains(LinkError.mpegAccessorTimedMissingBufferView));
    });

    test('reports an out-of-range extension bufferView at its JSON path', () {
      final context = _context();
      _asset(context, <String, Object>{'bufferView': 999});
      final issue = context.errors
          .singleWhere((i) => i.type == LinkError.unresolvedReference);
      expect(issue.toMap()['pointer'],
          '/accessors/0/extensions/MPEG_accessor_timed/bufferView');
    });
  });
}
