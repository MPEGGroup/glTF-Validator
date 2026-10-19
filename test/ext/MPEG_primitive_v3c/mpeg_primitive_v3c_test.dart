import 'package:gltf/gltf.dart';
import 'package:gltf/src/ext/MPEG_primitive_v3c/mpeg_primitive_v3c.dart' as v3c;
import 'package:test/test.dart';

import '../mpeg_test_utils.dart';

void main() {
  test('V3C is registered, parses nested atlas and links its references', () {
    final context = Context();
    final gltf = Gltf.fromMap(mpegTestAsset(), context);
    final extension = gltf.meshes[0].primitives[0]
        .extensions['MPEG_primitive_V3C'] as MPEGPrimitiveV3C;
    expect(extension.atlas.accessor, 1);
    expect(extension.atlas.bufferFormat, 'baseline');
    expect(extension.geometry, [0]);
    expect(extension.attributes, isEmpty);
    expect(extension.commonAtlasData, isNull);
    expect(gltf.accessors[1].isUsed, isTrue);
    expect(gltf.textures[0].isUsed, isTrue);
    expect(context.errors, isEmpty);
    expect(context.extensionsLoaded, contains('MPEG_primitive_V3C'));
  });

  test('parses optional nested attribute and common atlas objects', () {
    final asset = mpegTestAsset();
    final properties = v3cProperties(asset);
    properties['_MPEG_V3C_OVD_MAP'] = 0;
    properties['_MPEG_V3C_AVD'] = <Object>[
      <String, Object>{
        'type': 'color',
        'maps': <Object>[0]
      },
    ];
    properties['_MPEG_V3C_CAD'] = <String, Object>{'MIV_view_parameters': 1};
    final context = Context();
    final gltf = Gltf.fromMap(asset, context);
    final extension = gltf.meshes[0].primitives[0]
        .extensions['MPEG_primitive_V3C'] as MPEGPrimitiveV3C;
    expect(extension.attributes[0].maps, [0]);
    expect(extension.commonAtlasData.miv_view_parameters, 1);
    expect(context.errors, isEmpty);
  });

  for (final name in [
    '_MPEG_V3C_CONFIG',
    '_MPEG_V3C_AD',
    '_MPEG_V3C_GVD_MAPS'
  ]) {
    test('requires $name', () {
      final asset = mpegTestAsset();
      v3cProperties(asset).remove(name);
      final context = Context();
      Gltf.fromMap(asset, context);
      expect(context.errors, isNotEmpty);
    });
  }

  for (final name in ['_MPEG_V3C_AD', '_MPEG_V3C_CAD']) {
    test('rejects malformed nested $name', () {
      final asset = mpegTestAsset();
      v3cProperties(asset)[name] = 'invalid';
      final context = Context();
      Gltf.fromMap(asset, context);
      expect(context.errors, isNotEmpty);
    });
  }

  for (final format in v3c.BUFFER_FORMAT_LIST) {
    test('accepts atlas buffer format $format', () {
      final context = Context();
      v3c.V3C_AD.fromMap(
          <String, Object>{'accessor': 0, 'buffer_format': format}, context);
      expect(context.issues, isEmpty);
    });
  }

  test('unknown atlas formats produce a report issue', () {
    final context = Context();
    v3c.V3C_AD.fromMap(
        <String, Object>{'accessor': 0, 'buffer_format': 'invalid'}, context);
    expect(context.issues, isNotEmpty);
  });

  final invalidReferences = <String, Object>{
    '_MPEG_V3C_CONFIG': 999,
    '_MPEG_V3C_AD': <String, Object>{'accessor': 999},
    '_MPEG_V3C_GVD_MAPS': <Object>[999],
    '_MPEG_V3C_OVD_MAP': 999,
    '_MPEG_V3C_AVD': <Object>[
      <String, Object>{
        'maps': <Object>[999]
      }
    ],
    '_MPEG_V3C_CAD': <String, Object>{'MIV_view_parameters': 999},
  };
  final suffixes = <String, String>{
    '_MPEG_V3C_CONFIG': '',
    '_MPEG_V3C_AD': '/accessor',
    '_MPEG_V3C_GVD_MAPS': '/0',
    '_MPEG_V3C_OVD_MAP': '',
    '_MPEG_V3C_AVD': '/0/maps/0',
    '_MPEG_V3C_CAD': '/MIV_view_parameters',
  };
  for (final entry in invalidReferences.entries) {
    test('reports unresolved ${entry.key} at its JSON path', () {
      final asset = mpegTestAsset();
      v3cProperties(asset)[entry.key] = entry.value;
      final context = Context();
      Gltf.fromMap(asset, context);
      expect(
          context.errors.map((i) => i.toMap()['pointer']),
          contains(
              '/meshes/0/primitives/0/extensions/MPEG_primitive_V3C/${entry.key}${suffixes[entry.key]}'));
    });
  }
}
